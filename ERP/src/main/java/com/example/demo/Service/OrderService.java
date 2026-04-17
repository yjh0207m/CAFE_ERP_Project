package com.example.demo.Service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.Domain.Ingredients;
import com.example.demo.Domain.Menu;
import com.example.demo.Domain.Order;
import com.example.demo.Domain.OrderItem;
import com.example.demo.Domain.OrderPageRequest;
import com.example.demo.Domain.PageResult;
import com.example.demo.Domain.RecipeDomain;
import com.example.demo.Domain.StockLog;
import com.example.demo.mapper.IngredientsMapper;
import com.example.demo.mapper.OrderMapper;
import com.example.demo.mapper.RecipeMapper;
import com.example.demo.mapper.StockLogMapper;

@Service
public class OrderService {

    private final OrderMapper       orderMapper;
    private final IngredientsMapper ingredientsMapper;
    private final RecipeMapper      recipeMapper;
    private final StockLogMapper    stockLogMapper;

    OrderService(OrderMapper orderMapper,
                 IngredientsMapper ingredientsMapper,
                 RecipeMapper recipeMapper,
                 StockLogMapper stockLogMapper) {
        this.orderMapper       = orderMapper;
        this.ingredientsMapper = ingredientsMapper;
        this.recipeMapper      = recipeMapper;
        this.stockLogMapper    = stockLogMapper;
    }

    public List<Order> getOrderList() {
        return orderMapper.selectOrderList();
    }

    public PageResult<Order> getByPage(OrderPageRequest req) {
        List<Order> list  = orderMapper.findByPage(req);
        int         total = orderMapper.countAll(req);
        return new PageResult<>(list, total, req);
    }

    public List<Menu> getMenuList() {
        return orderMapper.selectMenuList();
    }

    @Transactional
    public void insertOrder(Order order) {
        orderMapper.insertOrder(order);
        if (order.getItems() != null) {
            for (OrderItem item : order.getItems()) {
                item.setOrderId(order.getId());
                orderMapper.insertOrderItem(item);
            }
        }
    }

    @Transactional
    public void updateOrderStatus(Long id, String status) {
        Order before = orderMapper.findById(id);

        if (before != null) {
            // 완료 처리 시 재고 차감 (중복 방지)
            if ("완료".equals(status) && !"완료".equals(before.getStatus())) {
                deductStockByOrder(id);
            }

            // 취소 처리 시 재고 복구
            // 완료 → 취소 시만 복구 (대기 → 취소는 차감된 재고 없으므로 복구 불필요)
            if ("취소".equals(status) && "완료".equals(before.getStatus())) {
                restoreStockByOrder(id);
            }
        }

        Order order = new Order();
        order.setId(id);
        order.setStatus(status);
        orderMapper.updateOrderStatus(order);
    }

    // 주문 취소 시 재고 복구 + stock_log 기록 (완료 → 취소 시만)
    private void restoreStockByOrder(Long orderId) {
        List<OrderItem> items = orderMapper.findItemsByOrderId(orderId);

        for (OrderItem item : items) {
            List<RecipeDomain> recipes = recipeMapper.getRecipeByMenuId(item.getMenuId());

            for (RecipeDomain recipe : recipes) {
                long   ingredientId = recipe.getIngredientId();
                double restoreQty   = recipe.getQuantity().doubleValue() * item.getQty();

                Ingredients ing = ingredientsMapper.findById(ingredientId);
                if (ing == null) continue;

                double beforeQty = ing.getStock_qty();
                double afterQty  = beforeQty + restoreQty;

                // 재고 복구 (양수로 증가)
                ingredientsMapper.addStock(ingredientId, restoreQty);

                // stock_log 기록
                StockLog log = new StockLog();
                log.setIngredient_id(ingredientId);
                log.setChange_type("adjust");
                log.setChange_qty(restoreQty);
                log.setBefore_qty(beforeQty);
                log.setAfter_qty(afterQty);
                log.setRef_type("order");
                log.setRef_id(orderId);
                log.setNote("주문 #" + orderId + " 취소 - 재고 복구");
                stockLogMapper.insert(log);
            }
        }
    }

    // 주문 완료 시 레시피 기반 재고 차감 + stock_log 기록
    private void deductStockByOrder(Long orderId) {
        List<OrderItem> items = orderMapper.findItemsByOrderId(orderId);

        for (OrderItem item : items) {
            // 해당 메뉴의 레시피 조회
            List<RecipeDomain> recipes = recipeMapper.getRecipeByMenuId(item.getMenuId());

            for (RecipeDomain recipe : recipes) {
                long   ingredientId = recipe.getIngredientId();
                // 레시피 1개당 수량 × 주문 수량
                double deductQty    = recipe.getQuantity().doubleValue() * item.getQty();

                // 차감 전 재고 조회
                Ingredients ing = ingredientsMapper.findById(ingredientId);
                if (ing == null) continue;

                double beforeQty = ing.getStock_qty();
                double afterQty  = Math.max(0, beforeQty - deductQty); // 음수 방지

                // 재고 차감
                ingredientsMapper.addStock(ingredientId, -deductQty);

                // stock_log 기록
                StockLog log = new StockLog();
                log.setIngredient_id(ingredientId);
                log.setChange_type("out");
                log.setChange_qty(deductQty);
                log.setBefore_qty(beforeQty);
                log.setAfter_qty(afterQty);
                log.setRef_type("order");
                log.setRef_id(orderId);
                log.setNote("주문 #" + orderId + " 완료 - " + item.getMenuId() + "번 메뉴");
                stockLogMapper.insert(log);
            }
        }
    }

    // 주문 상세 아이템 조회
    public List<OrderItem> getOrderItems(Long orderId) {
        return orderMapper.findItemsByOrderId(orderId);
    }

    public void deleteOrder(Long id) {
        orderMapper.deleteOrder(id);
    }
}