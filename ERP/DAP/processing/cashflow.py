"""
cashflow.py — 현금흐름표 생성
영업활동 / 투자활동 / 재무활동 현금흐름
"""

from processing.utils import in_period, format_period, safe_int


def build_cash_flow(
    orders:         list,
    order_items:    list,
    expenses:       list,
    payrolls:       list,
    purchases:      list,
    purchase_items: list,
    year:  int = None,
    month: int = None,
) -> dict:

    # ── 영업활동 유입: 매출 수금 ──────────────────────────────────
    revenue_inflow = sum(
        safe_int(o.get("finalAmount"))
        for o in orders
        if o.get("status") == "완료"
        and in_period((o.get("orderedAt") or "")[:10], year, month)
    )

    # ── 영업활동 유출: 급여 ────────────────────────────────────────
    payroll_outflow = sum(
        safe_int(p.get("netPay"))
        for p in payrolls
        if (year  is None or p.get("payYear")  == year)
        and (month is None or p.get("payMonth") == month)
    )

    # ── 영업활동 유출: 운영비용 (expenses) ─────────────────────────
    expense_outflow = sum(
        safe_int(e.get("amount"))
        for e in expenses
        if in_period((e.get("expenseDate") or "")[:10], year, month)
        and safe_int(e.get("status"), 1) == 1
    )

    # ── 영업활동 유출: 원재료 구매 ────────────────────────────────
    purchase_outflow = sum(
        safe_int(pur.get("total_cost"))
        for pur in purchases
        if (pur.get("status") or "") in ("ordered", "received")
        and in_period(str(pur.get("ordered_at") or "")[:10], year, month)
    )

    net_operating = revenue_inflow - payroll_outflow - expense_outflow - purchase_outflow

    return {
        "period": format_period(year, month),
        "operating": {
            "inflows": {
                "매출수금": revenue_inflow,
            },
            "outflows": {
                "급여지급":    payroll_outflow,
                "운영비용":    expense_outflow,
                "원재료구매":  purchase_outflow,
            },
            "total_inflows":  revenue_inflow,
            "total_outflows": payroll_outflow + expense_outflow + purchase_outflow,
            "net":            net_operating,
        },
        "investing": {
            "inflows":  {},
            "outflows": {},
            "net":      0,
        },
        "financing": {
            "inflows":  {},
            "outflows": {},
            "net":      0,
        },
        "net_cash_flow": net_operating,
    }
