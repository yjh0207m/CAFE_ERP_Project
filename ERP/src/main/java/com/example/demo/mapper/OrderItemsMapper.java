package com.example.demo.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface OrderItemsMapper {

	// 전체 주문 상세 (Python 분석용)
	List<?> findAll();

}