"""
journal.py — 매출 분개 생성
분개 유형:
  - 매출: Dr.현금 / Cr.매출
  - 급여: Dr.급여비용 / Cr.현금
  - 지출: Dr.[비용항목] / Cr.현금
  - 발주: Dr.재고자산 / Cr.미지급금
"""

from processing.utils import in_period, format_period


def build_journal(orders: list, expenses: list, payrolls: list, purchases: list,
                  year: int = None, month: int = None) -> dict:
    entries = []

    # ── 1. 매출 분개 (완료된 주문) ─────────────────────────────────
    for o in orders:
        if o.get("status") != "완료":
            continue
        ordered_at = (o.get("orderedAt") or "")[:10]
        if not in_period(ordered_at, year, month):
            continue
        amount = int(o.get("finalAmount") or 0)
        if amount <= 0:
            continue
        entries.append({
            "date":        ordered_at,
            "description": "주문 매출",
            "debit":       "현금",
            "credit":      "매출",
            "amount":      amount,
            "ref":         f"ORD-{o.get('id', '')}",
        })

    # ── 2. 급여 분개 ──────────────────────────────────────────────
    for p in payrolls:
        p_year  = p.get("payYear")
        p_month = p.get("payMonth")
        if year  is not None and p_year  != year:
            continue
        if month is not None and p_month != month:
            continue
        paid_at = (p.get("paidAt") or f"{p_year}-{p_month:02d}-01")[:10]
        net_pay = int(p.get("netPay") or 0)
        if net_pay <= 0:
            continue
        entries.append({
            "date":        paid_at,
            "description": f"급여 지급 ({p.get('employeeName', '')})",
            "debit":       "급여비용",
            "credit":      "현금",
            "amount":      net_pay,
            "ref":         f"PAY-{p.get('id', '')}",
        })

    # ── 3. 지출 분개 ──────────────────────────────────────────────
    for e in expenses:
        expense_date = (e.get("expenseDate") or "")[:10]
        if not in_period(expense_date, year, month):
            continue
        if int(e.get("status") or 1) == 0:   # 0 = 수입, 분개 제외
            continue
        amount = int(e.get("amount") or 0)
        if amount <= 0:
            continue
        exp_type = e.get("expenseType") or "운영비용"
        entries.append({
            "date":        expense_date,
            "description": f"{exp_type}: {e.get('description') or ''}".strip(": "),
            "debit":       exp_type,
            "credit":      "현금",
            "amount":      amount,
            "ref":         f"EXP-{e.get('id', '')}",
        })

    # ── 4. 발주 분개 ──────────────────────────────────────────────
    for pur in purchases:
        status = pur.get("status") or ""
        if status not in ("ordered", "received"):
            continue
        ordered_at = (str(pur.get("ordered_at") or ""))[:10]
        if not in_period(ordered_at, year, month):
            continue
        total_cost = int(pur.get("total_cost") or 0)
        if total_cost <= 0:
            continue
        entries.append({
            "date":        ordered_at,
            "description": f"원재료 발주 ({pur.get('supplier') or ''})",
            "debit":       "재고자산",
            "credit":      "미지급금",
            "amount":      total_cost,
            "ref":         f"PUR-{pur.get('id', '')}",
        })

    entries.sort(key=lambda x: x.get("date") or "")

    return {
        "period":      format_period(year, month),
        "entries":     entries,
        "total_count": len(entries),
        "total_debit": sum(e["amount"] for e in entries),
    }
