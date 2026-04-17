<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>수익 예측 | ERP CAFE</title>
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
        .trend-up   { color: #22c55e !important; }
        .trend-down { color: #ef4444 !important; }
        .trend-flat { color: #f59e0b !important; }
        .forecast-note {
            font-size: 0.78rem;
            color: var(--text-muted);
            padding: 6px 20px 10px;
            display: flex; gap: 16px; align-items: center;
        }
        .legend-line { display: inline-block; width: 24px; height: 2px; vertical-align: middle; margin-right: 4px; }
        .legend-solid { background: #5b6ef5; }
        .legend-dashed { background: repeating-linear-gradient(90deg, #5b6ef5 0, #5b6ef5 5px, transparent 5px, transparent 10px); }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/header.jsp"/>

<div class="content">

    <div class="page-header">
        <div class="page-title-wrap">
            <span class="page-icon">📈</span>
            <div>
                <h1 class="page-title">수익 예측</h1>
                <p class="page-sub">수익분석 &gt; 수익 예측</p>
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
            <div class="stat-icon blue">💰</div>
            <div class="stat-info">
                <div class="label">월평균 매출</div>
                <div class="value" id="avgRevenue">-</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon red">💸</div>
            <div class="stat-info">
                <div class="label">월평균 지출</div>
                <div class="value red" id="avgExpenses">-</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green">📈</div>
            <div class="stat-info">
                <div class="label">월평균 순이익</div>
                <div class="value" id="avgNet">-</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon blue">📊</div>
            <div class="stat-info">
                <div class="label">수익 트렌드</div>
                <div class="value" id="revenueTrend">-</div>
            </div>
        </div>
    </div>

    <!-- 매출 / 지출 예측 차트 -->
    <div class="chart-card" style="margin-bottom:20px;">
        <div class="chart-card-header">
            <h3>📈 매출 · 지출 추이 및 예측</h3>
        </div>
        <div class="forecast-note">
            <span><span class="legend-line legend-solid"></span>실적 구간</span>
            <span><span class="legend-line legend-dashed"></span>예측 구간 (점선)</span>
        </div>
        <div class="chart-wrap" style="min-height:300px;"><canvas id="revenueChart"></canvas></div>
    </div>

    <!-- 순이익 예측 차트 -->
    <div class="chart-card" style="margin-bottom:20px;">
        <div class="chart-card-header"><h3>💰 순이익 추이 및 예측</h3></div>
        <div class="forecast-note">
            <span><span class="legend-line legend-solid" style="background:#22c55e;"></span>실적</span>
            <span><span class="legend-line legend-dashed" style="background:repeating-linear-gradient(90deg,#22c55e 0,#22c55e 5px,transparent 5px,transparent 10px);"></span>예측 (점선)</span>
        </div>
        <div class="chart-wrap" style="min-height:260px;"><canvas id="netChart"></canvas></div>
    </div>

    <!-- 예측 상세 테이블 -->
    <div class="table-card">
        <div class="table-card-header">
            <h3>📋 월별 예측 상세</h3>
            <span id="forecastPeriod" style="font-size:0.82rem; color:var(--text-muted);"></span>
        </div>
        <div id="forecastTableBody">
            <div class="empty-placeholder">최신화 버튼을 눌러 데이터를 불러오세요.</div>
        </div>
    </div>

</div>

<script>
var FASTAPI_URL = 'http://127.0.0.1:8000';
var revenueChart, netChart;

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
    fetch('/api/revenue/forecast')
        .then(function(r) { return r.json(); })
        .then(function(data) {
            var hasData = data && ((data.history && data.history.length > 0)
                                || (data.forecasts && data.forecasts.length > 0));
            if (hasData) {
                document.getElementById('noBanner').style.display = 'none';
                renderForecast(data);
            } else {
                alert('예측 데이터가 없습니다. Python 분석 결과를 확인해주세요.');
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
    fetch('/api/revenue/forecast')
        .then(function(r) { return r.json(); })
        .then(function(data) {
            var hasData = data && data.history && data.history.length > 0;
            if (hasData) {
                document.getElementById('noBanner').style.display = 'none';
                renderForecast(data);
            }
        }).catch(function() {});
});

/* ===== 렌더링 ===== */
function renderForecast(data) {
    var history   = data.history   || [];
    var forecasts = data.forecasts || [];
    var summary   = data.summary   || {};

    // 요약 카드
    document.getElementById('summaryCards').style.display = 'grid';
    document.getElementById('avgRevenue').textContent  = fmtWon(summary.avg_monthly_revenue  || 0);
    document.getElementById('avgExpenses').textContent = fmtWon(summary.avg_monthly_expenses || 0);

    var avgNet = summary.avg_monthly_net || 0;
    document.getElementById('avgNet').textContent = fmtWon(avgNet);
    document.getElementById('avgNet').className   = 'value ' + (avgNet >= 0 ? 'green' : 'red');

    var trend = summary.revenue_trend || '-';
    var trendEl = document.getElementById('revenueTrend');
    trendEl.textContent = trend === '상승' ? '↑ ' + trend : trend === '하락' ? '↓ ' + trend : '→ ' + trend;
    trendEl.className   = 'value ' + (trend === '상승' ? 'trend-up' : trend === '하락' ? 'trend-down' : 'trend-flat');

    if (forecasts.length > 0) {
        var lastForecast = forecasts[forecasts.length - 1];
        document.getElementById('forecastPeriod').textContent = '향후 ' + forecasts.length + '개월 예측';
    }

    // 차트 레이블 및 데이터 합치기
    var hLen   = history.length;
    var hLabels = history.map(function(h)   { return h.label   || (h.year + '.' + h.month); });
    var fLabels = forecasts.map(function(f) { return (f.label || (f.year + '.' + f.month)) + '(예측)'; });
    var allLabels = hLabels.concat(fLabels);

    var allRevenue  = history.map(function(h) { return h.revenue    || 0; }).concat(forecasts.map(function(f) { return f.predicted_revenue   || 0; }));
    var allExpenses = history.map(function(h) { return h.expenses   || 0; }).concat(forecasts.map(function(f) { return f.predicted_expenses  || 0; }));
    var allNet      = history.map(function(h) { return h.net_income || 0; }).concat(forecasts.map(function(f) { return f.predicted_net_income || 0; }));

    // 구분선 플러그인 (실적/예측 경계)
    var dividerPlugin = {
        id: 'dividerLine',
        afterDraw: function(chart) {
            if (hLen === 0 || hLen >= allLabels.length) return;
            var ctx2  = chart.ctx;
            var xAxis = chart.scales.x;
            var yAxis = chart.scales.y;
            var x = xAxis.getPixelForValue(hLen - 0.5);
            ctx2.save();
            ctx2.setLineDash([5, 4]);
            ctx2.strokeStyle = 'rgba(0,0,0,0.18)';
            ctx2.lineWidth = 1.5;
            ctx2.beginPath();
            ctx2.moveTo(x, yAxis.top);
            ctx2.lineTo(x, yAxis.bottom);
            ctx2.stroke();
            ctx2.fillStyle = 'rgba(0,0,0,0.35)';
            ctx2.font = '11px sans-serif';
            ctx2.textAlign = 'center';
            ctx2.fillText('예측 →', x + 30, yAxis.top + 14);
            ctx2.restore();
        }
    };

    var chartOptions = {
        responsive: true,
        interaction: { mode: 'index', intersect: false },
        plugins: { legend: { position: 'top' } },
        scales: { y: { ticks: { callback: function(v) { return fmtAxis(v); } } } }
    };

    // 매출/지출 차트
    if (revenueChart) revenueChart.destroy();
    revenueChart = new Chart(document.getElementById('revenueChart'), {
        type: 'line',
        data: {
            labels: allLabels,
            datasets: [
                {
                    label: '매출',
                    data: allRevenue,
                    borderColor: '#5b6ef5',
                    backgroundColor: 'rgba(91,110,245,0.06)',
                    borderWidth: 2.5, pointRadius: 5, tension: 0.3, fill: false,
                    segment: { borderDash: function(ctx) { return ctx.p0DataIndex >= hLen - 1 ? [6, 3] : undefined; } }
                },
                {
                    label: '지출',
                    data: allExpenses,
                    borderColor: '#ef4444',
                    backgroundColor: 'rgba(239,68,68,0.04)',
                    borderWidth: 2, pointRadius: 4, tension: 0.3, fill: false,
                    segment: { borderDash: function(ctx) { return ctx.p0DataIndex >= hLen - 1 ? [6, 3] : undefined; } }
                }
            ]
        },
        options: chartOptions,
        plugins: [dividerPlugin]
    });

    // 순이익 차트
    if (netChart) netChart.destroy();
    netChart = new Chart(document.getElementById('netChart'), {
        type: 'line',
        data: {
            labels: allLabels,
            datasets: [{
                label: '순이익',
                data: allNet,
                borderColor: '#22c55e',
                backgroundColor: 'rgba(34,197,94,0.07)',
                borderWidth: 2.5, pointRadius: 5, tension: 0.3, fill: true,
                segment: { borderDash: function(ctx) { return ctx.p0DataIndex >= hLen - 1 ? [6, 3] : undefined; } }
            }]
        },
        options: chartOptions,
        plugins: [dividerPlugin]
    });

    // 예측 테이블
    if (forecasts.length === 0) {
        document.getElementById('forecastTableBody').innerHTML = '<div class="empty-placeholder">예측 데이터가 없습니다.</div>';
        return;
    }
    var rows = forecasts.map(function(f) {
        var net = f.predicted_net_income || 0;
        var netCls = net >= 0 ? 'amount-plus' : 'amount-minus';
        return '<tr>'
            + '<td>' + (f.label || (f.year + '년 ' + f.month + '월')) + '</td>'
            + '<td class="amount-plus">'   + fmtWon(f.predicted_revenue   || 0) + '</td>'
            + '<td class="amount-minus">'  + fmtWon(f.predicted_expenses  || 0) + '</td>'
            + '<td class="' + netCls + '">' + fmtWon(net) + '</td>'
            + '</tr>';
    }).join('');
    document.getElementById('forecastTableBody').innerHTML =
        '<table class="data-table"><thead><tr>'
        + '<th>기간</th><th>예측 매출</th><th>예측 지출</th><th>예측 순이익</th>'
        + '</tr></thead><tbody>' + rows + '</tbody></table>';
}

function fmtWon(v) {
    var n = Number(v);
    if (Math.abs(n) >= 100000000) return (n / 100000000).toFixed(1) + '억원';
    if (Math.abs(n) >= 10000)     return (n / 10000).toFixed(0) + '만원';
    return n.toLocaleString() + '원';
}
function fmtAxis(v) {
    if (Math.abs(v) >= 100000000) return (v / 100000000).toFixed(1) + '억';
    if (Math.abs(v) >= 10000)     return (v / 10000).toFixed(0) + '만';
    return v;
}
</script>
</body>
</html>
