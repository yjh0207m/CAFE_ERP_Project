<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>제품 관리</title>
    <link rel="stylesheet" href="/css/header.css" />
    <link rel="stylesheet" href="/css/Product/product.css" />
</head>

<body>
<jsp:include page="/WEB-INF/views/header.jsp"/>

<div class="content">

    <div class="page-header">
        <div class="page-title-wrap">
            <span class="page-icon">🍽️</span>
            <div>
                <h1 class="page-title">제품 관리</h1>
                <p class="page-sub">메뉴관리 &gt; 제품 관리</p>
            </div>
        </div>
        <button class="register-btn" onclick="openProductModal()">+ 제품등록</button>
    </div>
    
   <div class="summary-box">

    <div class="summary-card">
        <div class="summary-title">전체 품목</div>
        <div class="summary-value">📦 ${totalCount}개</div>
    </div>

    <div class="summary-card">
        <div class="summary-title">현재 페이지</div>
        <div class="summary-value">📄 ${currentPage} / ${totalPages}</div>
    </div>

    <div class="summary-card">
        <div class="summary-title">페이지당 항목</div>
        <div class="summary-value">📊 ${size}개</div>
    </div>

</div>

<!-- 카테고리 필터 -->
<div class="filter-wrapper">
    <div class="category-filter">
    <button class="cat-btn ${selectedCategory == null ? 'active' : ''}"
            onclick="location.href='/product/menu?page=1&size=${size}'">
        📦 전체
    </button>

    <c:forEach var="cat" items="${categoryList}">
        <button class="cat-btn ${selectedCategory == cat.id ? 'active' : ''}"
                onclick="location.href='/product/menu?page=1&size=${size}&categoryId=${cat.id}'">
            
            <c:choose>
            <c:when test="${cat.name == '커피'}">&#129380; ${cat.name}</c:when>
            <c:when test="${cat.name == '논커피'}">&#129380; ${cat.name}</c:when>
            <c:when test="${cat.name == '디저트'}">&#127856; ${cat.name}</c:when>
            <c:when test="${cat.name == '스무디/프라푸치노'}">&#127861; ${cat.name}</c:when>
            <c:when test="${cat.name == '티/한방'}">&#127845; ${cat.name}</c:when>
            <c:when test="${cat.name == '에이드'}">&#127865; ${cat.name}</c:when>
            <c:when test="${cat.name == '베이커리'}">&#129360; ${cat.name}</c:when>
            <c:when test="${cat.name == '샌드위치/브런치'}">&#129386; ${cat.name}</c:when>
            <c:when test="${cat.name == '티'}">&#129750; ${cat.name}</c:when>
            <c:when test="${cat.name == '사람'}">&#128100; ${cat.name}</c:when>
            <c:otherwise>&#10024; ${cat.name}</c:otherwise> 
        </c:choose>
            
        </button>
    </c:forEach>
</div>

    <div class="search-box">
        <input type="text" id="searchInput" placeholder="제품 검색..." 
               value="${keyword}" onkeyup="handleEnter(event)">
        <button onclick="searchProduct()">🔍 검색</button>
    </div>
</div>

    <div class="table-box">
        <table>
            <thead>
                <tr>
                    <th>제품번호</th>
                    <th>카테고리</th>
                    <th>제품명</th>
                    <th>판매가</th>
                    <th>원가</th>
                    <th>판매여부</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="menu" items="${menuList}">
                <tr onclick="location.href='/product/recipe/${menu.id}'" style="cursor:pointer;">
                    <td>${menu.id}</td>
                    <td>${menu.categoryName}</td>
                    <td>${menu.name}</td>
                    <td>${menu.price}원</td>
                    <td>${menu.cost}원</td>
                    <td>
                        <span class="badge ${menu.isAvailable == 1 ? 'badge-on' : 'badge-off'}">
                            ${menu.isAvailable == 1 ? '판매중' : '판매중지'}
                        </span>
                    </td>
                    <td>
                        <button class="btn update"
                            onclick="event.stopPropagation(); openUpdateModal(${menu.id}, ${menu.categoryId}, '${menu.name}', '${menu.description}', ${menu.price}, ${menu.cost}, ${menu.isAvailable})">수정</button>
                        <button class="btn delete"
                            onclick="event.stopPropagation(); openDeleteModal(${menu.id}, '${menu.name}')">삭제</button>
                    </td>
                </tr>
                </c:forEach>
            </tbody>
        </table>

        <!-- 테이블 하단: 좌측 size 선택 + 우측 총 개수 -->
        <div style="display:flex; align-items:center; justify-content:space-between; padding: 10px 4px;">
            <select onchange="changeSize(this.value)"
                    style="padding:6px 12px; border-radius:8px; border:1px solid #ddd;
                           font-size:14px; cursor:pointer; background:#fff;">
                <option value="10" ${size == 10 ? 'selected' : ''}>10개씩</option>
                <option value="20" ${size == 20 ? 'selected' : ''}>20개씩</option>
                <option value="50" ${size == 50 ? 'selected' : ''}>50개씩</option>
            </select>
            <div class="total-count">총 ${totalCount}개</div>
        </div>

    </div>


    <div class="paging-box">
        <div class="page-btns">

            <c:if test="${currentPage > 1}">
                <button class="page-btn"
                    onclick="location.href='/product/menu?page=${currentPage-1}&size=${size}&categoryId=${selectedCategory}&keyword=${keyword}'">
                    ◀
                </button>
            </c:if>

            <c:forEach begin="1" end="${totalPages}" var="i">
                <button 
                    class="page-btn ${i == currentPage ? 'active' : ''}"
                    onclick="location.href='/product/menu?page=${i}&size=${size}&categoryId=${selectedCategory}&keyword=${keyword}'">
                    ${i}
                </button>
            </c:forEach>

            <c:if test="${currentPage < totalPages}">
                <button class="page-btn"
                    onclick="location.href='/product/menu?page=${currentPage+1}&size=${size}&categoryId=${selectedCategory}&keyword=${keyword}'">
                    ▶
                </button>
            </c:if>

        </div>
    </div>

</div>

<!-- ===================== 제품등록 모달 ===================== -->
<div class="modal-overlay" id="productModal">
    <div class="modal-box">
        <div class="modal-header">
            <div class="modal-title">제품 등록</div>
            <button class="modal-close" onclick="closeProductModal()">✕</button>
        </div>
        <form action="/productInsert" method="post">
            <div class="modal-body">
                <div class="input-row">
                    <label>카테고리</label>
                    <div class="input-with-btn">
                        <select name="category_id" id="categorySelect" required>
                            <option value="">카테고리 선택</option>
                            <c:forEach var="cat" items="${categoryList}">
                                <option value="${cat.id}">${cat.name}</option>
                            </c:forEach>
                        </select>
                        <button type="button" class="small-btn" onclick="switchToCategoryModal()">+ 카테고리 등록</button>
                    </div>
                </div>
                <div class="input-row">
                    <label>제품명</label>
                    <input type="text" name="name" placeholder="제품명 입력" required>
                </div>
                <div class="input-row">
                    <label>설명</label>
                    <input type="text" name="description" placeholder="제품 설명 입력">
                </div>
                <div class="input-row">
                    <label>판매가</label>
                    <input type="number" name="price" placeholder="0" min="0" required>
                </div>
                <div class="input-row">
                    <label>판매 여부</label>
                    <select name="isAvailable">
                        <option value="1">판매중</option>
                        <option value="0">판매중지</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="cancel-btn" onclick="closeProductModal()">취소</button>
                <button type="submit" class="submit-btn">등록</button>
            </div>
        </form>
    </div>
</div>

<!-- ===================== 제품수정 모달 ===================== -->
<div class="modal-overlay" id="updateModal">
    <div class="modal-box">
        <div class="modal-header">
            <div class="modal-title">제품 수정</div>
            <button class="modal-close" onclick="closeUpdateModal()">✕</button>
        </div>
        <form action="/productUpdate" method="post">
            <input type="hidden" name="id" id="updateId">
            <div class="modal-body">
                <div class="input-row">
                    <label>카테고리</label>
                    <select name="category_id" id="updateCategoryId" required>
                        <c:forEach var="cat" items="${categoryList}">
                            <option value="${cat.id}">${cat.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="input-row">
                    <label>제품명</label>
                    <input type="text" name="name" id="updateName" required>
                </div>
                <div class="input-row">
                    <label>설명</label>
                    <input type="text" name="description" id="updateDescription">
                </div>
                <div class="input-row">
                    <label>판매가</label>
                    <input type="number" name="price" id="updatePrice" min="0" required>
                </div>
                <div class="input-row">
                    <label>원가</label>
                    <input type="number" name="cost" id="updateCost" min="0" required>
                </div>
                <div class="input-row">
                    <label>판매 여부</label>
                    <select name="isAvailable" id="updateIsAvailable">
                        <option value="1">판매중</option>
                        <option value="0">판매중지</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="cancel-btn" onclick="closeUpdateModal()">취소</button>
                <button type="submit" class="submit-btn">수정</button>
            </div>
        </form>
    </div>
</div>

<!-- ===================== 카테고리 등록 모달 ===================== -->
<div class="modal-overlay" id="categoryModal">
    <div class="modal-box modal-sm">
        <div class="modal-header">
            <div class="modal-title">카테고리 등록</div>
            <button class="modal-close" onclick="closeCategoryModal()">✕</button>
        </div>
        <div class="modal-body">
            <div class="input-row">
                <label>카테고리명</label>
                <input type="text" id="categoryNameInput" placeholder="카테고리명 입력">
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="cancel-btn" onclick="closeCategoryModal()">취소</button>
            <button type="button" class="submit-btn" onclick="submitCategory()">등록</button>
        </div>
    </div>
</div>

<!-- ===================== 삭제 확인 모달 ===================== -->
<div class="modal-overlay" id="deleteModal">
    <div class="modal-box modal-sm">
        <div class="modal-header">
            <div class="modal-title">삭제 확인</div>
            <button class="modal-close" onclick="closeDeleteModal()">✕</button>
        </div>
        <div class="modal-body">
            <p class="delete-msg">
                <strong id="deleteMenuName"></strong> 을(를)<br>삭제하시겠습니까?
            </p>
        </div>
        <div class="modal-footer">
            <button type="button" class="cancel-btn" onclick="closeDeleteModal()">아니요</button>
            <button type="button" class="submit-btn btn-danger" onclick="confirmDelete()">예</button>
        </div>
    </div>
</div>

<!-- 삭제용 hidden form -->
<form id="deleteForm" action="/productDelete" method="post">
    <input type="hidden" id="deleteMenuId" name="id">
</form>

<!-- 토스트 메시지 -->
<div class="toast" id="toast"></div>

<script>
/* ===== 제품등록 모달 ===== */
function openProductModal() {
    document.getElementById('productModal').classList.add('active');
}
function closeProductModal() {
    document.getElementById('productModal').classList.remove('active');
}

/* ===== 제품수정 모달 ===== */
function openUpdateModal(id, categoryId, name, description, price, cost, isAvailable) {
    document.getElementById('updateId').value = id;
    document.getElementById('updateCategoryId').value = categoryId;
    document.getElementById('updateName').value = name;
    document.getElementById('updateDescription').value = description || '';
    document.getElementById('updatePrice').value = price;
    document.getElementById('updateCost').value = cost;
    document.getElementById('updateIsAvailable').value = isAvailable;
    document.getElementById('updateModal').classList.add('active');
}
function closeUpdateModal() {
    document.getElementById('updateModal').classList.remove('active');
}

/* ===== size 변경 ===== */
function changeSize(size) {
    const params = new URLSearchParams(window.location.search);
    params.set('size', size);
    params.set('page', 1);
    location.href = '/product/menu?' + params.toString();
}

/* ===== 카테고리 모달 ===== */
function switchToCategoryModal() {
    document.getElementById('categoryModal').classList.add('active');
}
function closeCategoryModal() {
    document.getElementById('categoryModal').classList.remove('active');
}

/* 카테고리 AJAX 등록 */
function submitCategory() {
    const name = document.getElementById('categoryNameInput').value.trim();
    if (!name) { alert('카테고리명을 입력해주세요.'); return; }

    fetch('/categoryInsert', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'name=' + encodeURIComponent(name)
    })
    .then(res => res.json())
    .then(data => {
        ['categorySelect', 'updateCategoryId'].forEach(selectId => {
            const select = document.getElementById(selectId);
            const option = document.createElement('option');
            option.value = data.id;
            option.text = data.name;
            select.appendChild(option);
        });
        document.getElementById('categorySelect').value = data.id;
        document.getElementById('categoryNameInput').value = '';
        closeCategoryModal();
        showToast('등록되었습니다 ✓');
    })
    .catch(() => alert('카테고리 등록 중 오류가 발생했습니다.'));
}

/* ===== 토스트 메시지 ===== */
function showToast(msg) {
    const toast = document.getElementById('toast');
    toast.innerText = msg;
    toast.classList.add('show');
    setTimeout(() => toast.classList.remove('show'), 2500);
}

/* ===== 검색 ===== */
function searchProduct() {
    const keyword = document.getElementById("searchInput").value;
    const params = new URLSearchParams(window.location.search);
    params.set('keyword', keyword);
    params.set('page', 1);
    location.href = '/product/menu?' + params.toString();
}

function handleEnter(event) {
    if (event.key === "Enter") {
        searchProduct();
    }
}

/* ===== 삭제 모달 ===== */
function openDeleteModal(id, name) {
    document.getElementById('deleteMenuId').value = id;
    document.getElementById('deleteMenuName').innerText = name;
    document.getElementById('deleteModal').classList.add('active');
}
function closeDeleteModal() {
    document.getElementById('deleteModal').classList.remove('active');
}
function confirmDelete() {
    document.getElementById('deleteForm').submit();
}

/* 모달 바깥 클릭 시 닫기 */
document.querySelectorAll('.modal-overlay').forEach(overlay => {
    overlay.addEventListener('click', function(e) {
        if (e.target === this) this.classList.remove('active');
    });
});
</script>

</body>
</html>