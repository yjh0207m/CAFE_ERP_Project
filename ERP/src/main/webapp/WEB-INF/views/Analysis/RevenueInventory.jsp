<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>재고 소진 예측 | ERP CAFE</title>
    <link rel="stylesheet" href="/css/header.css"/>
    <link rel="stylesheet" href="/css/Analysis/analysis.css"/>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
    <style>
        .no-data-banner {
            background: #fff8e1;
            border: 1.5px solid #f59e0b;
            border-radius: 8px;
            padding: 14px 20px;
            font-size: 0.88rem;
            color: #92400e;
            margin-bottom: 20px;
        }
        .stat-row-4 {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 20px;
        }
        @media (max-width: 1100px) { .stat-row-4 { grid-template-columns: repeat(2, 1fr); } }
        .stat-icon.orange { background: #fff7ed; }
        .stat-icon.yellow { background: #fefce8; }
        .stat-info .value.orange { color: #f97316; }
        .stat-info .value.yellow { color: #eab308; }

        /* 상태 배지 */
        .badge-danger  { background: #fee2e2; color: #dc2626; }
        .badge-warning { background: #ffedd5; color: #ea580c; }
        .badge-caution { background: #fef9c3; color: #ca8a04; }
        .badge-normal  { background: #dcfce7; color: #16a34a; }
        .badge-gray    { background: #f3f4f6; color: #6b7280; }

        /* 소진 진행 바 */
        .days-bar-bg { background: #f1f5f9; border-radius: 4px; height: 6px; margin-top: 4px; }
        .days-bar    { height: 6px; border-radius: 4px; }

        .filter-row { display:flex; gap:8px; margin-bottom:16px; flex-wrap:wrap; }
        .filter-btn {
            padding: 5px 14px; border-radius: 20px; border: 1.5px solid var(--border);
            background: var(--bg-card); font-size: 0.82rem; font-weight: 600; cursor: pointer;
            font-family: 'Noto Sans KR', sans-serif; color: var(--text-secondary);
            transition: var(--transition);
        }
        .filter-btn:hover, .filter-btn.active {
            background: var(--primary-light); color: var(--primary); border-color: var(--primary);
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/header.jsp"/>

<div class="content">

    <div class="page-header">
        <div class="page-title-wrap">
            <span class="page-icon">⏳</span>
            <div>
                <h1 class="page-title">재고 소진 추이 예측</h1>
                <p class="page-sub">수익분석 &gt; 재고 소진 추이 예측</p>
            </div>
        </div>
        <div style="display:flex; align-items:center; gap:8px;">
            <input type="number" id="inputYear"  placeholder="년도" min="2020" max="2099"
                   style="width:78px; padding:5px 8px; border:1px solid var(--border); border-radius:6px; font-size:0.85rem; font-family:inherit;">
            <span style="font-size:0.85rem; color:var(--text-muted);">년</span>
            <input type="number" id="inputMonth" placeholder="월" min="1" max="12"
                   style="width:54px; padding:5px 8px; border:1px solid var(--border); border-radius:6px; font-size:0.85rem; font-family:inherit;">
            <span style="font-size:0.85rem; color:var(--text-muted);">월</span>
            <button class="btn btn-secondary" id="refreshBtn" onclick="refreshData()">🔄 최신화</button>
        </div>
    </div>

    <div id="noBanner" class="no-data-banner">
        📭 아직 데이터가 없습니다. 최신화 버튼을 눌러 분석을 실행하세요.
    </div>

    <!-- 요약 카드 -->
    <div class="stat-row-4" id="summaryCards" style="display:none;">
        <div class="stat-card">
            <div class="stat-icon blue">📦</div>
            <div class="stat-info">
                <div class="label">총 원재료</div>
                <div class="value" id="totalCount">-</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon red">🚨</div>
            <div class="stat-info">
                <div class="label">위험 (소진·부족·임박)</div>
                <div class="value red" id="dangerCount">-</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon orange">⚠️</div>
            <div class="stat-info">
                <div class="label">주의</div>
                <div class="value orange" id="cautionCount">-</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green">✅</div>
            <div class="stat-info">
                <div class="label">정상</div>
                <div class="value green" id="normalCount">-</div>
            </div>
        </div>
    </div>

    <!-- 소진 임박 TOP 차트 -->
    <div class="chart-card" style="margin-bottom:20px;" id="topChartCard" style="display:none;">
        <div class="chart-card-header"><h3>⚠️ 소진 임박 원재료 TOP 10 (소진 예상일 기준)</h3></div>
        <div class="chart-wrap" style="min-height:300px;"><canvas id="depletionChart"></canvas></div>
    </div>

    <!-- 상세 테이블 -->
    <div class="table-card">
        <div class="table-card-header">
            <h3>📋 원재료별 소진 예측 상세</h3>
            <span id="inventoryCount" style="font-size:0.82rem; color:var(--text-muted);"></span>
        </div>
        <div class="filter-row" id="filterRow" style="padding:12px 16px 0; display:none;">
            <button class="filter-btn active" onclick="filterTable('전체', this)">전체</button>
            <button class="filter-btn" onclick="filterTable('소진', this)">🔴 소진</button>
            <button class="filter-btn" onclick="filterTable('부족', this)">🟠 부족</button>
            <button class="filter-btn" onclick="filterTable('임박', this)">🟡 임박</button>
            <button class="filter-btn" onclick="filterTable('주의', this)">🟡 주의</button>
            <button class="filter-btn" onclick="filterTable('정상', this)">🟢 정상</button>
        </div>
        <div id="inventoryTableBody">
            <div class="empty-placeholder">최신화 버튼을 눌러 데이터를 불러오세요.</div>
        </div>
    </div>

</div>

<script>
var FASTAPI_URL = 'http://127.0.0.1:8000';
var depletionChart;
var _forecasts = [];

/* ===== 최신화 ===== */
function refreshData() {
    var btn   = document.getElementById('refreshBtn');
    var year  = document.getElementById('inputYear').value.trim();
    var month = document.getElementById('inputMonth').value.trim();

    var url = FASTAPI_URL + '/analysis/run';
    var params = [];
    if (year)  params.push('year='  + year);
    if (month) params.push('month=' + month);
    if (params.length) url += '?' + params.join('&');

    btn.disabled = true;
    btn.textContent = '⏳ 분석 실행 중...';

    fetch(url, { method: 'POST' })
        .then(function(r) { return r.json(); })
        .then(function() {
            btn.textContent = '⏳ 처리 중...';
            pollAndLoad(btn);
        })
        .catch(function() {
            alert('분석 서버에 연결할 수 없습니다.\n분석 서버가 실행 중인지 확인하세요.');
            btn.disabled = false;
            btn.textContent = '🔄 최신화';
        });
}

function pollAndLoad(btn) {
    fetch(FASTAPI_URL + '/status')
        .then(function(r) { return r.json(); })
        .then(function(status) {
            if (status.is_analyzing) {
                setTimeout(function() { pollAndLoad(btn); }, 2000);
            } else {
                loadAndRender(btn);
            }
        })
        .catch(function() {
            setTimeout(function() { pollAndLoad(btn); }, 2000);
        });
}

function loadAndRender(btn) {
    btn.textContent = '⏳ 데이터 로딩...';
    fetch('/api/revenue/inventory')
        .then(function(r) { return r.json(); })
        .then(function(data) {
            var forecasts = data && data.forecasts ? data.forecasts : (Array.isArray(data) ? data : []);
            if (forecasts.length > 0) {
                document.getElementById('noBanner').style.display = 'none';
                renderInventory(forecasts);
            } else {
                alert('재고 소진 예측 데이터가 없습니다.');
            }
        })
        .catch(function(e) { alert('데이터 로드 실패: ' + e.message); })
        .finally(function() {
            btn.disabled = false;
            btn.textContent = '🔄 최신화';
        });
}

/* ===== 페이지 로드 시 기존 데이터 자동 로드 ===== */
document.addEventListener('DOMContentLoaded', function() {
    fetch('/api/revenue/inventory')
        .then(function(r) { return r.json(); })
        .then(function(data) {
            var forecasts = data && data.forecasts ? data.forecasts : (Array.isArray(data) ? data : []);
            if (forecasts.length > 0) {
                document.getElementById('noBanner').style.display = 'none';
                renderInventory(forecasts);
            }
        }).catch(function() {});
});

/* ===== 상태 → 배지 클래스 ===== */
function getBadgeClass(status) {
    if (status === '소진')      return 'badge-danger';
    if (status === '부족')      return 'badge-warning';
    if (status === '임박')      return 'badge-warning';
    if (status === '주의')      return 'badge-caution';
    if (status === '정상')      return 'badge-normal';
    return 'badge-gray';
}

/* ===== 상태 → 바 색상 ===== */
function getBarColor(status) {
    if (status === '소진')  return '#dc2626';
    if (status === '부족')  return '#f97316';
    if (status === '임박')  return '#f59e0b';
    if (status === '주의')  return '#eab308';
    if (status === '정상')  return '#22c55e';
    return '#9ca3af';
}

/* ===== 렌더링 ===== */
function renderInventory(forecasts) {
    _forecasts = forecasts;

    // 요약 카드
    var total   = forecasts.length;
    var danger  = forecasts.filter(function(f) { return f.status === '소진' || f.status === '부족' || f.status === '임박'; }).length;
    var caution = forecasts.filter(function(f) { return f.status === '주의'; }).length;
    var normal  = forecasts.filter(function(f) { return f.status === '정상' || f.status === '데이터없음'; }).length;

    document.getElementById('summaryCards').style.display = 'grid';
    document.getElementById('totalCount').textContent   = total + '종';
    document.getElementById('dangerCount').textContent  = danger + '종';
    document.getElementById('cautionCount').textContent = caution + '종';
    document.getElementById('normalCount').textContent  = normal + '종';

    // TOP 10 수평 바 차트 (소진 임박 순 - days_until_empty 오름차순, 소진 제외)
    var chartData = forecasts.filter(function(f) {
        return f.status !== '데이터없음' && f.days_until_empty != null;
    }).slice(0, 10);

    if (depletionChart) depletionChart.destroy();
    if (chartData.length > 0) {
        document.getElementById('topChartCard').style.display = '';
        depletionChart = new Chart(document.getElementById('depletionChart'), {
            type: 'bar',
            data: {
                labels: chartData.map(function(f) { return f.name + ' (' + f.unit + ')'; }),
                datasets: [{
                    label: '소진 예상일 (일)',
                    data: chartData.map(function(f) { return f.days_until_empty || 0; }),
                    backgroundColor: chartData.map(function(f) { return getBarColor(f.status) + 'cc'; }),
                    borderColor:     chartData.map(function(f) { return getBarColor(f.status); }),
                    borderWidth: 1.5, borderRadius: 4
                }]
            },
            options: {
                indexAxis: 'y',
                responsive: true,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: function(ctx) {
                                var f = chartData[ctx.dataIndex];
                                return '소진까지 ' + ctx.raw + '일 · 예정일: ' + (f.predicted_depletion_date || '-');
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        title: { display: true, text: '소진 예상일수 (일)' },
                        ticks: { callback: function(v) { return v + '일'; } }
                    }
                }
            }
        });
    }

    // 테이블
    document.getElementById('filterRow').style.display = 'flex';
    renderTable(forecasts);
}

function renderTable(data) {
    document.getElementById('inventoryCount').textContent = '총 ' + data.length + '종';

    if (data.length === 0) {
        document.getElementById('inventoryTableBody').innerHTML = '<div class="empty-placeholder">해당 조건의 원재료가 없습니다.</div>';
        return;
    }

    var rows = data.map(function(f) {
        var daysEmpty = f.days_until_empty != null ? f.days_until_empty : '-';
        var daysMin   = f.days_until_min_stock != null ? f.days_until_min_stock : '-';
        var barWidth  = typeof daysEmpty === 'number' ? Math.min(100, (daysEmpty / 60) * 100) : 0;
        var barColor  = getBarColor(f.status);

        return '<tr>'
            + '<td style="text-align:left; font-weight:600;">' + (f.name || '-') + '</td>'
            + '<td>' + (f.category || '-') + '</td>'
            + '<td>' + fmtStock(f.current_stock) + ' ' + (f.unit || '') + '</td>'
            + '<td>' + (f.min_stock != null ? f.min_stock + ' ' + (f.unit || '') : '-') + '</td>'
            + '<td>' + (f.avg_daily_consumption != null ? f.avg_daily_consumption.toFixed(2) + ' ' + (f.unit || '') + '/일' : '-') + '</td>'
            + '<td>'
            +   (typeof daysEmpty === 'number'
                    ? '<div>' + daysEmpty + '일</div><div class="days-bar-bg"><div class="days-bar" style="width:' + barWidth + '%;background:' + barColor + ';"></div></div>'
                    : '-')
            + '</td>'
            + '<td>' + (typeof daysMin === 'number' ? daysMin + '일' : '-') + '</td>'
            + '<td>' + (f.predicted_depletion_date || '-') + '</td>'
            + '<td><span class="badge ' + getBadgeClass(f.status) + '">' + (f.status || '-') + '</span></td>'
            + '</tr>';
    }).join('');

    document.getElementById('inventoryTableBody').innerHTML =
        '<table class="data-table"><thead><tr>'
        + '<th>원재료명</th><th>카테고리</th><th>현재 재고</th><th>최소 재고</th>'
        + '<th>일평균 소비</th><th>소진까지</th><th>최소재고까지</th><th>소진 예정일</th><th>상태</th>'
        + '</tr></thead><tbody>' + rows + '</tbody></table>';
}

/* ===== 필터 ===== */
function filterTable(status, btn) {
    document.querySelectorAll('.filter-btn').forEach(function(b) { b.classList.remove('active'); });
    btn.classList.add('active');

    if (status === '전체') {
        renderTable(_forecasts);
    } else {
        renderTable(_forecasts.filter(function(f) { return f.status === status; }));
    }
}

function fmtStock(v) {
    if (v == null) return '-';
    return Number(v).toFixed(2);
}
</script>
</body>
</html>
