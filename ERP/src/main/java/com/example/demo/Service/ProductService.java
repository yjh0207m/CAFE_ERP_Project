package com.example.demo.Service;

import com.example.demo.Domain.MenuDomain;
import com.example.demo.Domain.CategoryDomain;
import com.example.demo.mapper.ProductMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProductService {

    @Autowired
    private ProductMapper productMapper;

    // 메뉴 목록 조회
    public List<MenuDomain> getMenuList() {
        return productMapper.getMenuList();
    }
    
    public MenuDomain getMenuById(Long id) { 
    	return productMapper.getMenuById(id); }

    // 카테고리 목록 조회
    public List<CategoryDomain> getCategoryList() {
        return productMapper.getCategoryList();
    }

    // 메뉴 등록
    public void insertMenu(MenuDomain menu) {
        productMapper.insertMenu(menu);
    }
    
    public void updateMenu(MenuDomain menu) { 
    	productMapper.updateMenu(menu); 
    	}
    
    public void deleteMenu(Long id) {
        productMapper.deleteRecipeByMenuId(id); // recipes 먼저 삭제
        productMapper.deleteMenu(id);           // menus 삭제
    }

    // 카테고리 등록
    public void insertCategory(CategoryDomain category) {
        productMapper.insertCategory(category);
    }
    
    
    public List<MenuDomain> getMenuList(int offset, int size) { return productMapper.getMenuList(size, offset); }
    public int getMenuCount() { return productMapper.getMenuCount(); }


//=========================
// ✅ 카테고리별 페이징 (추가)
// =========================
public List<MenuDomain> getMenuListByCategory(Long categoryId, int offset, int size) {
    return productMapper.getMenuListByCategory(categoryId, offset, size);
}

public int getMenuCountByCategory(Long categoryId) {
    return productMapper.getMenuCountByCategory(categoryId);
}
//검색
public List<MenuDomain> getMenuListByKeyword(String keyword, int offset, int size) {
 return productMapper.getMenuListByKeyword(keyword, offset, size);
}

public int getMenuCountByKeyword(String keyword) {
 return productMapper.getMenuCountByKeyword(keyword);
}
}