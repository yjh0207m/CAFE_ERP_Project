package com.example.demo.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.example.demo.Domain.StockLogs;

@Mapper
public interface StockLogsMapper {
//	List<Map<String, Object>> findAll();
	List<StockLogs> findAll();
}