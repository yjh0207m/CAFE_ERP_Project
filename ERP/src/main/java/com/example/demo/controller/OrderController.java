package com.example.demo.controller;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.demo.Service.OrderService;
import com.example.demo.Domain.Order;
import com.example.demo.Domain.OrderItem;
import com.example.demo.Domain.OrderPageRequest;
import com.example.demo.Domain.PageResult;

@Controller
public class OrderController {

    private final OrderService orderService;

    OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    // 주문 목록 페이지 - 페이지네이션 + 필터
    @GetMapping("/order")
    public String orderPage(
            @RequestParam(defaultValue = "1")   int    page,
            @RequestParam(defaultValue = "10")  int    size,
            @RequestParam(required = false)     String keyword,
            @RequestParam(required = false)     String status,
            @RequestParam(required = false)     String dateFrom,
            @RequestParam(required = false)     String dateTo,
            Model model) {

        OrderPageRequest req = new OrderPageRequest(page, size);
        req.setKeyword(keyword);
        req.setStatus(status);
        req.setDateFrom(dateFrom);
        req.setDateTo(dateTo);

        PageResult<Order> result = orderService.getByPage(req);

        model.addAttribute("result",   result);
        model.addAttribute("menuList", orderService.getMenuList());
        model.addAttribute("keyword",  keyword);
        model.addAttribute("status",   status);
        model.addAttribute("dateFrom", dateFrom);
        model.addAttribute("dateTo",   dateTo);
        model.addAttribute("size",     size);
        return "Order/OrderDetail";
    }

    // 주문 등록
    @PostMapping("/orderAdd")
    public String addOrder(
            @RequestParam String  orderNo,
            @RequestParam int     totalAmount,
            @RequestParam int     discountAmount,
            @RequestParam int     finalAmount,
            @RequestParam String  paymentType,
            @RequestParam(required = false) String note,
            @RequestParam(value = "menuId",    required = false) List<Long>    menuIds,
            @RequestParam(value = "qty",       required = false) List<Integer> qtys,
            @RequestParam(value = "unitPrice", required = false) List<Integer> unitPrices) {

        Order order = new Order();
        order.setOrderNo(orderNo);
        order.setTotalAmount(totalAmount);
        order.setDiscountAmount(discountAmount);
        order.setFinalAmount(finalAmount);
        order.setPaymentType(paymentType);
        order.setStatus("대기");
        order.setNote(note);

        List<OrderItem> items = new ArrayList<>();
        if (menuIds != null) {
            for (int i = 0; i < menuIds.size(); i++) {
                OrderItem item = new OrderItem();
                item.setMenuId(menuIds.get(i));
                item.setQty(qtys.get(i));
                item.setUnitPrice(unitPrices.get(i));
                item.setSubtotal(qtys.get(i) * unitPrices.get(i));
                items.add(item);
            }
        }
        order.setItems(items);
        orderService.insertOrder(order);
        return "redirect:/order";
    }

    // 상태 변경
    @PostMapping("/orderStatus")
    public String updateStatus(
            @RequestParam Long   id,
            @RequestParam String status,
            @RequestParam(defaultValue = "1") int page) {
        orderService.updateOrderStatus(id, status);
        return "redirect:/order?page=" + page;
    }

    // 주문 상세 아이템 조회 (모달용 JSON)
    @GetMapping("/order/{id}/items")
    @ResponseBody
    public java.util.List<OrderItem> getOrderItems(@PathVariable Long id) {
        return orderService.getOrderItems(id);
    }
}