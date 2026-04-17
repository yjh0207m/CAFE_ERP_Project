package com.example.demo.Domain;

import java.time.LocalDateTime;

public class Ingredients {
    private long          id;
    private String        name;
    private String        category;
    private String        unit;
    private double        stock_qty;
    private double        min_stock;
    private int           unit_cost;
    private String        supplier;      // 거래처명 (표시용)
    private Long          supplier_id;   // 거래처 FK
    private LocalDateTime created_at;
    private LocalDateTime updated_at;

    public long          getId()                          { return id; }
    public void          setId(long id)                   { this.id = id; }
    public String        getName()                        { return name; }
    public void          setName(String name)             { this.name = name; }
    public String        getCategory()                    { return category; }
    public void          setCategory(String category)     { this.category = category; }
    public String        getUnit()                        { return unit; }
    public void          setUnit(String unit)             { this.unit = unit; }
    public double        getStock_qty()                   { return stock_qty; }
    public void          setStock_qty(double stock_qty)   { this.stock_qty = stock_qty; }
    public double        getMin_stock()                   { return min_stock; }
    public void          setMin_stock(double min_stock)   { this.min_stock = min_stock; }
    public int           getUnit_cost()                   { return unit_cost; }
    public void          setUnit_cost(int unit_cost)      { this.unit_cost = unit_cost; }
    public String        getSupplier()                    { return supplier; }
    public void          setSupplier(String supplier)     { this.supplier = supplier; }
    public Long          getSupplier_id()                 { return supplier_id; }
    public void          setSupplier_id(Long supplier_id) { this.supplier_id = supplier_id; }
    public LocalDateTime getCreated_at()                  { return created_at; }
    public void          setCreated_at(LocalDateTime v)   { this.created_at = v; }
    public LocalDateTime getUpdated_at()                  { return updated_at; }
    public void          setUpdated_at(LocalDateTime v)   { this.updated_at = v; }
}
