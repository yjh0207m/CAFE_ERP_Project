package com.example.demo.Domain;

import java.time.LocalDateTime;

public class StockLogs {

	private Long id;
	private Long ingredientId;
	private double changeQty;
	private double beforeQty;
	private double afterQty;
	private String changeType;
	private LocalDateTime createdAt;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getIngredientId() {
		return ingredientId;
	}

	public void setIngredientId(Long ingredientId) {
		this.ingredientId = ingredientId;
	}

	public double getChangeQty() {
		return changeQty;
	}

	public void setChangeQty(double changeQty) {
		this.changeQty = changeQty;
	}

	public double getBeforeQty() {
		return beforeQty;
	}

	public void setBeforeQty(double beforeQty) {
		this.beforeQty = beforeQty;
	}

	public double getAfterQty() {
		return afterQty;
	}

	public void setAfterQty(double afterQty) {
		this.afterQty = afterQty;
	}

	public String getChangeType() {
		return changeType;
	}

	public void setChangeType(String changeType) {
		this.changeType = changeType;
	}

	public LocalDateTime getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(LocalDateTime createdAt) {
		this.createdAt = createdAt;
	}

}