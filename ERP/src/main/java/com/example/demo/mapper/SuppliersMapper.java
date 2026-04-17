package com.example.demo.mapper;

import com.example.demo.Domain.Ingredients;
import com.example.demo.Domain.PageRequest;
import com.example.demo.Domain.Suppliers;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface SuppliersMapper {
    List<Suppliers>   findAll();
    List<Suppliers>   findByPage(PageRequest req);
    int               countAll(PageRequest req);
    Suppliers         findById(@Param("id") Long id);
    List<Ingredients> findIngredientsBySupplierId(@Param("supplierId") Long supplierId);
    void              insert(Suppliers s);
    void              update(Suppliers s);
    void              delete(@Param("id") Long id);
}