"""
fetcher.py — Spring Boot REST API에서 데이터를 가져오는 모듈
모든 fetch 함수는 list(dict) 형식으로 반환
"""

import requests
from config import SPRING_API, REQUEST_TIMEOUT


def _get(key: str, params: dict = None) -> list:
    """공통 GET 요청 헬퍼"""
    try:
        r = requests.get(SPRING_API[key], params=params, timeout=REQUEST_TIMEOUT)
        r.raise_for_status()
        data = r.json()
        return data if isinstance(data, list) else []
    except Exception as e:
        print(f"[fetcher] {key} 수신 실패: {e}")
        return []


def fetch_orders() -> list:
    """주문 전체 (OrderDTO: id, totalAmount, finalAmount, paymentType, status, orderedAt)"""
    return _get("orders")


def fetch_order_items() -> list:
    """주문 상세 전체 (order_id, menu_id, menu_name, qty, unit_price, subtotal) — snake_case"""
    return _get("order_items")


def fetch_purchases() -> list:
    """발주 전체 (id, supplier, supplier_id, total_cost, status, ordered_at, received_at)"""
    return _get("purchases")


def fetch_purchase_items() -> list:
    """발주 상세 전체 (purchase_id, ingredient_id, qty, unit_cost, subtotal)"""
    return _get("purchase_items")


def fetch_expenses() -> list:
    """지출 전체 (id, expenseType, amount, expenseDate, description, status)"""
    return _get("expenses")


def fetch_payrolls(year: int = None, month: int = None) -> list:
    """급여 전체, 선택적으로 연/월 필터링 (payYear, payMonth, employeeId, employeeName, netPay)"""
    data = _get("payrolls")
    if year is not None:
        data = [p for p in data if p.get("payYear") == year]
    if month is not None:
        data = [p for p in data if p.get("payMonth") == month]
    return data


def fetch_ingredients() -> list:
    """재고 전체 (id, name, category, unit, stock_qty, min_stock, unit_cost, supplier_id)"""
    return _get("ingredients")


def fetch_stock_logs() -> list:
    """재고 로그 전체 (id, ingredientId, changeQty, beforeQty, afterQty, changeType, createdAt)"""
    return _get("stock_logs")


def fetch_menus() -> list:
    """메뉴 전체, categoryName 포함 (id, categoryId, categoryName, name, price, cost)"""
    return _get("menus")


def fetch_employees() -> list:
    """직원 전체 (id, name, position, contract_type, hourly_wage, monthly_salary, is_active)"""
    return _get("employees")


def fetch_categories() -> list:
    """메뉴 카테고리 전체 (id, name)"""
    return _get("categories")
