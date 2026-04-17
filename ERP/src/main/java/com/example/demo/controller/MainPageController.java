package com.example.demo.controller;

import com.example.demo.Domain.Ingredients;
import com.example.demo.Service.FinanceService;
import com.example.demo.Service.HRMService;
import com.example.demo.Service.IngredientsService;
import com.example.demo.Service.OrderService;
import com.example.demo.mapper.PurchaseItemsMapper;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Controller
public class MainPageController {

    private final OrderService         orderService;
    private final IngredientsService   ingredientsService;
    private final FinanceService       financeService;
    private final HRMService           hrmService;
    private final PurchaseItemsMapper  purchaseItemsMapper;

    public MainPageController(OrderService orderService,
                              IngredientsService ingredientsService,
                              FinanceService financeService,
                              HRMService hrmService,
                              PurchaseItemsMapper purchaseItemsMapper) {
        this.orderService        = orderService;
        this.ingredientsService  = ingredientsService;
        this.financeService      = financeService;
        this.hrmService          = hrmService;
        this.purchaseItemsMapper = purchaseItemsMapper;
    }

    @GetMapping("/MainPage")
    public String mainPage() {
        return "MainPage";
    }

    // ── 오늘 매출 / 주문건수 ──────────────────────────
    @GetMapping("/api/main/today")
    @ResponseBody
    public Map<String, Object> getTodayStats() {
        String today = LocalDate.now().toString();

        // 완료된 주문 중 오늘 것만
        List<com.example.demo.Domain.Order> allOrders = orderService.getOrderList();
        List<com.example.demo.Domain.Order> todayOrders = allOrders.stream()
                .filter(o -> "완료".equals(o.getStatus())
                        && o.getOrderedAt() != null
                        && o.getOrderedAt().toLocalDate().toString().equals(today))
                .collect(Collectors.toList());

        long todayRevenue = todayOrders.stream()
                .mapToLong(o -> o.getFinalAmount()).sum();
        int  todayCount   = todayOrders.size();

        Map<String, Object> result = new HashMap<>();
        result.put("todayRevenue", todayRevenue);
        result.put("todayCount",   todayCount);
        return result;
    }

    // ── 주간 매출 그래프 데이터 ───────────────────────
    @GetMapping("/api/main/weekly")
    @ResponseBody
    public Map<String, Object> getWeeklyStats() {
        List<com.example.demo.Domain.Order> allOrders = orderService.getOrderList();

        // 최근 7일 날짜 리스트
        String[] days    = new String[7];
        String[] labels  = {"일", "월", "화", "수", "목", "금", "토"};
        long[]   amounts = new long[7];

        LocalDate today = LocalDate.now();
        for (int i = 6; i >= 0; i--) {
            days[6 - i] = today.minusDays(i).toString();
        }

        for (com.example.demo.Domain.Order o : allOrders) {
            if (!"완료".equals(o.getStatus()) || o.getOrderedAt() == null) continue;
            String date = o.getOrderedAt().toLocalDate().toString();
            for (int i = 0; i < 7; i++) {
                if (days[i].equals(date)) {
                    amounts[i] += o.getFinalAmount();
                    break;
                }
            }
        }

        // 요일 라벨 (오늘 기준 7일)
        String[] dayLabels = new String[7];
        for (int i = 0; i < 7; i++) {
            LocalDate d = today.minusDays(6 - i);
            dayLabels[i] = labels[d.getDayOfWeek().getValue() % 7]
                         + " (" + d.getMonthValue() + "/" + d.getDayOfMonth() + ")";
        }

        Map<String, Object> result = new HashMap<>();
        result.put("labels",  dayLabels);
        result.put("amounts", amounts);
        return result;
    }

    // ── 재고 부족 원재료 ──────────────────────────────
    @GetMapping("/api/main/low-stock")
    @ResponseBody
    public List<Map<String, Object>> getLowStock() {
        // 발주 진행 중(ordered)인 원재료는 제외
        Set<Long> orderedIds = new HashSet<>(purchaseItemsMapper.findIngredientIdsWithActiveOrder());

        List<Ingredients> all = ingredientsService.getAll();
        return all.stream()
                .filter(i -> i.getStock_qty() <= i.getMin_stock())
                .filter(i -> !orderedIds.contains(i.getId()))
                .map(i -> {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id",           i.getId());
                    m.put("name",         i.getName());
                    m.put("category",     i.getCategory());
                    m.put("unit",         i.getUnit());
                    m.put("stock_qty",    i.getStock_qty());
                    m.put("min_stock",    i.getMin_stock());
                    m.put("supplier_id",  i.getSupplier_id());
                    m.put("supplier",     i.getSupplier());
                    m.put("unit_cost",    i.getUnit_cost());
                    return m;
                })
                .collect(Collectors.toList());
    }

    // ── 금일 근무자 + 출근 상태 ──────────────────────
    @GetMapping("/api/main/today-employees")
    @ResponseBody
    public List<Map<String, Object>> getTodayEmployees() {
        String today = LocalDate.now().toString();

        // 오늘 근태 데이터 조회 (직원 + 출근 상태 JOIN)
        List<Map<String, Object>> attendanceList =
                hrmService.getAttendanceWithEmployees(today);

        return attendanceList.stream().map(row -> {
            Map<String, Object> m = new HashMap<>();
            m.put("employee_id",    row.get("employee_id"));
            m.put("name",           row.get("name"));
            m.put("position",       row.get("position"));
            m.put("contract_type",  row.get("contract_type"));
            m.put("profile",        row.get("profile"));
            m.put("clock_in",       row.get("clock_in"));
            m.put("clock_out",      row.get("clock_out"));
            m.put("work_hours",     row.get("work_hours"));
            m.put("note",           row.get("note"));

            // 출근 상태 계산
            String status;
            if (row.get("clock_in") == null) {
                status = "absent";   // 미출근
            } else if (row.get("clock_out") == null) {
                status = "working";  // 출근 중
            } else {
                status = "done";     // 퇴근 완료
            }
            m.put("status", status);
            return m;
        }).collect(Collectors.toList());
    }
}