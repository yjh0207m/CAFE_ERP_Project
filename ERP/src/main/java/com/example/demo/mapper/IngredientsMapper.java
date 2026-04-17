package com.example.demo.mapper;

import com.example.demo.Domain.Ingredients;
import com.example.demo.Domain.PageRequest;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface IngredientsMapper {
    List<Ingredients> findAll();
    List<Ingredients> findByPage(PageRequest req);
    int               countAll(PageRequest req);
    Ingredients       findById(long id);
    List<Ingredients> findBySupplierId(@Param("supplierId") Long supplierId);
    void              insert(Ingredients i);
    void              update(Ingredients i);
    void              addStock(@Param("id") long id, @Param("qty") double qty); // 입고 시 재고 증가
    void              unlinkFromPurchaseItems(long id);
    void              delete(long id);
}