"""
capital_changes.py — 자본변동표 생성
구조 (사진 기준):
  항목      | 현금 | 재고 | 자본합계
  기초자본
  현금변동
  재고변동
  변동총액
  기말자본
"""


def build_capital_changes(
    balance_sheet:      dict,
    prev_balance_sheet: dict = None,
) -> dict:

    current  = balance_sheet.get("current", {})
    previous = balance_sheet.get("previous", {})

    # 전기 재무상태표가 별도로 전달된 경우 우선 사용
    if prev_balance_sheet and isinstance(prev_balance_sheet, dict):
        previous = prev_balance_sheet.get("current", {})

    curr_cash     = int(current.get("현금", 0))
    curr_inv      = int(current.get("재고", 0))
    curr_equity   = int(current.get("자본합계", 0))

    prev_cash     = int(previous.get("현금", 0))
    prev_inv      = int(previous.get("재고", 0))
    prev_equity   = int(previous.get("자본합계", 0))

    cash_change  = curr_cash  - prev_cash
    inv_change   = curr_inv   - prev_inv
    total_change = cash_change + inv_change

    return {
        "기초자본": {
            "현금":    prev_cash,
            "재고":    prev_inv,
            "자본합계": prev_equity,
        },
        "현금변동": cash_change,
        "재고변동": inv_change,
        "변동총액": total_change,
        "기말자본": {
            "현금":    curr_cash,
            "재고":    curr_inv,
            "자본합계": curr_equity,
        },
    }
