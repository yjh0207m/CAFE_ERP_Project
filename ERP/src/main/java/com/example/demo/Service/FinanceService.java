package com.example.demo.Service;

import com.example.demo.mapper.FinanceMapper;
import com.example.demo.Domain.FinanceExpense;
import com.example.demo.Domain.PageRequest;
import com.example.demo.Domain.PageResult;
import com.example.demo.Domain.Payrolls;
import com.example.demo.Domain.Employees;

import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class FinanceService {

    private final FinanceMapper financeMapper;

    public FinanceService(FinanceMapper financeMapper) {
        this.financeMapper = financeMapper;
    }

    // ── Expense ──────────────────────────────────────

    public void registerExpense(FinanceExpense expense) {
        financeMapper.insertExpense(expense);
    }

    /** 기존 전체 목록 (삭제 보류) */
    public List<FinanceExpense> getExpenseList() {
        return financeMapper.selectExpenseList();
    }

    /** 페이징 + 필터 (expenseType / dateFrom / dateTo / keyword) */
    public PageResult<FinanceExpense> getExpenseByPage(PageRequest req) {
        List<FinanceExpense> list = financeMapper.findExpenseByPage(req);
        int total = financeMapper.countExpense(req);
        return new PageResult<>(list, total, req);
    }

    public void updateExpense(FinanceExpense expense) {
        financeMapper.updateExpense(expense);
    }

    public void updateReceiptPath(Long id, String receiptPath) {
        financeMapper.updateReceiptPath(id, receiptPath);
    }

    public void deleteExpense(Long id) {
        financeMapper.deleteExpense(id);
    }

    // ── Payroll ───────────────────────────────────────

    /** 기존 전체 목록 (삭제 보류) */
    public List<Payrolls> getPayrollList() {
        return financeMapper.selectPayrollList();
    }

    /** 페이징 + 필터 (payYear / payMonth / keyword) */
    public PageResult<Payrolls> getPayrollByPage(PageRequest req) {
        List<Payrolls> list = financeMapper.findPayrollByPage(req);
        int total = financeMapper.countPayroll(req);
        return new PageResult<>(list, total, req);
    }

    public void registerPayroll(Payrolls payroll) {
        financeMapper.insertPayroll(payroll);
    }

    public void updatePayroll(Payrolls payroll) {
        financeMapper.updatePayroll(payroll);
    }

    public void deletePayroll(Long id) {
        financeMapper.deletePayroll(id);
    }

    public List<Employees> getActiveEmployeeList() {
        return financeMapper.selectActiveEmployeeList();
    }
}