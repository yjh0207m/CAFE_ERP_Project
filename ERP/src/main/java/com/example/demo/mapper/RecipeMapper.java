package com.example.demo.mapper;

import com.example.demo.Domain.RecipeDomain;
import com.example.demo.Domain.MenuDomain;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface RecipeMapper {
	MenuDomain getMenuById(Long menuId);
	List<RecipeDomain> getRecipeByMenuId(Long menuId);
    List<RecipeDomain> getRecipeList();
    List<MenuDomain> getMenuList();
    List<RecipeDomain> getIngredientList();
    void insertRecipe(RecipeDomain domain);
    void updateRecipe(RecipeDomain domain);
    void deleteRecipe(Long id);
    int calcMenuCost(Long menuId);
    void updateMenuCost(MenuDomain menu);
}