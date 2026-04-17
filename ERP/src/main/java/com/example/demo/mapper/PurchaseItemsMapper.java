package com.example.demo.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import com.example.demo.Domain.PurchaseItems;

@Mapper
public interface PurchaseItemsMapper {
	void insert(PurchaseItems item);

	List<Map<String, Object>> findByPurchaseId(long purchaseId);

	List<PurchaseItems> findAll();

	List<Long> findIngredientIdsWithActiveOrder();
}