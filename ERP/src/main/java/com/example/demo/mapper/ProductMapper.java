package com.example.demo.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.demo.Domain.CategoryDomain;
import com.example.demo.Domain.MenuDomain;

@Mapper
public interface ProductMapper {

	List<MenuDomain> getMenuList();

	MenuDomain getMenuById(Long id);

	List<CategoryDomain> getCategoryList();

	// size랑 offset 위치만 바꿨음
	List<MenuDomain> getMenuList(@Param("size") int size, @Param("offset") int offset);

	int getMenuCount();

	void insertMenu(MenuDomain menu);

	void updateMenu(MenuDomain menu);

	void deleteMenu(Long id);

	void deleteRecipeByMenuId(Long menuId);

	void insertCategory(CategoryDomain category);

	// =========================
	// ✅ 카테고리별 페이징 (추가)
	// =========================
	List<MenuDomain> getMenuListByCategory(@Param("categoryId") Long categoryId, @Param("offset") int offset,
			@Param("size") int size);

	int getMenuCountByCategory(@Param("categoryId") Long categoryId);

	// size랑 offset 위치만 바꿨음
	List<MenuDomain> getMenuListByKeyword(@Param("keyword") String keyword, @Param("size") int size,
			@Param("offset") int offset);

	int getMenuCountByKeyword(@Param("keyword") String keyword);

}