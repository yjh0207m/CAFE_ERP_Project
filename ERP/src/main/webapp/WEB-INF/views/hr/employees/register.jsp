<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>직원 등록 | ERP CAFE SYSTEM</title>
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
                <h1 class="page-title">직원 등록</h1>
                <p class="page-sub">인사관리 &gt; 직원 관리 &gt; 등록</p>
            </div>
        </div>
        <a href="/hr/employees" class="btn-back">&#8592; 목록으로</a>
    </div>

    <div class="form-card">
        <p class="form-section-title">기본 정보</p>

        <form action="/hr/employees/register" method="post" id="registerForm">

            <div class="form-grid">

                <!-- 사원번호 자동생성 -->
                <div class="form-group">
                    <label class="form-label">직원 번호</label>
                    <div class="input-with-btn">
                        <input type="text" class="form-input field-locked"
                               name="emp_num" id="empNum" readonly
                               placeholder="자동 생성됩니다" />
                        <button type="button" class="btn-gen" onclick="genEmpNum()">
                            &#8635; 재생성
                        </button>
                    </div>
                    <span class="field-hint">CEP-XXXXXXXX 형식으로 자동 생성</span>
                </div>

                <div class="form-group">
                    <label class="form-label required">이름</label>
                    <input type="text" class="form-input" name="name" placeholder="직원 이름" />
                </div>

                <div class="form-group">
                    <label class="form-label">나이</label>
                    <input type="number" class="form-input" name="age"
                           placeholder="나이" min="15" max="80" />
                </div>

                <div class="form-group">
                    <label class="form-label">연락처</label>
                    <input type="text" class="form-input" name="phone"
                           placeholder="010-0000-0000" />
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

                <!-- 고용형태 선택 → 시급/월급 자동 전환 -->
                <div class="form-group">
                    <label class="form-label required">고용 형태</label>
                    <select class="form-input form-select" name="contract_type"
                            id="contractType" onchange="toggleSalary()">
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

                <!-- 시급 (파트타임 선택 시 활성) -->
                <div class="form-group" id="hourlyGroup">
                    <label class="form-label">
                        시급 <span class="salary-type-badge part">파트타임</span>
                    </label>
                    <div class="input-wrap">
                        <input type="number" class="form-input input-with-unit field-locked"
                               name="hourly_wage" id="hourlyWage"
                               placeholder="0" min="0" value="0" readonly />
                        <span class="input-unit">원/h</span>
                    </div>
                    <span class="field-hint" id="hourlyHint">파트타임 선택 시 입력 가능</span>
                </div>

                <!-- 월급 (정규직 선택 시 활성) -->
                <div class="form-group" id="salaryGroup">
                    <label class="form-label">
                        월급 <span class="salary-type-badge full">정규직</span>
                    </label>
                    <div class="input-wrap">
                        <input type="number" class="form-input input-with-unit field-locked"
                               name="monthly_salary" id="monthlySalary"
                               placeholder="0" min="0" value="0" readonly />
                        <span class="input-unit">원</span>
                    </div>
                    <span class="field-hint" id="salaryHint">정규직 선택 시 입력 가능</span>
                </div>

                <div class="form-group">
                    <label class="form-label">은행명</label>
                    <input type="text" class="form-input" name="bank_name"
                           placeholder="예) 농협, 신한" />
                </div>

                <div class="form-group">
                    <label class="form-label">계좌번호</label>
                    <input type="text" class="form-input" name="account_no"
                           placeholder="계좌번호 입력" />
                </div>

            </div>

            <div class="form-actions">
                <button type="button" class="btn-cancel"
                        onclick="location.href='/hr/employees'">취소</button>
                <button type="button" class="btn-submit" onclick="submitForm()">등록</button>
            </div>

        </form>
    </div>
</div>

<script>
/* ===== 사원번호 자동생성 ===== */
function genEmpNum() {
    var suffix = String(Date.now()).slice(-8);
    document.getElementById('empNum').value = 'CEP-' + suffix;
}

/* ===== 고용형태 → 시급/월급 상호배타 ===== */
function toggleSalary() {
    var type        = document.getElementById('contractType').value;
    var hourlyInput = document.getElementById('hourlyWage');
    var salaryInput = document.getElementById('monthlySalary');
    var hourlyHint  = document.getElementById('hourlyHint');
    var salaryHint  = document.getElementById('salaryHint');

    if (type === '파트') {
        // 시급 활성
        hourlyInput.readOnly = false;
        hourlyInput.classList.remove('field-locked');
        hourlyInput.value = '';
        hourlyInput.placeholder = '시급 입력';
        hourlyHint.textContent = '';

        // 월급 비활성
        salaryInput.readOnly = true;
        salaryInput.classList.add('field-locked');
        salaryInput.value = '0';
        salaryHint.textContent = '정규직 선택 시 입력 가능';

    } else if (type === '풀') {
        // 월급 활성
        salaryInput.readOnly = false;
        salaryInput.classList.remove('field-locked');
        salaryInput.value = '';
        salaryInput.placeholder = '월급 입력';
        salaryHint.textContent = '';

        // 시급 비활성
        hourlyInput.readOnly = true;
        hourlyInput.classList.add('field-locked');
        hourlyInput.value = '0';
        hourlyHint.textContent = '파트타임 선택 시 입력 가능';

    } else {
        // 미선택 — 둘 다 비활성
        hourlyInput.readOnly = true;
        hourlyInput.classList.add('field-locked');
        hourlyInput.value = '0';
        hourlyHint.textContent = '파트타임 선택 시 입력 가능';

        salaryInput.readOnly = true;
        salaryInput.classList.add('field-locked');
        salaryInput.value = '0';
        salaryHint.textContent = '정규직 선택 시 입력 가능';
    }
}

/* ===== 유효성 검사 후 제출 ===== */
function submitForm() {
    var name     = document.querySelector('[name="name"]').value.trim();
    var position = document.querySelector('[name="position"]').value;
    var type     = document.getElementById('contractType').value;
    var hireDate = document.querySelector('[name="hire_date"]').value;

    if (!name)     { alert('이름을 입력해주세요.'); return; }
    if (!position) { alert('직책을 선택해주세요.'); return; }
    if (!type)     { alert('고용 형태를 선택해주세요.'); return; }
    if (!hireDate) { alert('입사일을 선택해주세요.'); return; }

    document.getElementById('registerForm').submit();
}

/* ===== 페이지 로드 시 초기화 ===== */
window.addEventListener('DOMContentLoaded', function() {
    genEmpNum();   // 사원번호 자동생성
    toggleSalary(); // 시급/월급 초기 잠금
});
</script>

</body>
</html>