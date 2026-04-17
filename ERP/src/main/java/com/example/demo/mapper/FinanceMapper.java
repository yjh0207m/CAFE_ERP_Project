package com.example.demo.mapper;

//import com.example.demo.Domain.Employee;
import com.example.demo.Domain.Employees;
import com.example.demo.Domain.FinanceExpense;
import com.example.demo.Domain.PageRequest;
import com.example.demo.Domain.Payrolls;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface FinanceMapper {

    // ── Expense ──────────────────────────────────────
    int insertExpense(FinanceExpense expense);
    List<FinanceExpense> selectExpenseList();           // 기존 (삭제 보류)
    List<FinanceExpense> findExpenseByPage(PageRequest req);
    int countExpense(PageRequest req);
    int updateExpense(FinanceExpense expense);
    int updateReceiptPath(@org.apache.ibatis.annotations.Param("id") Long id,
                          @org.apache.ibatis.annotations.Param("receiptPath") String receiptPath);
    int deleteExpense(Long id);

    // ── Payroll ───────────────────────────────────────
    List<Payrolls> selectPayrollList();                 // 기존 (삭제 보류)
    List<Payrolls> findPayrollByPage(PageRequest req);
    int countPayroll(PageRequest req);
    int insertPayroll(Payrolls payroll);
    int updatePayroll(Payrolls payroll);
    int deletePayroll(Long id);

    // ── Employee (수동처리 드롭다운) ──────────────────
    List<Employees> selectActiveEmployeeList();
}