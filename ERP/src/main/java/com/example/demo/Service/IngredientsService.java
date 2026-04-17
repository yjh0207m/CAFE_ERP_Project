package com.example.demo.Service;

import com.example.demo.Domain.Ingredients;
import com.example.demo.Domain.PageRequest;
import com.example.demo.Domain.PageResult;
import com.example.demo.Domain.StockLog;
import com.example.demo.mapper.IngredientsMapper;
import com.example.demo.mapper.StockLogMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
public class IngredientsService {

    private final IngredientsMapper mapper;
    private final StockLogMapper    stockLogMapper;

    public IngredientsService(IngredientsMapper mapper, StockLogMapper stockLogMapper) {
        this.mapper         = mapper;
        this.stockLogMapper = stockLogMapper;
    }

    public List<Ingredients> getAll() {
        return mapper.findAll();
    }

    public PageResult<Ingredients> getByPage(PageRequest req) {
        List<Ingredients> list  = mapper.findByPage(req);
        int               total = mapper.countAll(req);
        return new PageResult<>(list, total, req);
    }

    public Ingredients getById(long id) {
        return mapper.findById(id);
    }

    public List<Ingredients> getBySupplierId(Long supplierId) {
        return mapper.findBySupplierId(supplierId);
    }

    public void register(Ingredients i) {
        mapper.insert(i);
    }

    @Transactional
    public void modify(Ingredients i) {
        // 수정 전 재고량 조회
        Ingredients before = mapper.findById(i.getId());
        mapper.update(i);

        // 재고량이 변경된 경우에만 stock_log 기록
        if (before != null && Double.compare(before.getStock_qty(), i.getStock_qty()) != 0) {
            double changeQty = Math.abs(i.getStock_qty() - before.getStock_qty());
            StockLog log = new StockLog();
            log.setIngredient_id(i.getId());
            log.setChange_type("adjust");
            log.setChange_qty(changeQty);
            log.setBefore_qty(before.getStock_qty());
            log.setAfter_qty(i.getStock_qty());
            log.setRef_type("adjust");
            log.setRef_id(null);
            log.setNote("수동 재고 조정");
            stockLogMapper.insert(log);
        }
    }

    @Transactional
    public void remove(long id) {
        mapper.unlinkFromPurchaseItems(id); // FK 참조 해제
        mapper.delete(id);
    }
}