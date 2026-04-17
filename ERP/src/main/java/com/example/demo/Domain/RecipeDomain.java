package com.example.demo.Domain;

public class RecipeDomain {
    private Long id;
    private Long menuId;
    private Long ingredientId;
    private java.math.BigDecimal quantity;
    private String recipe;

    // 조인용 필드
    private String menuName;
    private String ingredientName;
    private java.math.BigDecimal currentStock;
    private String stockStatus; // 재고 부족 여부
    private String unit;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getMenuId() { return menuId; }
    public void setMenuId(Long menuId) { this.menuId = menuId; }
    public Long getIngredientId() { return ingredientId; }
    public void setIngredientId(Long ingredientId) { this.ingredientId = ingredientId; }
    public java.math.BigDecimal getQuantity() { return quantity; }
    public void setQuantity(java.math.BigDecimal quantity) { this.quantity = quantity; }
    public String getRecipe() { return recipe; }
    public void setRecipe(String recipe) { this.recipe = recipe; }
    public String getMenuName() { return menuName; }
    public void setMenuName(String menuName) { this.menuName = menuName; }
    public String getIngredientName() { return ingredientName; }
    public void setIngredientName(String ingredientName) { this.ingredientName = ingredientName; }
    public java.math.BigDecimal getCurrentStock() { return currentStock; }
    public void setCurrentStock(java.math.BigDecimal currentStock) { this.currentStock = currentStock; }
    public String getStockStatus() { return stockStatus; }
    public void setStockStatus(String stockStatus) { this.stockStatus = stockStatus; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
}