package com.example.demo.Service;

import com.example.demo.Domain.Ingredients;
import com.example.demo.Domain.PageRequest;
import com.example.demo.Domain.PageResult;
import com.example.demo.Domain.PurchaseItems;
import com.example.demo.Domain.Purchases;
import com.example.demo.Domain.StockLog;
import com.example.demo.mapper.IngredientsMapper;
import com.example.demo.mapper.PurchaseItemsMapper;
import com.example.demo.mapper.PurchasesMapper;
import com.example.demo.mapper.StockLogMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
public class PurchasesService {

    private final PurchasesMapper     purchasesMapper;
    private final PurchaseItemsMapper purchaseItemsMapper;
    private final IngredientsMapper   ingredientsMapper;
    private final StockLogMapper      stockLogMapper;

    public PurchasesService(PurchasesMapper pm, PurchaseItemsMapper pim,
                            IngredientsMapper im, StockLogMapper slm) {
        this.purchasesMapper     = pm;
        this.purchaseItemsMapper = pim;
        this.ingredientsMapper   = im;
        this.stockLogMapper      = slm;
    }

    public List<Purchases> getAll() {
        return purchasesMapper.findAll();
    }

    public PageResult<Purchases> getByPage(PageRequest req) {
        List<Purchases> list  = purchasesMapper.findByPage(req);
        int             total = purchasesMapper.countAll(req);
        return new PageResult<>(list, total, req);
    }

    public Purchases getById(long id) {
        return purchasesMapper.findById(id);
    }

    public List<Map<String, Object>> getItems(long purchaseId) {
        return purchaseItemsMapper.findByPurchaseId(purchaseId);
    }

    @Transactional
    public void register(Purchases p, List<PurchaseItems> items) {
        purchasesMapper.insert(p);
        for (PurchaseItems item : items) {
            item.setPurchase_id(p.getId());
            purchaseItemsMapper.insert(item);
        }
    }

    @Transactional
    public void modify(Purchases p) {
        // 입고완료로 변경되는 경우에만 처리
        if ("received".equals(p.getStatus())) {
            Purchases before = purchasesMapper.findById(p.getId());

            // 이미 입고완료면 중복 처리 방지
            if (before != null && !"received".equals(before.getStatus())) {

                // ── 1. 원재료별 재고 증가 + stock_log 기록 ──
                List<Map<String, Object>> items =
                        purchaseItemsMapper.findByPurchaseId(p.getId());

                for (Map<String, Object> item : items) {
                    if (item.get("ingredient_id") == null) continue;

                    long   ingredientId = Long.parseLong(item.get("ingredient_id").toString());
                    double qty          = Double.parseDouble(item.get("qty").toString());

                    // 변동 전 재고량 조회
                    Ingredients ing = ingredientsMapper.findById(ingredientId);
                    double beforeQty = (ing != null) ? ing.getStock_qty() : 0;
                    double afterQty  = beforeQty + qty;

                    // 재고 증가
                    ingredientsMapper.addStock(ingredientId, qty);

                    // stock_log 기록
                    StockLog log = new StockLog();
                    log.setIngredient_id(ingredientId);
                    log.setChange_type("in");
                    log.setChange_qty(qty);
                    log.setBefore_qty(beforeQty);
                    log.setAfter_qty(afterQty);
                    log.setRef_type("purchase");
                    log.setRef_id(p.getId());
                    log.setNote("발주 #" + p.getId() + " 입고");
                    stockLogMapper.insert(log);
                }


            }
        }

        purchasesMapper.update(p);
    }

    public void cancel(long id) {
        purchasesMapper.cancel(id);
    }
}