package com.example.demo.Domain;

public class Payrolls {
    private Long    id;
    private Long    employeeId;
    private int     payYear;
    private int     payMonth;
    private double  workHours;
    private int     basePay;
    private int     deduction;
    private int     netPay;
    private String  paidAt;
    private String  note;
    private int     payType;    // 'salary' | 'incentive'
    private String  createdAt;

    // 조인용 (employees 테이블에서)
    private String  employeeName;
    private String  employeeNo;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getEmployeeId() { return employeeId; }
    public void setEmployeeId(Long employeeId) { this.employeeId = employeeId; }

    public int getPayYear() { return payYear; }
    public void setPayYear(int payYear) { this.payYear = payYear; }

    public int getPayMonth() { return payMonth; }
    public void setPayMonth(int payMonth) { this.payMonth = payMonth; }

    public double getWorkHours() { return workHours; }
    public void setWorkHours(double workHours) { this.workHours = workHours; }

    public int getBasePay() { return basePay; }
    public void setBasePay(int basePay) { this.basePay = basePay; }

    public int getDeduction() { return deduction; }
    public void setDeduction(int deduction) { this.deduction = deduction; }

    public int getNetPay() { return netPay; }
    public void setNetPay(int netPay) { this.netPay = netPay; }

    public String getPaidAt() { return paidAt; }
    public void setPaidAt(String paidAt) { this.paidAt = paidAt; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public int getPayType() { return payType; }
    public void setPayType(int payType) { this.payType = payType; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    public String getEmployeeName() { return employeeName; }
    public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }

    public String getEmployeeNo() { return employeeNo; }
    public void setEmployeeNo(String employeeNo) { this.employeeNo = employeeNo; }
}