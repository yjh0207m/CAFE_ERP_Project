<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>발주 등록 | ERP CAFE</title>
    <link rel="stylesheet" href="/css/header.css"/>
    <link rel="stylesheet" href="/css/Ingredients/stock.css"/>
</head>
<body>

<jsp:include page="/WEB-INF/views/header.jsp"/>

<%
java.util.Map<String,String> emojiMap = new java.util.LinkedHashMap<>();
emojiMap.put("원두",     "☕");
emojiMap.put("유제품",   "🥛");
emojiMap.put("시럽/소스","🍯");
emojiMap.put("파우더",   "🌿");
emojiMap.put("차류",     "🍵");
emojiMap.put("소모품",   "🧴");
emojiMap.put("기타",     "📦");
request.setAttribute("emojiMap", emojiMap);
%>

<div class="content">

    <div class="page-header">
        <div class="page-title-wrap">
            <span class="page-icon">🛒</span>
            <div>
                <h1 class="page-title">발주 등록</h1>
                <p class="page-sub">재고관리 &gt; 발주 등록</p>
            </div>
        </div>
    </div>

    <div class="supplier-banner">
        💡 원재료를 선택하면 거래처가 자동으로 설정됩니다. 같은 거래처의 원재료만 한 번에 발주할 수 있습니다.
    </div>

    <div class="order-layout">

        <%-- 왼쪽: 원재료 목록 --%>
        <div class="order-left">
            <div class="table-card">
                <div class="table-card-header">
                    <h3>📦 원재료 선택</h3>
                    <input type="text" id="searchInput" placeholder="검색..."
                           oninput="filterIngredients()"
                           style="padding:6px 12px; border:1.5px solid var(--border);
                                  border-radius:var(--radius-sm); font-size:0.85rem;
                                  width:160px; outline:none;">
                </div>

                <div style="padding:12px 20px 0; display:flex; gap:6px; flex-wrap:wrap;
                            border-bottom:1.5px solid var(--border-light);">
                    <button class="tab-btn active" onclick="filterOrderCategory('all',this)">전체</button>
                    <button class="tab-btn" onclick="filterOrderCategory('원두',this)">☕ 원두</button>
                    <button class="tab-btn" onclick="filterOrderCategory('유제품',this)">🥛 유제품</button>
                    <button class="tab-btn" onclick="filterOrderCategory('시럽/소스',this)">🍯 시럽/소스</button>
                    <button class="tab-btn" onclick="filterOrderCategory('파우더',this)">🌿 파우더</button>
                    <button class="tab-btn" onclick="filterOrderCategory('차류',this)">🍵 차류</button>
                    <button class="tab-btn" onclick="filterOrderCategory('소모품',this)">🧴 소모품</button>
                    <button class="tab-btn" onclick="filterOrderCategory('기타',this)">📦 기타</button>
                </div>

                <table class="data-table">
                    <thead>
                        <tr>
                            <th>원재료명</th>
                            <th>카테고리</th>
                            <th>단위</th>
                            <th>현재 재고</th>
                            <th>단가</th>
                            <th>거래처</th>
                            <th>선택</th>
                        </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${empty ingredientList}">
                            <tr class="empty-row"><td colspan="7">등록된 원재료가 없습니다.</td></tr>
                        </c:when>
                        <c:otherwise>
                            <%-- 거래처 있는 원재료 (삭제된 거래처 제외) --%>
                            <c:forEach var="item" items="${ingredientList}">
                                <c:if test="${not empty item.supplier}">
                                <tr class="ingredient-row"
                                    data-id="${item.id}"
                                    data-name="${item.name}"
                                    data-unit="${item.unit}"
                                    data-cost="${item.unit_cost}"
                                    data-supplier-id="${item.supplier_id}"
                                    data-supplier-name="${item.supplier}"
                                    data-category="${item.category}">
                                    <td><strong>${item.name}</strong>
                                        <c:if test="${item.stock_qty <= item.min_stock}">
                                            <span class="badge badge-low" style="margin-left:6px;">부족</span>
                                        </c:if>
                                    </td>
                                    <td><span class="badge badge-category">${emojiMap[item.category]} ${item.category}</span></td>
                                    <td>${item.unit}</td>
                                    <td>${item.stock_qty}</td>
                                    <td><fmt:formatNumber value="${item.unit_cost}" pattern="#,###"/>원</td>
                                    <td><span class="supplier-tag">${item.supplier}</span></td>
                                    <td>
                                        <button type="button" class="btn btn-edit"
                                            onclick="addToCart(${item.id},'${item.name}','${item.unit}',${item.unit_cost},${item.supplier_id},'${item.supplier}')">
                                            + 추가
                                        </button>
                                    </td>
                                </tr>
                                </c:if>
                            </c:forEach>

                            <%-- 거래처 없는 원재료 구분선 --%>
                            <c:set var="hasNoSupplier" value="false"/>
                            <c:forEach var="item" items="${ingredientList}">
                                <c:if test="${empty item.supplier}"><c:set var="hasNoSupplier" value="true"/></c:if>
                            </c:forEach>
                            <c:if test="${hasNoSupplier == 'true'}">
                                <tr class="no-supplier-header">
                                    <td colspan="7">
                                        ⚠️ 거래처 미등록 원재료 &mdash; 발주 불가 (거래처 관리에서 거래처를 먼저 등록해 주세요)
                                    </td>
                                </tr>
                                <c:forEach var="item" items="${ingredientList}">
                                    <c:if test="${empty item.supplier}">
                                    <tr class="ingredient-row no-supplier-row"
                                        data-category="${item.category}"
                                        data-supplier-id="0"
                                        data-supplier-name="">
                                        <td><strong>${item.name}</strong></td>
                                        <td><span class="badge badge-category">${emojiMap[item.category]} ${item.category}</span></td>
                                        <td>${item.unit}</td>
                                        <td>${item.stock_qty}</td>
                                        <td><fmt:formatNumber value="${item.unit_cost}" pattern="#,###"/>원</td>
                                        <td><span style="color:var(--accent-red); font-size:0.78rem; font-weight:600;">미등록</span></td>
                                        <td>
                                            <button type="button" class="btn btn-cancel" disabled
                                                style="cursor:not-allowed; opacity:0.5;"
                                                title="거래처를 먼저 등록해 주세요">
                                                발주불가
                                            </button>
                                        </td>
                                    </tr>
                                    </c:if>
                                </c:forEach>
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
                <%-- JS 페이지네이션 --%>
                <div class="pagination" id="orderPagination">
                    <div class="page-size-select">
                        <select onchange="changePageSize(this.value)">
                            <option value="10">10개씩</option>
                            <option value="20">20개씩</option>
                            <option value="50">50개씩</option>
                        </select>
                    </div>
                    <div class="page-nav" id="pageNav"></div>
                    <div style="font-size:0.8rem; color:var(--text-muted);" id="pageInfo"></div>
                </div>
            </div>
        </div>

        <%-- 오른쪽: 발주 카트 --%>
        <div class="order-right">
            <div class="table-card">
                <div class="table-card-header"><h3>🛒 발주 목록</h3></div>
                <div style="padding:16px 20px;">
                    <div class="form-row">
                        <div class="form-group">
                            <label>거래처</label>
                            <input type="text" id="cart_supplier_name"
                                   placeholder="원재료 선택 시 자동 설정"
                                   readonly
                                   style="background:#f8f9ff; color:var(--primary);
                                          font-weight:600; cursor:default;">
                        </div>
                        <div class="form-group">
                            <label>발주일 *</label>
                            <input type="date" id="cart_ordered_at">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>비고</label>
                        <input type="text" id="cart_note" placeholder="메모 입력">
                    </div>
                </div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>원재료명</th>
                            <th>수량</th>
                            <th>단가</th>
                            <th>소계</th>
                            <th>삭제</th>
                        </tr>
                    </thead>
                    <tbody id="cartBody">
                        <tr>
                            <td colspan="5" style="padding:30px; color:var(--text-muted); text-align:center;">
                                원재료를 추가해 주세요
                            </td>
                        </tr>
                    </tbody>
                </table>
                <div class="cart-total">
                    <span>총 발주금액</span>
                    <strong id="totalAmount">0원</strong>
                </div>
                <div style="padding:16px 20px; display:flex; justify-content:flex-end; gap:10px;">
                    <button type="button" class="btn btn-cancel" onclick="clearCart()">초기화</button>
                    <button type="button" class="btn btn-primary" onclick="submitOrder()">발주 등록</button>
                </div>
            </div>
        </div>

    </div>
</div>

<%-- hidden form - supplier_id로 전송 --%>
<form id="orderForm" action="/inventory/order" method="post">
    <input type="hidden" name="supplier_id" id="form_supplier_id">
    <input type="hidden" name="ordered_at"  id="form_ordered_at">
    <input type="hidden" name="note"        id="form_note">
    <input type="hidden" name="total_cost"  id="form_total_cost">
    <input type="hidden" name="itemsJson"   id="form_items">
</form>

<style>
.order-layout {
    display: grid;
    grid-template-columns: 1fr 420px;
    gap: 20px;
    align-items: start;
}
.supplier-banner {
    background: var(--primary-light);
    border: 1.5px solid rgba(91,110,245,0.2);
    border-radius: var(--radius-md);
    padding: 12px 18px;
    font-size: 0.85rem;
    color: var(--primary);
    font-weight: 500;
    margin-bottom: 16px;
}
.supplier-tag {
    display: inline-block;
    background: var(--accent-green-light);
    color: var(--accent-green);
    font-size: 0.78rem;
    font-weight: 600;
    padding: 3px 10px;
    border-radius: 20px;
}
.cart-total {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 14px 20px;
    border-top: 1.5px solid var(--border-light);
    font-size: 0.95rem;
    font-weight: 600;
}
.cart-total strong {
    font-family: 'Outfit', sans-serif;
    font-size: 1.2rem;
    color: var(--primary);
}
.ingredient-row.disabled {
    opacity: 0.35;
    pointer-events: none;
}
/* 거래처 미등록 구분선 */
.no-supplier-header td {
    background: var(--accent-red-light);
    color: var(--accent-red);
    font-size: 0.82rem;
    font-weight: 600;
    padding: 10px 16px;
    border-top: 2px solid var(--accent-red);
}
/* 거래처 미등록 행 */
.no-supplier-row {
    opacity: 0.6;
    background: #fff8f8;
}
.no-supplier-row td { background: #fff8f8 !important; }
.tab-btn {
    padding: 6px 14px;
    border: 1.5px solid var(--border);
    border-radius: 20px;
    background: var(--bg-card);
    color: var(--text-secondary);
    font-size: 0.82rem;
    font-weight: 500;
    cursor: pointer;
    transition: var(--transition);
    font-family: 'Noto Sans KR', sans-serif;
    margin-bottom: 10px;
}
.tab-btn:hover  { border-color: var(--primary); color: var(--primary); }
.tab-btn.active {
    background: var(--primary-gradient);
    color: #fff;
    border-color: transparent;
    box-shadow: 0 2px 8px rgba(91,110,245,0.3);
}
@media (max-width: 1100px) {
    .order-layout { grid-template-columns: 1fr; }
}
</style>

<script>
var cart                = [];
var currentSupplierId   = 0;
var currentSupplierName = '';

// 페이지네이션 변수
var pageSize    = 10;
var currentPage = 1;
var currentCat  = 'all';
var currentKw   = '';

document.getElementById('cart_ordered_at').value = new Date().toISOString().split('T')[0];

// 페이지 로드 시 초기 렌더링
window.addEventListener('DOMContentLoaded', function() {
    renderPage();

    // 메인페이지에서 발주 버튼 클릭 시 해당 원재료 자동 추가
    var params    = new URLSearchParams(location.search);
    var highlight = params.get('highlight');
    if (highlight) {
        // renderPage 후 약간 딜레이 줘서 DOM 렌더 완료 후 실행
        setTimeout(function() {
            var row = document.querySelector('.ingredient-row[data-id="' + highlight + '"]');
            if (row) {
                // 해당 행 표시 (숨겨진 경우 페이지 이동)
                row.style.display = '';

                // 행 강조
                row.style.background = 'var(--accent-orange-light)';
                row.style.transition = 'background 1.5s';
                setTimeout(function() { row.style.background = ''; }, 2000);

                // 스크롤
                row.scrollIntoView({ behavior: 'smooth', block: 'center' });

                // 데이터 추출 후 카트에 바로 추가
                var id           = parseInt(row.dataset.id);
                var name         = decodeURIComponent(row.dataset.name || '');
                var unit         = row.dataset.unit || '';
                var unit_cost    = parseInt(row.dataset.cost) || 0;
                var supplierId   = parseInt(row.dataset.supplierId) || 0;
                var supplierName = row.dataset.supplierName || '';

                if (id && name && supplierId) {
                    addToCart(id, name, unit, unit_cost, supplierId, supplierName);
                }
            }
        }, 300);
    }
});

function updateRowStates() {
    document.querySelectorAll('.ingredient-row').forEach(function(row) {
        if (!currentSupplierId) { row.classList.remove('disabled'); return; }
        var rowSid = parseInt(row.dataset.supplierId) || 0;
        if (rowSid === currentSupplierId) { row.classList.remove('disabled'); }
        else                              { row.classList.add('disabled'); }
    });
    // 거래처 미등록 섹션은 renderPage()가 제어하므로 여기서 건드리지 않음
    renderPage();
}

function filterIngredients() {
    currentKw   = document.getElementById('searchInput').value.toLowerCase();
    currentPage = 1;
    renderPage();
}

function filterOrderCategory(category, btn) {
    document.querySelectorAll('.tab-btn').forEach(function(b) { b.classList.remove('active'); });
    btn.classList.add('active');
    currentCat  = category;
    currentPage = 1;
    renderPage();
}

/* JS 페이지네이션 핵심 함수 */
function getFilteredRows() {
    return Array.from(document.querySelectorAll('.ingredient-row')).filter(function(row) {
        var nameEl = row.querySelector('td strong');
        if (!nameEl) return false;
        var name   = nameEl.innerText.toLowerCase();
        var catOk  = (currentCat === 'all' || row.dataset.category === currentCat);
        var kwOk   = (currentKw === '' || name.includes(currentKw));
        return catOk && kwOk;
    });
}

function renderPage() {
    var allRows    = Array.from(document.querySelectorAll('.ingredient-row, .no-supplier-header'));
    var filtered   = getFilteredRows();
    var total      = filtered.length;
    var totalPages = Math.max(1, Math.ceil(total / pageSize));
    if (currentPage > totalPages) currentPage = totalPages;

    var start = (currentPage - 1) * pageSize;
    var end   = start + pageSize;

    // 모든 행 숨기기
    document.querySelectorAll('.ingredient-row').forEach(function(row) {
        row.style.display = 'none';
    });

    // no-supplier-header 처리
    var noSupHeader = document.querySelector('.no-supplier-header');
    if (noSupHeader) noSupHeader.style.display = 'none';

    // 필터된 행 중 현재 페이지 분만 표시
    filtered.slice(start, end).forEach(function(row) {
        row.style.display = '';
        // no-supplier-row면 헤더도 표시
        if (row.classList.contains('no-supplier-row') && noSupHeader) {
            noSupHeader.style.display = '';
        }
    });

    // 페이지 정보
    document.getElementById('pageInfo').innerText =
        '총 ' + total + '개 중 ' + Math.min(start + 1, total) + '-' + Math.min(end, total) + '개 표시';

    // 페이지 버튼 렌더
    var nav    = document.getElementById('pageNav');
    var html   = '';
    var block  = 5;
    var startP = Math.floor((currentPage - 1) / block) * block + 1;
    var endP   = Math.min(startP + block - 1, totalPages);

    if (startP > 1) html += '<button class="page-btn" onclick="goToPage(' + (startP - 1) + ')">◀</button>';
    for (var p = startP; p <= endP; p++) {
        html += '<button class="page-btn ' + (p === currentPage ? 'active' : '') + '" onclick="goToPage(' + p + ')">' + p + '</button>';
    }
    if (endP < totalPages) html += '<button class="page-btn" onclick="goToPage(' + (endP + 1) + ')">▶</button>';
    nav.innerHTML = html;
}

function goToPage(p) {
    currentPage = p;
    renderPage();
}

function changePageSize(s) {
    pageSize    = parseInt(s);
    currentPage = 1;
    renderPage();
}

function addToCart(id, name, unit, unit_cost, supplierId, supplierName) {
    var existing = cart.find(function(c) { return c.id === id; });
    if (existing) { existing.qty++; renderCart(); return; }

    if (!currentSupplierId) {
        currentSupplierId   = supplierId;
        currentSupplierName = supplierName || '';
        document.getElementById('cart_supplier_name').value = currentSupplierName;
        updateRowStates();
    }
    cart.push({ id: id, name: name, unit: unit, unit_cost: unit_cost, qty: 1 });
    renderCart();
}

function changeQty(id, qty) {
    var item = cart.find(function(c) { return c.id === id; });
    if (item) { item.qty = Math.max(1, parseInt(qty) || 1); renderCart(); }
}

function removeFromCart(id) {
    cart = cart.filter(function(c) { return c.id !== id; });
    if (cart.length === 0) {
        currentSupplierId   = 0;
        currentSupplierName = '';
        document.getElementById('cart_supplier_name').value = '';
        updateRowStates();
    }
    renderCart();
}

function clearCart() {
    cart = [];
    currentSupplierId   = 0;
    currentSupplierName = '';
    document.getElementById('cart_supplier_name').value = '';
    updateRowStates();
    renderCart();
}

function renderCart() {
    var tbody = document.getElementById('cartBody');
    if (cart.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" style="padding:30px; color:var(--text-muted); text-align:center;">원재료를 추가해 주세요</td></tr>';
        document.getElementById('totalAmount').innerText = '0원';
        return;
    }
    var total = 0, html = '';
    cart.forEach(function(item) {
        var sub = item.qty * item.unit_cost;
        total += sub;
        html += '<tr>'
            + '<td><strong>' + item.name + '</strong><br><small style="color:var(--text-muted)">' + item.unit + '</small></td>'
            + '<td><input type="number" min="1" value="' + item.qty + '" onchange="changeQty(' + item.id + ',this.value)"'
            + ' style="width:64px; padding:5px 8px; border:1.5px solid var(--border); border-radius:var(--radius-sm); text-align:center; font-size:0.88rem;"></td>'
            + '<td>' + item.unit_cost.toLocaleString() + '원</td>'
            + '<td><strong>' + sub.toLocaleString() + '원</strong></td>'
            + '<td><button type="button" class="btn btn-delete" onclick="removeFromCart(' + item.id + ')">✕</button></td>'
            + '</tr>';
    });
    tbody.innerHTML = html;
    document.getElementById('totalAmount').innerText = total.toLocaleString() + '원';
}

function submitOrder() {
    if (cart.length === 0)  { alert('발주할 원재료를 추가해 주세요.'); return; }
    if (!currentSupplierId) { alert('거래처가 등록된 원재료를 선택해 주세요.'); return; }
    var ordered_at = document.getElementById('cart_ordered_at').value;
    if (!ordered_at)        { alert('발주일을 선택해 주세요.'); return; }

    var total = cart.reduce(function(s, c) { return s + c.qty * c.unit_cost; }, 0);
    document.getElementById('form_supplier_id').value = currentSupplierId;
    document.getElementById('form_ordered_at').value  = ordered_at;
    document.getElementById('form_note').value        = document.getElementById('cart_note').value;
    document.getElementById('form_total_cost').value  = total;
    document.getElementById('form_items').value       = JSON.stringify(cart);

    if (confirm('총 ' + total.toLocaleString() + '원 발주하시겠습니까?')) {
        document.getElementById('orderForm').submit();
    }
}
</script>

</body>
</html>
