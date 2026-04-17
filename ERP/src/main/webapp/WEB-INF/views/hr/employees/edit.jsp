<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>직원 수정 | ERP CAFE SYSTEM</title>
    <link rel="stylesheet" href="/css/header.css" />
    <link rel="stylesheet" href="/css/Employee/employee.css" />
</head>
<body>

<jsp:include page="/WEB-INF/views/header.jsp" />

<div class="content">

    <div class="page-header">
        <div class="page-title-wrap">
            <span class="page-icon">&#9999;&#65039;</span>
            <div>
                <h1 class="page-title">직원 수정</h1>
                <p class="page-sub">인사관리 &gt; 직원 관리 &gt; 수정</p>
            </div>
        </div>
        <a href="/hr/employees" class="btn-back">&#8592; 목록으로</a>
    </div>

    <div class="form-card">
        <p class="form-section-title">직원 정보 수정</p>

        <form action="/hr/employees/update" method="post">

            <div class="form-grid">

                <div class="form-group">
                    <label class="form-label">직원 번호</label>
                    <input type="text" class="form-input field-locked"
                           name="emp_num" value="${employee.emp_num}" readonly />
                </div>

                <div class="form-group">
                    <label class="form-label required">이름</label>
                    <input type="text" class="form-input" name="name" value="${employee.name}" />
                </div>

                <div class="form-group">
                    <label class="form-label">나이</label>
                    <input type="number" class="form-input" name="age"
                           value="${employee.age}" min="15" max="80" />
                </div>

                <div class="form-group">
                    <label class="form-label">연락처</label>
                    <input type="text" class="form-input" name="phone" value="${employee.phone}" />
                </div>

                <div class="form-group">
                    <label class="form-label required">직책</label>
                    <select class="form-input form-select" name="position">
                        <option value="">선택</option>
                        <option value="점장"   ${employee.position == '점장'   ? 'selected' : ''}>점장</option>
                        <option value="매니저" ${employee.position == '매니저' ? 'selected' : ''}>매니저</option>
                        <option value="스탭"   ${employee.position == '스탭'   ? 'selected' : ''}>스탭</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label required">고용 형태</label>
                    <select class="form-input form-select" name="contract_type">
                        <option value="">선택</option>
                        <option value="풀"  ${employee.contract_type == '풀'   ? 'selected' : ''}>정규직 (풀타임)</option>
                        <option value="파트" ${employee.contract_type == '파트' ? 'selected' : ''}>파트타임</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label required">입사일</label>
                    <input type="date" class="form-input" name="hire_date" value="${employee.hire_date}" />
                </div>

                <div class="form-group">
                    <label class="form-label">퇴사일</label>
                    <input type="date" class="form-input" name="resign_date"
                           value="${employee.resign_date}" />
                </div>

                <div class="form-group">
                    <label class="form-label">시급</label>
                    <div class="input-wrap">
                        <input type="number" class="form-input input-with-unit" name="hourly_wage"
                               value="${employee.hourly_wage}" min="0" />
                        <span class="input-unit">원</span>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">월급</label>
                    <div class="input-wrap">
                        <input type="number" class="form-input input-with-unit" name="monthly_salary"
                               value="${employee.monthly_salary}" min="0" />
                        <span class="input-unit">원</span>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">은행명</label>
                    <input type="text" class="form-input" name="bank_name" value="${employee.bank_name}" />
                </div>

                <div class="form-group">
                    <label class="form-label">계좌번호</label>
                    <input type="text" class="form-input" name="account_no" value="${employee.account_no}" />
                </div>

                <div class="form-group form-group-full">
                    <label class="form-label required">재직 여부</label>
                    <div class="radio-group">
                        <label class="radio-item">
                            <input type="radio" name="is_active" value="1"
                                   ${employee.is_active == 1 ? 'checked' : ''} />
                            <span>재직</span>
                        </label>
                        <label class="radio-item">
                            <input type="radio" name="is_active" value="2"
                                   ${employee.is_active == 2 ? 'checked' : ''} />
                            <span>휴직</span>
                        </label>
                        <label class="radio-item">
                            <input type="radio" name="is_active" value="0"
                                   ${employee.is_active == 0 ? 'checked' : ''} />
                            <span>퇴사</span>
                        </label>
                    </div>
                </div>

            </div>

            <div class="form-actions">
                <button type="button" class="btn-cancel"
                        onclick="location.href='/hr/employees'">취소</button>
                <button type="submit" class="btn-submit">수정 저장</button>
            </div>

        </form>
    </div>
</div>

</body>
</html>