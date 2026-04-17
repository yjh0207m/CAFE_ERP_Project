package com.example.demo.controller;

import com.example.demo.Domain.RecipeDomain;
import com.example.demo.Service.RecipeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

@Controller
public class RecipeController {

    @Autowired
    private RecipeService recipeService;
    
 // 레시피 상세 페이지
    @GetMapping("/product/recipe/{menuId}")
    public String recipeDetail(@PathVariable Long menuId, Model model) {
        model.addAttribute("menu", recipeService.getMenuById(menuId));
        model.addAttribute("recipeList", recipeService.getRecipeByMenuId(menuId));
        model.addAttribute("ingredientList", recipeService.getIngredientList());
        return "Product/Recipedetail";
    }

    // 레시피 관리 페이지
    @GetMapping("/product/recipe")
    public String recipe(Model model) {
        model.addAttribute("recipeList", recipeService.getRecipeList());
        model.addAttribute("menuList", recipeService.getMenuList());
        model.addAttribute("ingredientList", recipeService.getIngredientList());
        return "Product/Recipe";
    }

    // 레시피 등록
    @PostMapping("/recipeInsert")
    public String recipeInsert(@RequestParam Long menuId,
                               @RequestParam Long ingredientId,
                               @RequestParam BigDecimal quantity,
                               @RequestParam(required = false) String recipe) {
        RecipeDomain domain = new RecipeDomain();
        domain.setMenuId(menuId);
        domain.setIngredientId(ingredientId);
        domain.setQuantity(quantity);
        domain.setRecipe(recipe);
        recipeService.insertRecipe(domain);
        recipeService.recalcMenuCost(menuId); // ← 원가 재계산
        return "redirect:/product/recipe/" + menuId;
    }

    // 레시피 수정
    @PostMapping("/recipeUpdate")
    public String recipeUpdate(@RequestParam Long id,
                               @RequestParam Long menuId,
                               @RequestParam Long ingredientId,
                               @RequestParam BigDecimal quantity,
                               @RequestParam(required = false) String recipe) {
        RecipeDomain domain = new RecipeDomain();
        domain.setId(id);
        domain.setMenuId(menuId);
        domain.setIngredientId(ingredientId);
        domain.setQuantity(quantity);
        domain.setRecipe(recipe);
        recipeService.updateRecipe(domain);
        recipeService.recalcMenuCost(menuId); // ← 원가 재계산
        return "redirect:/product/recipe/" + menuId;
    }
    // 레시피 삭제
    @PostMapping("/recipeDelete")
    public String recipeDelete(@RequestParam Long id,
                               @RequestParam Long menuId) {
        recipeService.deleteRecipe(id);
        recipeService.recalcMenuCost(menuId); // ← 원가 재계산
        return "redirect:/product/recipe/" + menuId;
    }
}