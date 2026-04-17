<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>근태 관리 | ERP CAFE SYSTEM</title>
    <link rel="stylesheet" href="/css/header.css" />
    <link rel="stylesheet" href="/css/attendance/attendance.css" />
</head>
<body>

<jsp:include page="/WEB-INF/views/header.jsp" />

<div class="content">

    <div class="page-header">
        <div class="page-title-wrap">
            <span class="page-icon">&#128197;</span>
            <div>
                <h1 class="page-title">근태 관리</h1>
                <p class="page-sub">인사관리 &gt; 근태 관리</p>
            </div>
        </div>
    </div>

    <div class="calendar-card">
        <jsp:include page="attendance/calendar.jsp" />
    </div>

</div>
</body>
</html>