"""
balance.py — 재무상태표 생성
구조 (사진 기준):
  항목    | 당기 | 전기
  현금
  재고
  자본합계
  미착재고
  부채합계
  자산총액

재고 / 미착재고는 분석 기간 종료일 기준으로 계산:
  - 미착재고: ordered_at <= 기간종료일 이고 status='ordered' 인 발주만 포함
  - 재고:    stock_logs를 이용해 기간종료일 이후 입출고를 역산하여 당시 재고량 추정
"""

import calendar
from collections import defaultdict
from datetime import date as _date

from processing.utils import safe_int, safe_float
from config import INITIAL_CAPITAL


def _period_end(year, month):
    """분석 기간의 마지막 날 반환 (year=None → None = 오늘까지 전체)"""
    if year is None:
        return None
    if month is None:
        return _date(year, 12, 31)
    last_day = calendar.monthrange(year, month)[1]
    return _date(year, month, last_day)


def _parse_date(s: str):
    try:
        return _date.fromisoformat(s)
    except Exception:
        return None


def build_balance_sheet(
    income_statement: dict,
    ingredients:      list,
    purchases_all:    list,
    stock_logs:       list = None,
    year:             int  = None,
    month:            int  = None,
    prev_balance:     dict = None,
    initial_capital:  int  = None,
) -> dict:

    if initial_capital is None:
        initial_capital = INITIAL_CAPITAL

    end_date = _period_end(year, month)   # 기간 종료일 (None = 전체)

    # ── 재고 자산가치 ─────────────────────────────────────────────
    # 현재 stock_qty를 기준으로, 기간 종료일 이후 발생한 입출고를 역산하여
    # 기간 종료 시점의 재고량을 추정한다.
    if end_date and stock_logs:
        # ingredientId → 역산 조정량 (양수: 추가로 있었음, 음수: 적게 있었음)
        adj: dict[int, float] = defaultdict(float)
        for log in stock_logs:
            dt = _parse_date((log.get("createdAt") or "")[:10])
            if dt is None or dt <= end_date:
                continue                       # 기간 종료일 이전 → 대상 아님
            iid = log.get("ingredientId")
            if not iid:
                continue
            iid = int(iid)
            ct = (log.get("changeType") or "").lower()
            qty = safe_float(log.get("changeQty"))
            if ct == "out":
                # 기간 후 판매 차감 → 당시엔 더 있었음
                adj[iid] += abs(qty)
            elif ct == "in":
                # 기간 후 입고 → 당시엔 적었음
                adj[iid] -= abs(qty)
            elif ct == "adjust":
                before = safe_float(log.get("beforeQty"))
                after  = safe_float(log.get("afterQty"))
                # 기간 후 수동조정을 되돌림
                adj[iid] -= (after - before)

        inventory_value = sum(
            max(safe_float(i.get("stock_qty")) + adj.get(int(i.get("id", 0)), 0.0), 0.0)
            * safe_int(i.get("unit_cost"))
            for i in (ingredients or [])
            if i.get("id")
        )
    else:
        # 전체 기간 조회이거나 stock_logs 없을 때 → 현재 재고 그대로
        inventory_value = sum(
            safe_float(i.get("stock_qty")) * safe_int(i.get("unit_cost"))
            for i in (ingredients or [])
        )
    inventory_value = round(inventory_value)

    # ── 미착재고 ──────────────────────────────────────────────────
    # status='ordered' 이면서 ordered_at 이 기간 종료일 이내인 것만 포함.
    # 기간 종료일보다 나중에 발주된 건은 해당 기간의 부채가 아님.
    in_transit = sum(
        safe_int(pur.get("total_cost"))
        for pur in (purchases_all or [])
        if (pur.get("status") or "") == "ordered"
        and (
            end_date is None
            or (
                _parse_date(str(pur.get("ordered_at") or "")[:10]) is not None
                and _parse_date(str(pur.get("ordered_at") or "")[:10]) <= end_date
            )
        )
    )

    # ── 자본합계 = 기초자본 + 당기순이익 ──────────────────────────
    net_income = safe_int(income_statement.get("net_income"))
    if prev_balance and isinstance(prev_balance, dict):
        opening_equity = safe_int(
            prev_balance.get("current", {}).get("자본합계", initial_capital)
        )
    else:
        opening_equity = initial_capital
    equity = opening_equity + net_income

    # ── 현금 = 자본합계 - 재고가치 ────────────────────────────────
    cash = equity - inventory_value

    # ── 부채합계 = 미착재고 ────────────────────────────────────────
    total_liabilities = in_transit

    # ── 자산총액 = 현금 + 재고 + 미착재고 ─────────────────────────
    total_assets = cash + inventory_value + in_transit

    current = {
        "현금":    cash,
        "재고":    inventory_value,
        "자본합계": equity,
        "미착재고": in_transit,
        "부채합계": total_liabilities,
        "자산총액": total_assets,
    }

    # ── 전기 (이전 기간 데이터) ───────────────────────────────────
    previous = {}
    if prev_balance and isinstance(prev_balance, dict):
        previous = prev_balance.get("current", {})

    return {
        "current":         current,
        "previous":        previous,
        "initial_capital": initial_capital,
        "net_income":      net_income,
    }
