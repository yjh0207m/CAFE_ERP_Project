package com.example.demo.controller;

import com.example.demo.Domain.*;
import com.example.demo.Service.IngredientsService;
import com.example.demo.Service.PurchasesService;
import com.example.demo.Service.SuppliersService;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.ServletContext;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Controller
public class IngredientsController {

    private final IngredientsService ingredientsService;
    private final SuppliersService   suppliersService;
    private final PurchasesService   purchasesService;
    private final ServletContext     servletContext;

    public IngredientsController(IngredientsService is, SuppliersService ss,
                                 PurchasesService ps, ServletContext sc) {
        this.ingredientsService = is;
        this.suppliersService   = ss;
        this.purchasesService   = ps;
        this.servletContext     = sc;
    }

    private String getUploadDir() throws IOException {
        String uploadDir = servletContext.getRealPath("/") + "uploads/contracts/";
        Files.createDirectories(Paths.get(uploadDir));
        return uploadDir;
    }

    // URL 인코딩 헬퍼
    private String encode(String value) {
        if (value == null || value.isEmpty()) return null;
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    // ============================================================
    // 재고 현황
    // ============================================================
    @GetMapping("/inventory")
    public String stock(
            @RequestParam(defaultValue = "1")  int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false)    String category,
            @RequestParam(required = false)    String keyword,
            @RequestParam(required = false)    String stockStatus,
            Model model) {

        PageRequest req = new PageRequest(page, size);
        req.setCategory(category);
        req.setKeyword(keyword);
        req.setStockStatus(stockStatus);

        model.addAttribute("result",       ingredientsService.getByPage(req));
        model.addAttribute("supplierList", suppliersService.getAll());
        model.addAttribute("category",     category);
        model.addAttribute("keyword",      keyword);
        model.addAttribute("stockStatus",  stockStatus);
        model.addAttribute("size",         size);
        return "Ingredients/ingredient";
    }

    @PostMapping("/inventory/register")
    public String stockRegister(
            @RequestParam String name,
            @RequestParam String category,
            @RequestParam String unit,
            @RequestParam(defaultValue = "0") double stock_qty,
            @RequestParam(defaultValue = "0") double min_stock,
            @RequestParam(defaultValue = "0") int    unit_cost,
            @RequestParam(required = false)   Long   supplier_id) {

        Ingredients i = new Ingredients();
        i.setName(name);
        i.setCategory(category);
        i.setUnit(unit);
        i.setStock_qty(stock_qty);
        i.setMin_stock(min_stock);
        i.setUnit_cost(unit_cost);
        i.setSupplier_id(supplier_id);
        ingredientsService.register(i);
        return "redirect:/inventory";
    }

    @GetMapping("/inventory/{id}")
    @ResponseBody
    public Ingredients stockGetOne(@PathVariable long id) {
        return ingredientsService.getById(id);
    }

    @PostMapping("/inventory/update")
    public String stockUpdate(
            @RequestParam long   id,
            @RequestParam String name,
            @RequestParam String category,
            @RequestParam String unit,
            @RequestParam double stock_qty,
            @RequestParam double min_stock,
            @RequestParam int    unit_cost,
            @RequestParam(required = false)   Long   supplier_id,
            @RequestParam(defaultValue = "1") int    page,
            @RequestParam(required = false)   String cat,
            @RequestParam(required = false)   String keyword,
            @RequestParam(required = false)   String stockStatus) {

        Ingredients i = new Ingredients();
        i.setId(id);
        i.setName(name);
        i.setCategory(category);
        i.setUnit(unit);
        i.setStock_qty(stock_qty);
        i.setMin_stock(min_stock);
        i.setUnit_cost(unit_cost);
        i.setSupplier_id(supplier_id);
        ingredientsService.modify(i);

        String redirect = "redirect:/inventory?page=" + page;
        String encCat = encode(cat);
        String encKw  = encode(keyword);
        String encSt  = encode(stockStatus);
        if (encCat != null) redirect += "&category="    + encCat;
        if (encKw  != null) redirect += "&keyword="     + encKw;
        if (encSt  != null) redirect += "&stockStatus=" + encSt;
        return redirect;
    }

    @PostMapping("/inventory/delete/{id}")
    public String stockDelete(@PathVariable long id,
                              @RequestParam(defaultValue = "1") int    page,
                              @RequestParam(required = false)   String cat,
                              @RequestParam(required = false)   String keyword,
                              @RequestParam(required = false)   String stockStatus) {
        ingredientsService.remove(id);

        String redirect = "redirect:/inventory?page=" + page;
        String encCat = encode(cat);
        String encKw  = encode(keyword);
        String encSt  = encode(stockStatus);
        if (encCat != null) redirect += "&category="    + encCat;
        if (encKw  != null) redirect += "&keyword="     + encKw;
        if (encSt  != null) redirect += "&stockStatus=" + encSt;
        return redirect;
    }

    // ============================================================
    // 거래처 등록
    // ============================================================

    @PostMapping("/inventory/vendor/register")
    public String supplierRegistPost(
            @RequestParam String supplier_name,
            @RequestParam(required = false) String supplier_type,
            @RequestParam(required = false) String ceo_name,
            @RequestParam(required = false) String address,
            @RequestParam(required = false) String note,
            @RequestParam(value = "contract_file", required = false) MultipartFile file
    ) throws IOException {
        Suppliers s = new Suppliers();
        s.setSupplier_name(supplier_name);
        s.setSupplier_type(supplier_type);
        s.setCeo_name(ceo_name);
        s.setAddress(address);
        s.setNote(note);

        if (file != null && !file.isEmpty()) {
            String filename = System.currentTimeMillis() + "_" + file.getOriginalFilename();
            Files.write(Paths.get(getUploadDir() + filename), file.getBytes());
            s.setContract_file("/uploads/contracts/" + filename);
        }
        suppliersService.register(s);
        return "redirect:/inventory/vendor";
    }

    // ============================================================
    // 거래처 관리
    // ============================================================
    @GetMapping("/inventory/vendor")
    public String supplierList(
            @RequestParam(defaultValue = "1")  int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false)    String category,
            @RequestParam(required = false)    String keyword,
            Model model) {

        PageRequest req = new PageRequest(page, size);
        req.setCategory(category);
        req.setKeyword(keyword);

        model.addAttribute("result",   suppliersService.getByPage(req));
        model.addAttribute("category", category);
        model.addAttribute("keyword",  keyword);
        model.addAttribute("size",     size);
        return "Ingredients/supplierList";
    }

    @GetMapping("/inventory/vendor/{id}/ingredients")
    @ResponseBody
    public List<Ingredients> supplierIngredients(@PathVariable Long id) {
        return suppliersService.getIngredientsBySupplier(id);
    }

    @PostMapping("/inventory/vendor/update")
    public String supplierUpdate(
            @RequestParam Long   id,
            @RequestParam String supplier_name,
            @RequestParam(required = false) String supplier_type,
            @RequestParam(required = false) String ceo_name,
            @RequestParam(required = false) String address,
            @RequestParam(required = false) String note,
            @RequestParam(required = false) String  contract_file,
            @RequestParam(required = false) String  delete_contract,
            @RequestParam(value = "new_contract_file", required = false) MultipartFile newFile
    ) throws IOException {

        Suppliers s = new Suppliers();
        s.setId(id);
        s.setSupplier_name(supplier_name);
        s.setSupplier_type(supplier_type);
        s.setCeo_name(ceo_name);
        s.setAddress(address);
        s.setNote(note);

        if ("true".equals(delete_contract)) {
            s.setContract_file(null);
        } else if (newFile != null && !newFile.isEmpty()) {
            String filename = System.currentTimeMillis() + "_" + newFile.getOriginalFilename();
            Files.write(Paths.get(getUploadDir() + filename), newFile.getBytes());
            s.setContract_file("/uploads/contracts/" + filename);
        } else {
            s.setContract_file(contract_file);
        }

        suppliersService.modify(s);
        return "redirect:/inventory/vendor";
    }

    @PostMapping("/inventory/vendor/delete/{id}")
    public String supplierDelete(@PathVariable long id) {
        // 계약서 파일 먼저 삭제
        Suppliers s = suppliersService.getById(id);
        if (s != null && s.getContract_file() != null && !s.getContract_file().isEmpty()) {
            try {
                String filePath = servletContext.getRealPath("/")
                                + s.getContract_file().replaceFirst("^/", "");
                java.nio.file.Path path = java.nio.file.Paths.get(filePath);
                java.nio.file.Files.deleteIfExists(path);
            } catch (Exception e) {
                // 파일 삭제 실패해도 거래처 삭제는 계속 진행
            }
        }
        suppliersService.remove(id);
        return "redirect:/inventory/vendor";
    }

    // ============================================================
    // 발주 내역
    // ============================================================
    @GetMapping("/inventory/order/history")
    public String purchaseList(
            @RequestParam(defaultValue = "1")  int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false)    String keyword,
            Model model) {

        PageRequest req = new PageRequest(page, size);
        req.setKeyword(keyword);

        model.addAttribute("result",  purchasesService.getByPage(req));
        model.addAttribute("keyword", keyword);
        model.addAttribute("size",    size);
        return "Ingredients/purchaseList";
    }

    @GetMapping("/inventory/order/items/{purchaseId}")
    @ResponseBody
    public List<Map<String, Object>> purchaseItems(@PathVariable long purchaseId) {
        return purchasesService.getItems(purchaseId);
    }

    @PostMapping("/inventory/order/update")
    public String purchaseUpdate(
            @RequestParam long   id,
            @RequestParam String status,
            @RequestParam(required = false) Long   supplier_id,
            @RequestParam(required = false) String received_at,
            @RequestParam(required = false) String note,
            @RequestParam(defaultValue = "1") int page) {

        Purchases p = new Purchases();
        p.setId(id);
        p.setStatus(status);
        p.setSupplier_id(supplier_id);
        p.setNote(note);
        if (received_at != null && !received_at.isEmpty()) {
            p.setReceived_at(java.time.LocalDate.parse(received_at));
        }
        purchasesService.modify(p);
        return "redirect:/inventory/order/history?page=" + page;
    }

    @PostMapping("/inventory/order/cancel/{id}")
    public String purchaseCancel(@PathVariable long id,
                                 @RequestParam(defaultValue = "1") int page) {
        purchasesService.cancel(id);
        return "redirect:/inventory/order/history?page=" + page;
    }

    // ============================================================
    // 발주 등록
    // ============================================================
    @GetMapping("/inventory/order")
    public String purchaseOrder(Model model) {
        model.addAttribute("ingredientList", ingredientsService.getAll());
        model.addAttribute("supplierList",   suppliersService.getAll());
        return "Ingredients/purchaseOrder";
    }

    @PostMapping("/inventory/order")
    public String purchaseOrderPost(
            @RequestParam Long   supplier_id,
            @RequestParam String ordered_at,
            @RequestParam(required = false) String note,
            @RequestParam int    total_cost,
            @RequestParam String itemsJson) throws Exception {

        Purchases p = new Purchases();
        p.setSupplier_id(supplier_id);
        p.setOrdered_at(LocalDate.parse(ordered_at));
        p.setNote(note);
        p.setTotal_cost(total_cost);

        ObjectMapper objectMapper = new ObjectMapper();
        List<Map<String, Object>> rawItems = objectMapper.readValue(itemsJson, List.class);

        List<PurchaseItems> items = new ArrayList<>();
        for (Map<String, Object> raw : rawItems) {
            PurchaseItems item = new PurchaseItems();
            item.setIngredient_id(Long.parseLong(raw.get("id").toString()));
            item.setQty(Double.parseDouble(raw.get("qty").toString()));
            item.setUnit_cost(Integer.parseInt(raw.get("unit_cost").toString()));
            item.setSubtotal((int)(item.getQty() * item.getUnit_cost()));
            items.add(item);
        }

        purchasesService.register(p, items);
        return "redirect:/inventory/order/history";
    }
}