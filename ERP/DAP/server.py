"""
server.py — FastAPI 분석 서버 (상시 실행)

실행 방법:
    uvicorn server:app --host 127.0.0.1 --port 8000 --reload

엔드포인트:
    POST /internal/update          ← main.py가 분석 완료 후 결과 전송
    GET  /analysis/journal         → 분개장 조회
    GET  /analysis/statement       → 재무제표 전체 조회
    GET  /analysis/forecast        → 수익 예측 조회
    GET  /analysis/inventory       → 재고 소진 예측 조회
    POST /analysis/run             → 분석 즉시 실행 (새로고침 버튼용)
    GET  /status                   → 서버 상태 및 마지막 업데이트 시각
"""

import asyncio
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path

import httpx
from fastapi import FastAPI, BackgroundTasks, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from config import SPRING_BASE_URL

app = FastAPI(title="카페 ERP 분석 서버", version="1.0.0")

# Spring Boot CORS 허용
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── 인메모리 저장소 ───────────────────────────────────────────────
_store: dict = {
    "journal":            {},
    "income_statement":   {},
    "balance_sheet":      {},
    "cash_flow":          {},
    "capital_changes":    {},
    "revenue_forecast":   {},
    "inventory_forecast": [],
    "ai_analysis":        "",
    "excel_path":         None,
    "last_updated":       None,
    "is_running":         False,
}


# ── Spring Boot로 결과 전송 ───────────────────────────────────────
async def _push_to_spring(data: dict):
    """분석 결과를 Spring Boot의 수신 엔드포인트로 전송"""
    spring_url = SPRING_BASE_URL
    endpoints = {
        f"{spring_url}/analysis/journal":          {"entries": data.get("journal", {}).get("entries", []),
                                                     "period":  data.get("journal", {}).get("period", "")},
        f"{spring_url}/analysis/statement":         {
            "income_statement": data.get("income_statement", {}),
            "balance_sheet":    data.get("balance_sheet", {}),
            "cash_flow":        data.get("cash_flow", {}),
            "capital_changes":  data.get("capital_changes", {}),
        },
        f"{spring_url}/analysis/forecast/result":   data.get("revenue_forecast", {}),
        f"{spring_url}/analysis/inventory/result":  {"forecasts": data.get("inventory_forecast", [])},
        f"{spring_url}/analysis/ai-report/result":  {"text": data.get("ai_analysis", "")},
    }

    async with httpx.AsyncClient(timeout=30.0) as client:
        for url, payload in endpoints.items():
            try:
                resp = await client.post(url, json=payload)
                print(f"[server] → Spring {url.split('/')[-1]}: {resp.status_code}")
            except Exception as e:
                print(f"[server] Spring 전송 실패 ({url}): {e}")

        # 엑셀 파일명을 Spring에 등록
        excel_path = data.get("excel_path")
        if excel_path:
            try:
                filename = Path(excel_path).name
                resp = await client.post(
                    f"{spring_url}/analysis/excel/register",
                    json={"filename": filename},
                )
                print(f"[server] → Spring excel/register: {resp.status_code}")
            except Exception as e:
                print(f"[server] 엑셀 등록 실패: {e}")


# ── 백그라운드 분석 실행 ──────────────────────────────────────────
async def _run_analysis(year: int = None, month: int = None):
    # is_running은 run_analysis 엔드포인트에서 미리 True로 세팅됨
    try:
        args = [sys.executable, str(Path(__file__).parent / "main.py")]
        if year:
            args.append(str(year))
        if month:
            args.append(str(month))
        print(f"[server] 분석 시작: {' '.join(args)}")
        env = {**os.environ, 'PYTHONIOENCODING': 'utf-8'}
        result = await asyncio.to_thread(subprocess.run, args, env=env)
        print(f"[server] 분석 완료 (returncode={result.returncode})")
    except Exception as e:
        print(f"[server] 분석 실행 오류: {e}")
    finally:
        _store["is_running"] = False


# ════════════════════════════════════════════════════════════════════
# 엔드포인트
# ════════════════════════════════════════════════════════════════════

@app.post("/internal/update")
async def internal_update(body: dict):
    """
    main.py가 분석 완료 후 모든 결과를 한번에 전송
    수신 후 Spring Boot에도 전달 완료 후 응답 반환
    (background_task 사용 시 is_running=False 시점에 Spring 전송이 미완료되는 문제 방지)
    """
    _store.update({
        "journal":            body.get("journal",            {}),
        "income_statement":   body.get("income_statement",   {}),
        "balance_sheet":      body.get("balance_sheet",      {}),
        "cash_flow":          body.get("cash_flow",          {}),
        "capital_changes":    body.get("capital_changes",    {}),
        "revenue_forecast":   body.get("revenue_forecast",   {}),
        "inventory_forecast": body.get("inventory_forecast", []),
        "ai_analysis":        body.get("ai_analysis",        ""),
        "excel_path":         body.get("excel_path"),
        "last_updated":       datetime.now().isoformat(),
    })
    print(f"[server] 데이터 업데이트 완료 - {datetime.now().strftime('%H:%M:%S')}")

    # Spring Boot 전송 완료 후 응답 (await: main.py가 응답 받는 시점 = Spring 수신 완료)
    await _push_to_spring(dict(_store))
    return {"status": "ok", "updated_at": _store["last_updated"]}


@app.get("/analysis/journal")
async def get_journal():
    """분개장 조회"""
    return _store.get("journal", {})


@app.get("/analysis/statement")
async def get_statement():
    """재무제표 전체 (손익+재무상태+현금흐름+자본변동) 조회"""
    return {
        "income_statement": _store.get("income_statement", {}),
        "balance_sheet":    _store.get("balance_sheet",    {}),
        "cash_flow":        _store.get("cash_flow",        {}),
        "capital_changes":  _store.get("capital_changes",  {}),
    }


@app.get("/analysis/forecast")
async def get_forecast():
    """수익 예측 조회"""
    return _store.get("revenue_forecast", {})


@app.get("/analysis/inventory")
async def get_inventory():
    """재고 소진 예측 조회"""
    return {"forecasts": _store.get("inventory_forecast", [])}


@app.get("/analysis/ai-report")
async def get_ai_report():
    """AI 재무 분석 보고서 조회"""
    return {"text": _store.get("ai_analysis", "")}


@app.post("/analysis/run")
async def run_analysis(
    year:  int = None,
    month: int = None,
    background_tasks: BackgroundTasks = None,
):
    """
    분석 즉시 실행 (JSP 새로고침 버튼 → Spring Boot → 여기 호출)
    백그라운드에서 main.py를 실행하고 즉시 응답 반환
    """
    if _store["is_running"]:
        return {"status": "already_running", "message": "분석이 이미 진행 중입니다."}
    _store["is_running"] = True  # 폴링 race condition 방지: 응답 전에 미리 세팅
    background_tasks.add_task(_run_analysis, year, month)
    return {"status": "started", "year": year, "month": month}


@app.get("/status")
async def get_status():
    """서버 상태 확인"""
    return {
        "status":       "running",
        "is_analyzing": _store["is_running"],
        "last_updated": _store["last_updated"],
        "has_data":     bool(_store.get("income_statement")),
        "excel_path":   _store["excel_path"],
    }


# ── 직접 실행 ─────────────────────────────────────────────────────
if __name__ == "__main__":
    import uvicorn
    from config import FASTAPI_HOST, FASTAPI_PORT
    print(f"[server] FastAPI 서버 시작: http://{FASTAPI_HOST}:{FASTAPI_PORT}")
    uvicorn.run("server:app", host=FASTAPI_HOST, port=FASTAPI_PORT, reload=False)
