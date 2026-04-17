"""
income.py — 손익계산서 생성
구조 (사진 기준):
  급여 지출: 매니저/점장/스텝 급여
  발주 비용: 원두/유제품/시럽소스/파우더/자류/소모품/기타
  기타 지출: 재료비/인건비/임대료/공과금/소모품/마케팅/기타
  매출:      커피류/논커피류/디저트/스무디프라푸치노/티한방/에이드/베이커리/샌드위치브런치/기타
  당기순이익
"""

from collections import defaultdict
from processing.utils import in_period, format_period, safe_int, safe_float

# ── 매출 카테고리 순서 ────────────────────────────────────────────
REVENUE_CATS = [
    "커피류", "논커피류", "디저트", "스무디/프라푸치노",
    "티/한방", "에이드", "베이커리", "샌드위치/브런치", "기타",
]

# ── 발주(원재료) 카테고리 ─────────────────────────────────────────
PURCHASE_CATS = ["원두", "유제품", "시럽/소스", "파우더", "차류", "소모품", "기타"]

# ── 급여 직책 ─────────────────────────────────────────────────────
PAYROLL_POSITIONS = ["매니저", "점장", "스탭", "기타"]

# ── 기타 지출 유형 ────────────────────────────────────────────────
EXPENSE_TYPES = ["재료비", "인건비", "임대료", "공과금", "소모품", "마케팅", "기타"]


def build_income_statement(
    orders:         list,
    order_items:    list,
    expenses:       list,
    payrolls:       list,
    purchases:      list,
    purchase_items: list,
    ingredients:    list = None,
    employees:      list = None,
    menus:          list = None,
    categories:     list = None,
    year:           int  = None,
    month:          int  = None,
) -> dict:

    # ── 보조 매핑 테이블 ──────────────────────────────────────────
    # categoryId → categoryName (categories API 우선 사용)
    cat_id_name: dict[int, str] = {}
    if categories:
        for c in categories:
            cid = c.get("id")
            cname = c.get("name") or "기타"
            if cid:
                cat_id_name[int(cid)] = cname

    # menuId → categoryName
    # menus.categoryName 우선, 없으면 categoryId → cat_id_name 참조
    menu_cat: dict[int, str] = {}
    if menus:
        for m in menus:
            mid = m.get("id")
            if not mid:
                continue
            cat = m.get("categoryName")
            if not cat and cat_id_name:
                cid = m.get("categoryId") or m.get("category_id")
                cat = cat_id_name.get(int(cid), "기타") if cid else "기타"
            menu_cat[int(mid)] = cat or "기타"

    # employeeId → position
    emp_pos: dict[int, str] = {}
    if employees:
        for e in employees:
            eid = e.get("id")
            pos = e.get("position") or "스텝"
            if eid:
                emp_pos[int(eid)] = pos

    # ingredientId → category
    ingr_cat: dict[int, str] = {}
    if ingredients:
        for i in ingredients:
            iid = i.get("id")
            cat = i.get("category") or "기타"
            if iid:
                ingr_cat[int(iid)] = cat

    # ── 완료 주문 ID 집합 (기간 필터 포함) ───────────────────────
    completed_ids: set[int] = set()
    for o in orders:
        if o.get("status") != "완료":
            continue
        if not in_period((o.get("orderedAt") or "")[:10], year, month):
            continue
        oid = o.get("id")
        if oid:
            completed_ids.add(int(oid))

    # ── ① 매출 집계 ───────────────────────────────────────────────
    # order_items API는 resultType="map" → snake_case 반환 (order_id, menu_id)
    revenue: dict[str, int] = {c: 0 for c in REVENUE_CATS}
    for item in order_items:
        oid = item.get("order_id")
        if not oid or int(oid) not in completed_ids:
            continue
        mid = item.get("menu_id")
        cat = menu_cat.get(int(mid), "기타") if mid else "기타"
        if cat not in revenue:
            cat = "기타"
        revenue[cat] += safe_int(item.get("subtotal"))
    total_revenue = sum(revenue.values())

    # ── ② 급여 집계 ───────────────────────────────────────────────
    payroll_by_pos: dict[str, int] = {p: 0 for p in PAYROLL_POSITIONS}
    incentive_total = 0
    for p in payrolls:
        if year  is not None and p.get("payYear")  != year:
            continue
        if month is not None and p.get("payMonth") != month:
            continue
        eid = p.get("employeeId")
        pos = emp_pos.get(int(eid), "스탭") if (eid and emp_pos) else "스탭"  # DB ENUM: 스탭
        if pos not in payroll_by_pos:
            pos = "기타"
        pay_type = safe_int(p.get("payType"), 0)
        if pay_type == 1:   # 인센티브
            incentive_total += safe_int(p.get("basePay"))
        else:               # 일반 급여
            payroll_by_pos[pos] += safe_int(p.get("basePay"))
    total_payroll = sum(payroll_by_pos.values()) + incentive_total

    # ── ③ 발주 비용 집계 (purchase_items × ingredient category) ──
    # 기간 내 유효 발주 ID
    valid_pur_ids: set[int] = set()
    for pur in purchases:
        status = pur.get("status") or ""
        if status not in ("ordered", "received"):
            continue
        ordered_at = str(pur.get("ordered_at") or "")[:10]
        if not in_period(ordered_at, year, month):
            continue
        pid = pur.get("id")
        if pid:
            valid_pur_ids.add(int(pid))

    purchase_by_cat: dict[str, int] = {c: 0 for c in PURCHASE_CATS}
    for item in purchase_items:
        pid = item.get("purchase_id")
        if not pid or int(pid) not in valid_pur_ids:
            continue
        iid  = item.get("ingredient_id")
        cat  = ingr_cat.get(int(iid), "기타") if iid else "기타"
        if cat not in purchase_by_cat:
            cat = "기타"
        purchase_by_cat[cat] += safe_int(item.get("subtotal"))
    total_purchases = sum(purchase_by_cat.values())

    # ── ④ 기타 지출 집계 (expenses 테이블) ───────────────────────
    expense_by_type: dict[str, int] = {t: 0 for t in EXPENSE_TYPES}
    for e in expenses:
        if not in_period((e.get("expenseDate") or "")[:10], year, month):
            continue
        if safe_int(e.get("status"), 1) == 0:   # 0 = 수입
            continue
        exp_type = e.get("expenseType") or "기타"
        if exp_type not in expense_by_type:
            exp_type = "기타"
        expense_by_type[exp_type] += safe_int(e.get("amount"))
    total_other_expenses = sum(expense_by_type.values())

    # ── 합계 계산 ─────────────────────────────────────────────────
    total_expenses = total_payroll + total_purchases + total_other_expenses
    net_income     = total_revenue - total_expenses

    return {
        "period": format_period(year, month),
        "payroll": {
            **payroll_by_pos,
            "인센티브": incentive_total,
            "급여소계": total_payroll,
        },
        "purchases": {
            **purchase_by_cat,
            "발주소계": total_purchases,
        },
        "expenses": {
            **expense_by_type,
            "지출소계": total_other_expenses,   # 재료비+인건비+임대료+공과금+소모품+마케팅+기타
            "총지출":   total_expenses,          # 급여소계+발주소계+지출소계
        },
        "revenue": {
            **revenue,
            "총매출": total_revenue,
        },
        "summary": {
            "총매출":      total_revenue,
            "총지출":      total_expenses,
            "급여소계":    total_payroll,
            "발주소계":    total_purchases,
            "지출소계":    total_other_expenses,
            "당기순이익":  net_income,
        },
        "net_income": net_income,
    }
