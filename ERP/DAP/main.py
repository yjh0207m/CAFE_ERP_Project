"""
main.py — RPA가 실행하는 진입점
실행 순서:
  1. 데이터 수신 (Spring REST API)
  2. 매출분개 생성
  3. 재무제표 계산 (손익 → 재무상태 → 현금흐름 → 자본변동)
  4. 수익 예측 / 재고 소진 예측
  5. 엑셀 생성 저장
  6. FastAPI 서버에 결과 POST

실행 방법:
    python main.py            → 기본: 올해 1월 1일 ~ 오늘
    python main.py 2026       → 2026년 전체
    python main.py 2026 3     → 2026년 3월만
"""

import re
import sys
import requests
from datetime import date, datetime
from pathlib import Path
from config import FASTAPI_BASE_URL, EXCEL_OUTPUT_DIR, INITIAL_CAPITAL
from processing.utils import in_period

# 데이터 수신
from data.fetcher import (
    fetch_orders, fetch_order_items,
    fetch_purchases, fetch_purchase_items,
    fetch_expenses, fetch_payrolls,
    fetch_ingredients, fetch_stock_logs,
    fetch_employees, fetch_menus, fetch_categories,
)

# 분석 처리
from processing.journal          import build_journal
from processing.income           import build_income_statement
from processing.balance          import build_balance_sheet
from processing.cashflow         import build_cash_flow
from processing.capital_changes  import build_capital_changes
from processing.forecast_revenue   import build_revenue_forecast
from processing.forecast_inventory import build_inventory_forecast
from processing.analysis           import build_financial_analysis

# 엑셀 출력
from export.excel import build_excel


def _remove_old_excel(year, month):
    """동일 분석 범위의 기존 엑셀 파일 삭제"""
    if year and month:
        pattern = re.compile(rf'재무분석_{year}년_{month}월_\d{{6}}_\d{{6}}\.xlsx')
    elif year:
        pattern = re.compile(rf'재무분석_{year}년_\d{{6}}_\d{{6}}\.xlsx')
    else:
        return

    for f in EXCEL_OUTPUT_DIR.glob('*.xlsx'):
        if pattern.match(f.name):
            f.unlink()
            print(f"  [excel] 기존 파일 삭제: {f.name}")


def _prev_period(year: int, month: int):
    """(year, month) 기준 직전 기간 반환"""
    if month is None:
        return year - 1, None
    if month == 1:
        return year - 1, 12
    return year, month - 1



def _period_has_data(prev_year, prev_month, orders, expenses, purchases, payrolls) -> bool:
    """이전 기간에 실제 거래 데이터가 있는지 확인"""
    for o in orders:
        if in_period((o.get("orderedAt") or "")[:10], prev_year, prev_month):
            return True
    for e in expenses:
        if in_period((e.get("expenseDate") or "")[:10], prev_year, prev_month):
            return True
    for pur in purchases:
        if in_period(str(pur.get("ordered_at") or "")[:10], prev_year, prev_month):
            return True
    for p in payrolls:
        if (prev_year is None or p.get("payYear") == prev_year) and \
           (prev_month is None or p.get("payMonth") == prev_month):
            return True
    return False


def _calc_prev_balance(
    year, month,
    orders, order_items, expenses, payrolls,
    purchases, purchase_items,
    ingredients, stock_logs, employees, menus, categories,
) -> dict | None:
    """
    전기(이전 기간) 재무상태표 계산.
    - 이전 기간에 데이터가 있으면: 해당 기간 필터링하여 재계산
    - 데이터가 없으면: 초기자본만 현금으로 보유한 '개업 전' 상태 반환
    year/month가 없으면 전기 없음 → None 반환
    """
    if not year:
        return None

    prev_year, prev_month = _prev_period(year, month)

    print(f"  [전기] {prev_year}년 {prev_month}월" if prev_month
          else f"  [전기] {prev_year}년 전체")

    # ── 이전 기간에 실제 데이터가 없으면 개업 전 상태 반환 ────────
    if not _period_has_data(prev_year, prev_month, orders, expenses, purchases, payrolls):
        print(f"  [전기] 데이터 없음 → 초기자본({INITIAL_CAPITAL:,}원)만 반영")
        return {
            "current": {
                "현금":    INITIAL_CAPITAL,
                "재고":    0,
                "자본합계": INITIAL_CAPITAL,
                "미착재고": 0,
                "부채합계": 0,
                "자산총액": INITIAL_CAPITAL,
            },
            "previous":        {},
            "initial_capital": INITIAL_CAPITAL,
            "net_income":      0,
        }

    # ── 이전 기간 데이터 있음 → 손익계산 후 재무상태표 산출 ────────
    # 전전기 재무상태표를 재귀로 계산하여 자본 체인을 올바르게 연결
    prev_prev_balance = _calc_prev_balance(
        prev_year, prev_month,
        orders, order_items, expenses, payrolls,
        purchases, purchase_items,
        ingredients, stock_logs, employees, menus, categories,
    )

    prev_income = build_income_statement(
        orders, order_items, expenses, payrolls,
        purchases, purchase_items,
        ingredients=ingredients,
        employees=employees,
        menus=menus,
        categories=categories,
        year=prev_year,
        month=prev_month,
    )

    prev_bal = build_balance_sheet(
        income_statement=prev_income,
        ingredients=ingredients,
        purchases_all=purchases,
        stock_logs=stock_logs,
        year=prev_year,
        month=prev_month,
        prev_balance=prev_prev_balance,
        initial_capital=INITIAL_CAPITAL,
    )
    return prev_bal


def run(year: int = None, month: int = None):
    """
    분석 전체 실행
    year/month: 특정 기간 지정 시 해당 기간만 집계 (None = 전체)
    """
    from datetime import date as _date
    _today = _date.today()

    y = year or _today.year
    m = month or None
    if m:
        label = f"{y}년 {m}월"
    elif year:
        label = f"{y}년 전체"
    else:
        label = f"{y}년 1월 1일 ~ {_today}"

    start_time = datetime.now()
    print(f"\n{'='*60}")
    print(f"[main] 분석 시작: {start_time.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"[main] 분석 기간: {label}")
    print(f"{'='*60}\n")

    # ── Step 1: 데이터 수신 ──────────────────────────────────────
    print("[Step 1] 데이터 수신 중...")
    today = date.today()

    orders         = fetch_orders()
    order_items    = fetch_order_items()
    purchases      = fetch_purchases()
    purchase_items = fetch_purchase_items()
    expenses       = fetch_expenses()
    payrolls       = fetch_payrolls()   # 전체 수신 후 income.py 내부에서 기간 필터링
    ingredients    = fetch_ingredients()
    stock_logs     = fetch_stock_logs()
    employees      = fetch_employees()    # 직책 기반 급여 분류용
    menus          = fetch_menus()        # 카테고리별 매출 분류용
    categories     = fetch_categories()   # 메뉴 카테고리 (categoryId→name 매핑용)

    print(f"  orders: {len(orders)}, order_items: {len(order_items)}")
    print(f"  purchases: {len(purchases)}, purchase_items: {len(purchase_items)}")
    print(f"  expenses: {len(expenses)}, payrolls: {len(payrolls)}")
    print(f"  ingredients: {len(ingredients)}, stock_logs: {len(stock_logs)}")
    print(f"  employees: {len(employees)}, menus: {len(menus)}, categories: {len(categories)}")

    # ── Step 2: 매출분개 생성 ────────────────────────────────────
    print("\n[Step 2] 매출분개 생성 중...")
    journal = build_journal(orders, expenses, payrolls, purchases,
                            year=year, month=month)

    # ── Step 3: 재무제표 계산 ────────────────────────────────────
    print("\n[Step 3] 재무제표 계산 중...")

    income = build_income_statement(
        orders, order_items, expenses, payrolls,
        purchases, purchase_items,
        ingredients=ingredients,
        employees=employees,
        menus=menus,
        categories=categories,
        year=year, month=month,
    )

    # ── 전기(이전 기간) 재무상태표 계산 ─────────────────────────
    prev_balance = _calc_prev_balance(
        year, month,
        orders, order_items, expenses, payrolls,
        purchases, purchase_items,
        ingredients, stock_logs, employees, menus, categories,
    )

    balance = build_balance_sheet(
        income_statement=income,
        ingredients=ingredients,
        purchases_all=purchases,
        stock_logs=stock_logs,
        year=year,
        month=month,
        prev_balance=prev_balance,
    )

    cashflow = build_cash_flow(
        orders, order_items, expenses, payrolls,
        purchases, purchase_items, year=year, month=month,
    )

    capital = build_capital_changes(
        balance_sheet=balance,
        prev_balance_sheet=None,
    )

    # ── Step 4: 예측 ────────────────────────────────────────────
    print("\n[Step 4] 예측 계산 중...")

    revenue_forecast   = build_revenue_forecast(
        orders, order_items, expenses, payrolls,
        purchases, purchase_items,
        ingredients=ingredients,
        employees=employees,
        menus=menus,
        categories=categories,
    )
    inventory_forecast = build_inventory_forecast(ingredients, stock_logs)

    # ── Step 4.5: AI 재무 분석 ───────────────────────────────────
    print("\n[Step 4.5] AI 재무 분석 중...")
    ai_analysis = build_financial_analysis(
        income   = income,
        balance  = balance,
        forecast = revenue_forecast,
        period   = label,
    )

    # ── Step 5: 엑셀 생성 ───────────────────────────────────────
    print("\n[Step 5] 엑셀 생성 중...")

    now = datetime.now()
    date_tag = now.strftime('%y%m%d_%H%M%S')   # 260327_124526
    if year and month:
        filename = f"재무분석_{year}년_{month}월_{date_tag}.xlsx"
    elif year:
        filename = f"재무분석_{year}년_{date_tag}.xlsx"
    else:
        filename = f"재무분석_{date_tag}.xlsx"

    _remove_old_excel(year, month)

    excel_path = build_excel(
        journal            = journal,
        income_statement   = income,
        balance_sheet      = balance,
        capital_changes    = capital,
        revenue_forecast   = revenue_forecast,
        inventory_forecast = inventory_forecast,
        filename           = filename,
    )

    # ── Step 6: FastAPI 업데이트 ─────────────────────────────────
    print("\n[Step 6] FastAPI 서버 업데이트 중...")

    payload = {
        "journal":            journal,
        "income_statement":   income,
        "balance_sheet":      balance,
        "cash_flow":          cashflow,
        "capital_changes":    capital,
        "revenue_forecast":   revenue_forecast,
        "inventory_forecast": inventory_forecast,
        "ai_analysis":        ai_analysis,
        "excel_path":         excel_path,
    }

    try:
        res = requests.post(
            f"{FASTAPI_BASE_URL}/internal/update",
            json=payload,
            timeout=15,
        )
        if res.status_code == 200:
            print(f"[Step 6] FastAPI 업데이트 성공")
        else:
            print(f"[Step 6] FastAPI 응답 오류: {res.status_code}")
    except Exception as e:
        print(f"[Step 6] FastAPI 연결 실패 (서버 실행 중인지 확인): {e}")

    # ── 완료 ────────────────────────────────────────────────────
    elapsed = (datetime.now() - start_time).seconds
    print(f"\n{'='*60}")
    print(f"[main] 분석 완료 - 소요시간: {elapsed}초")
    print(f"[main] 엑셀 저장: {excel_path}")
    print(f"{'='*60}\n")


if __name__ == "__main__":
    args = sys.argv[1:]
    from datetime import date as _date
    _today = _date.today()

    y = int(args[0]) if len(args) >= 1 else _today.year
    m = int(args[1]) if len(args) >= 2 else None

    run(year=y, month=m)
