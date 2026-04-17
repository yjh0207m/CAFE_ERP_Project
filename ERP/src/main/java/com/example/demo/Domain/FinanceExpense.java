package com.example.demo.Domain;

public class FinanceExpense {

    private Long   id;
    private String expenseType;
    private int    amount;
    private String expenseDate;
    private String description;
    private String receiptPath;      // 영수증 파일 저장 경로 (신규)
    private Long   registeredBy;
    private String registeredByName; // 조인용 (users.user_name)
    private int    status;
	private String createdAt;

    public Long   getId()                        { return id; }
    public void   setId(Long id)                 { this.id = id; }
    public String getExpenseType()               { return expenseType; }
    public void   setExpenseType(String v)       { this.expenseType = v; }
    public int    getAmount()                    { return amount; }
    public void   setAmount(int v)               { this.amount = v; }
    public String getExpenseDate()               { return expenseDate; }
    public void   setExpenseDate(String v)       { this.expenseDate = v; }
    public String getDescription()               { return description; }
    public void   setDescription(String v)       { this.description = v; }
    public String getReceiptPath()               { return receiptPath; }
    public void   setReceiptPath(String v)       { this.receiptPath = v; }
    public Long   getRegisteredBy()              { return registeredBy; }
    public void   setRegisteredBy(Long v)        { this.registeredBy = v; }
    public String getRegisteredByName()          { return registeredByName; }
    public void   setRegisteredByName(String v)  { this.registeredByName = v; }
    public String getCreatedAt()                 { return createdAt; }
    public void   setCreatedAt(String v)         { this.createdAt = v; }
    public int 	  getStatus()                    { return status; }
	public void   setStatus(int status)          { this.status = status; }
}