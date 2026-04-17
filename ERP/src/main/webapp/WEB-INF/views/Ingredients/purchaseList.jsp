<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>발주 내역 | ERP CAFE</title>
    <link rel="stylesheet" href="/css/header.css"/>
    <link rel="stylesheet" href="/css/Ingredients/stock.css"/>
</head>
<body>

<jsp:include page="/WEB-INF/views/header.jsp"/>

<div class="content">

    <div class="page-header">
        <div class="page-title-wrap">
            <span class="page-icon">📋</span>
            <div>
                <h1 class="page-title">발주 내역</h1>
                <p class="page-sub">재고관리 &gt; 발주 내역</p>
            </div>
        </div>
        <button class="btn btn-primary" onclick="location.href='/inventory/order'">+ 발주 등록</button>
    </div>

    <%-- 상태별 요약 --%>
    <div class="stat-row">
        <div class="stat-card">
            <div class="stat-icon blue">📋</div>
            <div class="stat-info">
                <div class="label">전체 발주</div>
                <div class="value">${result.totalCount}건</div>
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

    <%-- 검색 --%>
    <div class="filter-bar">
        <div></div>
        <div class="search-box">
            <input type="text" id="keywordInput" placeholder="거래처명 검색..."
                   value="${keyword}" onkeydown="if(event.key==='Enter') doSearch()">
            <button class="btn btn-edit" onclick="doSearch()">🔍 검색</button>
            <c:if test="${not empty keyword}">
                <button class="btn btn-cancel"
                        onclick="location.href='/inventory/order/history?page=1&size=${size}'">✕ 초기화</button>
            </c:if>
        </div>
    </div>

    <div class="table-card">
        <div class="table-card-header">
            <h3>발주 목록</h3>
            <span style="font-size:0.82rem; color:var(--text-muted);">
                총 ${result.totalCount}건 중 ${result.list.size()}건 표시
            </span>
        </div>
        <table class="data-table">
            <thead>
                <tr>
                    <th>번호</th>
                    <th>거래처명</th>
                    <th>총 금액</th>
                    <th>발주일</th>
                    <th>입고일</th>
                    <th>상태</th>
                    <th>비고</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty result.list}">
                    <tr class="empty-row"><td colspan="8">발주 내역이 없습니다.</td></tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="p" items="${result.list}">
                    <tr class="clickable-row"
                        onclick="openDetailModal(${p.id}, '${p.supplier}', '${p.ordered_at}')">
                        <td>${p.id}</td>
                        <td><strong>${p.supplier}</strong></td>
                        <td><fmt:formatNumber value="${p.total_cost}" pattern="#,###"/>원</td>
                        <td>${p.ordered_at}</td>
                        <td>${empty p.received_at ? '-' : p.received_at}</td>
                        <td>
                            <c:choose>
                                <c:when test="${p.status == 'ordered'}">
                                    <span class="badge badge-warning">발주완료</span>
                                </c:when>
                                <c:when test="${p.status == 'received'}">
                                    <span class="badge badge-normal">입고완료</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-low">취소</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>${empty p.note ? '-' : p.note}</td>
                        <td onclick="event.stopPropagation()">
                            <c:if test="${p.status == 'ordered'}">
                                <button class="btn btn-edit"
                                    data-id="${p.id}"
                                    data-supplier="${p.supplier}"
                                    data-supplierid="${p.supplier_id}"
                                    data-status="${p.status}"
                                    data-received="${p.received_at}"
                                    data-note="${p.note}"
                                    data-ordered="${p.ordered_at}"
                                    onclick="openEditModal(this)">
                                    수정
                                </button>
                                <form action="/inventory/order/cancel/${p.id}" method="post" style="display:inline"
                                      onsubmit="return confirm('발주를 취하하시겠습니까?')">
                                    <input type="hidden" name="page" value="${result.page}">
                                    <button type="submit" class="btn btn-delete">취하</button>
                                </form>
                            </c:if>
                            <c:if test="${p.status == 'cancelled' or p.status == 'received'}">
                                <span style="color:var(--text-muted); font-size:0.82rem;">처리완료</span>
                            </c:if>
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
                    <option value="10" ${size == 10 ? 'selected' : ''}>10개씩</option>
                    <option value="20" ${size == 20 ? 'selected' : ''}>20개씩</option>
                    <option value="50" ${size == 50 ? 'selected' : ''}>50개씩</option>
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
            <div style="font-size:0.8rem; color:var(--text-muted);">총 ${result.totalCount}건</div>
        </div>
    </div>
</div>

<%-- ===== 발주 상세 모달 ===== --%>
<div class="modal-overlay" id="detailModal">
    <div class="modal" style="width:640px; max-width:95vw;">
        <div class="modal-title">
            📦 발주 상세
            <span id="detailInfo" style="font-size:0.82rem; font-weight:400;
                  color:var(--text-muted); margin-left:10px;"></span>
        </div>
        <div id="detailContent" style="min-height:160px;"></div>
        <div class="modal-footer">
            <button type="button" class="btn btn-cancel" onclick="closeModal('detailModal')">닫기</button>
        </div>
    </div>
</div>

<%-- ===== 수정 모달 ===== --%>
<div class="modal-overlay" id="editModal">
    <div class="modal">
        <div class="modal-title">✏️ 발주 수정</div>
        <form action="/inventory/order/update" method="post">
            <input type="hidden" name="id"          id="edit_id">
            <input type="hidden" name="page"        value="${result.page}">
            <input type="hidden" name="status"      id="edit_status">
            <input type="hidden" name="supplier_id" id="edit_supplier_id">
            <div class="form-row">
                <div class="form-group">
                    <label>거래처명</label>
                    <input type="text" id="edit_supplier" readonly
                           style="background:#f8f9ff; color:var(--primary);
                                  font-weight:600; cursor:default;">
                </div>
                <div class="form-group">
                    <label>
                        입고일
                        <span style="font-size:0.72rem; color:var(--text-muted); font-weight:400;">
                            (입력 시 자동으로 입고완료 처리)
                        </span>
                    </label>
                    <input type="date" name="received_at" id="edit_received_at"
                           onchange="handleReceivedDate(this.value)">
                </div>
            </div>
            <div class="form-group">
                <label>비고</label>
                <input type="text" name="note" id="edit_note">
            </div>
            <div class="form-group">
                <label>현재 상태</label>
                <div id="edit_status_display"
                     style="padding:8px 12px; border-radius:var(--radius-sm);
                            font-size:0.88rem; font-weight:600; display:inline-block;">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-cancel" onclick="closeModal('editModal')">취소</button>
                <button type="submit" class="btn btn-primary">저장</button>
            </div>
        </form>
    </div>
</div>


<script>
var currentKeyword = '${keyword}';
var currentSize    = ${size};

function goPage(p) {
    var url = '/inventory/order/history?page=' + p + '&size=' + currentSize;
    if (currentKeyword) url += '&keyword=' + encodeURIComponent(currentKeyword);
    location.href = url;
}
function doSearch() {
    var kw  = document.getElementById('keywordInput').value.trim();
    var url = '/inventory/order/history?page=1&size=' + currentSize;
    if (kw) url += '&keyword=' + encodeURIComponent(kw);
    location.href = url;
}
function changeSize(s) {
    var url = '/inventory/order/history?page=1&size=' + s;
    if (currentKeyword) url += '&keyword=' + encodeURIComponent(currentKeyword);
    location.href = url;
}

function openModal(id)  { document.getElementById(id).classList.add('active'); }
function closeModal(id) { document.getElementById(id).classList.remove('active'); }

/* ===== 발주 상세 모달 ===== */
function openDetailModal(purchaseId, supplier, orderedAt) {
    document.getElementById('detailInfo').innerText = supplier + ' · ' + orderedAt;
    document.getElementById('detailContent').innerHTML =
        '<div style="text-align:center; padding:40px; color:var(--text-muted);">로딩 중...</div>';
    openModal('detailModal');

    fetch('/inventory/order/items/' + purchaseId)
        .then(function(res) { return res.json(); })
        .then(function(items) {
            if (!items || items.length === 0) {
                document.getElementById('detailContent').innerHTML =
                    '<div style="text-align:center; padding:40px; color:var(--text-muted);">등록된 원재료가 없습니다.</div>';
                return;
            }
            var total = 0;
            var html  = '<table class="detail-table">'
                + '<thead><tr>'
                + '<th>원재료명</th>'
                + '<th>단위</th>'
                + '<th>수량</th>'
                + '<th>단가</th>'
                + '<th>소계</th>'
                + '</tr></thead><tbody>';

            items.forEach(function(item) {
                total += Number(item.subtotal);
                html += '<tr>'
                    + '<td><strong>' + item.ingredient_name + '</strong></td>'
                    + '<td>' + item.ingredient_unit + '</td>'
                    + '<td>' + item.qty + '</td>'
                    + '<td>' + Number(item.unit_cost).toLocaleString() + '원</td>'
                    + '<td><strong>' + Number(item.subtotal).toLocaleString() + '원</strong></td>'
                    + '</tr>';
            });

            html += '</tbody></table>';
            html += '<div class="detail-total">'
                + '<span>총 발주금액</span>'
                + '<span class="total-amount">' + total.toLocaleString() + '원</span>'
                + '</div>';

            document.getElementById('detailContent').innerHTML = html;
        })
        .catch(function() {
            document.getElementById('detailContent').innerHTML =
                '<div style="text-align:center; padding:40px; color:var(--accent-red);">데이터를 불러오지 못했습니다.</div>';
        });
}

/* ===== 수정 모달 - data-* 방식 ===== */
function openEditModal(btn) {
    var id          = btn.dataset.id;
    var supplier    = btn.dataset.supplier;
    var supplierId  = btn.dataset.supplierid;
    var status      = btn.dataset.status;
    var received_at = btn.dataset.received;
    var note        = btn.dataset.note;
    var ordered_at  = btn.dataset.ordered;

    document.getElementById('edit_id').value          = id;
    document.getElementById('edit_supplier').value    = supplier;
    document.getElementById('edit_supplier_id').value = supplierId;
    document.getElementById('edit_status').value      = status;
    document.getElementById('edit_received_at').value = (received_at === 'null' ? '' : received_at);
    document.getElementById('edit_note').value        = (note === 'null' ? '' : note);

    // 발주일 이전 날짜 선택 불가
    document.getElementById('edit_received_at').min = ordered_at;

    // 현재 상태 표시
    handleReceivedDate(document.getElementById('edit_received_at').value);
    openModal('editModal');
}

function handleReceivedDate(val) {
    var statusEl  = document.getElementById('edit_status');
    var displayEl = document.getElementById('edit_status_display');
    if (val) {
        statusEl.value         = 'received';
        displayEl.innerText    = '✅ 입고완료';
        displayEl.style.background = 'var(--accent-green-light)';
        displayEl.style.color      = 'var(--accent-green)';
    } else {
        statusEl.value         = 'ordered';
        displayEl.innerText    = '📋 발주완료';
        displayEl.style.background = 'var(--accent-orange-light)';
        displayEl.style.color      = 'var(--accent-orange)';
    }
}

document.querySelectorAll('.modal-overlay').forEach(function(o) {
    o.addEventListener('click', function(e) { if(e.target===o) o.classList.remove('active'); });
});
</script>

</body>
</html>
