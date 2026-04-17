package com.example.demo.Domain;
 
public class MenuDomain {
    private Long id;
    private Long categoryId;
    private String categoryName; // JOIN용
    private String name;
    private String description;
    private int price;
    private int cost;
    private int isAvailable;
 
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getCategoryId() { return categoryId; }
    public void setCategoryId(Long categoryId) { this.categoryId = categoryId; }
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public int getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }
    public int getCost() { return cost; }
    public void setCost(int cost) { this.cost = cost; }
    public int getIsAvailable() { return isAvailable; }
    public void setIsAvailable(int isAvailable) { this.isAvailable = isAvailable; }
}