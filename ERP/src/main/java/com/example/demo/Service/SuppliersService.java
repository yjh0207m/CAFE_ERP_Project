package com.example.demo.Service;

import com.example.demo.Domain.Ingredients;
import com.example.demo.Domain.PageRequest;
import com.example.demo.Domain.PageResult;
import com.example.demo.Domain.Suppliers;
import com.example.demo.mapper.SuppliersMapper;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class SuppliersService {

    private final SuppliersMapper mapper;

    public SuppliersService(SuppliersMapper mapper) {
        this.mapper = mapper;
    }

    // 전체 목록 (드롭다운용)
    public List<Suppliers> getAll() {
        return mapper.findAll();
    }

    // 페이징 + 유형 필터
    public PageResult<Suppliers> getByPage(PageRequest req) {
        List<Suppliers> list  = mapper.findByPage(req);
        int             total = mapper.countAll(req);
        return new PageResult<>(list, total, req);
    }

    public Suppliers getById(Long id) {
        return mapper.findById(id);
    }

    // 거래처별 담당 원재료
    public List<Ingredients> getIngredientsBySupplier(Long supplierId) {
        return mapper.findIngredientsBySupplierId(supplierId);
    }

    public void register(Suppliers s) {
        mapper.insert(s);
    }

    public void modify(Suppliers s) {
        mapper.update(s);
    }

    public void remove(Long id) {
        mapper.delete(id);
    }
}