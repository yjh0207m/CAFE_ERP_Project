"""
utils.py — 처리 모듈 공통 헬퍼
"""

from datetime import date, datetime


def in_period(date_str: str, year: int = None, month: int = None) -> bool:
    """날짜 문자열이 지정 연/월 범위에 있는지 확인"""
    if not date_str:
        return False
    try:
        dt = date.fromisoformat(str(date_str)[:10])
        if year is not None and dt.year != year:
            return False
        if month is not None and dt.month != month:
            return False
        return True
    except (ValueError, TypeError):
        return False


def format_period(year: int = None, month: int = None) -> str:
    """기간 레이블 생성"""
    today = date.today()
    if year and month:
        return f"{year}년 {month}월"
    elif year:
        return f"{year}년 전체"
    else:
        return f"{today.year}년 1월 1일 ~ {today}"


def safe_int(val, default: int = 0) -> int:
    try:
        return int(val or default)
    except (TypeError, ValueError):
        return default


def safe_float(val, default: float = 0.0) -> float:
    try:
        return float(val or default)
    except (TypeError, ValueError):
        return default
