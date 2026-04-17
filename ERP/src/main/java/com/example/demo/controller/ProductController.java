package com.example.demo.controller;

import com.example.demo.Domain.MenuDomain;
import com.example.demo.Domain.CategoryDomain;
import com.example.demo.Service.ProductService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
public class ProductController {
	
    private final ProductService productService;
    
    ProductController(ProductService productService){
    	this.productService = productService;
    }
    
    // ✅ 제품관리 페이지 (검색 + 카테고리 + 페이징)
    @GetMapping("/product/menu")
    public String product(Model model,
                          @RequestParam(defaultValue = "1") int page,
                          @RequestParam(defaultValue = "10") int size,
                          @RequestParam(required = false) Long categoryId,
                          @RequestParam(required = false) String keyword) {

        int offset = (page - 1) * size;

        int total;
        List<MenuDomain> list;

        // 🔥 1순위: 검색
        if (keyword != null && !keyword.isEmpty()) {
            total = productService.getMenuCountByKeyword(keyword);
            list = productService.getMenuListByKeyword(keyword, offset, size);

        // 🔥 2순위: 카테고리
        } else if (categoryId != null) {
            total = productService.getMenuCountByCategory(categoryId);
            list = productService.getMenuListByCategory(categoryId, offset, size);

        // 🔥 기본: 전체
        } else {
            total = productService.getMenuCount();
            list = productService.getMenuList(offset, size);
        }

        int totalPages = (int) Math.ceil((double) total / size);

        model.addAttribute("menuList", list);
        model.addAttribute("categoryList", productService.getCategoryList());
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("totalCount", total);
        model.addAttribute("selectedCategory", categoryId);
        model.addAttribute("keyword", keyword); // 🔥 검색 유지용
        model.addAttribute("size", size);

        return "Product/product";
    }

    // 제품등록
    @PostMapping("/productInsert")
    public String productInsert(@RequestParam Long category_id,
                                @RequestParam String name,
                                @RequestParam(required = false) String description,
                                @RequestParam int price,
                                @RequestParam(defaultValue = "0") int cost,
                                @RequestParam int isAvailable) {

        MenuDomain menu = new MenuDomain();
        menu.setCategoryId(category_id);
        menu.setName(name);
        menu.setDescription(description);
        menu.setPrice(price);
        menu.setCost(cost);
        menu.setIsAvailable(isAvailable);

        productService.insertMenu(menu);
        return "redirect:/product/menu";
    }
    
    // 제품 수정
    @PostMapping("/productUpdate")
    public String productUpdate(@RequestParam Long id,
                                @RequestParam Long category_id,
                                @RequestParam String name,
                                @RequestParam(required = false) String description,
                                @RequestParam int price,
                                @RequestParam int cost,
                                @RequestParam int isAvailable) {

        MenuDomain menu = new MenuDomain();
        menu.setId(id);
        menu.setCategoryId(category_id);
        menu.setName(name);
        menu.setDescription(description);
        menu.setPrice(price);
        menu.setCost(cost);
        menu.setIsAvailable(isAvailable);

        productService.updateMenu(menu);
        return "redirect:/product/menu";
    }

    // 제품 삭제
    @PostMapping("/productDelete")
    public String productDelete(@RequestParam Long id) {
        productService.deleteMenu(id);
        return "redirect:/product/menu";
    }

    // 카테고리 등록
    @PostMapping("/categoryInsert")
    @ResponseBody
    public String categoryInsert(@RequestParam String name) {
        CategoryDomain category = new CategoryDomain();
        category.setName(name);
        productService.insertCategory(category);
        return "ok";
    }
}