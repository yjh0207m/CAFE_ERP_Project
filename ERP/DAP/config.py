"""
config.py — 전역 설정 모듈
모든 파일에서 이 모듈만 import해서 설정값 사용

사용법:
    from config import SPRING_BASE_URL, EXCEL_OUTPUT_DIR, INITIAL_CAPITAL
"""

import os
from pathlib import Path
from dotenv import load_dotenv

# ── .env 로드 ────────────────────────────────────────────────────
# config.py 기준으로 같은 폴더의 .env를 찾음
BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR / ".env", override=True)

# ── Spring Boot REST API ─────────────────────────────────────────
SPRING_BASE_URL: str = os.getenv("SPRING_BASE_URL", "http://localhost:8080")

SPRING_API = {
    "orders"         : f"{SPRING_BASE_URL}/api/orders",             # 주문 전체
    "order_items"    : f"{SPRING_BASE_URL}/api/order-items/all",    # 주문 상세
    "purchases"      : f"{SPRING_BASE_URL}/api/purchases",          # 발주 전체
    "purchase_items" : f"{SPRING_BASE_URL}/api/purchase-items/all", # 발주 상세 품목
    "expenses"       : f"{SPRING_BASE_URL}/api/expenses",           # 지출 전체
    "payrolls"       : f"{SPRING_BASE_URL}/api/payrolls",           # 급여 전체
    "ingredients"    : f"{SPRING_BASE_URL}/api/ingredients",        # 재고 전체
    "stock_logs"     : f"{SPRING_BASE_URL}/api/stock-logs",         # 재고 흐름
    "menus"          : f"{SPRING_BASE_URL}/api/menus/all",          # 메뉴 전체 (카테고리명 포함)
    "employees"      : f"{SPRING_BASE_URL}/api/employees",          # 직원 전체 (직책 포함)
    "categories"     : f"{SPRING_BASE_URL}/api/categories",         # 메뉴 카테고리 전체
}

# ── FastAPI 서버 ─────────────────────────────────────────────────
FASTAPI_HOST: str = os.getenv("FASTAPI_HOST", "127.0.0.1")
FASTAPI_PORT: int = int(os.getenv("FASTAPI_PORT", "8000"))
FASTAPI_BASE_URL: str = f"http://{FASTAPI_HOST}:{FASTAPI_PORT}"

# ── MariaDB 직접 접속 (Spring REST 우회용) ───────────────────────
DB_CONFIG = {
    "host"    : os.getenv("DB_HOST",     "localhost"),
    "port"    : int(os.getenv("DB_PORT", "3306")),
    "db"      : os.getenv("DB_NAME",     "cafe_erp"),
    "user"    : os.getenv("DB_USER",     "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "charset" : "utf8mb4",
}

# ── 엑셀 저장 경로 ───────────────────────────────────────────────
# DAP 폴더가 ERP/DAP 에 위치할 때: BASE_DIR.parent = ERP 루트
# → 기본값: ERP/src/main/resources/static/uploads/excel
# DAP 폴더가 독립적으로 존재할 때: .env 의 EXCEL_OUTPUT_DIR 로 재정의 가능
_default_excel_dir = str(BASE_DIR.parent / "src" / "main" / "resources" / "static" / "uploads" / "excel")
EXCEL_OUTPUT_DIR: Path = Path(os.getenv("EXCEL_OUTPUT_DIR", _default_excel_dir))
EXCEL_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)  # 없으면 자동 생성

# ── 재무제표 설정 ────────────────────────────────────────────────
INITIAL_CAPITAL: int = int(os.getenv("INITIAL_CAPITAL", "100000000"))

# ── HTTP 요청 타임아웃 (초) ──────────────────────────────────────
REQUEST_TIMEOUT: int = 10

# ── 재고 소진 임박 기준 (일) ─────────────────────────────────────
INVENTORY_WARNING_DAYS: int = 7   # 7일 이내 소진 예상 → 경고

# ── 수익 예측 기간 (개월) ────────────────────────────────────────
FORECAST_MONTHS: int = 6          # 향후 3개월 예측


# ── 설정값 확인용 (디버그 실행 시) ──────────────────────────────
if __name__ == "__main__":
    print("=" * 50)
    print("[config.py] 현재 설정값 확인")
    print("=" * 50)
    print(f"SPRING_BASE_URL      : {SPRING_BASE_URL}")
    print(f"FASTAPI_BASE_URL     : {FASTAPI_BASE_URL}")
    print(f"DB_HOST              : {DB_CONFIG['host']}:{DB_CONFIG['port']}")
    print(f"DB_NAME              : {DB_CONFIG['db']}")
    print(f"EXCEL_OUTPUT_DIR     : {EXCEL_OUTPUT_DIR.resolve()}")
    print(f"INITIAL_CAPITAL      : {INITIAL_CAPITAL:,}원")
    print(f"INVENTORY_WARNING    : {INVENTORY_WARNING_DAYS}일 이내")
    print(f"FORECAST_MONTHS      : {FORECAST_MONTHS}개월")
    print("=" * 50)