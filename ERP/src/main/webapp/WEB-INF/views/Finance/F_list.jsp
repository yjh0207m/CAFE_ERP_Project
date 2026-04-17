<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>지출 내역 | ERP CAFE SYSTEM</title>
    <link rel="stylesheet" href="/css/header.css" />
    <link rel="stylesheet" href="/css/Common.css" />
    <link rel="stylesheet" href="/css/Finance/F_list.css" />
</head>
<body>

<jsp:include page="/WEB-INF/views/header.jsp"/>

<div class="content">

    <!-- 페이지 헤더 -->
    <div class="page-header">
        <div class="page-title-wrap">
            <span class="page-icon">💳</span>
            <div>
                <h1 class="page-title">지출 내역</h1>
                <p class="page-sub">재무관리 &gt; 지출 내역</p>
            </div>
        </div>
        <button class="btn btn-primary" onclick="openRegisterModal()">+ 지출 등록</button>
    </div>

    <!-- 검색/필터 바 -->
    <div class="filter-bar">
        <select class="filter-input" id="filterType" onchange="goFilter()">
            <option value="" ${empty param.expenseType ? 'selected' : ''}>전체 유형</option>
            <option value="재료비"  ${param.expenseType == '재료비'  ? 'selected' : ''}>재료비</option>
            <option value="인건비"  ${param.expenseType == '인건비'  ? 'selected' : ''}>인건비</option>
            <option value="임대료"  ${param.expenseType == '임대료'  ? 'selected' : ''}>임대료</option>
            <option value="공과금"  ${param.expenseType == '공과금'  ? 'selected' : ''}>공과금</option>
            <option value="소모품"  ${param.expenseType == '소모품'  ? 'selected' : ''}>소모품</option>
            <option value="마케팅"  ${param.expenseType == '마케팅'  ? 'selected' : ''}>마케팅</option>
            <option value="기타"    ${param.expenseType == '기타'    ? 'selected' : ''}>기타</option>
        </select>
        <input type="date" class="filter-input" id="filterDateFrom"
               value="${param.dateFrom}" onchange="goFilter()" />
        <span class="filter-sep">~</span>
        <input type="date" class="filter-input" id="filterDateTo"
               value="${param.dateTo}" onchange="goFilter()" />
        <div class="search-box">
            <input type="text" class="filter-input" id="keywordInput"
                   placeholder="비고 검색..." value="${param.keyword}"
                   onkeydown="if(event.key==='Enter') goFilter()" />
            <button class="btn btn-primary" onclick="goFilter()">🔍 검색</button>
        </div>
        <button class="btn btn-reset" onclick="resetFilter()">초기화</button>
    </div>

    <!-- 테이블 -->
    <div class="table-card">
        <div class="table-card-header">
            <h3>지출 목록</h3>
            <span style="font-size:0.82rem; color:var(--text-muted);">
                총 ${result.totalCount}건 중 ${result.list.size()}건 표시
            </span>
        </div>
        <table class="expense-table">
            <thead>
                <tr>
                    <th>No.</th>
                    <th>지출 날짜</th>
                    <th>지출 유형</th>
                    <th>금액</th>
                    <th>비고</th>
                    <th>등록자</th>
                    <th>등록일시</th>
                    <th>영수증</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody id="tableBody">
                <c:choose>
                    <c:when test="${empty result.list}">
                        <tr>
                            <td colspan="9" class="empty-row">등록된 지출 내역이 없습니다.</td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="exp" items="${result.list}" varStatus="status">
                        <tr class="expense-row">
                            <td class="td-no">${(result.page - 1) * result.size + status.count}</td>
                            <td>${exp.expenseDate}</td>
                            <td><span class="type-badge type-${exp.expenseType}">${exp.expenseType}</span></td>
                            <td class="td-amount"><fmt:formatNumber value="${exp.amount}" pattern="#,###"/>원</td>
                            <td class="td-desc">${empty exp.description ? '-' : exp.description}</td>
                            <td>${empty exp.registeredByName ? '-' : exp.registeredByName}</td>
                            <td class="td-date">${exp.createdAt}</td>
                            <td>
                                <button class="btn-icon btn-receipt"
                                        data-id="${exp.id}"
                                        data-path="${empty exp.receiptPath ? '' : exp.receiptPath}"
                                        onclick="openReceiptPopup(this)">🧾 조회</button>
                            </td>
                            <td class="td-actions">
                                <button class="btn-icon btn-edit" onclick="openEditModal(${exp.id}, '${exp.expenseType}', ${exp.amount}, '${exp.expenseDate}', '${empty exp.description ? "" : exp.description}')">✏️</button>
                                <button class="btn-icon btn-delete" onclick="deleteExpense(${exp.id})">🗑️</button>
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
                <c:forEach begin="${result.startPage}" end="${result.endPage}" var="p">
                    <button class="page-btn ${p == result.page ? 'active' : ''}"
                            onclick="goPage(${p})">${p}</button>
                </c:forEach>
                <c:if test="${result.hasNext()}">
                    <button class="page-btn" onclick="goPage(${result.endPage + 1})">▶</button>
                </c:if>
            </div>

            <div style="font-size:0.8rem; color:var(--text-muted);">
                총 ${result.totalCount}건
            </div>
        </div>
    </div>

</div>

<!-- ===== 지출 등록 모달 ===== -->
<div class="modal-overlay" id="registerModal">
    <div class="modal modal-register">
        <div class="modal-header">
            <span class="modal-title">💰 지출 등록</span>
            <button class="modal-close" onclick="closeModal('registerModal')">✕</button>
        </div>
        <div class="modal-body">
            <form id="expenseForm" action="/f_register" method="post" enctype="multipart/form-data">
                <input type="hidden" id="regAmountRaw" name="amount" />

                <!-- 영수증 업로드 (OCR) -->
                <div class="form-group">
                    <label class="form-label">영수증 업로드 <span class="ocr-badge">🤖 OCR 자동분석</span></label>
                    <div class="file-drop-area" id="regFileDropArea"
                         onclick="document.getElementById('regReceiptFile').click()">
                        <input type="file" id="regReceiptFile" name="receiptFile"
                               accept="image/*" style="display:none;"
                               onchange="handleRegFileSelect(this)" />
                        <div class="file-drop-icon">📸</div>
                        <div class="file-drop-text" id="regFileDropText">
                            영수증을 업로드하면 내용을 자동으로 분석합니다<br>
                            <span class="file-drop-hint">JPG, PNG 지원 · 최대 10MB · 클릭 또는 드래그</span>
                        </div>
                    </div>
                    <div id="regOcrStatus" class="ocr-status" style="display:none;"></div>
                    <div class="file-preview" id="regFilePreview"></div>
                </div>

                <div class="form-group">
                    <label class="form-label required">지출 날짜</label>
                    <input type="date" class="form-input" id="regExpenseDate" name="expenseDate" />
                </div>

                <div class="form-group">
                    <label class="form-label required">지출 유형</label>
                    <select class="form-input form-select" id="regExpenseType" name="expenseType">
                        <option value="" disabled selected>유형 선택</option>
                        <option value="재료비">재료비</option>
                        <option value="인건비">인건비</option>
                        <option value="임대료">임대료</option>
                        <option value="공과금">공과금</option>
                        <option value="소모품">소모품</option>
                        <option value="마케팅">마케팅</option>
                        <option value="기타">기타</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label required">금액</label>
                    <div class="input-wrap">
                        <input type="text" class="form-input input-with-unit" id="regAmount"
                               placeholder="0" oninput="formatAmount(this)" />
                        <span class="input-unit">원</span>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">비고</label>
                    <textarea class="form-input form-textarea" id="regMemo" name="description"
                              placeholder="영수증 업로드 시 가맹점명이 자동입력됩니다"></textarea>
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn btn-cancel" onclick="closeModal('registerModal')">취소</button>
                    <button type="button" class="btn btn-primary" onclick="submitRegister()">등록</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ===== 수정 모달 ===== -->
<div class="modal-overlay" id="editModal">
    <div class="modal">
        <div class="modal-header">
            <span class="modal-title">지출 수정</span>
            <button class="modal-close" onclick="closeModal('editModal')">✕</button>
        </div>
        <div class="modal-body">
            <form id="editForm" action="/f_update" method="post">
                <input type="hidden" id="editId" name="id" />

                <div class="form-group">
                    <label class="form-label required">지출 날짜</label>
                    <input type="date" class="form-input" id="editDate" name="expenseDate" />
                </div>
                <div class="form-group">
                    <label class="form-label required">지출 유형</label>
                    <select class="form-input form-select" id="editType" name="expenseType">
                        <option value="재료비">재료비</option>
                        <option value="인건비">인건비</option>
                        <option value="임대료">임대료</option>
                        <option value="공과금">공과금</option>
                        <option value="소모품">소모품</option>
                        <option value="마케팅">마케팅</option>
                        <option value="기타">기타</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label required">금액</label>
                    <div class="input-wrap">
                        <input type="text" class="form-input input-with-unit" id="editAmountDisplay"
                               placeholder="0" oninput="formatAmount(this)" />
                        <input type="hidden" id="editAmount" name="amount" />
                        <span class="input-unit">원</span>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">비고</label>
                    <textarea class="form-input form-textarea" id="editDesc" name="description"
                              placeholder="추가 메모를 입력하세요"></textarea>
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn btn-cancel" onclick="closeModal('editModal')">취소</button>
                    <button type="button" class="btn btn-primary" onclick="submitEdit()">저장</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ===== 영수증 팝업 ===== -->
<div class="modal-overlay" id="receiptModal">
    <div class="modal modal-receipt">
        <div class="modal-header">
            <span class="modal-title">🧾 영수증 조회</span>
            <button class="modal-close" onclick="closeModal('receiptModal')">✕</button>
        </div>
        <div class="modal-body">
            <div class="receipt-preview-wrap" id="receiptPreviewWrap">
                <div class="receipt-empty" id="receiptEmpty">등록된 영수증이 없습니다.</div>
                <img id="receiptImg" class="receipt-img" src="" alt="영수증" style="display:none;" />
            </div>

            <div class="receipt-upload-section">
                <label class="form-label">영수증 변경</label>
                <div class="file-drop-area" id="receiptDropArea" onclick="document.getElementById('receiptUpload').click()">
                    <input type="file" id="receiptUpload" accept="image/*,.pdf" style="display:none;"
                           onchange="previewReceipt(this)" />
                    <div class="file-drop-icon">📎</div>
                    <div class="file-drop-text" id="receiptDropText">
                        클릭하거나 파일을 드래그하여 업로드<br>
                        <span class="file-drop-hint">JPG, PNG, PDF 지원</span>
                    </div>
                </div>
            </div>

            <div class="modal-actions">
                <button type="button" class="btn btn-cancel" onclick="closeModal('receiptModal')">닫기</button>
                <button type="button" class="btn btn-primary" onclick="applyReceipt()">적용</button>
            </div>
        </div>
    </div>
</div>

<script>
    /* ===== 현재 필터 상태 ===== */
    var currentPage    = ${empty result.page ? 1 : result.page};
    var currentSize    = ${empty size ? 10 : size};
    var currentType    = '${param.expenseType}';
    var currentFrom    = '${param.dateFrom}';
    var currentTo      = '${param.dateTo}';
    var currentKeyword = '${param.keyword}';

    /* ===== 페이지 이동 ===== */
    function buildUrl(page) {
        var type    = document.getElementById('filterType').value;
        var from    = document.getElementById('filterDateFrom').value;
        var to      = document.getElementById('filterDateTo').value;
        var keyword = document.getElementById('keywordInput').value.trim();
        var url = '/f_list?page=' + page + '&size=' + currentSize;
        if (type)    url += '&expenseType=' + encodeURIComponent(type);
        if (from)    url += '&dateFrom='    + encodeURIComponent(from);
        if (to)      url += '&dateTo='      + encodeURIComponent(to);
        if (keyword) url += '&keyword='     + encodeURIComponent(keyword);
        return url;
    }

    function goPage(p)  { location.href = buildUrl(p); }
    function goFilter() { location.href = buildUrl(1); }

    function changeSize(s) {
        currentSize = s;
        location.href = buildUrl(1);
    }

    function resetFilter() {
        location.href = '/f_list?page=1&size=' + currentSize;
    }

    /* ===== 금액 콤마 포맷 ===== */
    function formatAmount(input) {
        var val = input.value.replace(/[^0-9]/g, '');
        input.value = val ? Number(val).toLocaleString() : '';
    }

    /* ===== 모달 ===== */
    function openModal(id)  { document.getElementById(id).classList.add('active'); }
    function closeModal(id) { document.getElementById(id).classList.remove('active'); }

    /* ===== 지출 등록 모달 ===== */
    function openRegisterModal() {
        document.getElementById('expenseForm').reset();
        document.getElementById('regFileDropText').innerHTML =
            '영수증을 업로드하면 내용을 자동으로 분석합니다<br>' +
            '<span class="file-drop-hint">JPG, PNG 지원 · 최대 10MB · 클릭 또는 드래그</span>';
        document.getElementById('regFileDropArea').className = 'file-drop-area';
        document.getElementById('regFilePreview').innerHTML  = '';
        document.getElementById('regOcrStatus').style.display = 'none';
        openModal('registerModal');
    }

    /* ===== 등록 모달 — 파일 선택 ===== */
    function handleRegFileSelect(input) {
        var file = input.files[0];
        if (!file) return;
        var sizeKB = (file.size / 1024).toFixed(1);
        document.getElementById('regFileDropText').innerHTML =
            '<strong>' + file.name + '</strong><br><span class="file-drop-hint">' + sizeKB + ' KB</span>';
        document.getElementById('regFileDropArea').classList.add('has-file');
        if (file.type.startsWith('image/')) {
            var reader = new FileReader();
            reader.onload = function(e) {
                document.getElementById('regFilePreview').innerHTML =
                    '<img src="' + e.target.result + '" alt="영수증 미리보기" class="receipt-preview-img" />';
            };
            reader.readAsDataURL(file);
        }
        analyzeOcr(file);
    }

    /* ===== 등록 모달 — 드래그앤드롭 ===== */
    var regDropArea = document.getElementById('regFileDropArea');
    regDropArea.addEventListener('dragover',  function(e) { e.preventDefault(); regDropArea.classList.add('drag-over'); });
    regDropArea.addEventListener('dragleave', function()  { regDropArea.classList.remove('drag-over'); });
    regDropArea.addEventListener('drop', function(e) {
        e.preventDefault();
        regDropArea.classList.remove('drag-over');
        var file = e.dataTransfer.files[0];
        if (file) {
            var inp = document.getElementById('regReceiptFile');
            var dt = new DataTransfer();
            dt.items.add(file);
            inp.files = dt.files;
            handleRegFileSelect(inp);
        }
    });

    /* ===== OCR 분석 ===== */
    function analyzeOcr(file) {
        var statusEl = document.getElementById('regOcrStatus');
        statusEl.style.display = 'flex';
        statusEl.className     = 'ocr-status ocr-loading';
        statusEl.innerHTML     = '<span class="ocr-spinner"></span> 영수증 분석 중...';
        var formData = new FormData();
        formData.append('image', file);
        fetch('/ocr/analyze', { method: 'POST', body: formData })
            .then(function(res) { return res.json(); })
            .then(function(data) {
                if (data.success) {
                    applyOcrResult(data);
                    statusEl.className = 'ocr-status ocr-success';
                    statusEl.innerHTML = '✓ 분석 완료 — 내용을 확인 후 필요시 수정하세요.';
                } else {
                    statusEl.className = 'ocr-status ocr-fail';
                    statusEl.innerHTML = '⚠ 자동분석 실패: ' + (data.message || '수동으로 입력해주세요.');
                }
            })
            .catch(function() {
                statusEl.className = 'ocr-status ocr-fail';
                statusEl.innerHTML = '⚠ 서버 오류 — 수동으로 입력해주세요.';
            });
    }

    function applyOcrResult(data) {
        if (data.date   && data.date.length === 10) document.getElementById('regExpenseDate').value = data.date;
        if (data.amount && data.amount > 0) {
            document.getElementById('regAmount').value = data.amount.toLocaleString();
            document.getElementById('regAmountRaw').value = data.amount;
        }
        if (data.storeName) document.getElementById('regMemo').value = data.storeName;
    }

    /* ===== 등록 유효성 & 제출 ===== */
    function submitRegister() {
        var date   = document.getElementById('regExpenseDate').value;
        var type   = document.getElementById('regExpenseType').value;
        var amount = document.getElementById('regAmount').value.replace(/,/g, '');
        if (!date)   { alert('지출 날짜를 선택해주세요.'); return; }
        if (!type)   { alert('지출 유형을 선택해주세요.'); return; }
        if (!amount) { alert('금액을 입력해주세요.'); return; }
        document.getElementById('regAmountRaw').value = amount;
        document.getElementById('expenseForm').submit();
    }

    /* ===== 수정 모달 ===== */
    function openEditModal(id, type, amount, date, desc) {
        document.getElementById('editId').value            = id;
        document.getElementById('editDate').value          = date;
        document.getElementById('editType').value          = type;
        document.getElementById('editAmountDisplay').value = Number(amount).toLocaleString();
        document.getElementById('editAmount').value        = amount;
        document.getElementById('editDesc').value          = desc;
        openModal('editModal');
    }

    function submitEdit() {
        var raw = document.getElementById('editAmountDisplay').value.replace(/,/g, '');
        if (!raw) { alert('금액을 입력해주세요.'); return; }
        document.getElementById('editAmount').value = raw;
        document.getElementById('editForm').submit();
    }

    /* ===== 삭제 ===== */
    function deleteExpense(id) {
        if (!confirm('해당 지출 내역을 삭제하시겠습니까?')) return;
        var form  = document.createElement('form');
        form.method = 'post';
        form.action = '/f_delete';
        var input = document.createElement('input');
        input.type  = 'hidden';
        input.name  = 'id';
        input.value = id;
        form.appendChild(input);
        document.body.appendChild(form);
        form.submit();
    }

    /* ===== 영수증 팝업 ===== */
    var currentReceiptId = null;

    function openReceiptPopup(btn) {
        currentReceiptId = btn.getAttribute('data-id');
        var path = btn.getAttribute('data-path');
        var img   = document.getElementById('receiptImg');
        var empty = document.getElementById('receiptEmpty');

        // 업로드 UI 초기화
        document.getElementById('receiptDropText').innerHTML =
            '클릭하거나 파일을 드래그하여 업로드<br><span class="file-drop-hint">JPG, PNG, PDF 지원</span>';
        document.getElementById('receiptDropArea').classList.remove('has-file');
        document.getElementById('receiptUpload').value = '';

        if (path && path !== '') {
            // 경로 앞에 / 없으면 보정
            var normalizedPath = (path.charAt(0) === '/') ? path : '/' + path;
            img.onerror = function() {
                img.style.display  = 'none';
                empty.style.display = 'block';
                empty.innerHTML = '영수증을 불러올 수 없습니다.<br>'
                    + '<span style="font-size:0.76rem;color:var(--text-muted);">' + normalizedPath + '</span>';
            };
            img.onload = function() {
                img.style.display   = 'block';
                empty.style.display = 'none';
            };
            img.src = normalizedPath;
        } else {
            img.src = '';
            img.style.display = 'none';
            empty.style.display = 'block';
            empty.innerHTML = '등록된 영수증이 없습니다.';
        }

        openModal('receiptModal');
    }

    function previewReceipt(input) {
        var file = input.files[0];
        if (!file) return;
        var sizeKB = (file.size / 1024).toFixed(1);
        document.getElementById('receiptDropText').innerHTML =
            '<strong>' + file.name + '</strong><br><span class="file-drop-hint">' + sizeKB + ' KB</span>';
        document.getElementById('receiptDropArea').classList.add('has-file');
        if (file.type.startsWith('image/')) {
            var reader = new FileReader();
            reader.onload = function(e) {
                var img = document.getElementById('receiptImg');
                img.src = e.target.result;
                img.style.display = 'block';
                document.getElementById('receiptEmpty').style.display = 'none';
            };
            reader.readAsDataURL(file);
        }
    }

    var dropArea = document.getElementById('receiptDropArea');
    dropArea.addEventListener('dragover',  function(e) { e.preventDefault(); dropArea.classList.add('drag-over'); });
    dropArea.addEventListener('dragleave', function()  { dropArea.classList.remove('drag-over'); });
    dropArea.addEventListener('drop', function(e) {
        e.preventDefault();
        dropArea.classList.remove('drag-over');
        var file = e.dataTransfer.files[0];
        if (file) {
            var inp = document.getElementById('receiptUpload');
            var dt = new DataTransfer();
            dt.items.add(file);
            inp.files = dt.files;
            previewReceipt(inp);
        }
    });

    function applyReceipt() {
        var input = document.getElementById('receiptUpload');
        if (!input.files[0]) { alert('변경할 파일을 선택해주세요.'); return; }
        if (!currentReceiptId)  { alert('지출 ID를 확인할 수 없습니다.'); return; }

        var formData = new FormData();
        formData.append('receiptFile', input.files[0]);
        formData.append('id', currentReceiptId);

        fetch('/f_receipt_upload', { method: 'POST', body: formData })
            .then(function(res) { return res.json(); })
            .then(function(data) {
                if (data.success) {
                    alert('영수증이 변경되었습니다.');
                    closeModal('receiptModal');
                    location.reload();
                } else {
                    alert('업로드 실패: ' + (data.message || '다시 시도해주세요.'));
                }
            })
            .catch(function() {
                alert('서버 오류가 발생했습니다.');
            });
    }

    /* ===== 모달 외부 클릭 닫기 ===== */
    document.querySelectorAll('.modal-overlay').forEach(function(overlay) {
        overlay.addEventListener('click', function(e) {
            if (e.target === overlay) closeModal(overlay.id);
        });
    });
</script>

</body>
</html>
