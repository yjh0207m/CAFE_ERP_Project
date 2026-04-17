<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- 세션에서 로그인 직원 정보 가져오기 --%>
<%
String loginName     = (String) session.getAttribute("loginName");
String loginEmpNum   = (String) session.getAttribute("loginEmpNum");
String loginPosition = (String) session.getAttribute("loginPosition");
String loginProfile  = (String) session.getAttribute("loginProfile");

if (loginName     == null) loginName     = "알 수 없음";
if (loginEmpNum   == null) loginEmpNum   = "-";
if (loginPosition == null) loginPosition = "-";

String avatarChar = loginName.length() > 0 ? String.valueOf(loginName.charAt(0)) : "?";
%>

<link rel="stylesheet" href="/css/header.css" />

<!-- ===== 헤더 ===== -->
<div class="header">
    <div class="header-left" onclick="location.href='/MainPage'">ERP CAFE SYSTEM</div>
    <div class="header-right">

        <%-- 알림 버튼 + 드롭다운 --%>
        <div class="notification-wrap" id="notificationWrap">
            <button class="notif-btn" onclick="toggleNotifDropdown()" id="notifBtn">
                🔔
                <span class="notif-badge" id="notifBadge" style="display:none;">0</span>
            </button>
            <div class="notif-dropdown" id="notifDropdown">
                <div class="notif-header">
                    <span>📢 최근 공지사항</span>
                    <a href="/notice" class="notif-more">전체보기 →</a>
                </div>
                <div class="notif-list" id="notifList">
                    <div class="notif-empty">불러오는 중...</div>
                </div>
            </div>
        </div>

        <span id="clock"></span>
        👤 <%=loginName%>
        <button class="logout-btn" onclick="location.href='/logout'">로그아웃</button>
    </div>
</div>

<!-- ===== 사이드바 ===== -->
<div class="sidebar">

    <div class="menu-title">&lt;메뉴&gt;</div>

    <ul class="menu">

        <li class="has-submenu" onclick="toggleSubmenu(this)">📦 제품관리
            <ul class="submenu">
                <li onclick="event.stopPropagation(); location.href='/product/menu'">메뉴 관리</li>
            </ul>
        </li>

        <li class="has-submenu" onclick="toggleSubmenu(this)">📊 재고관리
            <ul class="submenu">
                <li onclick="event.stopPropagation(); location.href='/inventory'">재고 현황</li>
                <% if ("점장".equals(loginPosition)) { %>
                <li onclick="event.stopPropagation(); location.href='/inventory/vendor'">거래처 관리</li>
                <% } %>
                <li onclick="event.stopPropagation(); location.href='/inventory/order/history'">발주 내역</li>
                <li onclick="event.stopPropagation(); location.href='/inventory/order'">발주</li>
            </ul>
        </li>

        <% if ("점장".equals(loginPosition)) { %>
        <li class="has-submenu" onclick="toggleSubmenu(this)">👥 인사관리
            <ul class="submenu">
                <li onclick="event.stopPropagation(); location.href='/hr/attendance'">근태 관리</li>
                <li onclick="event.stopPropagation(); location.href='/hr/employees'">직원 관리</li>
                <li onclick="event.stopPropagation(); location.href='/hr/users'">ERP 사용자 관리</li>
            </ul>
        </li>
        <% } %>

        <li class="has-submenu" onclick="toggleSubmenu(this)">🧾 주문관리
            <ul class="submenu">
                <li onclick="event.stopPropagation(); location.href='/order'">주문 내역</li>
            </ul>
        </li>

        <li class="has-submenu" onclick="toggleSubmenu(this)">💰 재무관리
            <ul class="submenu">
                <li onclick="event.stopPropagation(); location.href='/f_list'">지출 내역</li>
                <% if ("점장".equals(loginPosition)) { %>
                <li onclick="event.stopPropagation(); location.href='/f_payrolls'">급여 내역</li>
                <% } %>
            </ul>
        </li>

        <li class="has-submenu" onclick="toggleSubmenu(this)">📈 수익분석
            <ul class="submenu">
                <li onclick="event.stopPropagation(); location.href='/analysis/stats'">수익 통계</li>
                <li onclick="event.stopPropagation(); location.href='/analysis/forecast'">수익 예측</li>
                <li onclick="event.stopPropagation(); location.href='/analysis/inventory'">재고 소진 추이 예측</li>
            </ul>
        </li>

    </ul>

    <!-- 사이드바 하단 유저 정보 -->
    <div class="user-info">
        <div class="user-avatar-wrap" onclick="openProfileModal()" title="프로필 사진 변경">
            <% if (loginProfile != null && !loginProfile.isEmpty()) { %>
                <div class="user-avatar" id="sidebarAvatar" style="padding:0; overflow:hidden;">
                    <img src="<%=loginProfile%>" alt="프로필"
                         style="width:100%; height:100%; object-fit:cover; border-radius:50%;">
                </div>
            <% } else { %>
                <div class="user-avatar" id="sidebarAvatar"><%=avatarChar%></div>
            <% } %>
            <div class="avatar-edit-overlay">✏️</div>
        </div>
        <div class="user-details">
            <div class="user-name"><%=loginName%></div>
            <div class="user-id"><%=loginEmpNum%></div>
            <div class="user-rank"><%=loginPosition%></div>
        </div>
    </div>

</div>

<!-- ===== 프로필 사진 변경 모달 ===== -->
<div class="profile-modal-overlay" id="profileModalOverlay">
    <div class="profile-modal">
        <div class="profile-modal-header">
            <span class="profile-modal-title">프로필 사진 변경</span>
            <button class="profile-modal-close" onclick="closeProfileModal()">✕</button>
        </div>

        <div class="profile-preview-wrap">
            <% if (loginProfile != null && !loginProfile.isEmpty()) { %>
                <img id="profilePreviewImg" class="profile-preview" src="<%=loginProfile%>" alt="미리보기">
            <% } else { %>
                <div id="profilePreviewText" class="profile-preview-text"><%=avatarChar%></div>
                <img id="profilePreviewImg" class="profile-preview" src="" alt="미리보기" style="display:none;">
            <% } %>
            <div>
                <label class="profile-file-label">
                    📁 파일 선택
                    <input type="file" id="profileFileInput" accept="image/*" onchange="onProfileFileChange(this)">
                </label>
                <div class="profile-selected-name" id="profileSelectedName">선택된 파일 없음</div>
            </div>
        </div>

        <div class="profile-modal-footer">
            <button class="btn-cancel" onclick="closeProfileModal()">취소</button>
            <button class="btn-save" id="profileSaveBtn" onclick="saveProfile()" disabled>저장</button>
        </div>
    </div>
</div>

<script>
    /* ===== 시계 ===== */
    function updateClock() {
        const now = new Date();
        const time = now.getFullYear() + "-" +
                     (now.getMonth() + 1) + "-" +
                     now.getDate() + " " +
                     now.toLocaleTimeString();
        document.getElementById("clock").innerText = time;
    }
    setInterval(updateClock, 1000);
    updateClock();

    /* ===== 서브메뉴 토글 ===== */
    function toggleSubmenu(menu) {
        const isOpen = menu.classList.contains('open');
        document.querySelectorAll('.has-submenu').forEach(m => m.classList.remove('open'));
        if (!isOpen) menu.classList.add('open');
    }

    /* ===== 현재 URL로 메뉴 자동 활성화 ===== */
    function setActiveMenu() {
    // 상세 페이지 -> 부모 메뉴 경로 별칭 매핑
    const pathAliasMap = {
        '/hr/attendanceIn': '/hr/attendance'
    };
    const rawPath = location.pathname;
    const path = pathAliasMap[rawPath] || rawPath;
    let bestMatch = null;
    let bestHref  = '';

    // 모든 서브메뉴 중 현재 URL과 가장 길게 매칭되는 것 하나만 선택
    document.querySelectorAll('.menu > li').forEach(li => {
        li.querySelectorAll('.submenu li').forEach(sub => {
            const href = sub.getAttribute('onclick')?.match(/location\.href='([^']+)'/)?.[1];
            if (!href) return;
            if ((path === href || path.startsWith(href + '/')) && href.length > bestHref.length) {
                bestMatch = { li, sub };
                bestHref  = href;
            }
        });
    });

    // 가장 잘 맞는 메뉴 하나만 활성화
    if (bestMatch) {
        bestMatch.li.classList.add('open');
        bestMatch.sub.classList.add('active');
    }
}
    setActiveMenu();

    /* ===== 알림 드롭다운 ===== */
    var notifLoaded = false;

    function toggleNotifDropdown() {
        const dropdown = document.getElementById('notifDropdown');
        const isOpen   = dropdown.classList.contains('open');
        if (isOpen) {
            dropdown.classList.remove('open');
        } else {
            dropdown.classList.add('open');
            if (!notifLoaded) loadNotifications();

            // 드롭다운 열면 현재 시간 저장 → 뱃지 즉시 숨김
            localStorage.setItem('noticeLastSeen', new Date().toISOString());
            document.getElementById('notifBadge').style.display = 'none';
        }
    }

    function loadNotifications() {
        fetch('/notice/recent')
            .then(function(res) { return res.json(); })
            .then(function(data) {
                notifLoaded = true;
                var list = data.list || [];

                var impLabel = { urgent: '🔴 긴급', important: '🟠 중요', normal: '🔵 일반' };
                var html = '';
                if (list.length === 0) {
                    html = '<div class="notif-empty">새 공지사항이 없습니다.</div>';
                } else {
                    list.forEach(function(n) {
                        html += '<a class="notif-item" href="/notice">'
                            + '<div class="notif-item-top">'
                            + '<span class="notif-imp ' + n.importance + '">'
                            + (impLabel[n.importance] || '일반') + '</span>'
                            + '<span class="notif-item-title">' + n.title + '</span>'
                            + '</div>'
                            + '<div class="notif-item-meta">'
                            + n.writer + ' · ' + (n.createdAtFormatted || '') + '</div>'
                            + '</a>';
                    });
                }
                document.getElementById('notifList').innerHTML = html;
            })
            .catch(function() {
                document.getElementById('notifList').innerHTML =
                    '<div class="notif-empty">불러오기 실패</div>';
            });
    }

    /* ===== 드롭다운 외부 클릭 닫기 ===== */
    document.addEventListener('click', function(e) {
        var wrap = document.getElementById('notificationWrap');
        if (wrap && !wrap.contains(e.target)) {
            document.getElementById('notifDropdown').classList.remove('open');
        }
    });

    /* ===== 프로필 사진 변경 모달 ===== */
    var _profileDataUrl = null; // 파일 선택 시 로컬 data URL 보관

    function openProfileModal() {
        document.getElementById('profileModalOverlay').classList.add('open');
    }
    function closeProfileModal() {
        document.getElementById('profileModalOverlay').classList.remove('open');
        document.getElementById('profileFileInput').value = '';
        document.getElementById('profileSelectedName').textContent = '선택된 파일 없음';
        document.getElementById('profileSaveBtn').disabled = true;
        _profileDataUrl = null;
    }
    function onProfileFileChange(input) {
        var file = input.files[0];
        if (!file) return;
        document.getElementById('profileSelectedName').textContent = file.name;
        document.getElementById('profileSaveBtn').disabled = false;
        var reader = new FileReader();
        reader.onload = function(e) {
            _profileDataUrl = e.target.result; // 로컬 data URL 저장
            var img = document.getElementById('profilePreviewImg');
            var txt = document.getElementById('profilePreviewText');
            img.src = e.target.result;
            img.style.display = 'block';
            if (txt) txt.style.display = 'none';
        };
        reader.readAsDataURL(file);
    }
    function saveProfile() {
        var file = document.getElementById('profileFileInput').files[0];
        if (!file) return;
        var btn = document.getElementById('profileSaveBtn');
        btn.disabled = true;
        btn.textContent = '저장 중...';

        var formData = new FormData();
        formData.append('file', file);

        fetch('/profile/update', { method: 'POST', body: formData })
            .then(function(r) { return r.json(); })
            .then(function(res) {
                if (res.success) {
                    // 이미 FileReader로 읽어둔 data URL을 바로 적용 → 네트워크 없이 즉시 반영
                    var avatar = document.getElementById('sidebarAvatar');
                    avatar.style.padding  = '0';
                    avatar.style.overflow = 'hidden';
                    var src = _profileDataUrl || (res.path + '?t=' + Date.now());
                    avatar.innerHTML = '<img src="' + src + '" style="width:100%;height:100%;object-fit:cover;border-radius:50%;" alt="프로필">';
                    closeProfileModal();
                } else {
                    alert(res.message || '저장에 실패했습니다.');
                    btn.disabled = false;
                    btn.textContent = '저장';
                }
            })
            .catch(function() {
                alert('서버 오류가 발생했습니다.');
                btn.disabled = false;
                btn.textContent = '저장';
            });
    }
    // 모달 외부 클릭 시 닫기
    document.getElementById('profileModalOverlay').addEventListener('click', function(e) {
        if (e.target === this) closeProfileModal();
    });

    /* ===== 페이지 로드 시 읽지 않은 공지 수 뱃지 표시 ===== */
    window.addEventListener('DOMContentLoaded', function() {
        fetch('/notice/recent')
            .then(function(res) { return res.json(); })
            .then(function(data) {
                var list  = data.list || [];
                var badge = document.getElementById('notifBadge');

                // localStorage에 저장된 마지막 확인 시간
                var lastSeen = localStorage.getItem('noticeLastSeen');

                // 마지막 확인 이후 생성된 공지만 카운트
                var unread = list.filter(function(n) {
                    if (!lastSeen) return true;
                    return new Date(n.created_at) > new Date(lastSeen);
                }).length;

                if (unread > 0) {
                    badge.textContent   = unread > 9 ? '9+' : unread;
                    badge.style.display = 'flex';
                } else {
                    badge.style.display = 'none';
                }
            })
            .catch(function() {});
    });
</script>
