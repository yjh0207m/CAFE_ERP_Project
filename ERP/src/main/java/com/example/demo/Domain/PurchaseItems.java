package com.example.demo.Domain;

public class PurchaseItems {
    private long   id;
    private long   purchase_id;
    private long   ingredient_id;
    private double qty;
    private int    unit_cost;
    private int    subtotal;
    private String note;
    
    
	public long getId() {
		return id;
	}
	public void setId(long id) {
		this.id = id;
	}
	public long getPurchase_id() {
		return purchase_id;
	}
	public void setPurchase_id(long purchase_id) {
		this.purchase_id = purchase_id;
	}
	public long getIngredient_id() {
		return ingredient_id;
	}
	public void setIngredient_id(long ingredient_id) {
		this.ingredient_id = ingredient_id;
	}
	public double getQty() {
		return qty;
	}
	public void setQty(double qty) {
		this.qty = qty;
	}
	public int getUnit_cost() {
		return unit_cost;
	}
	public void setUnit_cost(int unit_cost) {
		this.unit_cost = unit_cost;
	}
	public int getSubtotal() {
		return subtotal;
	}
	public void setSubtotal(int subtotal) {
		this.subtotal = subtotal;
	}
	public String getNote() {
		return note;
	}
	public void setNote(String note) {
		this.note = note;
	}

 
}