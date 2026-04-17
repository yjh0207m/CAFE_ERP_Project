<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ERP 사용자 관리 | ERP CAFE SYSTEM</title>
    <link rel="stylesheet" href="/css/header.css" />
    <link rel="stylesheet" href="/css/users/user-management.css" />
</head>
<body>

<jsp:include page="/WEB-INF/views/header.jsp" />

<%-- 등록된 id 목록 문자열 생성 (,1,3,7, 형태) --%>
<c:set var="userIdSet" value="," />
<c:forEach var="u" items="${users}">
    <c:set var="userIdSet" value="${userIdSet}${u.id}," />
</c:forEach>

<div class="content">

    <div class="page-header">
        <div class="page-title-wrap">
            <span class="page-icon">&#128272;</span>
            <div>
                <h1 class="page-title">ERP 사용자 관리</h1>
                <p class="page-sub">인사관리 &gt; ERP 사용자 관리</p>
            </div>
        </div>
        <button class="btn-register" onclick="openAuthModal('register')">
            + 새 계정 등록
        </button>
    </div>

    <c:if test="${param.msg == 'registered'}">
        <div class="alert-success">계정이 등록되었습니다.</div>
    </c:if>
    <c:if test="${param.msg == 'pw_changed'}">
        <div class="alert-success">비밀번호가 변경되었습니다.</div>
    </c:if>
    <c:if test="${param.msg == 'pw_error'}">
        <div class="alert-error-bar">비밀번호 변경 중 오류가 발생했습니다.</div>
    </c:if>
    <c:if test="${param.msg == 'del_done'}">
        <div class="alert-success">계정이 삭제되었습니다.</div>
    </c:if>
    <c:if test="${param.msg == 'del_error'}">
        <div class="alert-error-bar">계정 삭제 중 오류가 발생했습니다.</div>
    </c:if>

    <!-- 등록된 계정 목록 -->
    <div class="section-header">
        <span class="section-title">&#128101; 등록된 계정 목록</span>
    </div>

    <div class="table-card" style="margin-bottom:0; overflow-x:auto;">
        <table class="user-table" style="min-width:820px;">
            <thead>
                <tr>
                    <th>사원번호</th>
                    <th>이름</th>
                    <th>직위</th>
                    <th>고용형태</th>
                    <th>입사일</th>
                    <th>재직상태</th>
                    <th>활성여부</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty users}">
                        <tr><td colspan="8" class="empty-row">등록된 계정이 없습니다.</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="u" items="${users}">
                        <c:set var="emp" value="${empMapById[u.id]}" />
                        <tr>
                            <td class="td-empnum">${emp.emp_num}</td>
                            <td class="td-name">${emp.name}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${emp.position == '점장'}"><span class="pos-badge pos-a">점장</span></c:when>
                                    <c:when test="${emp.position == '매니저'}"><span class="pos-badge pos-b">매니저</span></c:when>
                                    <c:otherwise><span class="pos-badge pos-c">${emp.position}</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${emp.contract_type == '풀'}"><span class="contract-badge full">정규직</span></c:when>
                                    <c:otherwise><span class="contract-badge part">파트타임</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="td-date">${emp.hire_date}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${emp.is_active == 1}"><span class="status-badge active">재직</span></c:when>
                                    <c:when test="${emp.is_active == 2}"><span class="status-badge leave">휴직</span></c:when>
                                    <c:otherwise><span class="status-badge resigned">퇴사</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${u.is_active == 1}"><span class="active-badge on">활성</span></c:when>
                                    <c:otherwise><span class="active-badge off">비활성</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div class="action-cell">
                                    <c:choose>
                                        <c:when test="${emp.emp_num eq '222'}">
                                            <span class="btn-locked">보호된 계정</span>
                                        </c:when>
                                        <c:otherwise>
                                            <form action="/hr/users/toggle" method="post" style="display:inline;">
                                                <input type="hidden" name="emp_num" value="${emp.emp_num}" />
                                                <button type="submit"
                                                        class="${u.is_active == 1 ? 'btn-deactivate' : 'btn-activate'}">
                                                    <c:choose>
                                                        <c:when test="${u.is_active == 1}">비활성화</c:when>
                                                        <c:otherwise>활성화</c:otherwise>
                                                    </c:choose>
                                                </button>
                                            </form>
                                            <button class="btn-pw"
                                                    onclick="openAuthModal('pwchange','${emp.emp_num}','${emp.name}')">
                                                비밀번호 변경
                                            </button>
                                            <button class="btn-del-user"
                                                    onclick="openAuthModal('deleteuser','${emp.emp_num}','${emp.name}')">
                                                계정 삭제
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </td>
                        </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>

        <!-- 등록된 계정 페이징 -->
        <div class="pagination">
            <div class="page-nav">
                <c:if test="${userPage > 1}">
                    <button class="page-btn" onclick="goUserPage(${userPage - 1})">◀</button>
                </c:if>
                <c:forEach var="i" begin="1" end="${userTotalPages}">
                    <button class="page-btn ${i == userPage ? 'active' : ''}"
                            onclick="goUserPage(${i})">${i}</button>
                </c:forEach>
                <c:if test="${userPage < userTotalPages}">
                    <button class="page-btn" onclick="goUserPage(${userPage + 1})">▶</button>
                </c:if>
            </div>
            <div class="page-total">총 ${userTotalCount}개 계정</div>
        </div>
    </div>
    <div style="margin-bottom:36px;"></div>
    



    <!-- 전체 직원 목록 -->
    <div class="section-header">
        <span class="section-title">&#128100; 전체 직원 목록</span>
    </div>

    <div class="table-card" style="overflow-x:auto;">
        <table class="user-table" style="min-width:920px;">
            <thead>
                <tr>
                    <th>사원번호</th><th>이름</th><th>나이</th><th>연락처</th>
                    <th>직위</th><th>고용형태</th><th>시급</th><th>월급</th>
                    <th>입사일</th><th>은행</th><th>계좌번호</th><th>재직상태</th><th>ERP계정</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="emp" items="${employees}">
                <tr>
                    <td class="td-empnum">${emp.emp_num}</td>
                    <td class="td-name">${emp.name}</td>
                    <td>${emp.age}</td>
                    <td class="td-phone">${emp.phone}</td>
                    <td>
                        <c:choose>
                            <c:when test="${emp.position == '점장'}"><span class="pos-badge pos-a">점장</span></c:when>
                            <c:when test="${emp.position == '매니저'}"><span class="pos-badge pos-b">매니저</span></c:when>
                            <c:otherwise><span class="pos-badge pos-c">${emp.position}</span></c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${emp.contract_type == '풀'}"><span class="contract-badge full">정규직</span></c:when>
                            <c:otherwise><span class="contract-badge part">파트타임</span></c:otherwise>
                        </c:choose>
                    </td>
                    <td class="td-money">
                        <c:choose>
                            <c:when test="${emp.hourly_wage > 0}"><fmt:formatNumber value="${emp.hourly_wage}" pattern="#,###"/>원</c:when>
                            <c:otherwise>-</c:otherwise>
                        </c:choose>
                    </td>
                    <td class="td-money">
                        <c:choose>
                            <c:when test="${emp.monthly_salary > 0}"><fmt:formatNumber value="${emp.monthly_salary}" pattern="#,###"/>원</c:when>
                            <c:otherwise>-</c:otherwise>
                        </c:choose>
                    </td>
                    <td class="td-date">${emp.hire_date}</td>
                    <td>${emp.bank_name}</td>
                    <td class="td-account">${emp.account_no}</td>
                    <td>
                        <c:choose>
                            <c:when test="${emp.is_active == 1}"><span class="status-badge active">재직</span></c:when>
                            <c:when test="${emp.is_active == 2}"><span class="status-badge leave">휴직</span></c:when>
                            <c:otherwise><span class="status-badge resigned">퇴사</span></c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${fn:contains(userIdSet, ','.concat(emp.id).concat(','))}">
                                <span class="acct-badge has">등록됨</span>
                            </c:when>
                            <c:otherwise>
                                <span class="acct-badge none">미등록</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
                </c:forEach>
            </tbody>
        </table>

        <!-- 전체 직원 페이징 -->
        <div class="pagination">
            <div class="page-nav">
                <c:if test="${empPage > 1}">
                    <button class="page-btn" onclick="goEmpPage(${empPage - 1})">◀</button>
                </c:if>
                <c:forEach var="i" begin="1" end="${empTotalPages}">
                    <button class="page-btn ${i == empPage ? 'active' : ''}"
                            onclick="goEmpPage(${i})">${i}</button>
                </c:forEach>
                <c:if test="${empPage < empTotalPages}">
                    <button class="page-btn" onclick="goEmpPage(${empPage + 1})">▶</button>
                </c:if>
            </div>
            <div class="page-total">총 ${empTotalCount}명</div>
        </div>
    </div>

</div><!-- /content -->








<!-- ===== 관리자 인증 모달 ===== -->
<div class="modal-overlay" id="authModal">
    <div class="modal">
        <div class="modal-header">
            <span class="modal-title">&#128274; 관리자 인증</span>
            <button class="modal-close" onclick="closeAuthModal()">&#10005;</button>
        </div>
        <div class="modal-body">
            <p class="auth-desc" id="authDesc">이 작업은 관리자 인증이 필요합니다.</p>
            <div class="form-group" style="margin-bottom:14px;">
                <label class="form-label required">사원번호 (아이디)</label>
                <input type="text" class="form-input" id="authId" placeholder="사원번호 입력" />
            </div>
            <div class="form-group" style="margin-bottom:6px;">
                <label class="form-label required">비밀번호</label>
                <input type="password" class="form-input" id="authPw" placeholder="비밀번호 입력"
                       onkeydown="if(event.key==='Enter') submitAuth()" />
            </div>
            <p class="auth-error" id="authError"></p>
            <div class="modal-actions">
                <button class="btn-cancel" onclick="closeAuthModal()">취소</button>
                <button class="btn-submit" onclick="submitAuth()">인증</button>
            </div>
        </div>
    </div>
</div>

<!-- 비밀번호 변경용 hidden form -->
<form id="pwChangeForm" action="/hr/users/pw-change" method="post" style="display:none;">
    <input type="hidden" id="pwEmpNum"  name="emp_num" />
    <input type="hidden" id="pwNewPass" name="new_pw" />
</form>

<!-- 계정 삭제용 hidden form -->
<form id="delUserForm" action="/hr/users/delete" method="post" style="display:none;">
    <input type="hidden" id="delEmpNum" name="emp_num" />
</form>

<script>
/* ================================================================
   페이지 이동 — userPage / empPage 파라미터 분리
================================================================ */
var _userPage = ${empty userPage ? 1 : userPage};
var _empPage  = ${empty empPage  ? 1 : empPage};

function goUserPage(p) {
    var url = '/hr/users?userPage=' + p + '&empPage=' + _empPage;
    location.href = url;
}

function goEmpPage(p) {
    var url = '/hr/users?userPage=' + _userPage + '&empPage=' + p;
    location.href = url;
}

/* ===== 모달 상태 ===== */
var _pendingAction = null;   // 'register' | 'pwchange'
var _pendingEmpNum = null;
var _pendingName   = null;

function openAuthModal(action, empNum, name) {
    _pendingAction = action;
    _pendingEmpNum = empNum || null;
    _pendingName   = name   || null;

    document.getElementById('authId').value = '';
    document.getElementById('authPw').value = '';
    document.getElementById('authError').innerText = '';

    var desc = document.getElementById('authDesc');
    if (action === 'pwchange') {
        desc.innerText = name + ' 직원의 비밀번호를 변경하려면 관리자 인증이 필요합니다.';
    } else {
        desc.innerText = '새 계정 등록을 위해 관리자 인증이 필요합니다.';
    }

    document.getElementById('authModal').classList.add('active');
    setTimeout(function() { document.getElementById('authId').focus(); }, 200);
}

function closeAuthModal() {
    document.getElementById('authModal').classList.remove('active');
}

/* 모달 바깥 클릭 시 닫기 */
document.getElementById('authModal').addEventListener('click', function(e) {
    if (e.target === this) closeAuthModal();
});

/* ===== 인증 요청 ===== */
function submitAuth() {
    var uid = document.getElementById('authId').value.trim();
    var upw = document.getElementById('authPw').value.trim();
    if (!uid || !upw) {
        document.getElementById('authError').innerText = '아이디와 비밀번호를 입력해주세요.';
        return;
    }

    var xhr = new XMLHttpRequest();
    xhr.open('POST', '/hr/users/auth', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onload = function() {
        if (xhr.responseText.trim() === 'ok') {
            closeAuthModal();
            if (_pendingAction === 'register') {
                openRegisterModal();
            } else if (_pendingAction === 'pwchange') {
                openPwChangePrompt(_pendingEmpNum, _pendingName);
            } else if (_pendingAction === 'deleteuser') {
                execDeleteUser(_pendingEmpNum, _pendingName);
            }
        } else {
            document.getElementById('authError').innerText = '아이디 또는 비밀번호가 올바르지 않습니다.';
        }
    };
    xhr.send('userId=' + encodeURIComponent(uid) + '&userPw=' + encodeURIComponent(upw));
}

/* ===== 계정 삭제 ===== */
function execDeleteUser(empNum, name) {
    if (!confirm(name + ' 직원의 ERP 계정을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.')) return;
    document.getElementById('delEmpNum').value = empNum;
    document.getElementById('delUserForm').submit();
}

/* ===== 비밀번호 변경 프롬프트 ===== */
function openPwChangePrompt(empNum, name) {
    var pw1 = prompt(name + ' 직원의 새 비밀번호를 입력하세요 (4자 이상):');
    if (pw1 === null) return;
    if (pw1.length < 4) { alert('비밀번호는 4자 이상이어야 합니다.'); return; }

    var pw2 = prompt('비밀번호를 한 번 더 입력하세요:');
    if (pw2 === null) return;
    if (pw1 !== pw2) { alert('비밀번호가 일치하지 않습니다.'); return; }

    document.getElementById('pwEmpNum').value  = empNum;
    document.getElementById('pwNewPass').value = pw1;
    document.getElementById('pwChangeForm').submit();
}
</script>




<!-- ================================================================
     계정 등록 모달
================================================================ -->
<!-- 직원 데이터 JS 주입 (퇴사자 + 이미 계정 있는 직원 제외) -->
<script>
var EMP_DATA = [
    <c:forEach var="emp" items="${allEmployees}">
        <c:if test="${emp.is_active != 0 and !registeredIds.contains(emp.id)}">
        {
            emp_num  : "${emp.emp_num}",
            name     : "${emp.name}",
            age      : "${emp.age}",
            phone    : "${emp.phone}",
            position : "${emp.position}",
            contract : "${emp.contract_type}",
            hourly   : ${emp.hourly_wage},
            salary   : ${emp.monthly_salary},
            hire     : "${emp.hire_date}",
            bank     : "${emp.bank_name}",
            account  : "${emp.account_no}",
            status   : ${emp.is_active}
        },
        </c:if>
    </c:forEach>
];
</script>

<div class="modal-overlay" id="registerModal">
  <div class="modal reg-modal">
    <div class="modal-header">
      <span class="modal-title">&#128272; ERP 계정 등록</span>
      <button class="modal-close" onclick="closeRegisterModal()">&#10005;</button>
    </div>
    <div class="modal-body reg-modal-body">

      <form action="/hr/users/register" method="post" id="regForm">
        <input type="hidden" name="emp_num" id="hiddenEmpNum" />

        <!-- 직원 선택 -->
        <p class="reg-section-title">&#128100; 직원 선택</p>

        <div class="emp-filter-bar">
          <div class="search-wrap">
            <span class="search-icon">&#128269;</span>
            <input type="text" class="search-input" id="regSearchName"
                   placeholder="이름 검색..." oninput="applyRegFilter()" />
          </div>
          <div class="pos-filter-tabs">
            <button type="button" class="pos-tab active" id="reg-pos-all"    onclick="setRegPos('all')">전체</button>
            <button type="button" class="pos-tab"        id="reg-pos-점장"   onclick="setRegPos('점장')">점장</button>
            <button type="button" class="pos-tab"        id="reg-pos-매니저" onclick="setRegPos('매니저')">매니저</button>
            <button type="button" class="pos-tab"        id="reg-pos-스탭"   onclick="setRegPos('스탭')">스탭</button>
          </div>
          <span class="filter-count" id="regFilterCount"></span>
        </div>

        <div class="emp-table-wrap">
          <table class="emp-pick-table">
            <thead>
              <tr>
                <th>선택</th><th>사원번호</th><th>이름</th>
                <th>직위</th><th>고용형태</th><th>재직상태</th>
              </tr>
            </thead>
            <tbody id="regEmpPickBody"></tbody>
          </table>
        </div>
        <div class="pick-paging" id="regPickPaging"></div>

        <!-- 선택된 직원 정보 -->
        <div class="emp-info-box" id="regEmpInfoBox" style="display:none;">
          <p class="info-box-title">&#128100; 선택된 직원 정보</p>
          <div class="info-grid">
            <div class="info-item"><span class="info-label">사원번호</span><span class="info-value" id="regDispEmpNum">-</span></div>
            <div class="info-item"><span class="info-label">이름</span><span class="info-value" id="regDispName">-</span></div>
            <div class="info-item"><span class="info-label">나이</span><span class="info-value" id="regDispAge">-</span></div>
            <div class="info-item"><span class="info-label">연락처</span><span class="info-value" id="regDispPhone">-</span></div>
            <div class="info-item"><span class="info-label">직위</span><span class="info-value" id="regDispPosition">-</span></div>
            <div class="info-item"><span class="info-label">고용형태</span><span class="info-value" id="regDispContract">-</span></div>
          </div>
        </div>

        <!-- 비밀번호 -->
        <p class="reg-section-title" style="margin-top:24px;">&#128274; 비밀번호 설정</p>
        <div class="pw-section">
          <div class="form-group pw-group">
            <label class="form-label required">비밀번호</label>
            <input type="password" class="form-input" name="user_pw"
                   id="regUserPw" placeholder="비밀번호를 입력하세요" />
          </div>
          <div class="form-group pw-group">
            <label class="form-label required">비밀번호 확인</label>
            <input type="password" class="form-input" id="regUserPwConfirm"
                   placeholder="비밀번호를 다시 입력하세요" oninput="checkRegPw()" />
            <span class="pw-hint" id="regPwHint"></span>
          </div>
        </div>

        <div class="form-actions">
          <button type="button" class="btn-cancel" onclick="closeRegisterModal()">취소</button>
          <button type="button" class="btn-submit" onclick="submitReg()">등록</button>
        </div>
      </form>

    </div>
  </div>
</div>

<script>
/* ================================================================
   계정 등록 모달
================================================================ */
var REG_PAGE_SIZE   = 5;
var regCurrentPage  = 1;
var regCurrentPos   = 'all';
var regCurrentName  = '';
var regSelectedEmp  = null;
var regFilteredData = [];

function openRegisterModal() {
    // 상태 초기화
    regCurrentPage  = 1;
    regCurrentPos   = 'all';
    regCurrentName  = '';
    regSelectedEmp  = null;
    document.getElementById('regSearchName').value    = '';
    document.getElementById('hiddenEmpNum').value     = '';
    document.getElementById('regUserPw').value        = '';
    document.getElementById('regUserPwConfirm').value = '';
    document.getElementById('regPwHint').textContent  = '';
    document.getElementById('regEmpInfoBox').style.display = 'none';
    document.querySelectorAll('.pos-tab').forEach(function(b) { b.classList.remove('active'); });
    document.getElementById('reg-pos-all').classList.add('active');
    runRegFilter();
    document.getElementById('registerModal').classList.add('active');
}

function closeRegisterModal() {
    document.getElementById('registerModal').classList.remove('active');
}

function applyRegFilter() {
    regCurrentName = document.getElementById('regSearchName').value.trim().toLowerCase();
    regCurrentPage = 1;
    runRegFilter();
}

function setRegPos(pos) {
    regCurrentPos  = pos;
    regCurrentPage = 1;
    document.querySelectorAll('#registerModal .pos-tab').forEach(function(b) { b.classList.remove('active'); });
    document.getElementById('reg-pos-' + pos).classList.add('active');
    runRegFilter();
}

function runRegFilter() {
    regFilteredData = EMP_DATA.filter(function(e) {
        var nameMatch = regCurrentName === '' || e.name.toLowerCase().includes(regCurrentName);
        var posMatch  = regCurrentPos  === 'all' || e.position === regCurrentPos;
        return nameMatch && posMatch;
    });
    var countEl = document.getElementById('regFilterCount');
    countEl.textContent   = regFilteredData.length + '명';
    countEl.style.display = 'inline';
    renderRegTable();
    renderRegPaging();
}

function renderRegTable() {
    var tbody = document.getElementById('regEmpPickBody');
    var start = (regCurrentPage - 1) * REG_PAGE_SIZE;
    var end   = Math.min(start + REG_PAGE_SIZE, regFilteredData.length);
    var html  = '';

    if (regFilteredData.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="empty-row">계정 미등록 직원이 없습니다.</td></tr>';
        return;
    }

    for (var i = start; i < end; i++) {
        var e      = regFilteredData[i];
        var isSel  = regSelectedEmp && regSelectedEmp.emp_num === e.emp_num;
        var posCls = e.position === '점장' ? 'pos-a' : e.position === '매니저' ? 'pos-b' : 'pos-c';
        var conLbl = e.contract === '풀'
            ? '<span class="contract-badge full">정규직</span>'
            : '<span class="contract-badge part">파트타임</span>';
        var stLbl  = e.status === 2
            ? '<span class="status-badge leave">휴직</span>'
            : '<span class="status-badge active">재직</span>';

        html += '<tr class="pick-row' + (isSel ? ' selected' : '') + '" onclick="selectRegEmp(' + i + ')">'
              + '<td><span class="pick-radio' + (isSel ? ' checked' : '') + '"></span></td>'
              + '<td class="td-empnum">' + e.emp_num   + '</td>'
              + '<td class="td-name">'   + e.name      + '</td>'
              + '<td><span class="pos-badge ' + posCls + '">' + e.position + '</span></td>'
              + '<td>' + conLbl + '</td>'
              + '<td>' + stLbl  + '</td>'
              + '</tr>';
    }
    tbody.innerHTML = html;
}

function renderRegPaging() {
    var total    = Math.ceil(regFilteredData.length / REG_PAGE_SIZE);
    var pagingEl = document.getElementById('regPickPaging');
    if (total <= 1) { pagingEl.innerHTML = ''; return; }

    var html = '<button type="button" class="page-btn" onclick="goRegPage(' + (regCurrentPage - 1) + ')"'
             + (regCurrentPage === 1 ? ' disabled' : '') + '>◀</button>';
    for (var p = 1; p <= total; p++) {
        html += '<button type="button" class="page-btn' + (p === regCurrentPage ? ' active' : '')
              + '" onclick="goRegPage(' + p + ')">' + p + '</button>';
    }
    html += '<button type="button" class="page-btn" onclick="goRegPage(' + (regCurrentPage + 1) + ')"'
          + (regCurrentPage === total ? ' disabled' : '') + '>▶</button>';
    pagingEl.innerHTML = html;
}

function goRegPage(p) {
    var total = Math.ceil(regFilteredData.length / REG_PAGE_SIZE);
    if (p < 1 || p > total) return;
    regCurrentPage = p;
    renderRegTable();
    renderRegPaging();
}

function selectRegEmp(filteredIdx) {
    regSelectedEmp = regFilteredData[filteredIdx];
    document.getElementById('hiddenEmpNum').value = regSelectedEmp.emp_num;

    document.getElementById('regDispEmpNum').textContent   = regSelectedEmp.emp_num;
    document.getElementById('regDispName').textContent     = regSelectedEmp.name;
    document.getElementById('regDispAge').textContent      = regSelectedEmp.age      || '-';
    document.getElementById('regDispPhone').textContent    = regSelectedEmp.phone    || '-';
    document.getElementById('regDispPosition').textContent = regSelectedEmp.position;
    document.getElementById('regDispContract').textContent = regSelectedEmp.contract === '풀' ? '정규직' : '파트타임';

    document.getElementById('regEmpInfoBox').style.display = 'block';
    renderRegTable();
}

function checkRegPw() {
    var pw   = document.getElementById('regUserPw').value;
    var conf = document.getElementById('regUserPwConfirm').value;
    var hint = document.getElementById('regPwHint');
    if (!conf) { hint.textContent = ''; return; }
    if (pw === conf) {
        hint.textContent = '✓ 비밀번호가 일치합니다.';
        hint.style.color = '#16a34a';
    } else {
        hint.textContent = '✗ 비밀번호가 일치하지 않습니다.';
        hint.style.color = '#dc2626';
    }
}

function submitReg() {
    var empNum = document.getElementById('hiddenEmpNum').value;
    var pw     = document.getElementById('regUserPw').value;
    var conf   = document.getElementById('regUserPwConfirm').value;
    if (!empNum)       { alert('직원을 선택해주세요.'); return; }
    if (!pw)           { alert('비밀번호를 입력해주세요.'); return; }
    if (pw.length < 4) { alert('비밀번호는 4자 이상이어야 합니다.'); return; }
    if (pw !== conf)   { alert('비밀번호가 일치하지 않습니다.'); return; }
    document.getElementById('regForm').submit();
}

/* 모달 바깥 클릭 닫기 */
document.getElementById('registerModal').addEventListener('click', function(e) {
    if (e.target === this) closeRegisterModal();
});
</script>

</body>
</html>