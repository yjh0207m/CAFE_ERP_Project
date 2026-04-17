package com.example.demo.controller;

import com.example.demo.Service.FinanceService;
import com.example.demo.Service.IngredientsService;
import com.example.demo.Service.OrderService;
import com.example.demo.mapper.PurchasesMapper;
import com.example.demo.mapper.StockLogMapper;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;

@Controller
public class RevenueController {

    private final OrderService       orderService;
    private final IngredientsService ingredientsService;
    private final FinanceService     financeService;
    private final PurchasesMapper    purchasesMapper;
    private final StockLogMapper     stockLogMapper;

    // ── FastAPI 결과를 메모리에 보관 ──────────────────
    private static Map<String, Object> latestJournal   = new HashMap<>();
    private static Map<String, Object> latestStatement = new HashMap<>();
    private static Map<String, Object> latestForecast  = new HashMap<>();
    private static Map<String, Object> latestInventory = new HashMap<>();
    private static String              latestAiReport  = "";
    private static String              latestExcelPath = null;

    private static final String EXCEL_DIR =
        System.getProperty("user.dir") + "/src/main/resources/static/uploads/excel/";

    public RevenueController(OrderService orderService,
                             IngredientsService ingredientsService,
                             FinanceService financeService,
                             PurchasesMapper purchasesMapper,
                             StockLogMapper stockLogMapper) {
        this.orderService       = orderService;
        this.ingredientsService = ingredientsService;
        this.financeService     = financeService;
        this.purchasesMapper    = purchasesMapper;
        this.stockLogMapper     = stockLogMapper;
    }

    // ============================================================
    // 페이지 라우팅
    // ============================================================
    @GetMapping("/analysis/stats")
    public String stats(@RequestParam(defaultValue = "journal") String tab, Model model) {
        model.addAttribute("tab", tab);
        return "Analysis/RevenueStats";
    }

    @GetMapping("/analysis/forecast")
    public String forecast() {
        return "Analysis/RevenueForecast";
    }

    @GetMapping("/analysis/inventory")
    public String inventoryForecast() {
        return "Analysis/RevenueInventory";
    }

    // ============================================================
    // ① REST API - Python이 가져갈 원본 데이터
    // ============================================================
    @GetMapping("/api/data/orders")
    @ResponseBody
    public Object getOrders() {
        return orderService.getOrderList();
    }

    @GetMapping("/api/data/expenses")
    @ResponseBody
    public Object getExpenses() {
        return financeService.getExpenseList();
    }

    @GetMapping("/api/data/payrolls")
    @ResponseBody
    public Object getPayrolls() {
        return financeService.getPayrollList();
    }

    @GetMapping("/api/data/purchases")
    @ResponseBody
    public Object getPurchases() {
        return purchasesMapper.findAll();
    }

    @GetMapping("/api/data/ingredients")
    @ResponseBody
    public Object getIngredients() {
        return ingredientsService.getAll();
    }

    @GetMapping("/api/data/stock_logs")
    @ResponseBody
    public Object getStockLogs() {
        return stockLogMapper.findAll();
    }

    @GetMapping("/api/data/menus")
    @ResponseBody
    public Object getMenus() {
        return orderService.getMenuList();
    }

    // ============================================================
    // ② FastAPI → Spring POST 수신 (메모리 보관)
    // ============================================================
    @PostMapping("/analysis/journal")
    @ResponseBody
    public Map<String, Object> receiveJournal(@RequestBody Map<String, Object> body) {
        latestJournal = body;
        Map<String, Object> result = new HashMap<>();
        result.put("status", "ok");
        return result;
    }

    @PostMapping("/analysis/statement")
    @ResponseBody
    public Map<String, Object> receiveStatement(@RequestBody Map<String, Object> body) {
        latestStatement = body;
        Map<String, Object> result = new HashMap<>();
        result.put("status", "ok");
        return result;
    }

    @PostMapping("/analysis/forecast/result")
    @ResponseBody
    public Map<String, Object> receiveForecast(@RequestBody Map<String, Object> body) {
        latestForecast = body;
        Map<String, Object> result = new HashMap<>();
        result.put("status", "ok");
        return result;
    }

    @PostMapping("/analysis/inventory/result")
    @ResponseBody
    public Map<String, Object> receiveInventoryForecast(@RequestBody Map<String, Object> body) {
        latestInventory = body;
        Map<String, Object> result = new HashMap<>();
        result.put("status", "ok");
        return result;
    }

    @PostMapping("/analysis/ai-report/result")
    @ResponseBody
    public Map<String, Object> receiveAiReport(@RequestBody Map<String, Object> body) {
        Object text = body.get("text");
        latestAiReport = text != null ? text.toString() : "";
        Map<String, Object> result = new HashMap<>();
        result.put("status", "ok");
        return result;
    }

    // FastAPI → 엑셀 파일명 등록 (파일은 이미 static 폴더에 저장됨)
    @PostMapping("/analysis/excel/register")
    @ResponseBody
    public Map<String, Object> registerExcel(@RequestBody Map<String, String> body) {
        String filename = body.get("filename");
        latestExcelPath = "/uploads/excel/" + filename;
        Map<String, Object> result = new HashMap<>();
        result.put("status",      "registered");
        result.put("excelPath",   latestExcelPath);
        return result;
    }

    // ============================================================
    // ③ JSP가 조회하는 최신 결과 API
    // ============================================================
    @GetMapping("/api/revenue/journal")
    @ResponseBody
    public Map<String, Object> getLatestJournal() {
        return latestJournal;
    }

    @GetMapping("/api/revenue/statement")
    @ResponseBody
    public Map<String, Object> getLatestStatement() {
        return latestStatement;
    }

    @GetMapping("/api/revenue/forecast")
    @ResponseBody
    public Map<String, Object> getLatestForecast() {
        return latestForecast;
    }

    @GetMapping("/api/revenue/inventory")
    @ResponseBody
    public Map<String, Object> getLatestInventory() {
        return latestInventory;
    }

    @GetMapping("/api/revenue/ai-report")
    @ResponseBody
    public Map<String, Object> getLatestAiReport() {
        Map<String, Object> result = new HashMap<>();
        result.put("text", latestAiReport);
        return result;
    }

    // 엑셀 파일 존재 여부 확인
    @GetMapping("/api/revenue/excel-available")
    @ResponseBody
    public Map<String, Object> excelAvailable() {
        Map<String, Object> result = new HashMap<>();
        if (latestExcelPath == null) {
            result.put("available", false);
            return result;
        }
        File file = new File(EXCEL_DIR + Paths.get(latestExcelPath).getFileName().toString());
        result.put("available", file.exists());
        result.put("filename", Paths.get(latestExcelPath).getFileName().toString());
        return result;
    }

    // 엑셀 다운로드
    @GetMapping("/analysis/excel/download")
    public void downloadExcel(HttpServletResponse response) throws IOException {
        if (latestExcelPath == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "생성된 엑셀 파일이 없습니다.");
            return;
        }
        File file = new File(EXCEL_DIR + Paths.get(latestExcelPath).getFileName().toString());
        if (!file.exists()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "파일이 존재하지 않습니다.");
            return;
        }
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition",
                "attachment; filename=\"" +
                java.net.URLEncoder.encode(file.getName(), "UTF-8") + "\"");
        response.setContentLengthLong(file.length());
        try (FileInputStream fis = new FileInputStream(file);
             OutputStream os = response.getOutputStream()) {
            byte[] buf = new byte[4096];
            int len;
            while ((len = fis.read(buf)) != -1) os.write(buf, 0, len);
        }
    }
}