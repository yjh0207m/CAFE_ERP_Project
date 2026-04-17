package com.example.demo.mapper;

import com.example.demo.Domain.Purchases;
import com.example.demo.Domain.PageRequest;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface PurchasesMapper {
    List<Purchases> findAll();
    List<Purchases> findByPage(PageRequest req);
    int countAll(PageRequest req);
    Purchases findById(long id);
    void insert(Purchases p);
    void update(Purchases p);
    void cancel(long id);
}