package com.example.demo.Domain;

/**
 * Clova OCR 영수증 분석 결과를 담는 Domain
 * → /ocr/analyze 응답 + FinanceExpense 폼 자동채움에 사용
 */
public class OCRResult {

    private boolean success;   // OCR 성공 여부
    private String  storeName; // 가맹점명 (비고에 자동입력)
    private String  date;      // 지출일자  (yyyy-MM-dd)
    private int     amount;    // 합계 금액
    private String  message;   // 실패 시 메시지

    public OCRResult() {}

    /** 성공 결과 생성 편의 메서드 */
    public static OCRResult success(String storeName, String date, int amount) {
    	OCRResult r = new OCRResult();
        r.success   = true;
        r.storeName = storeName;
        r.date      = date;
        r.amount    = amount;
        return r;
    }

    /** 실패 결과 생성 편의 메서드 */
    public static OCRResult fail(String message) {
    	OCRResult r = new OCRResult();
        r.success = false;
        r.message = message;
        return r;
    }

    public boolean isSuccess()              { return success; }
    public void    setSuccess(boolean v)    { this.success = v; }
    public String  getStoreName()           { return storeName; }
    public void    setStoreName(String v)   { this.storeName = v; }
    public String  getDate()                { return date; }
    public void    setDate(String v)        { this.date = v; }
    public int     getAmount()              { return amount; }
    public void    setAmount(int v)         { this.amount = v; }
    public String  getMessage()             { return message; }
    public void    setMessage(String v)     { this.message = v; }
}