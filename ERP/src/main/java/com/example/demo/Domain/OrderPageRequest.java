package com.example.demo.Domain;

public class OrderPageRequest extends PageRequest {

    private String keyword;   // 주문번호 or 결제수단 검색
    private String status;    // 상태 필터 (대기/완료/취소)
    private String dateFrom;  // 시작일 (yyyy-MM-dd)
    private String dateTo;    // 종료일 (yyyy-MM-dd)

    public OrderPageRequest() {
        super(1, 10);
    }

    public OrderPageRequest(int page, int size) {
        super(page, size);
    }

    public String getKeyword()               { return keyword; }
    public void   setKeyword(String keyword) { this.keyword = keyword; }
    public String getStatus()                { return status; }
    public void   setStatus(String status)   { this.status = status; }
    public String getDateFrom()              { return dateFrom; }
    public void   setDateFrom(String d)      { this.dateFrom = d; }
    public String getDateTo()                { return dateTo; }
    public void   setDateTo(String d)        { this.dateTo = d; }
}