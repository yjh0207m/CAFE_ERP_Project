package com.example.demo.mapper;

import com.example.demo.Domain.StockLog;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface StockLogMapper {
    void             insert(StockLog log);
    List<StockLog>   findAll();
}
