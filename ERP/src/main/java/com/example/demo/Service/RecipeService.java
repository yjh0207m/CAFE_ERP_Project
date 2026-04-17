package com.example.demo.Service;

import com.example.demo.Domain.RecipeDomain;
import com.example.demo.Domain.MenuDomain;
import com.example.demo.mapper.RecipeMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RecipeService {

    @Autowired
    private RecipeMapper recipeMapper;

    public List<RecipeDomain> getRecipeList() { return recipeMapper.getRecipeList(); }

    public List<MenuDomain> getMenuList() { return recipeMapper.getMenuList(); }

    public List<RecipeDomain> getIngredientList() { return recipeMapper.getIngredientList(); }

    public void insertRecipe(RecipeDomain domain) { recipeMapper.insertRecipe(domain); }

    public void updateRecipe(RecipeDomain domain) { recipeMapper.updateRecipe(domain); }

    public void deleteRecipe(Long id) { recipeMapper.deleteRecipe(id); }
    
    public void recalcMenuCost(Long menuId) {
        int cost = recipeMapper.calcMenuCost(menuId);
        MenuDomain menu = new MenuDomain();
        menu.setId(menuId);
        menu.setCost(cost);
        recipeMapper.updateMenuCost(menu);
    }
    
    public MenuDomain getMenuById(Long menuId) { return recipeMapper.getMenuById(menuId); }
    
    public List<RecipeDomain> getRecipeByMenuId(Long menuId) { return recipeMapper.getRecipeByMenuId(menuId); }
}