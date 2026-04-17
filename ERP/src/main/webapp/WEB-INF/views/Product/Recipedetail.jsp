<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>레시피 상세</title>
    <link rel="stylesheet" href="/css/header.css" />
    <link rel="stylesheet" href="/css/Product/recipeDetail.css" />
</head>

<body>
<jsp:include page="/WEB-INF/views/header.jsp"/>

<div class="content">

    <!-- 뒤로가기 + 페이지 헤더 -->
    <div class="page-header">
    <div class="header-left-area">
        <div class="page-title">레시피 관리</div>
    </div>
    <div class="header-right-area">
        <button class="back-btn" onclick="history.back()">← 제품목록</button>
        <button class="register-btn" onclick="openInsertModal()">+ 원재료 추가</button>
    </div>
</div>

    <!-- 제품 카드 -->
    <div class="detail-card">

        <!-- 제품명 + 수정/삭제 -->
        <div class="detail-card-header">
            <div class="product-name">${menu.name}</div>
        </div>

        <!-- 레시피 테이블 -->
        <div class="detail-table-wrap">
            <table class="detail-table">
                <thead>
                    <tr>
                        <th>원재료</th>
                        <th>개당 소모량</th>
                        <th>재고수</th>
                        <th>재고 부족 여부</th>
                        <th>관리</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="recipe" items="${recipeList}">
                    <tr>
                        <td>${recipe.ingredientName}</td>
                        <td><fmt:formatNumber value="${recipe.quantity}" pattern="#,##0.###"/> ${recipe.recipe}</td>
						<td><fmt:formatNumber value="${recipe.currentStock}" pattern="#,##0.###"/></td>
                        <td>
                            <span class="badge ${recipe.stockStatus == '정상' ? 'badge-on' : 'badge-off'}">
                                ${recipe.stockStatus}
                            </span>
                        </td>
                        <td>
                            <button class="btn update"
                                onclick="openEditModal(${recipe.id}, ${recipe.ingredientId}, ${recipe.quantity}, '${recipe.recipe}')">수정</button>
                            <button class="btn delete"
                                onclick="openDeleteRecipeModal(${recipe.id}, '${recipe.ingredientName}')">삭제</button>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty recipeList}">
                    <tr>
                        <td colspan="5" class="empty-msg">등록된 레시피가 없습니다</td>
                    </tr>
                    </c:if>
                </tbody>
            </table>
        </div>

    </div>

</div>

<!-- ===================== 원재료 추가 모달 ===================== -->
<div class="modal-overlay" id="insertModal">
    <div class="modal-box">
        <div class="modal-header">
            <div class="modal-title">원재료 추가</div>
            <button class="modal-close" onclick="closeInsertModal()">✕</button>
        </div>
        <form action="/recipeInsert" method="post">
            <input type="hidden" name="menuId" value="${menu.id}">
            <div class="modal-body">
                <div class="input-row">
                    <label>원재료</label>
                    <select name="ingredientId" id="insertIngredientId" required onchange="autoFillUnit(this, 'insertRecipe')">
    					<option value="">원재료 선택</option>
    					<c:forEach var="ing" items="${ingredientList}">
        					<option value="${ing.id}" data-unit="${ing.unit}">${ing.ingredientName}</option>
    					</c:forEach>
					</select>
                </div>
                <div class="input-row">
                    <label>개당 소모량</label>
                    <input type="number" name="quantity" placeholder="예: 180" step="0.001" min="0" required>
                </div>
                <div class="input-row">
                    <label>단위 / 메모</label>
                    <input type="text" name="recipe" id="insertRecipe" placeholder="예: ml, 투샷">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="cancel-btn" onclick="closeInsertModal()">취소</button>
                <button type="submit" class="submit-btn">추가</button>
            </div>
        </form>
    </div>
</div>

<!-- ===================== 원재료 수정 모달 ===================== -->
<div class="modal-overlay" id="editModal">
    <div class="modal-box">
        <div class="modal-header">
            <div class="modal-title">원재료 수정</div>
            <button class="modal-close" onclick="closeEditModal()">✕</button>
        </div>
        <form action="/recipeUpdate" method="post">
            <input type="hidden" name="id" id="editId">
            <input type="hidden" name="menuId" value="${menu.id}">
            <div class="modal-body">
                <div class="input-row">
                    <label>원재료</label>
                    <select name="ingredientId" id="editIngredientId" required onchange="autoFillUnit(this, 'editRecipe')">
    					<c:forEach var="ing" items="${ingredientList}">
        					<option value="${ing.id}" data-unit="${ing.unit}">${ing.ingredientName}</option>
    					</c:forEach>
					</select>
                </div>
                <div class="input-row">
                    <label>개당 소모량</label>
                    <input type="number" name="quantity" id="editQuantity" step="0.001" min="0" required>
                </div>
                <div class="input-row">
                    <label>단위 / 메모</label>
                    <input type="text" name="recipe" id="editRecipe">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="cancel-btn" onclick="closeEditModal()">취소</button>
                <button type="submit" class="submit-btn">수정</button>
            </div>
        </form>
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
                <strong id="deleteIngredientName"></strong> 을(를)<br>삭제하시겠습니까?
            </p>
        </div>
        <div class="modal-footer">
            <button type="button" class="cancel-btn" onclick="closeDeleteModal()">아니요</button>
            <button type="button" class="submit-btn btn-danger" onclick="confirmDelete()">예</button>
        </div>
    </div>
</div>

<!-- 삭제용 hidden form -->
<form id="deleteForm" action="/recipeDelete" method="post">
    <input type="hidden" id="deleteRecipeId" name="id">
    <input type="hidden" name="menuId" value="${menu.id}"> <!-- ← 추가 -->
</form>

<!-- 토스트 -->
<div class="toast" id="toast"></div>

<script>
function openInsertModal() { document.getElementById('insertModal').classList.add('active'); }
function closeInsertModal() { document.getElementById('insertModal').classList.remove('active'); }

function openEditModal(id, ingredientId, quantity, recipe) {
    document.getElementById('editId').value = id;
    document.getElementById('editIngredientId').value = ingredientId;
    document.getElementById('editQuantity').value = quantity;
    document.getElementById('editRecipe').value = recipe || '';
    document.getElementById('editModal').classList.add('active');
}
function closeEditModal() { document.getElementById('editModal').classList.remove('active'); }

function autoFillUnit(selectEl, targetId) {
    const unit = selectEl.options[selectEl.selectedIndex].getAttribute('data-unit');
    document.getElementById(targetId).value = unit || '';
}

function openDeleteRecipeModal(id, name) {
    document.getElementById('deleteRecipeId').value = id;
    document.getElementById('deleteIngredientName').innerText = name;
    document.getElementById('deleteModal').classList.add('active');
}
function closeDeleteModal() { document.getElementById('deleteModal').classList.remove('active'); }
function confirmDelete() { document.getElementById('deleteForm').submit(); }

function showToast(msg) {
    const toast = document.getElementById('toast');
    toast.innerText = msg;
    toast.classList.add('show');
    setTimeout(() => toast.classList.remove('show'), 2500);
}

document.querySelectorAll('.modal-overlay').forEach(overlay => {
    overlay.addEventListener('click', function(e) {
        if (e.target === this) this.classList.remove('active');
    });
});
</script>

</body>
</html>