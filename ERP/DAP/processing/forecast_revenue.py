"""
forecast_revenue.py — 수익 예측 (Prophet ML + Holt's Fallback)

예측 방식:
  1. Prophet (Facebook Research) — 기본 모델 (데이터 3개월 이상 시)
     - 트렌드 자동 감지, 95% 신뢰 구간(revenue_lower / revenue_upper) 제공
     - ImportError 또는 예측 실패 시 자동으로 Holt's로 전환

  2. Holt's Double Exponential Smoothing — Fallback 모델
     - α = 0.4 (레벨 평활), β = 0.3 (트렌드 평활)
     - h개월 후 예측 = l_T + h * b_T

summary.model 필드:
  "prophet" — Prophet ML 사용
  "holt"    — Holt's 통계 모델 사용
"""

import logging
from datetime import date
from processing.income import build_income_statement

# Prophet 내부 로그 억제
logging.getLogger("prophet").setLevel(logging.WARNING)
logging.getLogger("cmdstanpy").setLevel(logging.WARNING)

# ── Holt's 파라미터 ──────────────────────────────────────────────────
_ALPHA = 0.4
_BETA  = 0.3


# ── 공통 유틸 ────────────────────────────────────────────────────────
def _next_ym(year: int, month: int, delta: int) -> tuple:
    """(year, month)에서 delta개월 후 반환"""
    total = (year * 12 + month - 1) + delta
    return total // 12, total % 12 + 1


# ── Holt's Double Exponential Smoothing ─────────────────────────────
def _holt(values: list, alpha: float, beta: float) -> tuple:
    """레벨(l)과 트렌드(b) 반환"""
    if not values:
        return 0.0, 0.0
    if len(values) == 1:
        return float(values[0]), 0.0

    l = float(values[0])
    b = float(values[1]) - float(values[0])

    for v in values[1:]:
        l_prev, b_prev = l, b
        l = alpha * float(v) + (1 - alpha) * (l_prev + b_prev)
        b = beta  * (l - l_prev) + (1 - beta) * b_prev

    return l, b


def _holt_forecast(history: list, months_ahead: int) -> tuple:
    """
    Holt's Double Exponential Smoothing으로 예측.
    신뢰 구간 없음 (revenue_lower / revenue_upper = None).
    """
    window   = min(6, len(history))
    recent   = history[-window:]
    rev_vals = [h["revenue"]    for h in recent]
    exp_vals = [h["expenses"]   for h in recent]

    rev_l, rev_b = _holt(rev_vals, _ALPHA, _BETA)
    exp_l, exp_b = _holt(exp_vals, _ALPHA, _BETA)

    last_ym   = (history[-1]["year"], history[-1]["month"])
    forecasts = []
    for h in range(1, months_ahead + 1):
        fy, fm   = _next_ym(last_ym[0], last_ym[1], h)
        pred_rev = max(0.0, rev_l + h * rev_b)
        pred_exp = max(0.0, exp_l + h * exp_b)
        forecasts.append({
            "year":                 fy,
            "month":                fm,
            "label":                f"{fy}년 {fm}월",
            "predicted_revenue":    round(pred_rev),
            "predicted_expenses":   round(pred_exp),
            "predicted_net_income": round(pred_rev - pred_exp),
            "revenue_lower":        None,
            "revenue_upper":        None,
        })

    print(f"[forecast] Holt's 예측 완료 ({len(forecasts)}개월)")
    return forecasts, "holt"


# ── Prophet ML 예측 ──────────────────────────────────────────────────
def _prophet_forecast(history: list, months_ahead: int) -> tuple:
    """
    Prophet으로 매출/지출 예측.
    95% 신뢰 구간(revenue_lower, revenue_upper) 포함.
    실패 시 Holt's로 자동 전환.
    """
    try:
        import pandas as pd
        from prophet import Prophet
    except ImportError as e:
        print(f"[forecast] Prophet 미설치 → Holt's fallback ({e})")
        return _holt_forecast(history, months_ahead)

    try:
        # DataFrame 구성
        df_rev = pd.DataFrame([
            {"ds": pd.Timestamp(h["year"], h["month"], 1), "y": float(h["revenue"])}
            for h in history
        ])
        df_exp = pd.DataFrame([
            {"ds": pd.Timestamp(h["year"], h["month"], 1), "y": float(h["expenses"])}
            for h in history
        ])

        def _make_model() -> "Prophet":
            """월별 소량 데이터 최적화 설정"""
            return Prophet(
                yearly_seasonality=False,   # 1년치 미만 데이터로 연간 계절성 학습 불가
                weekly_seasonality=False,   # 월별 집계 데이터이므로 주간 패턴 없음
                daily_seasonality=False,
                changepoint_prior_scale=0.05,   # 작은 값 → 과적합 방지
                uncertainty_samples=300,         # 신뢰 구간 샘플 수
            )

        m_rev = _make_model()
        m_rev.fit(df_rev)

        m_exp = _make_model()
        m_exp.fit(df_exp)

        # 미래 날짜 생성
        last = history[-1]
        future_dates = []
        for h in range(1, months_ahead + 1):
            fy, fm = _next_ym(last["year"], last["month"], h)
            future_dates.append(pd.Timestamp(fy, fm, 1))

        future_df = pd.DataFrame({"ds": future_dates})
        fc_rev = m_rev.predict(future_df)
        fc_exp = m_exp.predict(future_df)

        forecasts = []
        for i, ts in enumerate(future_dates):
            rev       = max(0.0, fc_rev.iloc[i]["yhat"])
            rev_lower = max(0.0, fc_rev.iloc[i]["yhat_lower"])
            rev_upper = max(0.0, fc_rev.iloc[i]["yhat_upper"])
            exp       = max(0.0, fc_exp.iloc[i]["yhat"])

            forecasts.append({
                "year":                 ts.year,
                "month":                ts.month,
                "label":                f"{ts.year}년 {ts.month}월",
                "predicted_revenue":    round(rev),
                "predicted_expenses":   round(exp),
                "predicted_net_income": round(rev - exp),
                "revenue_lower":        round(rev_lower),
                "revenue_upper":        round(rev_upper),
            })

        print(f"[forecast] Prophet ML 예측 완료 ({len(forecasts)}개월, "
              f"신뢰 구간 포함)")
        return forecasts, "prophet"

    except Exception as e:
        print(f"[forecast] Prophet 실패 → Holt's fallback ({e})")
        return _holt_forecast(history, months_ahead)


# ── 메인 함수 ────────────────────────────────────────────────────────
def build_revenue_forecast(
    orders,
    order_items,
    expenses,
    payrolls,
    purchases,
    purchase_items,
    ingredients=None,
    employees=None,
    menus=None,
    categories=None,
    months_ahead: int = None,
) -> dict:

    if months_ahead is None:
        months_ahead = 6

    # ── 데이터가 존재하는 월 탐색 ────────────────────────────────────
    month_set: set = set()

    for o in orders:
        if o.get("status") != "완료":
            continue
        dt_str = (o.get("orderedAt") or "")[:10]
        if dt_str:
            try:
                dt = date.fromisoformat(dt_str)
                month_set.add((dt.year, dt.month))
            except ValueError:
                pass

    for e in expenses:
        dt_str = (e.get("expenseDate") or "")[:10]
        if dt_str:
            try:
                dt = date.fromisoformat(dt_str)
                month_set.add((dt.year, dt.month))
            except ValueError:
                pass

    for p in payrolls:
        y, m = p.get("payYear"), p.get("payMonth")
        if y and m:
            month_set.add((int(y), int(m)))

    for pur in purchases:
        if (pur.get("status") or "") not in ("ordered", "received"):
            continue
        dt_str = str(pur.get("ordered_at") or "")[:10]
        if dt_str:
            try:
                dt = date.fromisoformat(dt_str)
                month_set.add((dt.year, dt.month))
            except ValueError:
                pass

    # ── 최근 6개월 이내, 당월 미포함 ────────────────────────────────
    today      = date.today()
    current_ym = (today.year, today.month)
    cutoff_ym  = _next_ym(today.year, today.month, -6)

    all_months = sorted(ym for ym in month_set if cutoff_ym <= ym < current_ym)

    if not all_months:
        return {"history": [], "forecasts": [], "summary": {}}

    # ── 월별 손익 집계 ───────────────────────────────────────────────
    history = []
    for ym in all_months:
        stmt = build_income_statement(
            orders, order_items, expenses, payrolls,
            purchases, purchase_items,
            ingredients=ingredients,
            employees=employees,
            menus=menus,
            categories=categories,
            year=ym[0],
            month=ym[1],
        )
        rev = stmt["summary"]["총매출"]
        exp = stmt["summary"]["총지출"]
        history.append({
            "year":       ym[0],
            "month":      ym[1],
            "label":      f"{ym[0]}년 {ym[1]}월",
            "revenue":    rev,
            "expenses":   exp,
            "net_income": rev - exp,
        })

    # ── 모델 선택: Prophet (3개월 이상) / Holt's (3개월 미만) ────────
    if len(history) >= 3:
        forecasts, model_used = _prophet_forecast(history, months_ahead)
    else:
        print(f"[forecast] 히스토리 {len(history)}개월 — "
              f"Prophet은 3개월 이상 필요, Holt's 사용")
        forecasts, model_used = _holt_forecast(history, months_ahead)

    # ── 트렌드 판정 (예측 순이익 첫 달 vs 마지막 달) ─────────────────
    if len(forecasts) >= 2:
        net_first   = forecasts[0]["predicted_net_income"]
        net_last    = forecasts[-1]["predicted_net_income"]
        trend_label = "상승" if net_last > net_first else ("하락" if net_last < net_first else "보합")
    elif forecasts:
        hist_avg    = sum(h["net_income"] for h in history) / len(history)
        trend_label = "상승" if forecasts[0]["predicted_net_income"] > hist_avg else "하락"
    else:
        trend_label = "보합"

    avg_rev = sum(h["revenue"]  for h in history) / len(history)
    avg_exp = sum(h["expenses"] for h in history) / len(history)

    return {
        "history":   history,
        "forecasts": forecasts,
        "summary": {
            "avg_monthly_revenue":  round(avg_rev),
            "avg_monthly_expenses": round(avg_exp),
            "avg_monthly_net":      round(avg_rev - avg_exp),
            "revenue_trend":        trend_label,
            "data_months":          len(all_months),
            "forecast_months":      months_ahead,
            "model":                model_used,   # "prophet" | "holt"
        },
    }
