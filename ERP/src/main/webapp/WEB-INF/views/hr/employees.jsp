<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>직원 관리 | ERP CAFE SYSTEM</title>
    <link rel="stylesheet" href="/css/header.css" />
    <link rel="stylesheet" href="/css/Employee/employee.css" />
</head>
<body>

<jsp:include page="/WEB-INF/views/header.jsp" />

<div class="content">

    <div class="page-header">
        <div class="page-title-wrap">
            <span class="page-icon">&#128100;</span>
            <div>
                <h1 class="page-title">직원 관리</h1>
                <p class="page-sub">인사관리 &gt; 직원 관리</p>
            </div>
        </div>
        <button class="btn-register" onclick="openRegisterModal()">
            + 직원 등록
        </button>
    </div>

    <!-- 필터 + 검색 바 -->
    <div class="filter-bar">
        <div class="status-tabs">
            <button class="tab-btn ${empty param.status || param.status == 'all'      ? 'active' : ''}"
                    onclick="goFilter('all')">전체</button>
            <button class="tab-btn ${param.status == 'active'   ? 'active' : ''}"
                    onclick="goFilter('active')">재직</button>
            <button class="tab-btn ${param.status == 'leave'    ? 'active' : ''}"
                    onclick="goFilter('leave')">휴직</button>
            <button class="tab-btn ${param.status == 'resigned' ? 'active' : ''}"
                    onclick="goFilter('resigned')">퇴사</button>
        </div>
        <div class="search-form">
            <div class="search-wrap">
                <span class="search-icon">&#128269;</span>
                <input type="text" class="search-input" id="searchName"
                       placeholder="이름 검색..."
                       value="${param.name}"
                       onkeydown="if(event.key==='Enter') doSearch()" />
            </div>
            <div class="search-wrap">
                <input type="text" class="search-input" id="searchPosition"
                       placeholder="직책 검색..."
                       value="${param.position}"
                       onkeydown="if(event.key==='Enter') doSearch()" />
            </div>
            <button type="button" class="btn-search" onclick="doSearch()">&#128269; 검색</button>
            <button type="button" class="btn-reset"  onclick="resetFilter()">초기화</button>
        </div>
    </div>

    <!-- 테이블 -->
    <div class="table-card">
        <table class="emp-table">
            <thead>
                <tr>
                    <th>프로필</th>
                    <th>사원번호</th>
                    <th>이름</th>
                    <th>연락처</th>
                    <th>나이</th>
                    <th>직책</th>
                    <th>입사일</th>
                    <th>퇴사일</th>
                    <th>시급</th>
                    <th>월급</th>
                    <th>풀/파트</th>
                    <th>은행</th>
                    <th>계좌번호</th>
                    <th>재직여부</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody id="empTableBody">
                <c:choose>
                    <c:when test="${empty employees}">
                        <tr><td colspan="15" class="empty-row">등록된 직원이 없습니다.</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="emp" items="${employees}">
                        <tr class="emp-row"
                            data-name="${emp.name}"
                            data-position="${emp.position}"
                            data-status="${emp.is_active}">

                            <td>
                                <c:choose>
                                    <c:when test="${not empty emp.profile}">
                                        <img class="emp-avatar" src="${emp.profile}" alt="${emp.name}"
                                             onclick="event.stopPropagation(); openProfileViewer('${emp.profile}', '${emp.name}')"
                                             style="cursor:zoom-in;" />
                                    </c:when>
                                    <c:otherwise>
                                        <div class="emp-avatar-placeholder">&#128100;</div>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="td-empnum">${emp.emp_num}</td>
                            <td class="td-name">${emp.name}</td>
                            <td class="td-phone">${emp.phone}</td>
                            <td>${emp.age}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${emp.position == '점장'}">
                                        <span class="position-badge pos-a">점장</span>
                                    </c:when>
                                    <c:when test="${emp.position == '매니저'}">
                                        <span class="position-badge pos-b">매니저</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="position-badge pos-c">${emp.position}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="td-date">${emp.hire_date}</td>
                            <td class="td-date">
                                <c:choose>
                                    <c:when test="${empty emp.resign_date}">-</c:when>
                                    <c:otherwise>${emp.resign_date}</c:otherwise>
                                </c:choose>
                            </td>
                            <td class="td-money">
                                <c:choose>
                                    <c:when test="${emp.hourly_wage > 0}">
                                        <fmt:formatNumber value="${emp.hourly_wage}" pattern="#,###"/>원
                                    </c:when>
                                    <c:otherwise>-</c:otherwise>
                                </c:choose>
                            </td>
                            <td class="td-money">
                                <c:choose>
                                    <c:when test="${emp.monthly_salary > 0}">
                                        <fmt:formatNumber value="${emp.monthly_salary}" pattern="#,###"/>원
                                    </c:when>
                                    <c:otherwise>-</c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${emp.contract_type == '풀'}">
                                        <span class="contract-badge full">정규직</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="contract-badge part">파트타임</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${emp.bank_name}</td>
                            <td class="td-account">${emp.account_no}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${emp.is_active == 1}">
                                        <span class="active-badge active">재직</span>
                                    </c:when>
                                    <c:when test="${emp.is_active == 2}">
                                        <span class="active-badge leave">휴직</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="active-badge resigned">퇴사</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="td-actions">
                                <c:choose>
                                    <c:when test="${emp.position == '점장' && emp.emp_num == '222'}">
                                        <span class="btn-locked" title="보호된 계정입니다">수정 불가</span>
                                        <span class="btn-locked" title="보호된 계정입니다">삭제 불가</span>
                                    </c:when>
                                    <c:otherwise>
                                        <button class="btn-edit"
                                                onclick="openEditModal('${emp.emp_num}')">
                                            수정
                                        </button>
                                        <button class="btn-delete"
                                                onclick="confirmDelete('${emp.emp_num}','${emp.name}')">
                                            삭제
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>


        <!-- ===== 페이지네이션 ===== -->
        <div class="pagination">

            <div class="page-size-select">
                <select onchange="changeSize(this.value)">
                    <option value="10"  ${size == 10  ? 'selected' : ''}>10개씩</option>
                    <option value="20"  ${size == 20  ? 'selected' : ''}>20개씩</option>
                    <option value="50"  ${size == 50  ? 'selected' : ''}>50개씩</option>
                </select>
            </div>

            <div class="page-nav">
                <c:if test="${currentPage > 1}">
                    <button class="page-btn" onclick="goPage(${currentPage - 1})">◀</button>
                </c:if>

                <c:forEach var="i" begin="1" end="${totalPages}">
                    <button class="page-btn ${i == currentPage ? 'active' : ''}"
                            onclick="goPage(${i})">${i}</button>
                </c:forEach>

                <c:if test="${currentPage < totalPages}">
                    <button class="page-btn" onclick="goPage(${currentPage + 1})">▶</button>
                </c:if>
            </div>

            <div class="page-total">총 ${totalCount}명</div>
        </div>

    </div><!-- /content -->


<form id="deleteForm" action="/hr/employees/delete" method="post" style="display:none;">
    <input type="hidden" id="deleteEmpNum" name="emp_num" />
</form>

<script>
/* ================================================================
   서버사이드 페이징 + 필터 네비게이션
================================================================ */
var _currentStatus = '${empty param.status ? "all" : param.status}';
var _currentSize   = ${empty size ? 10 : size};

function buildUrl(page, status, name, position, size) {
    var s   = status   || _currentStatus;
    var n   = name     !== undefined ? name     : document.getElementById('searchName').value.trim();
    var pos = position !== undefined ? position : document.getElementById('searchPosition').value.trim();
    var sz  = size     || _currentSize;
    var url = '/hr/employees?page=' + page + '&size=' + sz + '&status=' + encodeURIComponent(s);
    if (n)   url += '&name='     + encodeURIComponent(n);
    if (pos) url += '&position=' + encodeURIComponent(pos);
    return url;
}

/* 탭 클릭 → 서버 요청 (page=1 리셋) */
function goFilter(status) {
    location.href = buildUrl(1, status);
}

/* 검색 버튼 / Enter */
function doSearch() {
    location.href = buildUrl(1, _currentStatus);
}

/* 페이지 번호 클릭 */
function goPage(p) {
    location.href = buildUrl(p);
}

/* 페이지당 개수 변경 */
function changeSize(s) {
    _currentSize = s;
    location.href = buildUrl(1, _currentStatus,
        document.getElementById('searchName').value.trim(),
        document.getElementById('searchPosition').value.trim(),
        s);
}

/* 필터 초기화 */
function resetFilter() {
    location.href = '/hr/employees?page=1&size=' + _currentSize + '&status=all';
}

/* 직원 삭제 확인 */
function confirmDelete(empNum, name) {
    if (!confirm(name + ' 직원을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.')) return;
    document.getElementById('deleteEmpNum').value = empNum;
    document.getElementById('deleteForm').submit();
}
</script>



<!-- ================================================================
     등록 모달
================================================================ -->
<div class="emp-modal-overlay" id="registerModal">
  <div class="emp-modal">
    <div class="emp-modal-header">
      <span class="emp-modal-title">&#128100; 직원 등록</span>
      <button class="emp-modal-close" onclick="closeRegisterModal()">&#10005;</button>
    </div>
    <div class="emp-modal-body">
      <form action="/hr/employees/register" method="post" id="registerForm">
        <div class="form-grid">

          <!-- 프로필 사진 -->
          <div class="form-group form-group-full profile-upload-wrap">
            <div class="profile-upload-area" onclick="document.getElementById('regFileInput').click()">
              <img id="regProfilePreview" src="" alt="" style="display:none;width:100%;height:100%;object-fit:cover;border-radius:50%;" />
              <span class="profile-upload-icon" id="regProfileIcon">&#128100;</span>
            </div>
            <input type="file" id="regFileInput" accept="image/*" style="display:none"
                   onchange="handleProfileSelect(this,'regProfilePreview','regProfileIcon','regProfilePath','regDeleteBtn')" />
            <input type="hidden" id="regProfilePath" name="profile" value="" />
            <button type="button" id="regDeleteBtn" class="btn-profile-delete" style="display:none"
                    onclick="removeProfile('regProfilePreview','regProfileIcon','regProfilePath','regDeleteBtn','regFileInput')">
              &#10005; 사진 삭제
            </button>
            <span class="profile-upload-hint">클릭하여 사진 업로드 (선택사항)</span>
          </div>

          <div class="form-group">
            <label class="form-label">직원 번호</label>
            <div class="input-with-btn">
              <input type="text" class="form-input field-locked"
                     name="emp_num" id="regEmpNum" readonly placeholder="자동 생성됩니다" />
              <button type="button" class="btn-gen" onclick="genEmpNum()">&#8635; 재생성</button>
            </div>
            <span class="field-hint">CEP-XXXXXXXX 형식으로 자동 생성</span>
          </div>

          <div class="form-group">
            <label class="form-label required">이름</label>
            <input type="text" class="form-input" name="name" placeholder="직원 이름" />
          </div>

          <div class="form-group">
            <label class="form-label">나이</label>
            <input type="number" class="form-input" name="age" placeholder="나이" min="15" max="80" />
          </div>

          <div class="form-group">
            <label class="form-label">연락처</label>
            <input type="text" class="form-input" name="phone" placeholder="010-0000-0000" />
          </div>

          <div class="form-group">
            <label class="form-label required">직책</label>
            <select class="form-input form-select" name="position">
              <option value="">선택</option>
              <option value="점장">점장</option>
              <option value="매니저">매니저</option>
              <option value="스탭">스탭</option>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label required">고용 형태</label>
            <select class="form-input form-select" name="contract_type"
                    id="regContractType" onchange="toggleRegSalary()">
              <option value="">선택</option>
              <option value="파트">파트타임 (시급제)</option>
              <option value="풀">정규직 (월급제)</option>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label required">입사일</label>
            <input type="date" class="form-input" name="hire_date" />
          </div>

          <div class="form-group">
            <label class="form-label">퇴사일</label>
            <input type="date" class="form-input" name="resign_date" />
          </div>

          <div class="form-group" id="regHourlyGroup">
            <label class="form-label">시급 <span class="salary-type-badge part">파트타임</span></label>
            <div class="input-wrap">
              <input type="number" class="form-input input-with-unit field-locked"
                     name="hourly_wage" id="regHourlyWage"
                     placeholder="0" min="0" value="0" readonly />
              <span class="input-unit">원/h</span>
            </div>
            <span class="field-hint" id="regHourlyHint">파트타임 선택 시 입력 가능</span>
          </div>

          <div class="form-group" id="regSalaryGroup">
            <label class="form-label">월급 <span class="salary-type-badge full">정규직</span></label>
            <div class="input-wrap">
              <input type="number" class="form-input input-with-unit field-locked"
                     name="monthly_salary" id="regMonthlySalary"
                     placeholder="0" min="0" value="0" readonly />
              <span class="input-unit">원</span>
            </div>
            <span class="field-hint" id="regSalaryHint">정규직 선택 시 입력 가능</span>
          </div>

          <div class="form-group">
            <label class="form-label">은행명</label>
            <input type="text" class="form-input" name="bank_name" placeholder="예) 농협, 신한" />
          </div>

          <div class="form-group">
            <label class="form-label">계좌번호</label>
            <input type="text" class="form-input" name="account_no" placeholder="계좌번호 입력" />
          </div>

        </div>

        <div class="form-actions">
          <button type="button" class="btn-cancel" onclick="closeRegisterModal()">취소</button>
          <button type="button" class="btn-submit" onclick="submitRegisterForm()">등록</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- ================================================================
     수정 모달
================================================================ -->
<div class="emp-modal-overlay" id="editModal">
  <div class="emp-modal">
    <div class="emp-modal-header">
      <span class="emp-modal-title">&#9999;&#65039; 직원 수정</span>
      <button class="emp-modal-close" onclick="closeEditModal()">&#10005;</button>
    </div>
    <div class="emp-modal-body">
      <form action="/hr/employees/update" method="post" id="editForm">
        <div class="form-grid">

          <!-- 프로필 사진 -->
          <div class="form-group form-group-full profile-upload-wrap">
            <div class="profile-upload-area" onclick="document.getElementById('editFileInput').click()">
              <img id="editProfilePreview" src="" alt="" style="display:none;width:100%;height:100%;object-fit:cover;border-radius:50%;" />
              <span class="profile-upload-icon" id="editProfileIcon">&#128100;</span>
            </div>
            <input type="file" id="editFileInput" accept="image/*" style="display:none"
                   onchange="handleProfileSelect(this,'editProfilePreview','editProfileIcon','editProfilePath','editDeleteBtn')" />
            <input type="hidden" id="editProfilePath" name="profile" value="" />
            <button type="button" id="editDeleteBtn" class="btn-profile-delete" style="display:none"
                    onclick="removeProfile('editProfilePreview','editProfileIcon','editProfilePath','editDeleteBtn','editFileInput')">
              &#10005; 사진 삭제
            </button>
            <span class="profile-upload-hint">클릭하여 변경 (미선택 시 기존 사진 유지)</span>
          </div>

          <div class="form-group">
            <label class="form-label">직원 번호</label>
            <input type="text" class="form-input field-locked"
                   name="emp_num" id="editEmpNum" readonly />
          </div>

          <div class="form-group">
            <label class="form-label required">이름</label>
            <input type="text" class="form-input" name="name" id="editName" />
          </div>

          <div class="form-group">
            <label class="form-label">나이</label>
            <input type="number" class="form-input" name="age" id="editAge" min="15" max="80" />
          </div>

          <div class="form-group">
            <label class="form-label">연락처</label>
            <input type="text" class="form-input" name="phone" id="editPhone" />
          </div>

          <div class="form-group">
            <label class="form-label required">직책</label>
            <select class="form-input form-select" name="position" id="editPosition">
              <option value="">선택</option>
              <option value="점장">점장</option>
              <option value="매니저">매니저</option>
              <option value="스탭">스탭</option>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label required">고용 형태</label>
            <select class="form-input form-select" name="contract_type" id="editContractType">
              <option value="">선택</option>
              <option value="풀">정규직 (풀타임)</option>
              <option value="파트">파트타임</option>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label required">입사일</label>
            <input type="date" class="form-input" name="hire_date" id="editHireDate" />
          </div>

          <div class="form-group">
            <label class="form-label">퇴사일</label>
            <input type="date" class="form-input" name="resign_date" id="editResignDate" />
          </div>

          <div class="form-group">
            <label class="form-label">시급</label>
            <div class="input-wrap">
              <input type="number" class="form-input input-with-unit"
                     name="hourly_wage" id="editHourlyWage" min="0" />
              <span class="input-unit">원</span>
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">월급</label>
            <div class="input-wrap">
              <input type="number" class="form-input input-with-unit"
                     name="monthly_salary" id="editMonthlySalary" min="0" />
              <span class="input-unit">원</span>
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">은행명</label>
            <input type="text" class="form-input" name="bank_name" id="editBankName" />
          </div>

          <div class="form-group">
            <label class="form-label">계좌번호</label>
            <input type="text" class="form-input" name="account_no" id="editAccountNo" />
          </div>

          <div class="form-group form-group-full">
            <label class="form-label required">재직 여부</label>
            <div class="radio-group" id="editIsActiveGroup">
              <label class="radio-item">
                <input type="radio" name="is_active" value="1" /><span>재직</span>
              </label>
              <label class="radio-item">
                <input type="radio" name="is_active" value="2" /><span>휴직</span>
              </label>
              <label class="radio-item">
                <input type="radio" name="is_active" value="0" /><span>퇴사</span>
              </label>
            </div>
          </div>

        </div>

        <div class="form-actions">
          <button type="button" class="btn-cancel" onclick="closeEditModal()">취소</button>
          <button type="submit" class="btn-submit">수정 저장</button>
        </div>
      </form>
    </div>
  </div>
</div>

<script>
/* ================================================================
   등록 모달
================================================================ */
function openRegisterModal() {
    genEmpNum();
    toggleRegSalary();
    document.getElementById('registerForm').reset();
    genEmpNum();
    // 프로필 초기화
    document.getElementById('regProfilePath').value            = '';
    document.getElementById('regFileInput').value              = '';
    document.getElementById('regProfilePreview').style.display = 'none';
    document.getElementById('regProfileIcon').style.display    = '';
    document.getElementById('regDeleteBtn').style.display      = 'none';
    document.getElementById('registerModal').classList.add('active');
}

function closeRegisterModal() {
    document.getElementById('registerModal').classList.remove('active');
}

function genEmpNum() {
    var suffix = String(Date.now()).slice(-8);
    document.getElementById('regEmpNum').value = 'CEP-' + suffix;
}

function toggleRegSalary() {
    var type        = document.getElementById('regContractType').value;
    var hourlyInput = document.getElementById('regHourlyWage');
    var salaryInput = document.getElementById('regMonthlySalary');
    var hourlyHint  = document.getElementById('regHourlyHint');
    var salaryHint  = document.getElementById('regSalaryHint');

    if (type === '파트') {
        hourlyInput.readOnly = false; hourlyInput.classList.remove('field-locked');
        hourlyInput.value = ''; hourlyInput.placeholder = '시급 입력';
        hourlyHint.textContent = '';
        salaryInput.readOnly = true; salaryInput.classList.add('field-locked');
        salaryInput.value = '0'; salaryHint.textContent = '정규직 선택 시 입력 가능';
    } else if (type === '풀') {
        salaryInput.readOnly = false; salaryInput.classList.remove('field-locked');
        salaryInput.value = ''; salaryInput.placeholder = '월급 입력';
        salaryHint.textContent = '';
        hourlyInput.readOnly = true; hourlyInput.classList.add('field-locked');
        hourlyInput.value = '0'; hourlyHint.textContent = '파트타임 선택 시 입력 가능';
    } else {
        hourlyInput.readOnly = true; hourlyInput.classList.add('field-locked');
        hourlyInput.value = '0'; hourlyHint.textContent = '파트타임 선택 시 입력 가능';
        salaryInput.readOnly = true; salaryInput.classList.add('field-locked');
        salaryInput.value = '0'; salaryHint.textContent = '정규직 선택 시 입력 가능';
    }
}

function submitRegisterForm() {
    var name     = document.querySelector('#registerForm [name="name"]').value.trim();
    var position = document.querySelector('#registerForm [name="position"]').value;
    var type     = document.getElementById('regContractType').value;
    var hireDate = document.querySelector('#registerForm [name="hire_date"]').value;
    if (!name)     { alert('이름을 입력해주세요.'); return; }
    if (!position) { alert('직책을 선택해주세요.'); return; }
    if (!type)     { alert('고용 형태를 선택해주세요.'); return; }
    if (!hireDate) { alert('입사일을 선택해주세요.'); return; }
    document.getElementById('registerForm').submit();
}

/* ================================================================
   수정 모달
================================================================ */
function openEditModal(empNum) {
    fetch('/hr/employees/json/' + empNum)
        .then(function(res) {
            if (!res.ok) throw new Error('직원 정보를 불러오지 못했습니다.');
            return res.json();
        })
        .then(function(emp) {
            document.getElementById('editEmpNum').value        = emp.emp_num        || '';
            document.getElementById('editName').value          = emp.name           || '';
            document.getElementById('editAge').value           = emp.age            || '';
            document.getElementById('editPhone').value         = emp.phone          || '';
            document.getElementById('editPosition').value      = emp.position       || '';
            document.getElementById('editContractType').value  = emp.contract_type  || '';
            document.getElementById('editHireDate').value      = emp.hire_date      || '';
            document.getElementById('editResignDate').value    = emp.resign_date    || '';
            document.getElementById('editHourlyWage').value    = emp.hourly_wage    || 0;
            document.getElementById('editMonthlySalary').value = emp.monthly_salary || 0;
            document.getElementById('editBankName').value      = emp.bank_name      || '';
            document.getElementById('editAccountNo').value     = emp.account_no     || '';

            // 프로필
            var profilePath = emp.profile || '';
            document.getElementById('editProfilePath').value         = profilePath;
            document.getElementById('editFileInput').value           = '';
            var prev = document.getElementById('editProfilePreview');
            var icon = document.getElementById('editProfileIcon');
            var delBtn = document.getElementById('editDeleteBtn');
            if (profilePath) {
                prev.src = profilePath; prev.style.display = 'block';
                icon.style.display = 'none'; delBtn.style.display = '';
            } else {
                prev.src = ''; prev.style.display = 'none';
                icon.style.display = ''; delBtn.style.display = 'none';
            }

            // 재직 여부 라디오
            var radios = document.querySelectorAll('#editIsActiveGroup input[type="radio"]');
            radios.forEach(function(r) {
                r.checked = (parseInt(r.value) === parseInt(emp.is_active));
            });

            document.getElementById('editModal').classList.add('active');
        })
        .catch(function(err) { alert(err.message); });
}

function closeEditModal() {
    document.getElementById('editModal').classList.remove('active');
}

/* ================================================================
   프로필 사진 선택 → 서버 업로드 → hidden 필드에 경로 저장
================================================================ */
function removeProfile(previewId, iconId, pathFieldId, btnId, fileInputId) {
    document.getElementById(pathFieldId).value            = '';
    document.getElementById(fileInputId).value            = '';
    document.getElementById(previewId).style.display      = 'none';
    document.getElementById(iconId).style.display         = '';
    document.getElementById(btnId).style.display          = 'none';
}

function handleProfileSelect(input, previewId, iconId, pathFieldId, btnId) {
    if (!input.files || !input.files[0]) return;
    var file = input.files[0];
    var reader = new FileReader();
    reader.onload = function(e) {
        var img = new Image();
        img.onload = function() {
            // 최대 800px 리사이즈 + JPEG 85% 압축
            var MAX = 800, w = img.width, h = img.height;
            if (w > MAX || h > MAX) {
                if (w >= h) { h = Math.round(h * MAX / w); w = MAX; }
                else        { w = Math.round(w * MAX / h); h = MAX; }
            }
            var canvas = document.createElement('canvas');
            canvas.width = w; canvas.height = h;
            canvas.getContext('2d').drawImage(img, 0, 0, w, h);

            // 미리보기 즉시 표시
            document.getElementById(previewId).src           = canvas.toDataURL('image/jpeg', 0.85);
            document.getElementById(previewId).style.display = 'block';
            document.getElementById(iconId).style.display    = 'none';

            // 압축 blob → 전용 업로드 엔드포인트로 전송
            canvas.toBlob(function(blob) {
                var fd = new FormData();
                fd.append('file', blob, file.name);
                fetch('/hr/employees/profile-upload', { method: 'POST', body: fd })
                    .then(function(r) { return r.json(); })
                    .then(function(data) {
                        if (data.path) {
                            document.getElementById(pathFieldId).value = data.path;
                            document.getElementById(btnId).style.display = '';
                        } else {
                            alert('프로필 업로드 실패: ' + (data.error || '오류'));
                            document.getElementById(pathFieldId).value = '';
                        }
                    })
                    .catch(function() {
                        alert('프로필 업로드 중 네트워크 오류가 발생했습니다.');
                        document.getElementById(pathFieldId).value = '';
                    });
            }, 'image/jpeg', 0.85);
        };
        img.src = e.target.result;
    };
    reader.readAsDataURL(file);
}

/* 오버레이 클릭 시 닫기 */
document.getElementById('registerModal').addEventListener('click', function(e) {
    if (e.target === this) closeRegisterModal();
});
document.getElementById('editModal').addEventListener('click', function(e) {
    if (e.target === this) closeEditModal();
});
</script>



<!-- ===== 프로필 확대 뷰어 ===== -->
<div id="profileViewer" onclick="closeProfileViewer()"
     style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.82);
            z-index:9999; justify-content:center; align-items:center; flex-direction:column; gap:14px;">
    <img id="profileViewerImg" src="" alt=""
         style="width:300px; height:300px; border-radius:50%;
                border:4px solid #fff; box-shadow:0 8px 40px rgba(0,0,0,0.5);
                object-fit:cover; animation:pvZoom .2s ease;" />
    <div id="profileViewerName"
         style="color:#fff; font-size:1.05rem; font-weight:600; font-family:'Outfit',sans-serif;"></div>
    <div style="color:rgba(255,255,255,0.5); font-size:0.78rem;">클릭하거나 ESC로 닫기</div>
</div>
<style>
@keyframes pvZoom { from { transform:scale(0.7); opacity:0; } to { transform:scale(1); opacity:1; } }
</style>

<script>
function openProfileViewer(src, name) {
    var v = document.getElementById('profileViewer');
    document.getElementById('profileViewerImg').src         = src;
    document.getElementById('profileViewerName').innerText  = name || '';
    v.style.display = 'flex';
}
function closeProfileViewer() {
    document.getElementById('profileViewer').style.display = 'none';
}
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeProfileViewer();
});
</script>

</body>
</html>