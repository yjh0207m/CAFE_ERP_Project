package com.example.demo.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.example.demo.Domain.Menu;
import com.example.demo.Domain.Order;
import com.example.demo.Domain.OrderItem;
import com.example.demo.Domain.OrderPageRequest;

@Mapper
public interface OrderMapper {
    List<Order>     selectOrderList();
    List<Order>     findByPage(OrderPageRequest req);
    int             countAll(OrderPageRequest req);
    Order           findById(Long id);                        // 상태 중복 방지용
    List<OrderItem> findItemsByOrderId(Long orderId);         // 재고 차감용
    void            insertOrder(Order order);
    void            insertOrderItem(OrderItem item);
    List<Menu>      selectMenuList();
    void            updateOrderStatus(Order order);
    void            deleteOrder(Long id);
}
