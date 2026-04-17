<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>급여 내역 | ERP CAFE SYSTEM</title>
    <link rel="stylesheet" href="/css/header.css" />
    <link rel="stylesheet" href="/css/Common.css" />
    <link rel="stylesheet" href="/css/Finance/F_payrolls.css" />
</head>
<body>

<jsp:include page="/WEB-INF/views/header.jsp"/>

<div class="content">

    <!-- 페이지 헤더 -->
    <div class="page-header">
        <div class="page-title-wrap">
            <span class="page-icon">💵</span>
            <div>
                <h1 class="page-title">급여 내역</h1>
                <p class="page-sub">재무관리 &gt; 급여 내역</p>
            </div>
        </div>
        <button class="btn btn-primary" onclick="openAuthModal('manual')">+ 급여 수동처리</button>
    </div>

    <!-- 알림 메시지 -->
    <c:if test="${not empty msg}">
        <div class="alert-box">${msg}</div>
    </c:if>

    <!-- 필터 바 -->
    <div class="filter-bar">
        <select class="filter-input" id="filterYear" onchange="goFilter()">
            <option value="" ${empty param.payYear ? 'selected' : ''}>전체 연도</option>
            <!-- JS로 동적 생성 — buildYearOptions() 참조 -->
        </select>
        <select class="filter-input" id="filterMonth" onchange="goFilter()">
            <option value="" ${empty param.payMonth ? 'selected' : ''}>전체 월</option>
            <c:forEach begin="1" end="12" var="m">
                <option value="${m}" ${param.payMonth == m ? 'selected' : ''}>${m}월</option>
            </c:forEach>
        </select>
        <div class="search-box">
            <input type="text" class="filter-input" id="keywordInput"
                   placeholder="직원명 검색..." value="${param.keyword}"
                   onkeydown="if(event.key==='Enter') goFilter()" />
            <button class="btn btn-primary" onclick="goFilter()">&#128269; 검색</button>
        </div>
        <button class="btn btn-reset" onclick="resetFilter()">초기화</button>
    </div>

    <!-- 테이블 -->
    <div class="table-card">
        <div class="table-card-header">
            <h3>급여 목록</h3>
            <span style="font-size:0.82rem; color:var(--text-muted);">
                총 ${result.totalCount}건 중 ${result.list.size()}건 표시
            </span>
        </div>
        <table class="payroll-table">
            <thead>
                <tr>
                    <th>No.</th>
                    <th>직원명</th>
                    <th>사원번호</th>
                    <th>유형</th>
                    <th>지급연월</th>
                    <th>근무시간</th>
                    <th>기본급</th>
                    <th>공제액</th>
                    <th>실수령액</th>
                    <th>지급일</th>
                    <th>메모</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody id="tableBody">
                <c:choose>
                    <c:when test="${empty result.list}">
                        <tr><td colspan="12" class="empty-row">등록된 급여 내역이 없습니다.</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="p" items="${result.list}" varStatus="s">
                        <tr class="payroll-row">
                            <td class="td-no">${(result.page - 1) * result.size + s.count}</td>
                            <td class="td-name">${empty p.employeeName ? '-' : p.employeeName}</td>
                            <td class="td-empid">${empty p.employeeNo ? p.employeeId : p.employeeNo}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${empty p.payType || p.payType == 0}">
                                        <span class="pay-type-badge salary">&#128176; 급여</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="pay-type-badge incentive">&#127942; 인센티브</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${p.payYear}년 ${p.payMonth}월</td>
                            <td>${p.workHours}h</td>
                            <td class="td-money"><fmt:formatNumber value="${p.basePay}" pattern="#,###"/>원</td>
                            <td class="td-deduct"><fmt:formatNumber value="${p.deduction}" pattern="#,###"/>원</td>
                            <td class="td-net"><fmt:formatNumber value="${p.netPay}" pattern="#,###"/>원</td>
                            <td class="td-date">${empty p.paidAt ? '-' : p.paidAt}</td>
                            <td class="td-note">${empty p.note ? '-' : p.note}</td>
                            <td class="td-actions">
                                <button class="btn-icon btn-edit"
                                    onclick="openAuthModal('edit',
                                        ${p.id}, ${p.employeeId}, ${p.payYear}, ${p.payMonth},
                                        ${p.workHours}, ${p.basePay}, ${p.deduction}, ${p.netPay},
                                        '${empty p.paidAt ? "" : p.paidAt}',
                                        '${empty p.note ? "" : p.note}',
                                        ${empty p.payType ? 0 : p.payType})">&#9999;&#65039;</button>
                                <button class="btn-icon btn-delete"
                                    onclick="openAuthModal('delete', ${p.id})">&#128465;&#65039;</button>
                            </td>
                        </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>

        <!-- 페이지네이션 -->
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
                <c:forEach begin="${result.startPage}" end="${result.endPage}" var="pg">
                    <button class="page-btn ${pg == result.page ? 'active' : ''}"
                            onclick="goPage(${pg})">${pg}</button>
                </c:forEach>
                <c:if test="${result.hasNext()}">
                    <button class="page-btn" onclick="goPage(${result.endPage + 1})">▶</button>
                </c:if>
            </div>
            <div style="font-size:0.8rem; color:var(--text-muted);">총 ${result.totalCount}건</div>
        </div>
    </div>

</div><!-- /content -->


<!-- ================================================================
     관리자 인증 모달
================================================================ -->
<div class="modal-overlay" id="authModal">
    <div class="modal">
        <div class="modal-header">
            <span class="modal-title">&#128272; 관리자 인증</span>
            <button class="modal-close" onclick="closeModal('authModal')">&#10005;</button>
        </div>
        <div class="modal-body">
            <p class="auth-desc">이 작업은 관리자 인증이 필요합니다.</p>
            <div class="form-group">
                <label class="form-label required">사원번호 (아이디)</label>
                <input type="text" class="form-input" id="authId" placeholder="사원번호 입력" />
            </div>
            <div class="form-group">
                <label class="form-label required">비밀번호</label>
                <input type="password" class="form-input" id="authPw" placeholder="비밀번호 입력"
                       onkeydown="if(event.key==='Enter') submitAuth()" />
            </div>
            <p class="auth-error" id="authError"></p>
            <div class="modal-actions">
                <button class="btn btn-cancel" onclick="closeModal('authModal')">취소</button>
                <button class="btn btn-primary" onclick="submitAuth()">인증</button>
            </div>
        </div>
    </div>
</div>


<!-- ================================================================
     수정 모달
================================================================ -->
<div class="modal-overlay" id="editModal">
    <div class="modal modal-wide">
        <div class="modal-header">
            <span class="modal-title" id="editModalTitle">급여 수정</span>
            <button class="modal-close" onclick="closeModal('editModal')">&#10005;</button>
        </div>
        <div class="modal-body">
            <form id="editForm" action="/payroll/update" method="post">
                <input type="hidden" id="editId"         name="id" />
                <input type="hidden" id="editEmployeeId" name="employeeId" />
                <input type="hidden" id="editPayType"    name="payType" />
                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label required">지급 연도</label>
                        <input type="number" class="form-input" id="editYear" name="payYear" min="2020" max="2099" />
                    </div>
                    <div class="form-group">
                        <label class="form-label required">지급 월</label>
                        <input type="number" class="form-input" id="editMonth" name="payMonth" min="1" max="12" />
                    </div>

                    <!-- 근무시간: 급여=입력가능, 인센티브=잠금 -->
                    <div class="form-group">
                        <label class="form-label" id="editWorkHoursLabel">근무시간</label>
                        <div class="input-wrap">
                            <input type="number" class="form-input input-with-unit" id="editWorkHours" name="workHours" step="0.1" />
                            <span class="input-unit">h</span>
                        </div>
                    </div>

                    <!-- 기본급/지급액: 급여·인센티브 모두 입력가능, 입력 시 공제·실수령 자동계산 -->
                    <div class="form-group">
                        <label class="form-label required" id="editBasePayLabel">기본급</label>
                        <div class="input-wrap">
                            <input type="text" class="form-input input-with-unit" id="editBasePayDisp"
                                   oninput="onEditBasePayInput()" />
                            <input type="hidden" id="editBasePay" name="basePay" />
                            <span class="input-unit">원</span>
                        </div>
                        <span class="field-hint" id="editBasePayHint"></span>
                    </div>

                    <!-- 공제액: 급여·인센티브 모두 자동계산(잠금) -->
                    <div class="form-group">
                        <label class="form-label">공제액 <span class="calc-badge" id="editDeductBadge">자동 9.4%</span></label>
                        <div class="input-wrap">
                            <input type="text" class="form-input input-with-unit field-locked"
                                   id="editDeductionDisp" readonly />
                            <input type="hidden" id="editDeduction" name="deduction" />
                            <span class="input-unit">원</span>
                        </div>
                        <span class="field-hint">4대보험 기준 자동계산</span>
                    </div>

                    <!-- 실수령액: 급여·인센티브 모두 자동계산(잠금) -->
                    <div class="form-group">
                        <label class="form-label required">실수령액</label>
                        <div class="input-wrap">
                            <input type="text" class="form-input input-with-unit field-locked"
                                   id="editNetPayDisp" readonly />
                            <input type="hidden" id="editNetPay" name="netPay" />
                            <span class="input-unit">원</span>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">지급일</label>
                        <input type="date" class="form-input" id="editPaidAt" name="paidAt" />
                    </div>
                    <div class="form-group form-group-full">
                        <label class="form-label">메모</label>
                        <textarea class="form-input form-textarea" id="editNote" name="note"></textarea>
                    </div>
                </div>
                <div class="modal-actions">
                    <button type="button" class="btn btn-cancel" onclick="closeModal('editModal')">취소</button>
                    <button type="button" class="btn btn-primary" onclick="submitEdit()">저장</button>
                </div>
            </form>
        </div>
    </div>
</div>


<!-- ================================================================
     급여 수동처리 모달 (3-Step)
     Step 1 : 처리 유형 선택 (일반 급여 / 인센티브)
     Step 2 : 직원 선택     (검색 + 직위 탭 + 테이블)
     Step 3 : 금액 입력     (유형에 따라 폼 다르게)
================================================================ -->
<div class="modal-overlay" id="manualModal">
    <div class="modal modal-manual">

        <div class="modal-header">
            <div class="manual-step-header">
                <span class="modal-title">&#128181; 급여 수동처리</span>
                <div class="step-indicator">
                    <span class="step-dot active" id="stepDot1">1</span>
                    <span class="step-line"></span>
                    <span class="step-dot" id="stepDot2">2</span>
                    <span class="step-line"></span>
                    <span class="step-dot" id="stepDot3">3</span>
                </div>
            </div>
            <button class="modal-close" onclick="closeModal('manualModal')">&#10005;</button>
        </div>

        <!-- ── Step 1 : 처리 유형 선택 ───────────────────────── -->
        <div id="manualStep1" class="modal-body step-body">
            <p class="step-label">&#128196; 처리할 급여 유형을 선택하세요</p>

            <div class="pay-type-grid">
                <!-- 일반 급여 -->
                <div class="pay-type-card" id="typeCardSalary" onclick="selectPayType('salary')">
                    <div class="pay-type-icon">&#128176;</div>
                    <div class="pay-type-name">일반 급여</div>
                    <div class="pay-type-desc">
                        정기 급여 수동 처리<br>
                        <span class="pay-type-sub">기본급 · 공제액 · 실수령액 계산</span>
                    </div>
                    <span class="pay-type-radio" id="radioSalary"></span>
                </div>
                <!-- 인센티브 -->
                <div class="pay-type-card" id="typeCardIncentive" onclick="selectPayType('incentive')">
                    <div class="pay-type-icon">&#127942;</div>
                    <div class="pay-type-name">인센티브</div>
                    <div class="pay-type-desc">
                        성과급 · 특별 지급<br>
                        <span class="pay-type-sub">지급액 + 지급 사유 입력</span>
                    </div>
                    <span class="pay-type-radio" id="radioIncentive"></span>
                </div>
            </div>

            <div class="modal-actions">
                <button type="button" class="btn btn-cancel" onclick="closeModal('manualModal')">취소</button>
                <button type="button" class="btn btn-primary" id="btnStep1Next"
                        onclick="goStep2()" disabled>다음 &#8594;</button>
            </div>
        </div><!-- /step1 -->

        <!-- ── Step 2 : 직원 선택 ─────────────────────────── -->
        <div id="manualStep2" class="modal-body step-body" style="display:none;">
            <p class="step-label" id="step2Label">&#128100; 급여를 처리할 직원을 선택하세요</p>

            <!-- 검색 + 직위 탭 -->
            <div class="emp-search-bar">
                <div class="emp-search-input-wrap">
                    <span class="emp-search-icon">&#128269;</span>
                    <input type="text" id="empSearchInput"
                           class="emp-search-input"
                           placeholder="이름 검색..."
                           oninput="renderEmpTable()" />
                </div>
                <div class="emp-tab-row">
                    <button class="emp-tab active" data-pos="" onclick="setEmpTab(this)">전체</button>
                    <button class="emp-tab" data-pos="점장"   onclick="setEmpTab(this)">점장</button>
                    <button class="emp-tab" data-pos="매니저" onclick="setEmpTab(this)">매니저</button>
                    <button class="emp-tab" data-pos="스태프" onclick="setEmpTab(this)">스태프</button>
                    <span class="emp-count-badge" id="empCountBadge">0명</span>
                </div>
            </div>

            <!-- 직원 테이블 -->
            <div class="emp-table-wrap">
                <table class="emp-select-table">
                    <thead>
                        <tr>
                            <th style="width:48px;">선택</th>
                            <th>사원번호</th>
                            <th>이름</th>
                            <th>직위</th>
                            <th>고용형태</th>
                            <th>재직상태</th>
                        </tr>
                    </thead>
                    <tbody id="empTableBody">
                        <tr><td colspan="6" class="empty-row">직원 정보를 불러오는 중...</td></tr>
                    </tbody>
                </table>
            </div>

            <!-- 선택 미리보기 -->
            <div id="empSelectedPreview" class="emp-selected-preview" style="display:none;">
                <span class="preview-icon">&#10003;</span>
                <span id="previewText" class="preview-text"></span>
            </div>

            <div class="modal-actions">
                <button type="button" class="btn btn-cancel" onclick="goStep1()">&#8592; 이전</button>
                <button type="button" class="btn btn-primary" id="btnStep2Next"
                        onclick="goStep3()" disabled>다음 &#8594;</button>
            </div>
        </div><!-- /step2 -->

        <!-- ── Step 3a : 일반 급여 입력 ──────────────────────── -->
        <div id="manualStep3Salary" class="modal-body step-body" style="display:none;">

            <!-- 선택된 직원 배너 -->
            <div class="selected-emp-banner">
                <span class="banner-emp-icon">&#128100;</span>
                <div class="banner-emp-info">
                    <strong id="bannerNameS"></strong>
                    <span id="bannerDetailS"></span>
                </div>
                <button type="button" class="btn-change-emp" onclick="goStep2()">직원 변경</button>
            </div>

            <form id="manualForm" action="/payroll/manual" method="post">
                <input type="hidden" name="employeeId" id="manualEmpId" />
                <input type="hidden" name="payType"    value=0 />

                <!-- 지급일에서 JS로 연도/월 추출해서 채움 -->
                <input type="hidden" name="payYear"  id="manualYear" />
                <input type="hidden" name="payMonth" id="manualMonth" />

                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label" id="workHoursLabel">근무시간</label>
                        <div class="input-wrap">
                            <input type="number" class="form-input input-with-unit"
                                   name="workHours" id="manualWorkHours"
                                   step="0.1" value="0" min="0"
                                   oninput="onWorkHoursInput()" />
                            <span class="input-unit">h</span>
                        </div>
                        <span class="field-hint" id="workHoursHint"></span>
                    </div>
                    <div class="form-group">
                        <label class="form-label">기본급 <span class="lock-badge">&#128274;</span></label>
                        <div class="input-wrap">
                            <input type="text" class="form-input input-with-unit field-locked"
                                   id="manualBaseDisp" readonly placeholder="직원 선택 후 자동계산" />
                            <input type="hidden" name="basePay" id="manualBasePay" />
                            <span class="input-unit">원</span>
                        </div>
                        <span class="field-hint" id="basePayHint"></span>
                    </div>
                    <div class="form-group">
                        <label class="form-label">공제액 <span class="calc-badge">자동 9.4%</span></label>
                        <div class="input-wrap">
                            <input type="text" class="form-input input-with-unit field-locked"
                                   id="manualDeductDisp" readonly />
                            <input type="hidden" name="deduction" id="manualDeduction" />
                            <span class="input-unit">원</span>
                        </div>
                        <span class="field-hint">4대보험 기준 자동계산</span>
                    </div>
                    <div class="form-group">
                        <label class="form-label required">실수령액</label>
                        <div class="input-wrap">
                            <input type="text" class="form-input input-with-unit"
                                   id="manualNetDisp"
                                   oninput="formatAmountInput(this, 'manualNetPay')"
                                   placeholder="자동계산 또는 직접 수정" />
                            <input type="hidden" name="netPay" id="manualNetPay" />
                            <span class="input-unit">원</span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label required">지급일</label>
                        <input type="date" class="form-input" name="paidAt" id="manualPaidAt"
                               onchange="onSalaryDateChange(this.value)" />
                        <span class="field-hint">연도·월은 지급일에서 자동 추출됩니다</span>
                    </div>
                    <div class="form-group form-group-full">
                        <label class="form-label">메모</label>
                        <textarea class="form-input form-textarea" name="note" id="manualNote"></textarea>
                    </div>
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn btn-cancel" onclick="goStep2()">&#8592; 이전</button>
                    <button type="button" class="btn btn-primary" onclick="submitManual()">처리</button>
                </div>
            </form>
        </div><!-- /step3-salary -->

        <!-- ── Step 3b : 인센티브 입력 ───────────────────────── -->
        <div id="manualStep3Incentive" class="modal-body step-body" style="display:none;">

            <!-- 선택된 직원 배너 -->
            <div class="selected-emp-banner incentive-banner">
                <span class="banner-emp-icon">&#127942;</span>
                <div class="banner-emp-info">
                    <strong id="bannerNameI"></strong>
                    <span id="bannerDetailI"></span>
                </div>
                <button type="button" class="btn-change-emp" onclick="goStep2()">직원 변경</button>
            </div>

            <form id="incentiveForm" action="/payroll/manual" method="post">
                <input type="hidden" name="employeeId" id="incentiveEmpId" />
                <input type="hidden" name="payType"    value=1 />
                <!-- 일반 급여 필드 고정값 — 백엔드 파라미터 맞춤 -->
                <input type="hidden" name="basePay"   value="0" />
                <input type="hidden" name="deduction" id="incentiveDeduction" value="0" />
                <input type="hidden" name="workHours" value="0" />

                <div class="incentive-amount-wrap">
                    <label class="form-label required">인센티브 지급액 (세전)</label>
                    <div class="input-wrap incentive-amount-input-wrap">
                        <input type="text" class="form-input input-with-unit incentive-amount-input"
                               id="incentiveAmountDisp"
                               placeholder="0"
                               oninput="onIncentiveAmountInput(this)" />
                        <input type="hidden" name="netPay" id="incentiveNetPay" />
                        <span class="input-unit">원</span>
                    </div>
                    <span class="field-hint" id="incentiveDeductHint" style="color:var(--text-muted);"></span>
                </div>

                <!-- 지급일에서 JS로 연도/월 추출해서 채움 -->
                <input type="hidden" name="payYear"  id="incentiveYear" />
                <input type="hidden" name="payMonth" id="incentiveMonth" />

                <div class="form-grid" style="margin-top:16px;">
                    <div class="form-group form-group-full">
                        <label class="form-label required">지급일</label>
                        <input type="date" class="form-input" name="paidAt" id="incentivePaidAt"
                               onchange="onIncentiveDateChange(this.value)" />
                        <span class="field-hint">연도·월은 지급일에서 자동 추출됩니다</span>
                    </div>
                    <div class="form-group form-group-full">
                        <label class="form-label required">지급 사유</label>
                        <textarea class="form-input form-textarea" name="note" id="incentiveNote"
                                  placeholder="예: 3월 판매 목표 달성 인센티브, 우수 직원 포상 등"
                                  style="min-height:80px;"></textarea>
                    </div>
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn btn-cancel" onclick="goStep2()">&#8592; 이전</button>
                    <button type="button" class="btn btn-primary" onclick="submitIncentive()">처리</button>
                </div>
            </form>
        </div><!-- /step3-incentive -->

    </div>
</div>


<!-- 삭제용 hidden form -->
<form id="deleteForm" action="/payroll/delete" method="post" style="display:none;">
    <input type="hidden" id="deleteId" name="id" />
</form>


<!-- ================================================================
     직원 데이터 주입 (JSTL → JS 배열)
     Employees.java 필드명 기준: emp_num, contract_type,
     hourly_wage, monthly_salary, is_active (0=휴직/1=재직/2=퇴사)
================================================================ -->
<script>
var EMP_LIST = [
    <c:forEach var="e" items="${employeeList}" varStatus="s">
    {
        id:            ${e.id},
        empNum:        '${e.emp_num}',
        name:          '${e.name}',
        position:      '${e.position}',
        contractType:  '${e.contract_type}',
        status:        '<c:choose><c:when test="${e.is_active == 1}">재직</c:when><c:when test="${e.is_active == 2}">퇴사</c:when><c:otherwise>휴직</c:otherwise></c:choose>',
        hourlyWage:    ${empty e.hourly_wage    ? 0 : e.hourly_wage},
        monthlySalary: ${empty e.monthly_salary ? 0 : e.monthly_salary}
    }<c:if test="${!s.last}">,</c:if>
    </c:forEach>
];
</script>

<script>
/* ================================================================
   연도 select 동적 생성 (2020 ~ 현재 연도)
================================================================ */
(function buildYearOptions() {
    var sel      = document.getElementById('filterYear');
    var thisYear = new Date().getFullYear();
    var selected = '${param.payYear}';
    for (var y = thisYear; y >= thisYear - 5; y--) {
        var opt = document.createElement('option');
        opt.value     = y;
        opt.textContent = y + '년';
        if (String(y) === selected) opt.selected = true;
        sel.appendChild(opt);
    }
})();

/* ================================================================
   페이지 필터 / 페이징
================================================================ */
var currentSize = ${empty size ? 10 : size};

function buildUrl(page) {
    var year    = document.getElementById('filterYear').value;
    var month   = document.getElementById('filterMonth').value;
    var keyword = document.getElementById('keywordInput').value.trim();
    var url = '/f_payrolls?page=' + page + '&size=' + currentSize;
    if (year)    url += '&payYear='  + encodeURIComponent(year);
    if (month)   url += '&payMonth=' + encodeURIComponent(month);
    if (keyword) url += '&keyword='  + encodeURIComponent(keyword);
    return url;
}
function goPage(p)     { location.href = buildUrl(p); }
function goFilter()    { location.href = buildUrl(1); }
function changeSize(s) { currentSize = s; location.href = buildUrl(1); }
function resetFilter() { location.href = '/f_payrolls?page=1&size=' + currentSize; }

/* ================================================================
   모달 공통
================================================================ */
function openModal(id)  { document.getElementById(id).classList.add('active'); }
function closeModal(id) { document.getElementById(id).classList.remove('active'); }

document.querySelectorAll('.modal-overlay').forEach(function(o) {
    o.addEventListener('click', function(e) { if (e.target === o) closeModal(o.id); });
});

/* ================================================================
   관리자 인증
================================================================ */
var _pendingAction = null;
var _pendingArgs   = [];

function openAuthModal(action) {
    _pendingAction = action;
    _pendingArgs   = Array.prototype.slice.call(arguments, 1);
    document.getElementById('authId').value        = '';
    document.getElementById('authPw').value        = '';
    document.getElementById('authError').innerText = '';
    openModal('authModal');
    setTimeout(function() { document.getElementById('authId').focus(); }, 200);
}

function submitAuth() {
    var uid = document.getElementById('authId').value.trim();
    var upw = document.getElementById('authPw').value.trim();
    if (!uid || !upw) {
        document.getElementById('authError').innerText = '아이디와 비밀번호를 입력해주세요.';
        return;
    }
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '/payroll/auth', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onload = function() {
        if (xhr.responseText === 'ok') {
            closeModal('authModal');
            if      (_pendingAction === 'edit')   { openEditModal.apply(null, _pendingArgs); }
            else if (_pendingAction === 'delete') { execDelete(_pendingArgs[0]); }
            else if (_pendingAction === 'manual') { openManualModal(); }
        } else {
            document.getElementById('authError').innerText = '아이디 또는 비밀번호가 올바르지 않습니다.';
        }
    };
    xhr.send('userId=' + encodeURIComponent(uid) + '&userPw=' + encodeURIComponent(upw));
}

/* ================================================================
   수정 모달
================================================================ */
function openEditModal(id, empId, year, month, workHours, basePay, deduction, netPay, paidAt, note, payType) {
    var isSalary = (parseInt(payType, 10) === 0);

    document.getElementById('editId').value         = id;
    document.getElementById('editEmployeeId').value = empId;
    document.getElementById('editPayType').value    = payType;
    document.getElementById('editYear').value       = year;
    document.getElementById('editMonth').value      = month;
    document.getElementById('editPaidAt').value     = paidAt;
    document.getElementById('editNote').value       = note;

    // 모달 타이틀
    document.getElementById('editModalTitle').innerHTML =
        isSalary ? '&#128176; 급여 수정' : '&#127942; 인센티브 수정';

    var workHoursEl   = document.getElementById('editWorkHours');
    var basePayDispEl = document.getElementById('editBasePayDisp');

    if (isSalary) {
        /* ── 일반 급여: 기본급 입력 가능, 공제액·실수령액 자동계산, 근무시간 입력가능 ── */
        workHoursEl.value   = workHours;
        workHoursEl.readOnly = false;
        workHoursEl.classList.remove('field-locked');

        basePayDispEl.value    = Number(basePay).toLocaleString();
        basePayDispEl.readOnly = false;
        basePayDispEl.classList.remove('field-locked');

        document.getElementById('editBasePayLabel').innerHTML  = '기본급';
        document.getElementById('editWorkHoursLabel').textContent = '근무시간';
        document.getElementById('editDeductBadge').style.display  = '';
        document.getElementById('editBasePayHint').textContent = '기본급 입력 시 공제액·실수령액 자동계산';

        // 기본급 기준으로 공제/실수령 자동계산 세팅
        editCalcFromBase(Number(basePay));

    } else {
        /* ── 인센티브: 근무시간 잠금 / 지급액 입력가능 + 공제·실수령 자동계산 ── */
        workHoursEl.value    = workHours;
        workHoursEl.readOnly = true;
        workHoursEl.classList.add('field-locked');

        basePayDispEl.value    = Number(basePay).toLocaleString();
        basePayDispEl.readOnly = false;
        basePayDispEl.classList.remove('field-locked');

        document.getElementById('editBasePayLabel').innerHTML     = '지급액 (세전)';
        document.getElementById('editWorkHoursLabel').textContent = '근무시간 (잠금)';
        document.getElementById('editDeductBadge').style.display  = '';
        document.getElementById('editBasePayHint').textContent    = '지급액 입력 시 공제액·실수령액 자동계산';

        // 기존 지급액 기준으로 공제/실수령 자동계산 세팅
        editCalcFromBase(Number(basePay));
    }

    document.getElementById('editBasePay').value = basePay;
    openModal('editModal');
}

/* 기본급 입력 → 공제·실수령 자동계산 (급여 수정 전용) */
function onEditBasePayInput() {
    var raw  = document.getElementById('editBasePayDisp').value.replace(/[^0-9]/g, '');
    document.getElementById('editBasePayDisp').value = raw ? Number(raw).toLocaleString() : '';
    editCalcFromBase(parseInt(raw || '0', 10));
}

function editCalcFromBase(basePay) {
    var deduction = Math.round(basePay * 0.094);
    var netPay    = basePay - deduction;
    document.getElementById('editBasePay').value      = basePay;
    document.getElementById('editDeductionDisp').value = deduction.toLocaleString();
    document.getElementById('editDeduction').value    = deduction;
    document.getElementById('editNetPayDisp').value   = netPay.toLocaleString();
    document.getElementById('editNetPay').value       = netPay;
}

function formatAmount(input) {
    var val = input.value.replace(/[^0-9]/g, '');
    input.value = val ? Number(val).toLocaleString() : '';
}

function submitEdit() {
    var basePay = document.getElementById('editBasePay').value;
    if (!basePay || basePay === '0') {
        alert('기본급(지급액)을 입력해주세요.');
        return;
    }
    document.getElementById('editForm').submit();
}

/* ================================================================
   삭제
================================================================ */
function execDelete(id) {
    if (!confirm('해당 급여 내역을 삭제하시겠습니까?')) return;
    document.getElementById('deleteId').value = id;
    document.getElementById('deleteForm').submit();
}

/* ================================================================
   수동처리 모달 — 3-Step 제어
   Step1: 유형선택 / Step2: 직원선택 / Step3: 금액입력
================================================================ */
var _selectedEmp   = null;
var _contractType  = '';
var _hourlyWage    = 0;
var _currentTabPos = '';
var _payType       = '';   // 'salary' | 'incentive'

function openManualModal() {
    _selectedEmp   = null;
    _contractType  = '';
    _hourlyWage    = 0;
    _currentTabPos = '';
    _payType       = '';

    /* 유형 카드 초기화 */
    document.getElementById('typeCardSalary').classList.remove('selected');
    document.getElementById('typeCardIncentive').classList.remove('selected');
    document.getElementById('radioSalary').classList.remove('pay-type-radio-on');
    document.getElementById('radioIncentive').classList.remove('pay-type-radio-on');
    document.getElementById('btnStep1Next').disabled = true;

    showStep(1);
    openModal('manualModal');
}

function showStep(n) {
    document.getElementById('manualStep1').style.display           = (n === 1) ? '' : 'none';
    document.getElementById('manualStep2').style.display           = (n === 2) ? '' : 'none';
    document.getElementById('manualStep3Salary').style.display     = (n === 3 && _payType === 'salary')    ? '' : 'none';
    document.getElementById('manualStep3Incentive').style.display  = (n === 3 && _payType === 'incentive') ? '' : 'none';
    /* 인디케이터 */
    document.getElementById('stepDot1').classList.toggle('active', n >= 1);
    document.getElementById('stepDot2').classList.toggle('active', n >= 2);
    document.getElementById('stepDot3').classList.toggle('active', n >= 3);
}

/* ── Step1: 유형 선택 ── */
function selectPayType(type) {
    _payType = type;
    document.getElementById('typeCardSalary').classList.toggle('selected',    type === 'salary');
    document.getElementById('typeCardIncentive').classList.toggle('selected',  type === 'incentive');
    document.getElementById('radioSalary').classList.toggle('pay-type-radio-on',    type === 'salary');
    document.getElementById('radioIncentive').classList.toggle('pay-type-radio-on', type === 'incentive');
    document.getElementById('btnStep1Next').disabled = false;
}

function goStep1() {
    showStep(1);
}

/* ── Step2: 직원 선택으로 이동 ── */
function goStep2() {
    if (!_payType) { alert('처리 유형을 선택해주세요.'); return; }

    /* Step2 라벨 업데이트 */
    document.getElementById('step2Label').innerText =
        (_payType === 'incentive' ? '🏆' : '👤')
        + ' 처리할 직원을 선택하세요';

    /* 직원 선택 초기화 */
    _selectedEmp = null;
    _currentTabPos = '';
    document.querySelectorAll('.emp-tab').forEach(function(t) { t.classList.remove('active'); });
    document.querySelector('.emp-tab[data-pos=""]').classList.add('active');
    document.getElementById('empSearchInput').value = '';
    document.getElementById('empSelectedPreview').style.display = 'none';
    document.getElementById('btnStep2Next').disabled = true;

    showStep(2);
    renderEmpTable();
}

/* ── Step3: 금액 입력으로 이동 ── */
function goStep3() {
    if (!_selectedEmp) { alert('직원을 선택해주세요.'); return; }

    var nameText   = '[' + _selectedEmp.empNum + '] ' + _selectedEmp.name;
    var detailText = _selectedEmp.position + ' / ' + _selectedEmp.contractType;

    if (_payType === 'salary') {
        /* 배너 */
        document.getElementById('bannerNameS').innerText   = nameText;
        document.getElementById('bannerDetailS').innerText = detailText;

        /* hidden 세팅 */
        document.getElementById('manualEmpId').value = _selectedEmp.id;

        /* 급여 필드 초기화 */
        _contractType = _selectedEmp.contractType;
        _hourlyWage   = _selectedEmp.hourly_wage || _selectedEmp.hourlyWage || 0;

        document.getElementById('manualWorkHours').value  = '0';
        ['manualBaseDisp','manualBasePay','manualDeductDisp',
         'manualDeduction','manualNetDisp','manualNetPay',
         'manualPaidAt','manualNote'].forEach(function(id) {
            document.getElementById(id).value = '';
        });
        document.getElementById('basePayHint').innerText   = '';
        document.getElementById('workHoursHint').innerText = '';

        var isFull = (_contractType === '풀');
        if (isFull) {
            document.getElementById('workHoursLabel').innerText = '근무시간';
            document.getElementById('workHoursHint').innerText  = '정규직은 기록용 (기본급에 영향 없음)';
            document.getElementById('basePayHint').innerText    = '정규직 월급 고정';
            calcAndSetPay(_selectedEmp.monthly_salary || _selectedEmp.monthlySalary || 0);
        } else {
            document.getElementById('workHoursLabel').innerText = '근무시간 (입력 필수)';
            document.getElementById('workHoursHint').innerText  =
                '시급 ' + Number(_hourlyWage).toLocaleString() + '원/h — 시간 입력 시 기본급 자동계산';
            document.getElementById('basePayHint').innerText    = '시급 × 근무시간 자동계산';
            calcAndSetPay(0);
        }

    } else {
        /* 인센티브 */
        document.getElementById('bannerNameI').innerText   = nameText;
        document.getElementById('bannerDetailI').innerText = detailText;

        document.getElementById('incentiveEmpId').value       = _selectedEmp.id;
        document.getElementById('incentiveAmountDisp').value  = '';
        document.getElementById('incentiveNetPay').value      = '';
        document.getElementById('incentiveDeduction').value   = '0';
        document.getElementById('incentiveYear').value        = '';
        document.getElementById('incentiveMonth').value       = '';
        document.getElementById('incentivePaidAt').value      = '';
        document.getElementById('incentiveNote').value        = '';
        document.getElementById('incentiveDeductHint').innerHTML = '';
    }

    showStep(3);
}

/* ================================================================
   직원 테이블 렌더링
================================================================ */
function setEmpTab(btn) {
    document.querySelectorAll('.emp-tab').forEach(function(t) { t.classList.remove('active'); });
    btn.classList.add('active');
    _currentTabPos = btn.getAttribute('data-pos');
    renderEmpTable();
}

function renderEmpTable() {
    var keyword = document.getElementById('empSearchInput').value.trim().toLowerCase();
    var filtered = EMP_LIST.filter(function(e) {
        var matchPos = (_currentTabPos === '' || e.position === _currentTabPos);
        var matchKw  = (keyword === '' ||
                        e.name.toLowerCase().indexOf(keyword) >= 0 ||
                        e.empNum.toLowerCase().indexOf(keyword) >= 0);
        return matchPos && matchKw;
    });

    document.getElementById('empCountBadge').innerText = filtered.length + '명';
    var tbody = document.getElementById('empTableBody');

    if (filtered.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="empty-row">해당하는 직원이 없습니다.</td></tr>';
        return;
    }

    var html = '';
    filtered.forEach(function(e) {
        var isSel   = _selectedEmp && _selectedEmp.id === e.id;
        var stClass = (e.status === '재직' || e.status === '') ? 'status-active' : 'status-leave';
        html += '<tr class="emp-row' + (isSel ? ' emp-row-selected' : '') + '"'
              + ' onclick="selectEmp(' + e.id + ')">'
              + '<td><span class="emp-radio' + (isSel ? ' emp-radio-on' : '') + '"></span></td>'
              + '<td class="td-empnum">' + e.empNum + '</td>'
              + '<td><strong>' + e.name + '</strong></td>'
              + '<td>' + e.position + '</td>'
              + '<td><span class="contract-badge contract-' + e.contractType.replace(/\s/g,'') + '">'
              +     e.contractType + '</span></td>'
              + '<td><span class="status-badge ' + stClass + '">' + (e.status || '재직') + '</span></td>'
              + '</tr>';
    });
    tbody.innerHTML = html;
}

function selectEmp(id) {
    _selectedEmp = null;
    for (var i = 0; i < EMP_LIST.length; i++) {
        if (EMP_LIST[i].id === id) { _selectedEmp = EMP_LIST[i]; break; }
    }
    if (!_selectedEmp) return;

    document.getElementById('empSelectedPreview').style.display = '';
    document.getElementById('previewText').innerText =
        '[' + _selectedEmp.empNum + '] ' + _selectedEmp.name
        + '  ' + _selectedEmp.position + ' / ' + _selectedEmp.contractType;
    document.getElementById('btnStep2Next').disabled = false;

    renderEmpTable();
}

/* ================================================================
   급여 자동계산 (일반 급여 전용)
================================================================ */
function onWorkHoursInput() {
    if (_contractType === '풀') return;
    var hours = parseFloat(document.getElementById('manualWorkHours').value) || 0;
    calcAndSetPay(Math.round(_hourlyWage * hours));
}

function calcAndSetPay(basePay) {
    var deduction = Math.round(basePay * 0.094);
    var netPay    = basePay - deduction;
    document.getElementById('manualBaseDisp').value   = basePay.toLocaleString();
    document.getElementById('manualBasePay').value    = basePay;
    document.getElementById('manualDeductDisp').value = deduction.toLocaleString();
    document.getElementById('manualDeduction').value  = deduction;
    document.getElementById('manualNetDisp').value    = netPay.toLocaleString();
    document.getElementById('manualNetPay').value     = netPay;
}

function formatAmountInput(dispInput, hiddenId) {
    var val = dispInput.value.replace(/[^0-9]/g, '');
    dispInput.value = val ? Number(val).toLocaleString() : '';
    document.getElementById(hiddenId).value = val || '0';
}

/* 인센티브 금액 입력 → 9.4% 공제 자동계산 */
function onIncentiveAmountInput(dispInput) {
    var val       = dispInput.value.replace(/[^0-9]/g, '');
    dispInput.value = val ? Number(val).toLocaleString() : '';
    var gross     = parseInt(val || '0', 10);
    var deduction = Math.round(gross * 0.094);
    var netPay    = gross - deduction;
    document.getElementById('incentiveNetPay').value    = netPay;
    document.getElementById('incentiveDeduction').value = deduction;
    var hintEl = document.getElementById('incentiveDeductHint');
    if (gross > 0) {
        hintEl.innerHTML = '공제액 <strong>' + deduction.toLocaleString() + '원</strong> (9.4%)'
            + ' &nbsp;→&nbsp; 실수령액 <strong>' + netPay.toLocaleString() + '원</strong>';
    } else {
        hintEl.innerHTML = '';
    }
}

/* ================================================================
   제출
================================================================ */
/* 지급일 → payYear / payMonth 자동 추출 */
function onSalaryDateChange(val) {
    if (!val) return;
    var parts = val.split('-');
    document.getElementById('manualYear').value  = parts[0];
    document.getElementById('manualMonth').value = parseInt(parts[1], 10);
}

function submitManual() {
    if (!document.getElementById('manualEmpId').value) {
        alert('직원을 선택해주세요.'); return;
    }
    var paidAt = document.getElementById('manualPaidAt').value;
    if (!paidAt) {
        alert('지급일을 선택해주세요.'); return;
    }
    var bp = document.getElementById('manualBasePay').value;
    if (!bp || bp === '0') {
        alert('기본급이 0원입니다.\n근무시간을 입력하거나 직원을 다시 선택해주세요.'); return;
    }
    /* 지급일에서 연도/월 채우기 (onchange 미발생 케이스 대비) */
    onSalaryDateChange(paidAt);
    document.getElementById('manualForm').submit();
}

/* 지급일 → payYear / payMonth 자동 추출 */
function onIncentiveDateChange(val) {
    if (!val) return;
    var parts = val.split('-');
    document.getElementById('incentiveYear').value  = parts[0];
    document.getElementById('incentiveMonth').value = parseInt(parts[1], 10);
}

function submitIncentive() {
    if (!document.getElementById('incentiveEmpId').value) {
        alert('직원을 선택해주세요.'); return;
    }
    var amt = document.getElementById('incentiveNetPay').value;
    if (!amt || amt === '0') {
        alert('인센티브 지급액을 입력해주세요.'); return;
    }
    var paidAt = document.getElementById('incentivePaidAt').value;
    if (!paidAt) {
        alert('지급일을 선택해주세요.'); return;
    }
    if (!document.getElementById('incentiveNote').value.trim()) {
        alert('지급 사유를 입력해주세요.'); return;
    }
    /* 지급일에서 연도/월 채우기 (onchange 미발생 케이스 대비) */
    onIncentiveDateChange(paidAt);
    document.getElementById('incentiveForm').submit();
}
</script>

</body>
</html>
