<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>주문 내역</title>
    <link rel="stylesheet" href="/css/header.css" />
    <link rel="stylesheet" href="/css/Order/OrderDetail.css" />
</head>
<body>
    <jsp:include page="/WEB-INF/views/header.jsp"/>
    <div class="content">

        <div class="page-header">
            <div class="page-title-wrap">
                <span class="page-icon">📑</span>
                <div>
                    <h1 class="page-title">주문 내역</h1>
                    <p class="page-sub">주문관리 &gt; 주문 내역</p>
                </div>
            </div>
            <button class="btn-add" onclick="openAddPopup()">+ 주문 추가</button>
        </div>

        <%-- ===== 필터 바 ===== --%>
        <div class="filter-bar">
            <%-- 상태 탭 --%>
            <div class="status-tabs">
                <button class="status-tab-btn ${empty status ? 'active' : ''}"
                        onclick="goFilter('','${keyword}','${dateFrom}','${dateTo}')">전체</button>
                <button class="status-tab-btn ${status == '대기' ? 'active' : ''}"
                        onclick="goFilter('대기','${keyword}','${dateFrom}','${dateTo}')">⏳ 대기</button>
                <button class="status-tab-btn ${status == '완료' ? 'active' : ''}"
                        onclick="goFilter('완료','${keyword}','${dateFrom}','${dateTo}')">✅ 완료</button>
                <button class="status-tab-btn ${status == '취소' ? 'active' : ''}"
                        onclick="goFilter('취소','${keyword}','${dateFrom}','${dateTo}')">❌ 취소</button>
            </div>

            <%-- 날짜 + 검색 --%>
            <div class="filter-right">
                <div class="date-range">
                    <input type="date" id="dateFrom" value="${dateFrom}"
                           onchange="goFilter('${status}','${keyword}',this.value,document.getElementById('dateTo').value)">
                    <span style="color:#aaa;">~</span>
                    <input type="date" id="dateTo" value="${dateTo}"
                           onchange="goFilter('${status}','${keyword}',document.getElementById('dateFrom').value,this.value)">
                    <c:if test="${not empty dateFrom or not empty dateTo}">
                        <button class="btn-filter-reset"
                                onclick="goFilter('${status}','${keyword}','','')">날짜 초기화</button>
                    </c:if>
                </div>
                <div class="search-wrap">
                    <input type="text" id="keywordInput" placeholder="주문번호 / 결제수단 검색..."
                           value="${keyword}"
                           onkeydown="if(event.key==='Enter') doSearch()">
                    <button class="btn-search" onclick="doSearch()">🔍</button>
                    <c:if test="${not empty keyword}">
                        <button class="btn-filter-reset"
                                onclick="goFilter('${status}','','${dateFrom}','${dateTo}')">✕</button>
                    </c:if>
                </div>
            </div>
        </div>

        <%-- ===== 테이블 ===== --%>
        <table class="order-table">
            <thead>
                <tr>
                    <th>주문번호</th>
                    <th>할인 전 총액</th>
                    <th>할인 금액</th>
                    <th>실제 결제 금액</th>
                    <th>결제수단</th>
                    <th>상태</th>
                    <th>요청사항</th>
                    <th>주문일시</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty result.list}">
                        <tr><td colspan="9" class="no-data">등록된 주문이 없습니다.</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="order" items="${result.list}">
                            <tr class="clickable-row"
                                onclick="openDetailModal(${order.id}, '${order.orderNo}', '${order.status}', ${order.discountAmount}, ${order.finalAmount})">
                                <td>${order.orderNo}</td>
                                <td><fmt:formatNumber value="${order.totalAmount}" pattern="#,###"/>원</td>
                                <td><fmt:formatNumber value="${order.discountAmount}" pattern="#,###"/>원</td>
                                <td><fmt:formatNumber value="${order.finalAmount}" pattern="#,###"/>원</td>
                                <td>${order.paymentType}</td>
                                <td><span class="status-badge status-${order.status}">${order.status}</span></td>
                                <td>${empty order.note ? '-' : order.note}</td>
                                <td>${order.orderedAtFormatted}</td>
                                <td class="action-cell" onclick="event.stopPropagation()">
                                    <button class="btn-action btn-status"
                                            onclick="openStatusPopup(${order.id}, '${order.status}')">상태변경</button>

                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>

        <%-- ===== 페이지네이션 ===== --%>
        <div class="order-pagination">
            <div class="page-size-wrap">
                <select onchange="changeSize(this.value)">
                    <option value="10" ${size == 10 ? 'selected' : ''}>10개씩</option>
                    <option value="20" ${size == 20 ? 'selected' : ''}>20개씩</option>
                    <option value="50" ${size == 50 ? 'selected' : ''}>50개씩</option>
                </select>
            </div>

            <div class="page-nav-wrap">
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

            <div class="page-info">총 ${result.totalCount}건</div>
        </div>

    </div>

    <%-- ===== 주문 추가 팝업 ===== --%>
    <div class="popup-overlay" id="popupOverlay" onclick="closePopupOutside(event)">
        <div class="popup-box popup-wide">
            <div class="popup-header">
                <h3>주문 추가</h3>
                <button type="button" class="btn-close" onclick="closePopup()">✕</button>
            </div>
            <form id="orderForm" action="/orderAdd" method="post">
                <div class="popup-body">
                    <div class="form-row">
                        <label>주문번호</label>
                        <input type="text" name="orderNo" id="orderNo" readonly class="input-readonly"/>
                    </div>
                    <div class="form-row">
                        <label>메뉴 선택</label>
                        <div class="menu-grid">
                            <c:forEach var="menu" items="${menuList}">
                                <div class="menu-card" onclick="addToCart(${menu.id}, '${menu.name}', ${menu.price})">
                                    <div class="menu-name">${menu.name}</div>
                                    <div class="menu-price"><fmt:formatNumber value="${menu.price}" pattern="#,###"/>원</div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                    <div class="form-row">
                        <label>장바구니 <span id="cartCount" class="cart-count">0개</span></label>
                        <div class="cart-box">
                            <div class="cart-row cart-header">
                                <div class="col-name">메뉴</div>
                                <div class="col-price">단가</div>
                                <div class="col-qty">수량</div>
                                <div class="col-sub">소계</div>
                                <div class="col-del"></div>
                            </div>
                            <div id="cartBody">
                                <div class="cart-empty">메뉴를 선택하세요</div>
                            </div>
                        </div>
                        <div id="cartHiddenInputs"></div>
                    </div>
                    <div class="form-row">
                        <label>할인 전 총액 (원)</label>
                        <input type="number" name="totalAmount" id="totalAmount" readonly class="input-readonly" value="0"/>
                    </div>
                    <div class="form-row">
                        <label>할인 항목</label>
                        <div class="discount-options">
                            <button type="button" class="btn-discount" onclick="applyDiscount(this, 5)">멤버십 할인 (5%)</button>
                            <button type="button" class="btn-discount" onclick="applyDiscount(this, 10)">쿠폰 할인 (10%)</button>
                            <button type="button" class="btn-discount" onclick="applyDiscount(this, 20)">VIP 할인 (20%)</button>
                        </div>
                    </div>
                    <div class="form-row">
                        <label>할인 금액 (원)</label>
                        <input type="number" name="discountAmount" id="discountAmount" readonly class="input-readonly" value="0"/>
                    </div>
                    <div class="form-row">
                        <label>실제 결제 금액 (원)</label>
                        <input type="number" name="finalAmount" id="finalAmount" readonly class="input-readonly" value="0"/>
                    </div>
                    <div class="form-row">
                        <label>결제수단</label>
                        <select name="paymentType" id="paymentType">
                            <option value="카드">카드</option>
                            <option value="현금">현금</option>
                            <option value="카카오페이">카카오페이</option>
                            <option value="네이버페이">네이버페이</option>
                            <option value="토스페이">토스</option>
                        </select>
                    </div>
                    <div class="form-row">
                        <label>요청사항</label>
                        <textarea name="note" id="note" placeholder="요청사항을 입력하세요"></textarea>
                    </div>
                </div>
                <div class="popup-footer">
                    <button type="button" class="btn-cancel" onclick="closePopup()">취소</button>
                    <button type="button" class="btn-submit" onclick="submitOrder()">주문 등록</button>
                </div>
            </form>
        </div>
    </div>

    <%-- ===== 주문 상세 모달 ===== --%>
    <div class="popup-overlay" id="detailModal" style="display:none;" onclick="if(event.target===this)this.style.display='none'">
        <div class="popup-box" style="width:540px; max-width:95vw;">
            <div class="popup-header">
                <h3 style="display:flex; align-items:center; gap:8px;">
                    📋 주문 상세
                    <span id="detailOrderNo" style="font-size:0.85rem; font-weight:400;
                          color:var(--text-muted); margin-left:8px;"></span>
                </h3>
                <button class="btn-close" onclick="document.getElementById('detailModal').style.display='none'">✕</button>
            </div>
            <div class="popup-body">
                <div id="detailContent">
                    <div style="text-align:center; padding:30px; color:var(--text-muted);">로딩 중...</div>
                </div>
            </div>
            <div class="popup-footer">
                <button type="button" class="btn-cancel" onclick="document.getElementById('detailModal').style.display='none'">닫기</button>
            </div>
        </div>
    </div>

    <%-- ===== 상태 변경 팝업 ===== --%>
    <div class="popup-overlay" id="statusOverlay" onclick="closeStatusPopupOutside(event)">
        <div class="popup-box" style="width:360px;">
            <div class="popup-header">
                <h3>상태 변경</h3>
                <button type="button" class="btn-close" onclick="closeStatusPopup()">✕</button>
            </div>
            <form id="statusForm" action="/orderStatus" method="post">
                <div class="popup-body">
                    <input type="hidden" name="id"   id="statusOrderId"/>
                    <input type="hidden" name="page" value="${result.page}"/>
                    <div class="form-row">
                        <label>변경할 상태 선택</label>
                        <div class="status-options">
                            <button type="button" class="btn-status-opt" data-value="완료"  onclick="selectStatus(this)">완료</button>
                            <button type="button" class="btn-status-opt" data-value="취소"  onclick="selectStatus(this)">취소</button>
                        </div>
                        <input type="hidden" name="status" id="selectedStatus"/>
                    </div>
                </div>
                <div class="popup-footer">
                    <button type="button" class="btn-cancel" onclick="closeStatusPopup()">닫기</button>
                    <button type="button" class="btn-submit" onclick="submitStatus()">변경</button>
                </div>
            </form>
        </div>
    </div>



    <script>
    var currentStatus   = '${status}';
    var currentKeyword  = '${keyword}';
    var currentDateFrom = '${dateFrom}';
    var currentDateTo   = '${dateTo}';
    var currentSize     = ${size};

    function goPage(p) {
        var url = buildUrl(p, currentSize, currentStatus, currentKeyword, currentDateFrom, currentDateTo);
        location.href = url;
    }
    function goFilter(st, kw, df, dt) {
        var url = buildUrl(1, currentSize, st, kw, df, dt);
        location.href = url;
    }
    function doSearch() {
        var kw = document.getElementById('keywordInput').value.trim();
        goFilter(currentStatus, kw, currentDateFrom, currentDateTo);
    }
    function changeSize(s) {
        var url = buildUrl(1, s, currentStatus, currentKeyword, currentDateFrom, currentDateTo);
        location.href = url;
    }
    function buildUrl(page, size, st, kw, df, dt) {
        var url = '/order?page=' + page + '&size=' + size;
        if (st) url += '&status='   + encodeURIComponent(st);
        if (kw) url += '&keyword='  + encodeURIComponent(kw);
        if (df) url += '&dateFrom=' + df;
        if (dt) url += '&dateTo='   + dt;
        return url;
    }

    /* ===== 주문 추가 팝업 ===== */
    var cart = [];
    var selectedDiscountRate = 0;

    function openAddPopup() {
        cart = [];
        selectedDiscountRate = 0;
        generateOrderNo();
        renderCart();
        document.querySelectorAll('.btn-discount').forEach(function(b) { b.classList.remove('active'); });
        document.getElementById('totalAmount').value    = '0';
        document.getElementById('discountAmount').value = '0';
        document.getElementById('finalAmount').value    = '0';
        document.getElementById('paymentType').value    = '카드';
        document.getElementById('note').value           = '';
        document.getElementById('popupOverlay').style.display = 'flex';
    }
    function closePopup() { document.getElementById('popupOverlay').style.display = 'none'; }
    function closePopupOutside(e) { if (e.target === document.getElementById('popupOverlay')) closePopup(); }

    function generateOrderNo() {
        var now  = new Date();
        var date = now.getFullYear().toString()
                 + String(now.getMonth() + 1).padStart(2, '0')
                 + String(now.getDate()).padStart(2, '0');
        var rand = String(Math.floor(1000 + Math.random() * 9000));
        document.getElementById('orderNo').value = 'ORD-' + date + '-' + rand;
    }

    function addToCart(menuId, menuName, unitPrice) {
        menuId = Number(menuId);
        var exist = cart.find(function(c) { return c.menuId === menuId; });
        if (exist) { exist.qty++; }
        else { cart.push({ menuId: menuId, menuName: menuName, unitPrice: unitPrice, qty: 1 }); }
        renderCart();
    }
    function changeQty(menuId, delta) {
        menuId = Number(menuId);
        var item = cart.find(function(c) { return c.menuId === menuId; });
        if (!item) return;
        item.qty += delta;
        if (item.qty <= 0) cart = cart.filter(function(c) { return c.menuId !== menuId; });
        renderCart();
    }
    function removeCart(menuId) {
        menuId = Number(menuId);
        cart = cart.filter(function(c) { return c.menuId !== menuId; });
        renderCart();
    }
    function renderCart() {
        var body   = document.getElementById('cartBody');
        var hidden = document.getElementById('cartHiddenInputs');
        hidden.innerHTML = '';
        if (cart.length === 0) {
            body.innerHTML = '<div class="cart-empty">메뉴를 선택하세요</div>';
            document.getElementById('cartCount').textContent = '0개';
            updateTotal();
            return;
        }
        body.innerHTML = '';
        cart.forEach(function(item) {
            var subtotal = item.unitPrice * item.qty;
            var row = document.createElement('div');
            row.className = 'cart-row cart-item';
            row.innerHTML =
                '<div class="col-name">' + item.menuName + '</div>' +
                '<div class="col-price">' + item.unitPrice.toLocaleString() + '원</div>' +
                '<div class="col-qty">' +
                    '<button type="button" onclick="changeQty(' + item.menuId + ', -1)">－</button>' +
                    '<span>' + item.qty + '</span>' +
                    '<button type="button" onclick="changeQty(' + item.menuId + ', 1)">＋</button>' +
                '</div>' +
                '<div class="col-sub">' + subtotal.toLocaleString() + '원</div>' +
                '<div class="col-del"><button type="button" class="btn-remove" onclick="removeCart(' + item.menuId + ')">✕</button></div>';
            body.appendChild(row);
            hidden.innerHTML +=
                '<input type="hidden" name="menuId"    value="' + item.menuId    + '">' +
                '<input type="hidden" name="qty"       value="' + item.qty       + '">' +
                '<input type="hidden" name="unitPrice" value="' + item.unitPrice + '">';
        });
        document.getElementById('cartCount').textContent = cart.length + '개';
        updateTotal();
    }
    function applyDiscount(btn, rate) {
        if (btn.classList.contains('active')) {
            btn.classList.remove('active');
            selectedDiscountRate = 0;
        } else {
            document.querySelectorAll('.btn-discount').forEach(function(b) { b.classList.remove('active'); });
            btn.classList.add('active');
            selectedDiscountRate = rate;
        }
        updateTotal();
    }
    function updateTotal() {
        var total    = cart.reduce(function(s, c) { return s + c.unitPrice * c.qty; }, 0);
        var discount = Math.floor(total * selectedDiscountRate / 100);
        document.getElementById('totalAmount').value    = total;
        document.getElementById('discountAmount').value = discount;
        document.getElementById('finalAmount').value    = total - discount;
    }
    function submitOrder() {
        if (cart.length === 0) { alert('메뉴를 1개 이상 선택해주세요.'); return; }
        document.getElementById('orderForm').submit();
    }

    /* ===== 상태 변경 팝업 ===== */
    function openStatusPopup(orderId, curStatus) {
        document.getElementById('statusOrderId').value  = orderId;
        document.getElementById('selectedStatus').value = curStatus;
        document.querySelectorAll('.btn-status-opt').forEach(function(b) {
            b.classList.toggle('active', b.getAttribute('data-value') === curStatus);
        });
        document.getElementById('statusOverlay').style.display = 'flex';
    }
    function closeStatusPopup() { document.getElementById('statusOverlay').style.display = 'none'; }
    function closeStatusPopupOutside(e) { if (e.target === document.getElementById('statusOverlay')) closeStatusPopup(); }
    function selectStatus(btn) {
        document.querySelectorAll('.btn-status-opt').forEach(function(b) { b.classList.remove('active'); });
        btn.classList.add('active');
        document.getElementById('selectedStatus').value = btn.getAttribute('data-value');
    }
    function submitStatus() {
        if (!document.getElementById('selectedStatus').value) { alert('상태를 선택해주세요.'); return; }
        document.getElementById('statusForm').submit();
    }

    
    /* ===== 주문 상세 모달 ===== */
    function openDetailModal(orderId, orderNo, status, discountAmount, finalAmount) {
        document.getElementById('detailOrderNo').innerText = orderNo;
        document.getElementById('detailContent').innerHTML =
            '<div style="text-align:center; padding:30px; color:var(--text-muted);">로딩 중...</div>';
        document.getElementById('detailModal').style.display = 'flex';

        fetch('/order/' + orderId + '/items')
            .then(function(res) { return res.json(); })
            .then(function(items) {
                if (!items || items.length === 0) {
                    document.getElementById('detailContent').innerHTML =
                        '<div style="text-align:center; padding:30px; color:var(--text-muted);">주문 항목이 없습니다.</div>';
                    return;
                }
                var total = 0;
                var html  = '<table style="width:100%; border-collapse:collapse; font-size:0.88rem;">'
                    + '<thead><tr style="background:#fafafa;">'
                    + '<th style="padding:10px 14px; text-align:left; border-bottom:1.5px solid #f3f4f6; font-size:0.75rem; color:#9ca3af; font-weight:600; text-transform:uppercase;">메뉴명</th>'
                    + '<th style="padding:10px 14px; text-align:center; border-bottom:1.5px solid #f3f4f6; font-size:0.75rem; color:#9ca3af; font-weight:600; text-transform:uppercase;">수량</th>'
                    + '<th style="padding:10px 14px; text-align:right; border-bottom:1.5px solid #f3f4f6; font-size:0.75rem; color:#9ca3af; font-weight:600; text-transform:uppercase;">단가</th>'
                    + '<th style="padding:10px 14px; text-align:right; border-bottom:1.5px solid #f3f4f6; font-size:0.75rem; color:#9ca3af; font-weight:600; text-transform:uppercase;">소계</th>'
                    + '</tr></thead><tbody>';

                items.forEach(function(item) {
                    total += item.subtotal;
                    html += '<tr style="border-bottom:1px solid #f3f4f6;">'
                        + '<td style="padding:12px 14px; text-align:left;"><strong>' + (item.menuName || '-') + '</strong></td>'
                        + '<td style="padding:12px 14px; text-align:center;">' + item.qty + '</td>'
                        + '<td style="padding:12px 14px; text-align:right;">' + Number(item.unitPrice).toLocaleString() + '원</td>'
                        + '<td style="padding:12px 14px; text-align:right;"><strong>' + Number(item.subtotal).toLocaleString() + '원</strong></td>'
                        + '</tr>';
                });

                html += '</tbody></table>';
                html += '<div style="padding:12px 14px; background:#f8f9ff; border-top:1px solid #f3f4f6; border-radius:0 0 8px 8px;">';
                if (discountAmount > 0) {
                    html += '<div style="display:flex; justify-content:space-between; font-size:0.85rem; color:#9ca3af; margin-bottom:6px;">'
                        + '<span>소계</span><span>' + Number(total).toLocaleString() + '원</span></div>';
                    html += '<div style="display:flex; justify-content:space-between; font-size:0.85rem; color:#ef4444; margin-bottom:8px;">'
                        + '<span>할인</span><span>-' + Number(discountAmount).toLocaleString() + '원</span></div>';
                }
                html += '<div style="display:flex; justify-content:space-between; font-weight:700; color:#5b6ef5; font-size:1rem;">'
                    + '<span>최종 결제</span>'
                    + '<span style="font-family:Outfit,sans-serif;">' + Number(finalAmount).toLocaleString() + '원</span></div>';
                html += '</div>';

                document.getElementById('detailContent').innerHTML = html;
            })
            .catch(function() {
                document.getElementById('detailContent').innerHTML =
                    '<div style="text-align:center; padding:30px; color:#ef4444;">불러오기 실패</div>';
            });
    }

    function closeModal(id) {
        document.getElementById(id).style.display = 'none';
    }

    document.getElementById('detailModal').addEventListener('click', function(e) {
        if (e.target === this) this.style.display = 'none';
    });

    </script>
</body>
</html>
