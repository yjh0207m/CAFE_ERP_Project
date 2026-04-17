 <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>근태 상세 | ERP CAFE SYSTEM</title>
    <link rel="stylesheet" href="/css/header.css" />
    <link rel="stylesheet" href="/css/attendance/attendance.css" />
</head>
<body>

<jsp:include page="/WEB-INF/views/header.jsp" />

<div class="content">

    <!-- 페이지 헤더 -->
    <div class="page-header">
        <div class="page-title-wrap">
            <span class="page-icon">&#128203;</span>
            <div>
                <h1 class="page-title">${date} 근태 현황</h1>
                <p class="page-sub">인사관리 &gt; 근태 관리 &gt; 상세</p>
            </div>
        </div>
        <a href="/hr/attendance" class="btn-back">&#8592; 달력으로</a>
    </div>

    <!-- 검색 + 필터 바 -->
    <div class="filter-bar">
        <div class="search-wrap">
            <span class="search-icon">&#128269;</span>
            <input type="text" id="searchName" class="search-input"
                   placeholder="직원 이름 검색..." oninput="applyFilter()" />
        </div>
        <select class="filter-select" id="filterStatus" onchange="applyFilter()">
            <option value="all">전체</option>
            <option value="none">미출근</option>
            <option value="working">출근 중</option>
            <option value="done">근무 완료</option>
        </select>
        <button class="btn-reset" onclick="resetFilter()">초기화</button>
        <span class="filter-count" id="filterCount"></span>

        <!-- 일괄변경 버튼 (체크 시 활성화) -->
        <div class="bulk-actions" id="bulkActions" style="display:none;">
            <span class="bulk-selected" id="bulkSelected">0명 선택</span>
            <button class="btn-bulk" onclick="openBulkModal()">&#9999; 일괄 시간 변경</button>
        </div>
    </div>

    <!-- 테이블 카드 -->
    <div class="table-card">
        <form action="/hr/saveAttendance" method="post" id="attForm">

            <div class="att-table-wrap">
            <table class="att-table">
                <thead>
                    <tr>
                        <th class="th-check">
                            <input type="checkbox" id="checkAll" onchange="toggleAll(this)" />
                        </th>
                        <th>직원 ID</th>
                        <th>직원 이름</th>
                        <th>근무 날짜</th>
                        <th>출근 시간</th>
                        <th>근무 시간</th>
                        <th>퇴근 시간</th>
                        <th>상태</th>
                        <th>특이사항</th>
                    </tr>
                </thead>
                <tbody id="attTableBody">
                    <c:choose>
                        <c:when test="${empty attendance}">
                            <tr>
                                <td colspan="9" class="empty-row">등록된 근태 기록이 없습니다.</td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="a" items="${attendance}" varStatus="s">
                            <tr class="att-row"
                                data-name="${a.name}"
                                data-clockin="${a.clock_in}"
                                data-clockout="${a.clock_out}">

                                <!-- 체크박스 -->
                                <td class="td-check">
                                    <input type="checkbox" class="row-check"
                                           onchange="onCheckChange()" />
                                </td>

                                <td class="td-id">
                                    <input type="hidden" name="list[${s.index}].employee_id"
                                           value="${a.employee_id}" />
                                    ${a.employee_id}
                                </td>
                                <td class="td-name">${a.name}</td>
                                <td class="td-date">
                                    <input type="hidden" name="list[${s.index}].work_date_str"
                                           value="${date}" />
                                    ${date}
                                </td>
                                <td>
                                    <input type="time" class="time-input clock-in"
                                           name="list[${s.index}].clock_in_str"
                                           value="${a.clock_in}"
                                           onchange="calcWorkHours(this.closest('tr')); updateStatus(this.closest('tr'))" />
                                </td>
                                <td>
                                    <input type="text" class="hours-input"
                                           name="list[${s.index}].work_hours_str"
                                           value="${a.work_hours}" readonly placeholder="자동계산" />
                                </td>
                                <td>
                                    <input type="time" class="time-input clock-out"
                                           name="list[${s.index}].clock_out_str"
                                           value="${a.clock_out}"
                                           onchange="calcWorkHours(this.closest('tr')); updateStatus(this.closest('tr'))" />
                                </td>
                                <td class="td-status">
                                    <c:choose>
                                        <c:when test="${empty a.clock_in}">
                                            <span class="status-badge none">미출근</span>
                                        </c:when>
                                        <c:when test="${not empty a.clock_in and empty a.clock_out}">
                                            <span class="status-badge working">출근 중</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge done">완료</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <input type="text" class="note-input"
                                           name="list[${s.index}].note"
                                           value="${a.note}" placeholder="특이사항 입력" />
                                </td>
                            </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
            </div><%-- /att-table-wrap --%>

            <div class="form-actions">
                <button type="submit" class="btn-save">저장</button>
            </div>

        </form>

        <!-- 페이징 -->
        <div class="pagination">
            <%-- 이전 블록 --%>
            <c:choose>
                <c:when test="${startPage > 1}">
                    <a href="/hr/attendanceIn?date=${date}&page=${startPage - 1}&size=${size}">◀</a>
                </c:when>
                <c:otherwise>
                    <span class="disabled">◀</span>
                </c:otherwise>
            </c:choose>

            <%-- 페이지 번호 --%>
            <c:forEach begin="${startPage}" end="${endPage}" var="p">
                <c:choose>
                    <c:when test="${p == currentPage}">
                        <span class="active">${p}</span>
                    </c:when>
                    <c:otherwise>
                        <a href="/hr/attendanceIn?date=${date}&page=${p}&size=${size}">${p}</a>
                    </c:otherwise>
                </c:choose>
            </c:forEach>

            <%-- 다음 블록 --%>
            <c:choose>
                <c:when test="${endPage < totalPages}">
                    <a href="/hr/attendanceIn?date=${date}&page=${endPage + 1}&size=${size}">▶</a>
                </c:when>
                <c:otherwise>
                    <span class="disabled">▶</span>
                </c:otherwise>
            </c:choose>
        </div>
        <p class="page-info">전체 ${totalCount}명 / ${currentPage} 페이지 (${totalPages} 페이지)</p>

    </div><%-- /table-card --%>

</div>

<!-- ===== 일괄변경 모달 ===== -->
<div class="modal-overlay" id="bulkModal">
    <div class="modal">
        <div class="modal-header">
            <span class="modal-title">&#9999; 일괄 시간 변경</span>
            <button class="modal-close" onclick="closeModal()">&#10005;</button>
        </div>
        <div class="modal-body">
            <p class="modal-desc" id="modalDesc">선택된 직원의 시간을 일괄 변경합니다.</p>

            <!-- 변경 대상 선택 -->
            <div class="form-group">
                <label class="form-label">변경 항목</label>
                <div class="radio-group">
                    <label class="radio-item">
                        <input type="radio" name="bulkTarget" value="both" checked onchange="onTargetChange()" />
                        <span>출근 + 퇴근 모두</span>
                    </label>
                    <label class="radio-item">
                        <input type="radio" name="bulkTarget" value="in" onchange="onTargetChange()" />
                        <span>출근 시간만</span>
                    </label>
                    <label class="radio-item">
                        <input type="radio" name="bulkTarget" value="out" onchange="onTargetChange()" />
                        <span>퇴근 시간만</span>
                    </label>
                </div>
            </div>

            <!-- 출근 시간 입력 -->
            <div class="form-group" id="inTimeGroup">
                <label class="form-label">출근 시간</label>
                <input type="time" class="time-input-modal" id="bulkClockIn" value="09:00" />
            </div>

            <!-- 퇴근 시간 입력 -->
            <div class="form-group" id="outTimeGroup">
                <label class="form-label">퇴근 시간</label>
                <input type="time" class="time-input-modal" id="bulkClockOut" value="18:00" />
            </div>

            <div class="modal-actions">
                <button class="btn-cancel" onclick="closeModal()">취소</button>
                <button class="btn-apply" onclick="applyBulk()">적용</button>
            </div>
        </div>
    </div>
</div>

<script>
/* ===== 근무시간 자동계산 ===== */
function calcWorkHours(row) {
    var clockIn    = row.querySelector(".clock-in").value;
    var clockOut   = row.querySelector(".clock-out").value;
    var hoursInput = row.querySelector(".hours-input");

    if (clockIn && clockOut) {
        var inTime  = new Date("2000-01-01T" + clockIn);
        var outTime = new Date("2000-01-01T" + clockOut);
        var diff    = (outTime - inTime) / 1000 / 60 / 60;
        if (diff < 0) { alert("퇴근 시간이 출근 시간보다 빠릅니다."); hoursInput.value = ""; return; }
        if (diff >= 6) diff -= 1;
        hoursInput.value = diff.toFixed(1) + "h";
    } else {
        hoursInput.value = "";
    }
}

/* ===== 상태 배지 업데이트 ===== */
function updateStatus(row) {
    var clockIn  = row.querySelector(".clock-in").value;
    var clockOut = row.querySelector(".clock-out").value;
    row.setAttribute("data-clockin",  clockIn);
    row.setAttribute("data-clockout", clockOut);

    var badge = row.querySelector(".td-status");
    if (!clockIn) {
        badge.innerHTML = '<span class="status-badge none">미출근</span>';
    } else if (clockIn && !clockOut) {
        badge.innerHTML = '<span class="status-badge working">출근 중</span>';
    } else {
        badge.innerHTML = '<span class="status-badge done">완료</span>';
    }
    applyFilter();
}

/* ===== 전체 체크 ===== */
function toggleAll(master) {
    var rows = getVisibleRows();
    rows.forEach(function(row) {
        row.querySelector(".row-check").checked = master.checked;
    });
    onCheckChange();
}

/* ===== 체크 변경 ===== */
function onCheckChange() {
    var all     = document.querySelectorAll(".row-check");
    var checked = document.querySelectorAll(".row-check:checked");

    document.getElementById("checkAll").checked =
        all.length > 0 && checked.length === all.length;
    document.getElementById("checkAll").indeterminate =
        checked.length > 0 && checked.length < all.length;

    var bulkActions = document.getElementById("bulkActions");
    var bulkSelected = document.getElementById("bulkSelected");

    if (checked.length > 0) {
        bulkActions.style.display = "flex";
        bulkSelected.textContent  = checked.length + "명 선택됨";
    } else {
        bulkActions.style.display = "none";
    }
}

/* ===== 검색 + 필터 ===== */
function applyFilter() {
    var keyword = document.getElementById("searchName").value.trim().toLowerCase();
    var status  = document.getElementById("filterStatus").value;
    var rows    = document.querySelectorAll(".att-row");
    var visible = 0;

    rows.forEach(function(row) {
        var name     = (row.getAttribute("data-name") || "").toLowerCase();
        var clockIn  = row.getAttribute("data-clockin")  || "";
        var clockOut = row.getAttribute("data-clockout") || "";

        var nameMatch = keyword === "" || name.includes(keyword);
        var statusMatch = false;

        if (status === "all") {
            statusMatch = true;
        } else if (status === "none") {
            statusMatch = clockIn === "" || clockIn === "null";
        } else if (status === "working") {
            statusMatch = clockIn !== "" && clockIn !== "null"
                       && (clockOut === "" || clockOut === "null");
        } else if (status === "done") {
            statusMatch = clockIn !== "" && clockIn !== "null"
                       && clockOut !== "" && clockOut !== "null";
        }

        var show = nameMatch && statusMatch;
        row.style.display = show ? "" : "none";
        if (show) visible++;
    });

    var countEl = document.getElementById("filterCount");
    if (keyword || status !== "all") {
        countEl.textContent  = visible + " / " + rows.length + "명 표시 중";
        countEl.style.display = "inline";
    } else {
        countEl.style.display = "none";
    }

    // 검색 결과 없음
    var noResult = document.getElementById("noResult");
    if (visible === 0 && rows.length > 0) {
        if (!noResult) {
            var tr = document.createElement("tr");
            tr.id  = "noResult";
            tr.innerHTML = '<td colspan="9" class="empty-row">검색 결과가 없습니다.</td>';
            document.getElementById("attTableBody").appendChild(tr);
        }
    } else {
        if (noResult) noResult.remove();
    }
}

function resetFilter() {
    document.getElementById("searchName").value   = "";
    document.getElementById("filterStatus").value = "all";
    applyFilter();
}

function getVisibleRows() {
    return Array.from(document.querySelectorAll(".att-row"))
        .filter(function(r) { return r.style.display !== "none"; });
}

/* ===== 일괄변경 모달 ===== */
function openBulkModal() {
    var checked = document.querySelectorAll(".row-check:checked").length;
    document.getElementById("modalDesc").textContent =
        "선택된 " + checked + "명의 출퇴근 시간을 일괄 변경합니다.";
    document.getElementById("bulkModal").classList.add("active");
    onTargetChange();
}

function closeModal() {
    document.getElementById("bulkModal").classList.remove("active");
}

function onTargetChange() {
    var target = document.querySelector("input[name='bulkTarget']:checked").value;
    document.getElementById("inTimeGroup").style.display  =
        (target === "both" || target === "in")  ? "" : "none";
    document.getElementById("outTimeGroup").style.display =
        (target === "both" || target === "out") ? "" : "none";
}

function applyBulk() {
    var target   = document.querySelector("input[name='bulkTarget']:checked").value;
    var bulkIn   = document.getElementById("bulkClockIn").value;
    var bulkOut  = document.getElementById("bulkClockOut").value;

    var checkedRows = Array.from(document.querySelectorAll(".att-row"))
        .filter(function(row) {
            return row.querySelector(".row-check").checked;
        });

    checkedRows.forEach(function(row) {
        if ((target === "both" || target === "in") && bulkIn) {
            row.querySelector(".clock-in").value = bulkIn;
        }
        if ((target === "both" || target === "out") && bulkOut) {
            row.querySelector(".clock-out").value = bulkOut;
        }
        calcWorkHours(row);
        updateStatus(row);
    });

    closeModal();

    // 적용 완료 토스트
    showToast(checkedRows.length + "명에게 시간이 적용되었습니다.");
}

/* ===== 토스트 메시지 ===== */
function showToast(msg) {
    var toast = document.getElementById("toast");
    if (!toast) {
        toast = document.createElement("div");
        toast.id = "toast";
        toast.className = "toast";
        document.body.appendChild(toast);
    }
    toast.textContent = msg;
    toast.classList.add("show");
    setTimeout(function() { toast.classList.remove("show"); }, 2500);
}

/* ===== 모달 오버레이 클릭 닫기 ===== */
document.getElementById("bulkModal").addEventListener("click", function(e) {
    if (e.target === this) closeModal();
});

/* ===== 초기 실행 ===== */
document.addEventListener("DOMContentLoaded", function() { applyFilter(); });
</script>

</body>
</html>