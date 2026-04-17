<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그인 | ERP CAFE SYSTEM</title>
    <link rel="stylesheet" href="/css/header.css" />
    <link rel="stylesheet" href="/css/login.css" />
</head>
<body>

<div class="login-wrap">

    <!-- 로고 -->
    <div class="login-logo">
        <span class="login-logo-icon">&#9749;</span>
        <div class="login-logo-title">ERP CAFE SYSTEM</div>
        <p class="login-logo-sub">카페 통합 관리 시스템</p>
    </div>

    <!-- 로그인 카드 -->
    <div class="login-card">
        <h1 class="login-card-title">로그인</h1>

        <!-- 에러 메시지 -->
        <c:if test="${not empty sessionScope.loginError}">
            <div class="login-error">
                &#9888; ${sessionScope.loginError}
            </div>
            <c:remove var="loginError" scope="session" />
        </c:if>

        <form action="/login" method="post" id="loginForm">

            <div class="login-form-group">
                <label class="login-label" for="username">사원번호 (아이디)</label>
                <div class="login-input-wrap">
                    <span class="login-input-icon">&#128100;</span>
                    <input type="text" class="login-input" id="username"
                           name="username" placeholder="사원번호를 입력하세요"
                           autocomplete="username" />
                </div>
            </div>

            <div class="login-form-group">
                <label class="login-label" for="password">비밀번호</label>
                <div class="login-input-wrap">
                    <span class="login-input-icon">&#128274;</span>
                    <input type="password" class="login-input" id="password"
                           name="password" placeholder="비밀번호를 입력하세요"
                           autocomplete="current-password"
                           onkeydown="if(event.key==='Enter') document.getElementById('loginForm').submit()" />
                </div>
            </div>

            <button type="submit" class="login-btn">로그인</button>

        </form>
    </div>

</div>

</body>
</html>
