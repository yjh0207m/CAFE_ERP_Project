<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>재고 현황 | ERP CAFE</title>
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
            <span class="page-icon">📦</span>
            <div>
                <h1 class="page-title">재고 현황</h1>
                <p class="page-sub">재고관리 &gt; 재고 현황</p>
            </div>
        </div>
        <button class="btn btn-primary" onclick="openModal('registerModal')">+ 원재료 등록</button>
    </div>

    <%-- 상단 요약 --%>
    <div class="stat-row">
        <div class="stat-card">
            <div class="stat-icon blue">📦</div>
            <div class="stat-info">
                <div class="label">전체 품목</div>
                <div class="value">${result.totalCount}개</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon blue">📄</div>
            <div class="stat-info">
                <div class="label">현재 페이지</div>
                <div class="value">${result.page} / ${result.totalPages}</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green">✅</div>
            <div class="stat-info">
                <div class="label">페이지당 항목</div>
                <div class="value">${result.size}개</div>
            </div>
        </div>
    </div>

    <%-- 검색 + 카테고리 필터 --%>
    <div class="filter-bar">
        <div class="category-tabs">
            <button class="tab-btn ${empty category ? 'active' : ''}"
                    onclick="goFilter('', '${keyword}')">전체</button>
            <button class="tab-btn ${category == '원두' ? 'active' : ''}"
                    onclick="goFilter('원두', '${keyword}')">☕ 원두</button>
            <button class="tab-btn ${category == '유제품' ? 'active' : ''}"
                    onclick="goFilter('유제품', '${keyword}')">🥛 유제품</button>
            <button class="tab-btn ${category == '시럽/소스' ? 'active' : ''}"
                    onclick="goFilter('시럽/소스', '${keyword}')">🍯 시럽/소스</button>
            <button class="tab-btn ${category == '파우더' ? 'active' : ''}"
                    onclick="goFilter('파우더', '${keyword}')">🌿 파우더</button>
            <button class="tab-btn ${category == '차류' ? 'active' : ''}"
                    onclick="goFilter('차류', '${keyword}')">🍵 차류</button>
            <button class="tab-btn ${category == '소모품' ? 'active' : ''}"
                    onclick="goFilter('소모품', '${keyword}')">🧴 소모품</button>
            <button class="tab-btn ${category == '기타' ? 'active' : ''}"
                    onclick="goFilter('기타', '${keyword}')">📦 기타</button>
        </div>
        <div class="category-tabs" style="margin-top:6px;">
            <button class="tab-btn ${empty stockStatus ? 'active' : ''}"
                    onclick="goStatusFilter('')">전체 상태</button>
            <button class="tab-btn ${stockStatus == 'low' ? 'active' : ''}"
                    onclick="goStatusFilter('low')">⚠ 부족</button>
            <button class="tab-btn ${stockStatus == 'warning' ? 'active' : ''}"
                    onclick="goStatusFilter('warning')">△ 주의</button>
            <button class="tab-btn ${stockStatus == 'normal' ? 'active' : ''}"
                    onclick="goStatusFilter('normal')">✓ 정상</button>
        </div>
        <div class="search-box">
            <input type="text" id="keywordInput" placeholder="원재료명 검색..."
                   value="${keyword}" onkeydown="if(event.key==='Enter') doSearch()">
            <button class="btn btn-edit" onclick="doSearch()">🔍 검색</button>
            <c:if test="${not empty keyword}">
                <button class="btn btn-cancel" onclick="goFilter('${category}','')">✕ 초기화</button>
            </c:if>
        </div>
    </div>

    <%-- 테이블 --%>
    <div class="table-card">
        <div class="table-card-header">
            <h3>원재료 목록</h3>
            <span style="font-size:0.82rem; color:var(--text-muted);">
                총 ${result.totalCount}개 중 ${result.list.size()}개 표시
            </span>
        </div>
        <table class="data-table">
            <thead>
                <tr>
                    <th>카테고리</th>
                    <th>원재료명</th>
                    <th>단위</th>
                    <th>현재 재고</th>
                    <th>최소 기준량</th>
                    <th>상태</th>
                    <th>거래처</th>
                    <th>원가</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty result.list}">
                    <tr class="empty-row"><td colspan="9">등록된 원재료가 없습니다.</td></tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="item" items="${result.list}">
                    <tr>
                        <td>
                            <span class="badge badge-category">
                                ${emojiMap[item.category]} ${item.category}
                            </span>
                        </td>
                        <td><strong>${item.name}</strong></td>
                        <td>${item.unit}</td>
                        <td>${item.stock_qty}</td>
                        <td>${item.min_stock}</td>
                        <td>
                            <c:choose>
                                <c:when test="${item.stock_qty <= item.min_stock}">
                                    <span class="badge badge-low">⚠ 부족</span>
                                </c:when>
                                <c:when test="${item.stock_qty <= item.min_stock * 1.5}">
                                    <span class="badge badge-warning">△ 주의</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-normal">✓ 정상</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <%-- 거래처명 클릭 시 거래처 관리로 이동 --%>
                        <td>
                            <c:choose>
                                <c:when test="${not empty item.supplier}">
                                    <a href="/inventory/vendor"
                                       style="color:var(--primary); font-weight:600;
                                              text-decoration:none; font-size:0.82rem;">
                                        ${item.supplier}
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-low">미등록</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td><fmt:formatNumber value="${item.unit_cost}" pattern="#,###"/>원</td>
                        <td>
                            <button class="btn btn-edit"
                                onclick="openEditModal(${item.id})">
                                수정
                            </button>
                            <form action="/inventory/delete/${item.id}" method="post" style="display:inline"
                                  onsubmit="return confirm('${item.name}을(를) 삭제하시겠습니까?')">
                                <input type="hidden" name="page" value="${result.page}">
                                <c:if test="${not empty category}">
                                    <input type="hidden" name="cat" value="${category}">
                                </c:if>
                                <c:if test="${not empty keyword}">
                                    <input type="hidden" name="keyword" value="${keyword}">
                                </c:if>
                                <c:if test="${not empty stockStatus}">
                                    <input type="hidden" name="stockStatus" value="${stockStatus}">
                                </c:if>
                                <button type="submit" class="btn btn-delete">삭제</button>
                            </form>
                        </td>
                    </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>

        <%-- 페이지네이션 --%>
        <div class="pagination">
            <div class="page-size-select">
                <select onchange="changeSize(this.value)">
                    <option value="10"  ${size == 10  ? 'selected' : ''}>10개씩</option>
                    <option value="20"  ${size == 20  ? 'selected' : ''}>20개씩</option>
                    <option value="50"  ${size == 50  ? 'selected' : ''}>50개씩</option>
                </select>
            </div>
            <div class="page-nav">
                <c:if test="${result.hasPrev()}">
                    <button class="page-btn" onclick="goPage(${result.startPage - 1})">◀</button>
                </c:if>
                <c:forEach begin="${result.startPage}" end="${result.endPage}" var="p">
                    <button class="page-btn ${p == result.page ? 'active' : ''}"
                            onclick="goPage(${p})">${p}</button>
                </c:forEach>
                <c:if test="${result.hasNext()}">
                    <button class="page-btn" onclick="goPage(${result.endPage + 1})">▶</button>
                </c:if>
            </div>
            <div style="font-size:0.8rem; color:var(--text-muted);">총 ${result.totalCount}개</div>
        </div>
    </div>
</div>

<%-- ===== 등록 모달 ===== --%>
<div class="modal-overlay" id="registerModal">
    <div class="modal">
        <div class="modal-title">➕ 원재료 등록</div>
        <form action="/inventory/register" method="post">
            <div class="form-row">
                <div class="form-group">
                    <label>원재료명 *</label>
                    <input type="text" name="name" required placeholder="예: 원두">
                </div>
                <div class="form-group">
                    <label>카테고리 *</label>
                    <select name="category" required>
                        <option value="">선택하세요</option>
                        <option value="원두">☕ 원두</option>
                        <option value="유제품">🥛 유제품</option>
                        <option value="시럽/소스">🍯 시럽/소스</option>
                        <option value="파우더">🌿 파우더</option>
                        <option value="차류">🍵 차류</option>
                        <option value="소모품">🧴 소모품</option>
                        <option value="기타">📦 기타</option>
                    </select>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>단위 *</label>
                    <input type="text" name="unit" required placeholder="예: kg, box">
                </div>
                <div class="form-group">
                    <label>거래처</label>
                    <%-- 텍스트 입력 → 드롭다운으로 변경 --%>
                    <select name="supplier_id">
                        <option value="">선택하세요</option>
                        <c:forEach var="s" items="${supplierList}">
                            <option value="${s.id}">${s.supplier_name}
                                <c:if test="${not empty s.supplier_type}"> (${s.supplier_type})</c:if>
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>현재 재고량</label>
                    <input type="number" name="stock_qty" step="0.01" value="0">
                </div>
                <div class="form-group">
                    <label>최소 재고 기준량</label>
                    <input type="number" name="min_stock" step="0.01" value="0">
                </div>
            </div>
            <div class="form-group">
                <label>원가 (개당)</label>
                <input type="number" name="unit_cost" value="0">
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-cancel" onclick="closeModal('registerModal')">취소</button>
                <button type="submit" class="btn btn-primary">등록</button>
            </div>
        </form>
    </div>
</div>

<%-- ===== 수정 모달 ===== --%>
<div class="modal-overlay" id="editModal">
    <div class="modal">
        <div class="modal-title">✏️ 원재료 수정</div>
        <form action="/inventory/update" method="post">
            <input type="hidden" name="id"   id="edit_id">
            <input type="hidden" name="page" value="${result.page}">
            <c:if test="${not empty category}">
                <input type="hidden" name="cat" value="${category}">
            </c:if>
            <c:if test="${not empty stockStatus}">
                <input type="hidden" name="stockStatus" value="${stockStatus}">
            </c:if>
            <div class="form-row">
                <div class="form-group">
                    <label>원재료명 *</label>
                    <input type="text" name="name" id="edit_name" required>
                </div>
                <div class="form-group">
                    <label>카테고리 *</label>
                    <select name="category" id="edit_category" required>
                        <option value="원두">☕ 원두</option>
                        <option value="유제품">🥛 유제품</option>
                        <option value="시럽/소스">🍯 시럽/소스</option>
                        <option value="파우더">🌿 파우더</option>
                        <option value="차류">🍵 차류</option>
                        <option value="소모품">🧴 소모품</option>
                        <option value="기타">📦 기타</option>
                    </select>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>단위 *</label>
                    <input type="text" name="unit" id="edit_unit" required>
                </div>
                <div class="form-group">
                    <label>거래처</label>
                    <select name="supplier_id" id="edit_supplier_id">
                        <option value="">선택하세요</option>
                        <c:forEach var="s" items="${supplierList}">
                            <option value="${s.id}">${s.supplier_name}
                                <c:if test="${not empty s.supplier_type}"> (${s.supplier_type})</c:if>
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>현재 재고량</label>
                    <input type="number" name="stock_qty" id="edit_stock_qty" step="0.01">
                </div>
                <div class="form-group">
                    <label>최소 재고 기준량</label>
                    <input type="number" name="min_stock" id="edit_min_stock" step="0.01">
                </div>
            </div>
            <div class="form-group">
                <label>원가 (개당)</label>
                <input type="number" name="unit_cost" id="edit_unit_cost">
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-cancel" onclick="closeModal('editModal')">취소</button>
                <button type="submit" class="btn btn-primary">저장</button>
            </div>
        </form>
    </div>
</div>

<script>
var currentCategory    = '${category}';
var currentKeyword     = '${keyword}';
var currentSize        = ${size};
var currentStockStatus = '${stockStatus}';

function buildUrl(page, size, cat, kw, st) {
    var url = '/inventory?page=' + page + '&size=' + size;
    if (cat) url += '&category='    + encodeURIComponent(cat);
    if (kw)  url += '&keyword='     + encodeURIComponent(kw);
    if (st)  url += '&stockStatus=' + encodeURIComponent(st);
    return url;
}
function goPage(p) {
    location.href = buildUrl(p, currentSize, currentCategory, currentKeyword, currentStockStatus);
}
function goFilter(cat, kw) {
    location.href = buildUrl(1, currentSize, cat, kw, currentStockStatus);
}
function goStatusFilter(st) {
    location.href = buildUrl(1, currentSize, currentCategory, currentKeyword, st);
}
function doSearch() {
    goFilter(currentCategory, document.getElementById('keywordInput').value.trim());
}
function changeSize(s) {
    location.href = buildUrl(1, s, currentCategory, currentKeyword, currentStockStatus);
}
function openModal(id)  { document.getElementById(id).classList.add('active'); }
function closeModal(id) { document.getElementById(id).classList.remove('active'); }

/* data-* 방식으로 수정 모달 열기 */
function openEditModal(id) {
    fetch('/inventory/' + id)
        .then(function(res) { return res.json(); })
        .then(function(item) {
            document.getElementById('edit_id').value          = item.id;
            document.getElementById('edit_name').value        = item.name;
            document.getElementById('edit_category').value    = item.category;
            document.getElementById('edit_unit').value        = item.unit;
            document.getElementById('edit_stock_qty').value   = item.stock_qty;
            document.getElementById('edit_min_stock').value   = item.min_stock;
            document.getElementById('edit_unit_cost').value   = item.unit_cost;
            var supplierId = item.supplier_id;
            document.getElementById('edit_supplier_id').value =
                (supplierId && supplierId !== null) ? supplierId : '';
            openModal('editModal');
        });
}

document.querySelectorAll('.modal-overlay').forEach(function(o) {
    o.addEventListener('click', function(e) { if(e.target===o) o.classList.remove('active'); });
});
</script>

</body>
</html>
