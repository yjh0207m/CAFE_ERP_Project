"""
forecast_inventory.py — 재고 소진 추이 예측
stock_logs의 'out' 로그로 일평균 소비량 계산 → 소진 예정일 예측
'adjust' 로그: net_loss = 손실합계 - 발견합계 (상쇄 가능, net_loss>0이면 유효재고 차감)
"""

from collections import defaultdict
from datetime import date, timedelta
from processing.utils import safe_float
from config import INVENTORY_WARNING_DAYS


def build_inventory_forecast(
    ingredients: list,
    stock_logs:  list,
    warning_days: int = None,
) -> list:

    if warning_days is None:
        warning_days = INVENTORY_WARNING_DAYS

    today = date.today()

    # ── ingredient_id별 out 로그 집계 ─────────────────────────────
    consumption: dict[int, list] = defaultdict(list)

    # ── ingredient_id별 adjust(loss) 집계 ─────────────────────────
    # net_loss = Σ(before>after 차이) - Σ(after>before 차이)
    # 양수: 실질 손실, 음수: 재고 증가(발견), 0: 상쇄
    adjust_loss: dict[int, float] = defaultdict(float)

    for log in stock_logs:
        change_type = (log.get("changeType") or "").lower()
        iid = log.get("ingredientId")
        if not iid:
            continue
        iid = int(iid)

        if change_type == "out":
            qty    = abs(safe_float(log.get("changeQty")))
            dt_str = (log.get("createdAt") or "")[:10]
            if not dt_str:
                continue
            try:
                dt = date.fromisoformat(dt_str)
                consumption[iid].append((dt, qty))
            except ValueError:
                pass

        elif change_type == "adjust":
            before = safe_float(log.get("beforeQty"))
            after  = safe_float(log.get("afterQty"))
            diff   = after - before   # 양수: 증가(발견), 음수: 감소(손실)
            adjust_loss[iid] -= diff  # 손실 방향(감소)이 양수가 되도록 부호 반전

    forecasts = []
    for ingr in ingredients:
        iid           = ingr.get("id")
        name          = ingr.get("name") or ""
        category      = ingr.get("category") or ""
        unit          = ingr.get("unit") or ""
        current_stock = safe_float(ingr.get("stock_qty"))
        min_stock     = safe_float(ingr.get("min_stock"))

        logs     = consumption.get(int(iid), []) if iid else []
        net_loss = round(adjust_loss.get(int(iid), 0.0), 3) if iid else 0.0

        # net_loss > 0: 누적 실질 손실만큼 유효 재고 차감
        effective_stock = max(current_stock - max(net_loss, 0.0), 0.0)

        if not logs:
            forecasts.append({
                "id":                       iid,
                "name":                     name,
                "category":                 category,
                "unit":                     unit,
                "current_stock":            round(current_stock, 3),
                "effective_stock":          round(effective_stock, 3),
                "min_stock":                round(min_stock, 3),
                "net_loss":                 net_loss,
                "avg_daily_consumption":    0.0,
                "days_until_empty":         None,
                "days_until_min_stock":     None,
                "predicted_depletion_date": None,
                "status":                   "데이터없음",
            })
            continue

        # 기간 내 총 소비량 / 기간일수 = 일평균 소비량
        dates       = [l[0] for l in logs]
        min_date    = min(dates)
        max_date    = max(dates)
        period_days = max((max_date - min_date).days, 1)
        total_consumed = sum(l[1] for l in logs)
        avg_daily = total_consumed / period_days

        if avg_daily > 0:
            days_empty     = int(effective_stock / avg_daily)
            days_to_min    = int(max(effective_stock - min_stock, 0) / avg_daily)
            depletion_date = (today + timedelta(days=days_empty)).isoformat()
        else:
            days_empty     = None
            days_to_min    = None
            depletion_date = None

        # 재고 상태 판정
        if effective_stock <= 0:
            status = "소진"
        elif effective_stock <= min_stock:
            status = "부족"
        elif days_empty is not None and days_empty <= warning_days:
            status = "임박"
        elif days_to_min is not None and days_to_min <= warning_days:
            status = "주의"
        else:
            status = "정상"

        forecasts.append({
            "id":                       iid,
            "name":                     name,
            "category":                 category,
            "unit":                     unit,
            "current_stock":            round(current_stock, 3),
            "effective_stock":          round(effective_stock, 3),
            "min_stock":                round(min_stock, 3),
            "net_loss":                 net_loss,
            "avg_daily_consumption":    round(avg_daily, 4),
            "days_until_empty":         days_empty,
            "days_until_min_stock":     days_to_min,
            "predicted_depletion_date": depletion_date,
            "status":                   status,
        })

    # 긴급 순서로 정렬 (소진 임박한 것 먼저)
    ORDER = {"소진": 0, "부족": 1, "임박": 2, "주의": 3, "정상": 4, "데이터없음": 5}
    forecasts.sort(key=lambda x: (
        ORDER.get(x["status"], 9),
        x["days_until_empty"] if x["days_until_empty"] is not None else 99999,
    ))

    return forecasts
