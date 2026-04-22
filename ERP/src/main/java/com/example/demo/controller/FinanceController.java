package com.example.demo.controller;

import com.example.demo.Service.FinanceService;
import com.example.demo.Service.UserService;
import com.example.demo.Domain.Employees;
import com.example.demo.Domain.FinanceExpense;
import com.example.demo.Domain.PageRequest;
import com.example.demo.Domain.PageResult;
import com.example.demo.Domain.Payrolls;
// Employee는 Service 내부에서만 사용하므로 Controller에선 import 불필요

import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.io.File;
import java.util.List;
import java.util.UUID;

@Controller
public class FinanceController {

    private final FinanceService financeService;
    private final UserService    userService;

    public FinanceController(FinanceService financeService,
                             UserService userService) {
        this.financeService = financeService;
        this.userService    = userService;
    }


    @PostMapping("/f_register")
    public String registerExpense(
            @RequestParam String    expenseType,
            @RequestParam int       amount,
            @RequestParam String    expenseDate,
            @RequestParam(required = false) String        description,
            @RequestParam(required = false) MultipartFile receiptFile,
            HttpSession        session,
            RedirectAttributes ra) {

        Long userId = (Long) session.getAttribute("loginUserId");

        String receiptPath = null;
        if (receiptFile != null && !receiptFile.isEmpty()) {
            try {
                // src/main/resources/static/ 하위에 저장 → Spring Boot가 자동으로 정적 서빙
                String uploadDir = System.getProperty("user.dir")
                        + "/src/main/webapp/uploads/receipts/";
                File dir = new File(uploadDir);
                if (!dir.exists()) dir.mkdirs();

                String originalName = receiptFile.getOriginalFilename();
                String ext = (originalName != null && originalName.contains("."))
                        ? originalName.substring(originalName.lastIndexOf('.'))
                        : ".jpg";
                String savedName = UUID.randomUUID().toString() + ext;

                receiptFile.transferTo(new File(uploadDir + savedName));
                receiptPath = "/uploads/receipts/" + savedName;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        FinanceExpense expense = new FinanceExpense();
        expense.setExpenseType(expenseType);
        expense.setAmount(amount);
        expense.setExpenseDate(expenseDate);
        expense.setDescription(description);
        expense.setReceiptPath(receiptPath);
        expense.setRegisteredBy(userId);  // users.id = employees.id (FK) → registered_by
        expense.setStatus(1);             // 1 = 지출, 0 = 수입

        financeService.registerExpense(expense);
        ra.addFlashAttribute("msg", "지출이 등록되었습니다.");
        return "redirect:/f_list";
    }

    /* ===== 지출 내역 목록 (페이징) ===== */
    @GetMapping("/f_list")
    public String financeList(
            @RequestParam(defaultValue = "1")  int    page,
            @RequestParam(defaultValue = "10") int    size,
            @RequestParam(required = false)    String expenseType,
            @RequestParam(required = false)    String dateFrom,
            @RequestParam(required = false)    String dateTo,
            @RequestParam(required = false)    String keyword,
            Model model) {

        PageRequest req = new PageRequest(page, size);
        req.setExpenseType(expenseType);
        req.setDateFrom(dateFrom);
        req.setDateTo(dateTo);
        req.setKeyword(keyword);

        model.addAttribute("result",  financeService.getExpenseByPage(req));
        model.addAttribute("size",    size);
        return "Finance/F_list";
    }

    /* ===== 지출 수정 ===== */
    @PostMapping("/f_update")
    public String updateExpense(
            @RequestParam Long   id,
            @RequestParam String expenseType,
            @RequestParam int    amount,
            @RequestParam String expenseDate,
            @RequestParam(required = false) String description) {

        FinanceExpense expense = new FinanceExpense();
        expense.setId(id);
        expense.setExpenseType(expenseType);
        expense.setAmount(amount);
        expense.setExpenseDate(expenseDate);
        expense.setDescription(description);

        financeService.updateExpense(expense);
        return "redirect:/f_list";
    }

    /* ===== 영수증 변경 (AJAX) ===== */
    @PostMapping("/f_receipt_upload")
    @ResponseBody
    public java.util.Map<String, Object> uploadReceipt(
            @RequestParam Long          id,
            @RequestParam MultipartFile receiptFile) {

        java.util.Map<String, Object> result = new java.util.HashMap<>();
        try {
            if (receiptFile == null || receiptFile.isEmpty()) {
                result.put("success", false);
                result.put("message", "파일이 없습니다.");
                return result;
            }

            // user.dir 기준 경로 구성 + 실제 경로 로그 출력 (경로 문제 디버그용)
            String uploadDir = System.getProperty("user.dir")
                    + "/src/main/webapp/uploads/receipts/";
            File dir = new File(uploadDir);
            System.out.println("[영수증 업로드] 저장 경로: " + dir.getAbsolutePath());

            if (!dir.exists()) {
                boolean created = dir.mkdirs();
                System.out.println("[영수증 업로드] 디렉토리 생성: " + created);
            }

            String originalName = receiptFile.getOriginalFilename();
            String ext = (originalName != null && originalName.contains("."))
                    ? originalName.substring(originalName.lastIndexOf('.'))
                    : ".jpg";
            String savedName = UUID.randomUUID().toString() + ext;
            File destFile = new File(dir.getAbsolutePath() + "/" + savedName);

            // 파일 저장 먼저 시도 — 성공해야만 DB 업데이트
            receiptFile.transferTo(destFile);

            if (!destFile.exists()) {
                result.put("success", false);
                result.put("message", "파일 저장에 실패했습니다. 경로를 확인해주세요: " + destFile.getAbsolutePath());
                return result;
            }

            String receiptPath = "/uploads/receipts/" + savedName;
            financeService.updateReceiptPath(id, receiptPath);

            System.out.println("[영수증 업로드] 저장 성공: " + destFile.getAbsolutePath());
            result.put("success", true);
            result.put("path", receiptPath);

        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "오류: " + e.getMessage());
        }
        return result;
    }

    /* ===== 지출 삭제 ===== */
    @PostMapping("/f_delete")
    public String deleteExpense(@RequestParam Long id) {
        financeService.deleteExpense(id);
        return "redirect:/f_list";
    }

    /* ===== 급여 내역 목록 (페이징) ===== */
    @GetMapping("/f_payrolls")
    public String payrollList(
            @RequestParam(defaultValue = "1")  int    page,
            @RequestParam(defaultValue = "10") int    size,
            @RequestParam(required = false)    String payYear,
            @RequestParam(required = false)    String payMonth,
            @RequestParam(required = false)    String keyword,
            Model model) {

        PageRequest req = new PageRequest(page, size);
        req.setPayYear(payYear);
        req.setPayMonth(payMonth);
        req.setKeyword(keyword);
        
        PageResult<Payrolls> result = financeService.getPayrollByPage(req);
        List<Employees> employeeList = financeService.getActiveEmployeeList();
        
        model.addAttribute("result",       result);
        model.addAttribute("size",         size);
        model.addAttribute("employeeList", employeeList);
        return "Finance/F_payrolls";
    }

    /* ===== 관리자 인증 ===== */
    @PostMapping("/payroll/auth")
    @ResponseBody
    public String adminAuth(@RequestParam String userId,
                            @RequestParam String userPw,
                            HttpSession session) {
        String loginEmpNum = (String) session.getAttribute("loginEmpNum");
        if (loginEmpNum == null || !loginEmpNum.equals(userId)) return "fail";
        boolean valid = userService.login(userId, userPw);
        return valid ? "ok" : "fail";
    }

    /* ===== 급여 수정 ===== */
    @PostMapping("/payroll/update")
    public String updatePayroll(@RequestParam Long   id,
                                @RequestParam Long   employeeId,
                                @RequestParam int    payYear,
                                @RequestParam int    payMonth,
                                @RequestParam double workHours,
                                @RequestParam int    basePay,
                                @RequestParam int    deduction,
                                @RequestParam int    netPay,
                                @RequestParam int    payType,
                                @RequestParam(required = false) String paidAt,
                                @RequestParam(required = false) String note,
                                RedirectAttributes ra) {
        Payrolls p = new Payrolls();
        p.setId(id);
        p.setEmployeeId(employeeId);
        p.setPayYear(payYear);
        p.setPayMonth(payMonth);
        p.setWorkHours(workHours);
        p.setBasePay(basePay);
        p.setDeduction(deduction);
        p.setNetPay(netPay);
        p.setPayType(payType);
        p.setPaidAt(paidAt);
        p.setNote(note);
        financeService.updatePayroll(p);
        ra.addFlashAttribute("msg", "수정되었습니다.");
        return "redirect:/f_payrolls";
    }

    /* ===== 급여 삭제 ===== */
    @PostMapping("/payroll/delete")
    public String deletePayroll(@RequestParam Long id, RedirectAttributes ra) {
        financeService.deletePayroll(id);
        ra.addFlashAttribute("msg", "삭제되었습니다.");
        return "redirect:/f_payrolls";
    }

    /* ===== 급여 수동처리 ===== */
    @PostMapping("/payroll/manual")
    public String manualPayroll(@RequestParam Long   employeeId,
                                @RequestParam int    payYear,
                                @RequestParam int    payMonth,
                                @RequestParam double workHours,
                                @RequestParam int    basePay,
                                @RequestParam int    deduction,
                                @RequestParam int    netPay,
                                @RequestParam int    payType,
                                @RequestParam(required = false) String paidAt,
                                @RequestParam(required = false) String note,
                                RedirectAttributes ra) {
        Payrolls p = new Payrolls();
        p.setEmployeeId(employeeId);
        p.setPayYear(payYear);
        p.setPayMonth(payMonth);
        p.setWorkHours(workHours);
        p.setBasePay(basePay);
        p.setDeduction(deduction);
        p.setNetPay(netPay);
        p.setPaidAt(paidAt);
        p.setNote(note);
        p.setPayType(payType);
        financeService.registerPayroll(p);
        ra.addFlashAttribute("msg", "급여가 수동 처리되었습니다.");
        return "redirect:/f_payrolls";
    }
}