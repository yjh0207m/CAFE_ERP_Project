<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>

<div class="calendar-wrap">

    <!-- 캘린더 헤더 -->
    <div class="cal-header">
        <button class="cal-nav-btn" onclick="prevMonth()">&#9664;</button>
        <h3 class="cal-title" id="calendarTitle" onclick="showYearSelector()">
            <span id="titleText"></span>
            <span class="cal-title-hint">▾</span>
        </h3>
        <button class="cal-nav-btn" onclick="nextMonth()">&#9654;</button>
    </div>

    <!-- 연도/월 셀렉터 -->
    <div id="yearSelector"  class="cal-selector" style="display:none;"></div>
    <div id="monthSelector" class="cal-selector" style="display:none;"></div>

    <!-- 요일 헤더 -->
    <div class="cal-grid">
        <div class="cal-dow sun">일</div>
        <div class="cal-dow">월</div>
        <div class="cal-dow">화</div>
        <div class="cal-dow">수</div>
        <div class="cal-dow">목</div>
        <div class="cal-dow fri">금</div>
        <div class="cal-dow sat">토</div>

        <!-- 날짜 셀 -->
        <div id="calendarBody" style="display:contents;"></div>
    </div>

    <!-- 범례 -->
    <div class="cal-legend">
        <span class="legend-dot green"></span> 출근 기록 있음
        <span class="legend-dot gray" style="margin-left:16px;"></span> 기록 없음
    </div>

</div>

<script>
var attendanceData  = {};
var attendanceNames = {};

<%
List<Map<String, Object>> countList = (List<Map<String, Object>>) request.getAttribute("attendanceCount");
if (countList != null) {
    for (Map<String, Object> row : countList) {
%>
attendanceData["<%=row.get("work_date")%>"] = <%=row.get("count")%>;
<%
    }
}

List<Map<String, Object>> nameList = (List<Map<String, Object>>) request.getAttribute("attendanceNames");
if (nameList != null) {
    for (Map<String, Object> row : nameList) {
%>
if (!attendanceNames["<%=row.get("work_date")%>"]) {
    attendanceNames["<%=row.get("work_date")%>"] = [];
}
attendanceNames["<%=row.get("work_date")%>"].push("<%=row.get("name")%>");
<%
    }
}
%>

var today        = new Date();
var currentYear  = today.getFullYear();
var currentMonth = today.getMonth();

function renderCalendar() {
    document.getElementById("yearSelector").style.display  = "none";
    document.getElementById("monthSelector").style.display = "none";

    var firstDay = new Date(currentYear, currentMonth, 1).getDay();
    var lastDate = new Date(currentYear, currentMonth + 1, 0).getDate();

    document.getElementById("titleText").innerText =
        currentYear + "년 " + (currentMonth + 1) + "월";

    var body = document.getElementById("calendarBody");
    body.innerHTML = "";

    var todayStr = today.getFullYear() + "-"
        + String(today.getMonth() + 1).padStart(2, "0") + "-"
        + String(today.getDate()).padStart(2, "0");

    // 빈 셀
    for (var i = 0; i < firstDay; i++) {
        body.innerHTML += '<div class="cal-cell empty"></div>';
    }

    for (var day = 1; day <= lastDate; day++) {
        var dateStr = currentYear + "-"
            + String(currentMonth + 1).padStart(2, "0") + "-"
            + String(day).padStart(2, "0");

        var count     = attendanceData[dateStr]  || 0;
        var names     = attendanceNames[dateStr] || [];
        var nameHtml  = names.length > 0
            ? "<ul class='att-names'>" + names.map(function(n){ return "<li>" + n + "</li>"; }).join("") + "</ul>"
            : "";

        var isToday   = (dateStr === todayStr) ? " today" : "";
        var hasAtt    = count > 0 ? " has-att" : "";
        var col       = (firstDay + day - 1) % 7;
        var dayClass  = col === 0 ? " sun" : col === 6 ? " sat" : "";

        body.innerHTML +=
            '<div class="cal-cell' + isToday + hasAtt + dayClass + '" onclick="moveDate(\'' + dateStr + '\')">'
          +   '<span class="cal-day-num">' + day + '</span>'
          +   (count > 0 ? '<span class="att-count">출근 ' + count + '명</span>' : '')
          +   (nameHtml ? '<div class="att-tooltip">' + nameHtml + '</div>' : '')
          + '</div>';
    }
}

function showYearSelector() {
    var box = document.getElementById("yearSelector");
    box.style.display = "block";
    document.getElementById("monthSelector").style.display = "none";

    var html = '<div class="year-scroll">';
    for (var y = currentYear - 10; y <= currentYear + 5; y++) {
        var sel = y === currentYear ? ' class="selected"' : '';
        html += '<div' + sel + ' onclick="selectYear(' + y + ')">' + y + '년</div>';
    }
    html += '</div>';
    box.innerHTML = html;

    // 현재 연도로 스크롤
    setTimeout(function() {
        var sel = box.querySelector('.selected');
        if (sel) sel.scrollIntoView({ block: 'center' });
    }, 50);
}

function selectYear(year) {
    currentYear = year;
    document.getElementById("yearSelector").style.display = "none";

    var box  = document.getElementById("monthSelector");
    box.style.display = "block";
    var months = ["1월","2월","3월","4월","5월","6월","7월","8월","9월","10월","11월","12월"];
    var html = '<div class="month-grid">';
    months.forEach(function(m, i) {
        var sel = i === currentMonth ? ' class="selected"' : '';
        html += '<div' + sel + ' onclick="selectMonth(' + (i+1) + ')">' + m + '</div>';
    });
    html += '</div>';
    box.innerHTML = html;
}

function selectMonth(month) {
    currentMonth = month - 1;
    document.getElementById("monthSelector").style.display = "none";
    renderCalendar();
}

function prevMonth() {
    currentMonth--;
    if (currentMonth < 0) { currentMonth = 11; currentYear--; }
    renderCalendar();
}

function nextMonth() {
    currentMonth++;
    if (currentMonth > 11) { currentMonth = 0; currentYear++; }
    renderCalendar();
}

function moveDate(date) {
    location.href = "/hr/attendanceIn?date=" + date;
}

renderCalendar();
</script>