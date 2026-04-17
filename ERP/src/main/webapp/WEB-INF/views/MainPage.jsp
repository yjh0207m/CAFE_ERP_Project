<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ERP CAFE SYSTEM</title>
    <link rel="stylesheet" href="/css/header.css"/>
    <link rel="stylesheet" href="/css/MainPage.css"/>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
</head>
<body>

<jsp:include page="/WEB-INF/views/header.jsp"/>

<div class="content">

    <div class="page-header">
        <div class="page-title">업무 대시보드 <span id="todayDate"></span></div>
    </div>

    <%-- 알림 배너 (재고 부족 / 소진 임박) --%>
    <div id="alertArea"></div>

    <%-- 요약 카드 3개 --%>
    <div class="stat-row">
        <div class="stat-card" onclick="location.href='/order'">
            <div class="stat-icon blue">🧾</div>
            <div class="stat-info">
                <div class="label">오늘 주문건수</div>
                <div class="value blue" id="todayCount">-</div>
            </div>
        </div>
        <div class="stat-card" onclick="location.href='/order'">
            <div class="stat-icon green">💰</div>
            <div class="stat-info">
                <div class="label">오늘 매출</div>
                <div class="value green" id="todayRevenue">-</div>
            </div>
        </div>
        <div class="stat-card" onclick="location.href='/inventory'">
            <div class="stat-icon red">⚠️</div>
            <div class="stat-info">
                <div class="label">재고 부족 원재료</div>
                <div class="value red" id="lowStockCount">-</div>
            </div>
        </div>
    </div>

    <%-- 메인 그리드 --%>
    <div class="main-grid">

        <%-- 주간 매출 그래프 --%>
        <div class="dash-card main-grid-full">
            <div class="dash-card-header">
                <h3>📊 주간 매출 현황</h3>
                <span id="weeklyTotal" style="font-size:0.82rem; color:var(--text-muted);"></span>
            </div>
            <div class="chart-wrap">
                <canvas id="weeklyChart"></canvas>
            </div>
        </div>

        <%-- 재고 부족 원재료 --%>
        <div class="dash-card">
            <div class="dash-card-header">
                <h3>⚠️ 재고 부족 원재료</h3>
                <a href="/inventory" style="font-size:0.8rem; color:var(--primary);
                   text-decoration:none; font-weight:600;">전체 보기 →</a>
            </div>
            <div id="lowStockArea">
                <div class="empty-msg">로딩 중...</div>
            </div>
            <div class="dash-pagination" id="lowStockPaging" style="display:none;">
                <button class="dash-page-btn" id="lowStockPrev" onclick="changeLowStockPage(-1)">◀</button>
                <span id="lowStockPageInfo" style="font-size:0.82rem; color:var(--text-muted);"></span>
                <button class="dash-page-btn" id="lowStockNext" onclick="changeLowStockPage(1)">▶</button>
            </div>
        </div>

        <%-- 금일 근무자 --%>
        <div class="dash-card">
            <div class="dash-card-header">
                <h3>👥 금일 근무자</h3>
                <% String mainLoginPosition = (String) session.getAttribute("loginPosition"); %>
                <% if ("점장".equals(mainLoginPosition)) { %>
                <a id="linkTodayAttendance" href="/hr/attendanceIn?date="
                   style="font-size:0.8rem; color:var(--primary);
                   text-decoration:none; font-weight:600;">근태 현황 →</a>
                <% } %>
            </div>
            <div class="dash-card-body">
                <div id="employeeArea">
                    <div class="empty-msg">로딩 중...</div>
                </div>
                <div class="dash-pagination" id="empPaging" style="display:none;">
                    <button class="dash-page-btn" id="empPrev" onclick="changeEmpPage(-1)">◀</button>
                    <span id="empPageInfo" style="font-size:0.82rem; color:var(--text-muted);"></span>
                    <button class="dash-page-btn" id="empNext" onclick="changeEmpPage(1)">▶</button>
                </div>
            </div>
        </div>

    </div>
</div>

<script>
/* ===== 오늘 날짜 표시 + 버튼/링크에 적용 ===== */
var todayStr = '';
(function() {
    var now  = new Date();
    var days = ['일','월','화','수','목','금','토'];
    document.getElementById('todayDate').textContent =
        now.getFullYear() + '년 ' + (now.getMonth()+1) + '월 ' + now.getDate() + '일 (' + days[now.getDay()] + ')';

    // yyyy-MM-dd 형식
    var mm = String(now.getMonth() + 1).padStart(2, '0');
    var dd = String(now.getDate()).padStart(2, '0');
    todayStr = now.getFullYear() + '-' + mm + '-' + dd;

    // 근태 현황 링크도 오늘 날짜
    var attendanceLink = document.getElementById('linkTodayAttendance');
    if (attendanceLink) attendanceLink.href = '/hr/attendanceIn?date=' + todayStr;
})();

/* ===== 오늘 매출/주문 ===== */
fetch('/api/main/today')
    .then(function(r) { return r.json(); })
    .then(function(data) {
        document.getElementById('todayCount').textContent   = (data.todayCount   || 0) + '건';
        document.getElementById('todayRevenue').textContent = '₩' + (data.todayRevenue || 0).toLocaleString();
    });

/* ===== 주간 매출 차트 ===== */
fetch('/api/main/weekly')
    .then(function(r) { return r.json(); })
    .then(function(data) {
        var total = (data.amounts || []).reduce(function(s, v) { return s + v; }, 0);
        document.getElementById('weeklyTotal').textContent = '주간 합계: ₩' + total.toLocaleString();

        new Chart(document.getElementById('weeklyChart'), {
            type: 'bar',
            data: {
                labels: data.labels || [],
                datasets: [{
                    label: '매출',
                    data:  data.amounts || [],
                    backgroundColor: 'rgba(91, 110, 245, 0.7)',
                    borderRadius: 8,
                    borderSkipped: false
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: { callback: function(v) { return '₩' + v.toLocaleString(); } },
                        grid: { color: 'rgba(0,0,0,0.05)' }
                    },
                    x: { grid: { display: false } }
                }
            }
        });
    });

/* ===== 재고 부족 페이징 ===== */
var lowStockData = [];
var lowStockPage = 1;
var lowStockSize = 5;

function renderLowStock() {
    var total      = lowStockData.length;
    var totalPages = Math.max(1, Math.ceil(total / lowStockSize));
    if (lowStockPage > totalPages) lowStockPage = totalPages;
    var start = (lowStockPage - 1) * lowStockSize;
    var paged = lowStockData.slice(start, start + lowStockSize);
    var area  = document.getElementById('lowStockArea');

    if (total === 0) {
        area.innerHTML = '<div class="empty-msg">✅ 재고 부족 원재료가 없습니다.</div>';
        document.getElementById('lowStockPaging').style.display = 'none';
        return;
    }

    var rows = paged.map(function(item) {
        return '<tr>'
            + '<td style="text-align:left;"><strong>' + (item.name || '-') + '</strong></td>'
            + '<td><span style="background:var(--primary-light);color:var(--primary);font-size:0.75rem;font-weight:600;padding:2px 8px;border-radius:20px;">' + (item.category || '-') + '</span></td>'
            + '<td class="stock-qty-low">' + (item.stock_qty || 0) + ' ' + (item.unit || '') + '</td>'
            + '<td style="color:var(--text-muted);">' + (item.min_stock || 0) + ' ' + (item.unit || '') + '</td>'
            + '<td><button class="btn-order-now" onclick="orderNow(' + item.id + ',&quot;' + encodeURIComponent(item.name||'') + '&quot;,' + (item.unit_cost||0) + ',' + (item.supplier_id||0) + ')">🛒 발주</button></td>'
            + '</tr>';
    }).join('');

    area.innerHTML = '<table class="low-stock-table"><thead><tr><th>원재료명</th><th>카테고리</th><th>현재 재고</th><th>최소 기준</th><th>발주</th></tr></thead><tbody>' + rows + '</tbody></table>';

    document.getElementById('lowStockPageInfo').textContent = lowStockPage + ' / ' + totalPages;
    document.getElementById('lowStockPrev').disabled = (lowStockPage <= 1);
    document.getElementById('lowStockNext').disabled = (lowStockPage >= totalPages);
    document.getElementById('lowStockPaging').style.display = total > lowStockSize ? 'flex' : 'none';
}

function changeLowStockPage(dir) {
    lowStockPage += dir;
    renderLowStock();
}

/* ===== 금일 근무자 페이징 ===== */
var empData = [];
var empPage = 1;
var empSize = 5;

function renderEmployees() {
    var total      = empData.length;
    var totalPages = Math.max(1, Math.ceil(total / empSize));
    if (empPage > totalPages) empPage = totalPages;
    var start = (empPage - 1) * empSize;
    var paged = empData.slice(start, start + empSize);
    var area  = document.getElementById('employeeArea');

    if (total === 0) {
        area.innerHTML = '<div class="empty-msg">등록된 재직 직원이 없습니다.</div>';
        document.getElementById('empPaging').style.display = 'none';
        return;
    }

    var statusMap = {
        'absent':  { label: '미출근', cls: 'status-absent' },
        'working': { label: '출근 중', cls: 'status-working' },
        'done':    { label: '퇴근',   cls: 'status-done' }
    };

    var html = '<div class="employee-list">';
    paged.forEach(function(emp) {
        var avatarChar = emp.name ? emp.name.charAt(0) : '?';
        var ct        = emp.contract_type || '';
        var typeLabel = (ct === 'full' || ct === '풀') ? '정규직' : '파트타임';
        var posClassMap = { '점장': 'pos-owner', '매니저': 'pos-manager', '스탭': 'pos-staff' };
        var posClass = posClassMap[emp.position] || 'pos-staff';
        var st        = statusMap[emp.status] || { label: '-', cls: '' };
        var clockIn   = emp.clock_in  ? String(emp.clock_in).substring(0,5)  : '-';
        var clockOut  = emp.clock_out ? String(emp.clock_out).substring(0,5) : '-';
        var avatarHtml = emp.profile
            ? '<img class="emp-avatar-photo" src="' + emp.profile + '" alt="' + (emp.name||'') + '"'
              + ' onclick="openProfileViewer(\'' + emp.profile + '\',\'' + (emp.name||'') + '\')" style="cursor:zoom-in;">'
            : '<div class="emp-avatar">' + avatarChar + '</div>';
        var clockHtml = '';
        if (emp.status === 'working') {
            clockHtml = '<div class="emp-clock"><span style="font-size:0.72rem;color:var(--text-muted);">출근 ' + clockIn + '</span></div>';
        } else if (emp.status === 'done') {
            clockHtml = '<div class="emp-clock"><span style="font-size:0.72rem;color:var(--text-muted);">출근 ' + clockIn + '</span>'
                + '<span style="font-size:0.72rem;color:var(--text-muted);">퇴근 ' + clockOut + '</span></div>';
        }
        html += '<div class="employee-item">'
            + avatarHtml
            + '<div class="emp-info"><div class="emp-name">' + (emp.name||'-') + '</div><div class="emp-position">' + typeLabel + '</div></div>'
            + clockHtml
            + '<span class="emp-status ' + st.cls + '">' + st.label + '</span>'
            + '<span class="emp-type ' + posClass + '">' + (emp.position||'-') + '</span>'
            + '</div>';
    });
    html += '</div>';
    area.innerHTML = html;

    document.getElementById('empPageInfo').textContent = empPage + ' / ' + totalPages;
    document.getElementById('empPrev').disabled = (empPage <= 1);
    document.getElementById('empNext').disabled = (empPage >= totalPages);
    document.getElementById('empPaging').style.display = total > empSize ? 'flex' : 'none';
}

function changeEmpPage(dir) {
    empPage += dir;
    renderEmployees();
}

/* ===== 재고 부족 원재료 ===== */
fetch('/api/main/low-stock')
    .then(function(r) { return r.json(); })
    .then(function(list) {
        document.getElementById('lowStockCount').textContent = (list.length || 0) + '개';

        // 알림 배너
        var alertArea = document.getElementById('alertArea');
        if (list.length > 0) {
            alertArea.innerHTML =
                '<div class="alert-banner danger">'
                + '⚠️ 재고 부족 원재료가 <strong>' + list.length + '개</strong> 있습니다. 즉시 발주가 필요합니다.'
                + '<a href="/inventory/order">발주 페이지로 →</a>'
                + '</div>';
        }

        lowStockData = list;
        lowStockPage = 1;
        renderLowStock();
    });

/* ===== 발주 즉시 이동 (해당 원재료 발주 페이지로) ===== */
function orderNow(ingredientId, name, unitCost, supplierId) {
    // 발주 페이지로 이동하면서 해당 원재료 자동 선택 파라미터 전달
    var params = '?highlight=' + ingredientId;
    location.href = '/inventory/order' + params;
}

/* ===== 금일 근무자 ===== */
fetch('/api/main/today-employees')
    .then(function(r) { return r.json(); })
    .then(function(list) {
        // 1순위: 출근(working) → 퇴근(done) → 미출근(absent)
        // 2순위: 직급 (점장 → 매니저 → 스탭)
        var posOrder    = { '점장': 0, '매니저': 1, '스탭': 2 };
        var statusOrder = { 'working': 0, 'done': 1, 'absent': 2 };
        list.sort(function(a, b) {
            var sa = statusOrder[a.status] !== undefined ? statusOrder[a.status] : 99;
            var sb = statusOrder[b.status] !== undefined ? statusOrder[b.status] : 99;
            if (sa !== sb) return sa - sb;
            var pa = posOrder[a.position] !== undefined ? posOrder[a.position] : 99;
            var pb = posOrder[b.position] !== undefined ? posOrder[b.position] : 99;
            return pa - pb;
        });
        empData = list;
        empPage = 1;
        renderEmployees();
    });
/* ===== 프로필 확대 뷰어 ===== */
function openProfileViewer(src, name) {
    var v = document.getElementById('profileViewer');
    document.getElementById('profileViewerImg').src        = src;
    document.getElementById('profileViewerName').innerText = name || '';
    v.style.display = 'flex';
}
function closeProfileViewer() {
    document.getElementById('profileViewer').style.display = 'none';
}
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeProfileViewer();
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

</body>
</html>
