<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>수익 통계 | ERP CAFE</title>
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
        .ai-report-card {
            background: #fff;
            border: 1.5px solid var(--border, #e2e8f0);
            border-radius: 12px;
            padding: 24px 28px;
            margin-top: 24px;
        }
        .ai-report-card-header {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 1rem;
            font-weight: 700;
            color: var(--text, #1e293b);
            margin-bottom: 16px;
            padding-bottom: 12px;
            border-bottom: 1px solid var(--border, #e2e8f0);
        }
        .ai-report-body {
            font-size: 0.95rem;
            color: var(--text, #334155);
            line-height: 1.8;
        }
        .ai-report-body .ai-h1 {
            font-size: 1.15rem;
            font-weight: 700;
            color: var(--text, #1e293b);
            margin: 0 0 16px 0;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--border, #e2e8f0);
        }
        .ai-report-body .ai-section {
            font-size: 1rem;
            font-weight: 700;
            color: var(--text, #1e293b);
            margin: 20px 0 6px 0;
        }
        .ai-report-body .ai-hr {
            display: none;
        }
        .ai-report-body .ai-list-item {
            margin: 6px 0 2px 0;
            font-weight: 700;
            color: var(--text, #1e293b);
        }
        .ai-report-body p {
            margin: 0 0 6px 0;
        }
        .ai-report-loading {
            display: flex;
            align-items: center;
            gap: 10px;
            color: var(--text-muted, #64748b);
            font-size: 0.88rem;
            padding: 10px 0;
        }
        .ai-spinner {
            width: 18px;
            height: 18px;
            border: 2px solid #e2e8f0;
            border-top-color: #5b6ef5;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
        }
        @keyframes spin { to { transform: rotate(360deg); } }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/header.jsp"/>

<div class="content">

    <div class="page-header">
        <div class="page-title-wrap">
            <span class="page-icon">📊</span>
            <div>
                <h1 class="page-title">수익 통계</h1>
                <p class="page-sub">수익분석 &gt; 수익 통계</p>
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
            <button class="btn btn-primary"   onclick="downloadExcel()">⬇ 다운로드</button>
        </div>
    </div>

    <%-- 탭 --%>
    <div class="analysis-tabs">
        <button class="analysis-tab-btn ${tab == 'journal'   ? 'active' : ''}" onclick="switchTab('journal',   this)">📒 매출분개</button>
        <button class="analysis-tab-btn ${tab == 'statement' ? 'active' : ''}" onclick="switchTab('statement', this)">📊 재무제표</button>
    </div>

    <%-- 데이터 없을 때 안내 배너 --%>
    <div id="noBanner" class="no-data-banner">
        📭 아직 데이터가 없습니다. 최신화 버튼을 눌러 분석을 실행하세요.
    </div>

    <%-- ===== 매출분개 탭 ===== --%>
    <div id="tab-journal" class="tab-content ${tab == 'journal' ? 'active' : ''}">

        <%-- 요약 카드 --%>
        <div class="stat-row">
            <div class="stat-card">
                <div class="stat-icon blue">💰</div>
                <div class="stat-info">
                    <div class="label">총 매출</div>
                    <div class="value" id="totalRevenue">-</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon red">💸</div>
                <div class="stat-info">
                    <div class="label">총 지출</div>
                    <div class="value red" id="totalExpense">-</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green">📈</div>
                <div class="stat-info">
                    <div class="label">당기순이익</div>
                    <div class="value" id="netProfit">-</div>
                </div>
            </div>
        </div>

        <%-- 차트 2개 --%>
        <div class="analysis-grid">
            <div class="chart-card">
                <div class="chart-card-header"><h3>📈 월별 매출 / 지출 추이</h3></div>
                <div class="chart-wrap"><canvas id="barChart"></canvas></div>
            </div>
            <div class="chart-card">
                <div class="chart-card-header"><h3>🍩 지출 항목별 비중</h3></div>
                <div class="chart-wrap"><canvas id="donutChart"></canvas></div>
            </div>
        </div>

        <%-- 순이익 라인 차트 --%>
        <div class="chart-card" style="margin-bottom:20px;">
            <div class="chart-card-header"><h3>💰 순이익 추이</h3></div>
            <div class="chart-wrap"><canvas id="lineChart"></canvas></div>
        </div>

        <%-- 분개장 테이블 --%>
        <div class="table-card">
            <div class="table-card-header">
                <h3>📒 매출분개 내역</h3>
                <span id="journalCount" style="font-size:0.82rem; color:var(--text-muted);"></span>
            </div>
            <div id="journalTable">
                <div class="empty-placeholder">최신화 버튼을 눌러 데이터를 불러오세요.</div>
            </div>
            <div id="journalPaging" style="display:none; padding:14px 0 4px; display:flex; justify-content:center; gap:6px;"></div>
        </div>
    </div>

    <%-- ===== 재무제표 탭 ===== --%>
    <div id="tab-statement" class="tab-content ${tab == 'statement' ? 'active' : ''}">

        <div class="statement-grid">
            <div class="statement-card">
                <div class="statement-card-header">📋 재무상태표</div>
                <div id="balanceSheet"><div class="empty-placeholder">최신화 버튼을 눌러 데이터를 불러오세요.</div></div>
            </div>
            <div class="statement-card">
                <div class="statement-card-header">📊 손익계산서</div>
                <div id="incomeStatement"><div class="empty-placeholder">최신화 버튼을 눌러 데이터를 불러오세요.</div></div>
            </div>
            <div class="statement-card">
                <div class="statement-card-header">💼 자본변동표</div>
                <div id="equityStatement"><div class="empty-placeholder">최신화 버튼을 눌러 데이터를 불러오세요.</div></div>
            </div>
        </div>

        <%-- AI 재무 분석 카드 --%>
        <div class="ai-report-card" id="aiReportCard" style="display:none;">
            <div class="ai-report-card-header">🤖 AI 재무 동향 분석</div>
            <div id="aiReportBody" class="ai-report-body"></div>
        </div>
    </div>

</div>

<script>
var FASTAPI_URL   = 'http://127.0.0.1:8000';
var currentTab    = '${tab}';
var barChart, donutChart, lineChart;
var _journal = null, _statement = null, _forecast = null, _aiReport = null;
var _journalPage  = 1;
var _journalSize  = 20;

/* ===== 탭 전환 ===== */
function switchTab(tab, btn) {
    document.querySelectorAll('.tab-content').forEach(function(el) { el.classList.remove('active'); });
    document.querySelectorAll('.analysis-tab-btn').forEach(function(b) { b.classList.remove('active'); });
    document.getElementById('tab-' + tab).classList.add('active');
    btn.classList.add('active');
    currentTab = tab;
    history.replaceState(null, '', '/analysis/stats?tab=' + tab);
    if (_statement && Object.keys(_statement).length > 0) {
        if (tab === 'journal' && _journal) renderJournal();
        else if (tab === 'statement') { renderStatement(); renderAiReport(); }
    }
}

/* ===== 최신화 버튼 ===== */
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
    Promise.all([
        fetch('/api/revenue/journal').then(function(r)    { return r.json(); }),
        fetch('/api/revenue/statement').then(function(r)  { return r.json(); }),
        fetch('/api/revenue/forecast').then(function(r)   { return r.json(); }),
        fetch('/api/revenue/ai-report').then(function(r)  { return r.json(); })
    ]).then(function(results) {
        _journal   = results[0];
        _statement = results[1];
        _forecast  = results[2];
        _aiReport  = results[3];
        var hasData = _statement && _statement.income_statement
                      && Object.keys(_statement.income_statement).length > 0;
        if (hasData) {
            document.getElementById('noBanner').style.display = 'none';
            if (currentTab === 'journal') renderJournal();
            else renderStatement();
            renderAiReport();
        } else {
            alert('데이터가 없습니다. Python 분석 결과를 확인해주세요.');
        }
    }).catch(function(e) {
        alert('데이터 로드 실패: ' + e.message);
    }).finally(function() {
        btn.disabled = false;
        btn.textContent = '🔄 최신화';
    });
}

/* ===== 페이지 로드 시 기존 데이터 자동 로드 ===== */
document.addEventListener('DOMContentLoaded', function() {
    Promise.all([
        fetch('/api/revenue/journal').then(function(r)   { return r.json(); }),
        fetch('/api/revenue/statement').then(function(r) { return r.json(); }),
        fetch('/api/revenue/forecast').then(function(r)  { return r.json(); }),
        fetch('/api/revenue/ai-report').then(function(r) { return r.json(); })
    ]).then(function(results) {
        var j = results[0], s = results[1], f = results[2], a = results[3];
        var hasData = s && s.income_statement && Object.keys(s.income_statement).length > 0;
        if (hasData) {
            _journal = j; _statement = s; _forecast = f; _aiReport = a;
            document.getElementById('noBanner').style.display = 'none';
            if (currentTab === 'journal') renderJournal();
            else renderStatement();
            renderAiReport();
        }
    }).catch(function() {});
});

/* ===== 매출분개 렌더링 ===== */
function renderJournal() {
    var inc     = (_statement.income_statement || {});
    var summary = inc.summary || {};
    var totalRevenue = summary['총매출']      || 0;
    var totalExpense = summary['총지출']      || 0;
    var netProfit    = summary['당기순이익'] != null ? summary['당기순이익'] : (totalRevenue - totalExpense);

    document.getElementById('totalRevenue').textContent = fmtWon(totalRevenue);
    document.getElementById('totalExpense').textContent = fmtWon(totalExpense);
    document.getElementById('netProfit').textContent    = fmtWon(netProfit);
    document.getElementById('netProfit').className      = 'value ' + (netProfit >= 0 ? 'green' : 'red');

    // 월별 트렌드 (forecast history)
    var history  = (_forecast && _forecast.history) ? _forecast.history : [];
    var labels   = history.map(function(h) { return h.label || (h.year + '.' + h.month); });
    var revenues = history.map(function(h) { return h.revenue   || 0; });
    var expenses = history.map(function(h) { return h.expenses  || 0; });
    var profits  = history.map(function(h) { return h.net_income || 0; });

    // ① 바 차트
    if (barChart) barChart.destroy();
    if (labels.length > 0) {
        barChart = new Chart(document.getElementById('barChart'), {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [
                    { label: '매출', data: revenues, backgroundColor: 'rgba(91,110,245,0.7)', borderRadius: 6 },
                    { label: '지출', data: expenses, backgroundColor: 'rgba(239,68,68,0.5)',  borderRadius: 6 }
                ]
            },
            options: {
                responsive: true,
                plugins: { legend: { position: 'top' } },
                scales: { y: { ticks: { callback: function(v) { return fmtAxis(v); } } } }
            }
        });
    } else {
        document.getElementById('barChart').parentElement.innerHTML = '<div class="no-data-msg">월별 이력 데이터가 없습니다.</div>';
    }

    // ② 도넛 차트 (지출 항목별)
    var payrollData   = inc.payroll   || {};
    var purchasesData = inc.purchases || {};
    var expDetail     = inc.expenses  || {};
    var donutItems = [
        { name: '급여',   amount: payrollData['급여소계']   || 0 },
        { name: '발주',   amount: purchasesData['발주소계'] || 0 },
        { name: '임대료', amount: expDetail['임대료'] || 0 },
        { name: '공과금', amount: expDetail['공과금'] || 0 },
        { name: '소모품', amount: expDetail['소모품'] || 0 },
        { name: '마케팅', amount: expDetail['마케팅'] || 0 },
        { name: '재료비', amount: expDetail['재료비'] || 0 },
        { name: '기타',   amount: expDetail['기타']   || 0 }
    ].filter(function(d) { return d.amount > 0; });

    if (donutChart) donutChart.destroy();
    if (donutItems.length > 0) {
        var colors = ['#5b6ef5','#ef4444','#f59e0b','#22c55e','#8b5cf6','#06b6d4','#ec4899','#84cc16'];
        donutChart = new Chart(document.getElementById('donutChart'), {
            type: 'doughnut',
            data: {
                labels: donutItems.map(function(d) { return d.name; }),
                datasets: [{
                    data: donutItems.map(function(d) { return d.amount; }),
                    backgroundColor: colors.slice(0, donutItems.length),
                    borderWidth: 2, borderColor: '#fff'
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'right' },
                    tooltip: { callbacks: { label: function(ctx) { return ctx.label + ': ' + fmtWon(ctx.raw); } } }
                }
            }
        });
    } else {
        document.getElementById('donutChart').parentElement.innerHTML = '<div class="no-data-msg">지출 항목 데이터가 없습니다.</div>';
    }

    // ③ 순이익 라인 차트
    if (lineChart) lineChart.destroy();
    if (labels.length > 0) {
        lineChart = new Chart(document.getElementById('lineChart'), {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: '순이익',
                    data: profits,
                    borderColor: '#22c55e',
                    backgroundColor: 'rgba(34,197,94,0.08)',
                    borderWidth: 2.5, pointRadius: 5, tension: 0.3, fill: true
                }]
            },
            options: {
                responsive: true,
                plugins: { legend: { position: 'top' } },
                scales: { y: { ticks: { callback: function(v) { return fmtAxis(v); } } } }
            }
        });
    } else {
        document.getElementById('lineChart').parentElement.innerHTML = '<div class="no-data-msg">월별 이력 데이터가 없습니다.</div>';
    }

    // ④ 분개장 테이블
    _journalPage = 1;
    renderJournalTable();
}

function getType(ref) {
    if (!ref) return '기타';
    var r = String(ref);
    if (r.indexOf('ORD-') === 0) return '매출';
    if (r.indexOf('PAY-') === 0) return '급여';
    if (r.indexOf('EXP-') === 0) return '지출';
    if (r.indexOf('PUR-') === 0) return '발주';
    return '기타';
}
function getBadge(type) {
    if (type === '매출') return 'badge-normal';
    if (type === '급여' || type === '지출') return 'badge-low';
    return 'badge-category';
}

function renderJournalTable() {
    var entries = (_journal && _journal.entries) ? _journal.entries : [];
    var period  = (_journal && _journal.period)  ? _journal.period  : '';
    var total   = entries.length;
    var totalPages = Math.max(1, Math.ceil(total / _journalSize));
    if (_journalPage > totalPages) _journalPage = totalPages;

    document.getElementById('journalCount').textContent = period + ' · 총 ' + total + '건';

    if (total === 0) {
        document.getElementById('journalTable').innerHTML = '<div class="empty-placeholder">분개 데이터가 없습니다.</div>';
        document.getElementById('journalPaging').style.display = 'none';
        return;
    }

    var start = (_journalPage - 1) * _journalSize;
    var paged = entries.slice(start, start + _journalSize);

    var rows = paged.map(function(e) {
        var type = getType(e.ref);
        return '<tr>'
            + '<td>' + (e.date || '-') + '</td>'
            + '<td><span class="badge ' + getBadge(type) + '">' + type + '</span></td>'
            + '<td style="text-align:left;">' + (e.description || '-') + '</td>'
            + '<td>' + (e.debit  || '-') + '</td>'
            + '<td>' + (e.credit || '-') + '</td>'
            + '<td class="amount-plus">' + (e.amount != null ? fmtWon(Number(e.amount)) : '-') + '</td>'
            + '</tr>';
    }).join('');

    document.getElementById('journalTable').innerHTML =
        '<table class="data-table"><thead><tr>'
        + '<th>날짜</th><th>유형</th><th>내용</th><th>차변(계정)</th><th>대변(계정)</th><th>금액</th>'
        + '</tr></thead><tbody>' + rows + '</tbody></table>';

    // 페이징 버튼
    var pagingEl = document.getElementById('journalPaging');
    pagingEl.style.display = 'flex';
    var blockSize = 5;
    var blockStart = Math.floor((_journalPage - 1) / blockSize) * blockSize + 1;
    var blockEnd   = Math.min(blockStart + blockSize - 1, totalPages);
    var btns = '';
    if (blockStart > 1) {
        btns += '<button class="page-btn" onclick="changeJournalPage(' + (blockStart - 1) + ')">◀</button>';
    }
    for (var i = blockStart; i <= blockEnd; i++) {
        btns += '<button class="page-btn' + (i === _journalPage ? ' active' : '') + '" onclick="changeJournalPage(' + i + ')">' + i + '</button>';
    }
    if (blockEnd < totalPages) {
        btns += '<button class="page-btn" onclick="changeJournalPage(' + (blockEnd + 1) + ')">▶</button>';
    }
    pagingEl.innerHTML = btns;
}

function changeJournalPage(page) {
    var entries = (_journal && _journal.entries) ? _journal.entries : [];
    var totalPages = Math.max(1, Math.ceil(entries.length / _journalSize));
    if (page < 1 || page > totalPages) return;
    _journalPage = page;
    renderJournalTable();
}

/* ===== AI 분석 렌더링 ===== */
function renderAiReport() {
    var card = document.getElementById('aiReportCard');
    var body = document.getElementById('aiReportBody');
    var text = _aiReport && _aiReport.text ? _aiReport.text.trim() : '';
    if (!text) {
        card.style.display = 'none';
        return;
    }

    // 줄 단위로 파싱
    var lines = text.split('\n');
    var html = '';
    var i = 0;
    while (i < lines.length) {
        var line = lines[i];
        var trimmed = line.trim();

        // 빈 줄 건너뜀
        if (trimmed === '') { i++; continue; }

        // --- 구분선 숨김
        if (/^---+$/.test(trimmed)) { i++; continue; }

        // # 제목
        if (trimmed.charAt(0) === '#') {
            var headText = esc(trimmed.replace(/^[#]+\s*/, ''));
            html += '<div class="ai-h1">' + headText + '</div>';
            i++; continue;
        }

        // **섹션 헤더** (줄 전체가 bold)
        if (/^\*\*(.+)\*\*$/.test(trimmed)) {
            var secText = esc(trimmed.replace(/^\*\*|\*\*$/g, ''));
            html += '<div class="ai-section">' + secText + '</div>';
            i++; continue;
        }

        // 번호 항목: "1." 또는 "1. **제목**" — 다음 줄이 bold 제목이면 합침
        if (/^\d+\.$/.test(trimmed)) {
            var num = trimmed;
            // 앞으로 빈 줄 건너뛰고 제목 줄 탐색
            var j = i + 1;
            while (j < lines.length && lines[j].trim() === '') j++;
            var nextLine = j < lines.length ? lines[j].trim() : '';
            if (/^\*\*(.+)\*\*$/.test(nextLine)) {
                var itemTitle = esc(nextLine.replace(/^\*\*|\*\*$/g, ''));
                html += '<div class="ai-list-item">' + num + ' ' + itemTitle + '</div>';
                i = j + 1; continue;
            } else {
                html += '<div class="ai-list-item">' + esc(num) + '</div>';
                i++; continue;
            }
        }

        // 일반 텍스트 — 인라인 bold 처리
        var lineHtml = esc(trimmed).replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
        html += '<p>' + lineHtml + '</p>';
        i++;
    }

    body.innerHTML = html;
    card.style.display = 'block';
}
function esc(s) {
    return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

/* ===== 재무제표 렌더링 ===== */
function renderStatement() {
    var bs  = _statement.balance_sheet  || {};
    var inc = _statement.income_statement || {};
    var cc  = _statement.capital_changes  || {};

    var current      = bs.current      || {};
    var summary      = inc.summary     || {};
    var payroll      = inc.payroll     || {};
    var purchasesInc = inc.purchases   || {};
    var expDetail    = inc.expenses    || {};
    var revDetail    = inc.revenue     || {};

    var netProfit    = summary['당기순이익'] != null ? summary['당기순이익'] : (bs.net_income || 0);

    // 재무상태표
    document.getElementById('balanceSheet').innerHTML = buildTable([
        { label: '현금',          value: current['현금']     || 0, type: 'neutral' },
        { label: '재고자산',      value: current['재고']     || 0, type: 'neutral' },
        { label: '자산총액',      value: current['자산총액'] || 0, type: 'total',  bold: true },
        { label: '미착재고(부채)',value: current['미착재고'] || 0, type: 'minus' },
        { label: '부채합계',      value: current['부채합계'] || 0, type: 'minus' },
        { label: '자본합계',      value: current['자본합계'] || 0, type: 'total',  bold: true }
    ]);

    // 손익계산서
    var incRows = [];
    Object.keys(revDetail).forEach(function(k) {
        var v = revDetail[k];
        if (k !== '총매출' && typeof v === 'number' && v > 0) {
            incRows.push({ label: k, value: v, type: 'plus' });
        }
    });
    incRows.push({ label: '총매출',    value: summary['총매출']    || 0, type: 'plus',  bold: true });
    incRows.push({ label: '── 지출 ──', value: null, type: 'divider' });
    incRows.push({ label: '급여소계',   value: payroll['급여소계']     || 0, type: 'minus' });
    incRows.push({ label: '발주소계',   value: purchasesInc['발주소계'] || 0, type: 'minus' });
    incRows.push({ label: '지출소계',   value: expDetail['지출소계']   || 0, type: 'minus' });
    incRows.push({ label: '총지출',    value: summary['총지출']    || 0, type: 'minus', bold: true });
    incRows.push({ label: '당기순이익', value: netProfit, type: netProfit >= 0 ? 'plus' : 'minus', bold: true });
    document.getElementById('incomeStatement').innerHTML = buildTable(incRows);

    // 자본변동표
    var prevCapital = (cc['기초자본'] || {})['자본합계'] || 0;
    var currCapital = (cc['기말자본'] || {})['자본합계'] || 0;
    var changeTotal = cc['변동총액'] != null ? cc['변동총액'] : (currCapital - prevCapital);
    document.getElementById('equityStatement').innerHTML = buildTable([
        { label: '기초자본',    value: prevCapital,  type: 'neutral' },
        { label: '당기순이익',  value: netProfit,    type: netProfit >= 0 ? 'plus' : 'minus' },
        { label: '기말자본',    value: currCapital,  type: 'total',  bold: true },
        { label: '변동총액',    value: changeTotal,  type: changeTotal >= 0 ? 'plus' : 'minus', bold: true }
    ]);
}

function buildTable(rows) {
    var html = '<table class="statement-table">';
    rows.forEach(function(row) {
        if (row.type === 'divider') {
            html += '<tr><td colspan="2" style="text-align:center;color:var(--text-muted);font-size:0.75rem;padding:5px;">' + row.label + '</td></tr>';
            return;
        }
        if (row.value === null || row.value === undefined) return;
        var cls    = row.type === 'plus' ? 'amount-plus' : row.type === 'minus' ? 'amount-minus' : row.type === 'total' ? 'amount-total' : '';
        var prefix = row.type === 'plus' ? '+' : row.type === 'minus' ? '-' : '';
        html += '<tr' + (row.bold ? ' class="row-total"' : '') + '>'
            + '<td class="st-label">' + row.label + '</td>'
            + '<td class="st-value ' + cls + '">' + prefix + Math.abs(row.value).toLocaleString() + '원</td>'
            + '</tr>';
    });
    return html + '</table>';
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

function downloadExcel() {
    fetch('/api/revenue/excel-available')
        .then(function(r) { return r.json(); })
        .then(function(res) {
            if (res.available) {
                location.href = '/analysis/excel/download';
            } else {
                alert('다운로드할 파일이 없습니다.\n최신화 버튼을 눌러 분석을 먼저 실행해주세요.');
            }
        })
        .catch(function() {
            alert('다운로드할 파일이 없습니다.\n최신화 버튼을 눌러 분석을 먼저 실행해주세요.');
        });
}
</script>
</body>
</html>
