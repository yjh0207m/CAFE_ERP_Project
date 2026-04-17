<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
String loginName     = (String) session.getAttribute("loginName");
String loginPosition = (String) session.getAttribute("loginPosition");
if (loginName     == null) loginName     = "";
if (loginPosition == null) loginPosition = "";

// 등록 권한: 점장/스탭만
boolean canWrite = "점장".equals(loginPosition) || "스탭".equals(loginPosition);

// EL에서 사용하기 위해 request attribute로 세팅
request.setAttribute("loginName",     loginName);
request.setAttribute("loginPosition", loginPosition);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>공지사항 | ERP CAFE</title>
    <link rel="stylesheet" href="/css/header.css"/>
    <link rel="stylesheet" href="/css/Notice/notice.css"/>
</head>
<body>

<jsp:include page="/WEB-INF/views/header.jsp"/>

<div class="content">

    <div class="page-header">
        <div class="page-title">공지사항 <span>본사에서 내려온 공지를 확인합니다</span></div>
        <% if (canWrite) { %>
            <button class="btn btn-primary" onclick="openModal('registerModal')">+ 공지 등록</button>
        <% } %>
    </div>

    <%-- 요약 카드 --%>
    <div class="summary-box">
        <div class="summary-card">
            <div class="summary-title">전체 공지</div>
            <div class="summary-value">📢 ${totalCount}건</div>
        </div>
        <div class="summary-card">
            <div class="summary-title">현재 페이지</div>
            <div class="summary-value">📄 ${currentPage} / ${totalPages}</div>
        </div>
        <div class="summary-card">
            <div class="summary-title">페이지당 항목</div>
            <div class="summary-value">📊 ${size}건</div>
        </div>
    </div>

    <%-- 중요도 탭 --%>
    <div class="filter-bar">
        <div class="category-tabs">
            <button class="tab-btn ${empty selectedImportance ? 'active' : ''}"
                    onclick="location.href='/notice?page=1&size=${size}'">전체</button>
            <button class="tab-btn ${selectedImportance == 'urgent' ? 'active' : ''}"
                    onclick="location.href='/notice?page=1&size=${size}&importance=urgent'">🔴 긴급</button>
            <button class="tab-btn ${selectedImportance == 'important' ? 'active' : ''}"
                    onclick="location.href='/notice?page=1&size=${size}&importance=important'">🟠 중요</button>
            <button class="tab-btn ${selectedImportance == 'normal' ? 'active' : ''}"
                    onclick="location.href='/notice?page=1&size=${size}&importance=normal'">🔵 일반</button>
        </div>
    </div>

    <%-- 공지 목록 --%>
    <div class="table-card">
        <div class="table-card-header">
            <h3>공지 목록</h3>
            <span style="font-size:0.82rem; color:var(--text-muted);">총 ${totalCount}건</span>
        </div>
        <table class="data-table">
            <thead>
                <tr>
                    <th style="width:80px;">중요도</th>
                    <th>제목</th>
                    <th style="width:120px;">작성자</th>
                    <th style="width:160px;">등록일</th>
                    <th style="width:100px;">관리</th>
                </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty list}">
                    <tr class="empty-row"><td colspan="5">등록된 공지사항이 없습니다.</td></tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="n" items="${list}">
                    <tr class="notice-row clickable-row"
                        data-importance="${n.importance}"
                        onclick="openDetailModal(${n.id})">
                        <td>
                            <c:choose>
                                <c:when test="${n.importance == 'urgent'}">
                                    <span class="importance-badge urgent">🔴 긴급</span>
                                </c:when>
                                <c:when test="${n.importance == 'important'}">
                                    <span class="importance-badge important">🟠 중요</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="importance-badge normal">🔵 일반</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="notice-title"><strong>${n.title}</strong></td>
                        <td>${n.writer}</td>
                        <td style="font-family:'Outfit',sans-serif; font-size:0.82rem;">
    						${n.createdAtFormatted}
    						<c:if test="${n.modified}">
        						<br><span style="font-size:0.72rem; color:var(--text-muted);">
            						수정 ${n.updatedAtFormatted}
        						</span>
    						</c:if>
						</td>
                        <td onclick="event.stopPropagation()">
                            <%-- 본인이 작성했으면 수정/삭제 가능 --%>
                            <c:if test="${n.writer == loginName}">
                                <button class="btn btn-edit"
                                    onclick="openEditModal(${n.id})">
                                    수정
                                </button>
                                <form action="/notice/delete/${n.id}" method="post" style="display:inline"
                                      onsubmit="return confirm('공지를 삭제하시겠습니까?')">
                                    <button type="submit" class="btn btn-delete">삭제</button>
                                </form>
                            </c:if>
                        </td>
                    </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>

        <%-- 테이블 하단: size 선택 + 총 개수 --%>
        <div class="table-bottom-bar">
            <select onchange="changeSize(this.value)">
                <option value="10" ${size == 10 ? 'selected' : ''}>10건씩</option>
                <option value="20" ${size == 20 ? 'selected' : ''}>20건씩</option>
                <option value="50" ${size == 50 ? 'selected' : ''}>50건씩</option>
            </select>
            <div class="total-count">총 ${totalCount}건</div>
        </div>
    </div>

    <%-- 페이지네이션 --%>
    <div class="paging-box">
        <div class="page-btns">
            <c:if test="${currentPage > 1}">
                <button class="page-btn"
                    onclick="location.href='/notice?page=${currentPage-1}&size=${size}&importance=${selectedImportance}'">◀</button>
            </c:if>

            <c:forEach begin="1" end="${totalPages}" var="i">
                <button class="page-btn ${i == currentPage ? 'active' : ''}"
                    onclick="location.href='/notice?page=${i}&size=${size}&importance=${selectedImportance}'">${i}</button>
            </c:forEach>

            <c:if test="${currentPage < totalPages}">
                <button class="page-btn"
                    onclick="location.href='/notice?page=${currentPage+1}&size=${size}&importance=${selectedImportance}'">▶</button>
            </c:if>
        </div>
    </div>

</div>

<%-- ===== 공지 상세 모달 ===== --%>
<div class="modal-overlay" id="detailModal">
    <div class="modal modal-wide">
        <div class="modal-title">
            <span id="detailBadge"></span>
            <span id="detailTitle"></span>
        </div>
        <div class="notice-meta">
    		<span>✍️ <span id="detailWriter"></span></span>
    		<span>🕐 등록 <span id="detailDate"></span></span>
    		<span id="detailModified" style="display:none;">✏️ 수정 <span id="detailModifiedDate"></span></span>
		</div>
        <div class="notice-content" id="detailContent"></div>
        <div class="modal-footer">
            <button type="button" class="btn btn-cancel" onclick="closeModal('detailModal')">닫기</button>
        </div>
    </div>
</div>

<%-- ===== 공지 등록 모달 (점장/스탭만) ===== --%>
<% if (canWrite) { %>
<div class="modal-overlay" id="registerModal">
    <div class="modal modal-wide">
        <div class="modal-title">📢 공지 등록</div>
        <form action="/notice/register" method="post">
            <div class="form-group">
                <label>제목 *</label>
                <input type="text" name="title" required placeholder="공지 제목을 입력하세요">
            </div>
            <div class="form-group">
                <label>중요도</label>
                <div class="importance-select">
                    <label class="importance-option">
                        <input type="radio" name="importance" value="normal" checked>
                        <span class="importance-badge normal">🔵 일반</span>
                    </label>
                    <label class="importance-option">
                        <input type="radio" name="importance" value="important">
                        <span class="importance-badge important">🟠 중요</span>
                    </label>
                    <label class="importance-option">
                        <input type="radio" name="importance" value="urgent">
                        <span class="importance-badge urgent">🔴 긴급</span>
                    </label>
                </div>
            </div>
            <div class="form-group">
                <label>내용 *</label>
                <textarea name="content" rows="8" required placeholder="공지 내용을 입력하세요"></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-cancel" onclick="closeModal('registerModal')">취소</button>
                <button type="submit" class="btn btn-primary">등록</button>
            </div>
        </form>
    </div>
</div>
<% } %>

<%-- ===== 공지 수정 모달 ===== --%>
<div class="modal-overlay" id="editModal">
    <div class="modal modal-wide">
        <div class="modal-title">✏️ 공지 수정</div>
        <form action="/notice/update" method="post">
            <input type="hidden" name="id"     id="edit_id">
            <input type="hidden" name="writer" id="edit_writer"><%-- writer 유지 --%>
            <div class="form-group">
                <label>제목 *</label>
                <input type="text" name="title" id="edit_title" required>
            </div>
            <div class="form-group">
                <label>중요도</label>
                <div class="importance-select">
                    <label class="importance-option">
                        <input type="radio" name="importance" value="normal" id="edit_imp_normal">
                        <span class="importance-badge normal">🔵 일반</span>
                    </label>
                    <label class="importance-option">
                        <input type="radio" name="importance" value="important" id="edit_imp_important">
                        <span class="importance-badge important">🟠 중요</span>
                    </label>
                    <label class="importance-option">
                        <input type="radio" name="importance" value="urgent" id="edit_imp_urgent">
                        <span class="importance-badge urgent">🔴 긴급</span>
                    </label>
                </div>
            </div>
            <div class="form-group">
                <label>내용 *</label>
                <textarea name="content" id="edit_content" rows="8" required></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-cancel" onclick="closeModal('editModal')">취소</button>
                <button type="submit" class="btn btn-primary">저장</button>
            </div>
        </form>
    </div>
</div>

<script>
function openModal(id)  { document.getElementById(id).classList.add('active'); }
function closeModal(id) { document.getElementById(id).classList.remove('active'); }

/* 공지 상세 모달 */
function openDetailModal(id) {
    fetch('/notice/' + id)
        .then(function(res) { return res.json(); })
        .then(function(n) {
            var badgeMap = {
                urgent:    '<span class="importance-badge urgent">🔴 긴급</span>',
                important: '<span class="importance-badge important">🟠 중요</span>',
                normal:    '<span class="importance-badge normal">🔵 일반</span>'
            };
            document.getElementById('detailBadge').innerHTML  = badgeMap[n.importance] || '';
            document.getElementById('detailTitle').innerText  = ' ' + n.title;
            document.getElementById('detailWriter').innerText = n.writer;
            document.getElementById('detailDate').innerText   = n.createdAtFormatted;
            document.getElementById('detailContent').innerHTML =
                (n.content || '').replace(/\n/g, '<br>');

            // 수정 시간 표시
            var modifiedEl = document.getElementById('detailModified');
            if (n.modified) {
                document.getElementById('detailModifiedDate').innerText = n.updatedAtFormatted;
                modifiedEl.style.display = 'inline';
            } else {
                modifiedEl.style.display = 'none';
            }

            openModal('detailModal');
        });
}

/* 수정 모달 - fetch로 전체 데이터 가져와서 세팅 */
function openEditModal(id) {
    fetch('/notice/' + id)
        .then(function(res) { return res.json(); })
        .then(function(n) {
            document.getElementById('edit_id').value      = n.id;
            document.getElementById('edit_writer').value  = n.writer; // writer 유지
            document.getElementById('edit_title').value   = n.title;
            document.getElementById('edit_content').value = n.content;
            document.getElementById('edit_imp_' + n.importance).checked = true;
            openModal('editModal');
        });
}

/* size 변경 */
function changeSize(size) {
    var params = new URLSearchParams(window.location.search);
    params.set('size', size);
    params.set('page', 1);
    location.href = '/notice?' + params.toString();
}

/* 모달 외부 클릭 닫기 */
document.querySelectorAll('.modal-overlay').forEach(function(o) {
    o.addEventListener('click', function(e) {
        if (e.target === o) o.classList.remove('active');
    });
});
</script>

</body>
</html>
