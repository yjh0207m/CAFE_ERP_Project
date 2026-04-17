package com.example.demo.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.Domain.Order;
import com.example.demo.Domain.PurchaseItems;
import com.example.demo.Domain.StockLogs;
import com.example.demo.dto.OrderDTO;
import com.example.demo.dto.StockLogDTO;
import com.example.demo.mapper.FinanceMapper;
import com.example.demo.mapper.HRMMapper;
import com.example.demo.mapper.IngredientsMapper;
import com.example.demo.mapper.OrderItemsMapper;
import com.example.demo.mapper.OrderMapper;
import com.example.demo.mapper.ProductMapper;
import com.example.demo.mapper.PurchaseItemsMapper;
import com.example.demo.mapper.PurchasesMapper;
import com.example.demo.mapper.StockLogsMapper;

@RestController
@RequestMapping("/api")
public class DataApiController {

	private final OrderMapper orderMapper;
	private final OrderItemsMapper orderItemsMapper;
	private final FinanceMapper financeMapper;
	private final HRMMapper hrmMapper;
	private final IngredientsMapper ingredientsMapper;
	private final PurchasesMapper purchasesMapper;
	private final PurchaseItemsMapper purchaseItemsMapper;
	private final ProductMapper productMapper;
	private final StockLogsMapper stockLogsMapper;

	public DataApiController(OrderMapper orderMapper, OrderItemsMapper orderItemsMapper, FinanceMapper financeMapper,
			HRMMapper hrmMapper, IngredientsMapper ingredientsMapper, PurchasesMapper purchasesMapper,
			PurchaseItemsMapper purchaseItemsMapper, ProductMapper productMapper, StockLogsMapper stockLogsMapper) {
		this.orderMapper = orderMapper;
		this.orderItemsMapper = orderItemsMapper;
		this.financeMapper = financeMapper;
		this.hrmMapper = hrmMapper;
		this.ingredientsMapper = ingredientsMapper;
		this.purchasesMapper = purchasesMapper;
		this.purchaseItemsMapper = purchaseItemsMapper;
		this.productMapper = productMapper;
		this.stockLogsMapper = stockLogsMapper;
	}

	// 1. 주문
//	@GetMapping("/orders")
//	public List<?> getOrders() {
//		return orderMapper.selectOrderList();
//	}

	@GetMapping("/orders")
	public List<OrderDTO> getOrders() {

		List<Order> orders = orderMapper.selectOrderList();

		return orders.stream().map(o -> {
			OrderDTO dto = new OrderDTO();
			dto.setId(o.getId());
			dto.setTotalAmount(o.getTotalAmount());
			dto.setFinalAmount(o.getFinalAmount());
			dto.setPaymentType(o.getPaymentType());
			dto.setStatus(o.getStatus());
			dto.setOrderedAt(o.getOrderedAtFormatted());
			return dto;
		}).toList();
	}

	// 2. 주문 상세 (Python용)
	@GetMapping("/order-items/all")
	public List<?> getAllOrderItems() {
		return orderItemsMapper.findAll();
	}

	// 3. 메뉴
//	@GetMapping("/menus")
//	public List<?> getMenus() {
//		return productMapper.getMenuList();
//	}

	@GetMapping("/menus/all")
	public List<?> getMenusAll() {
		return productMapper.getMenuList(10000, 0);
	}

	// 4. 재료
	@GetMapping("/ingredients")
	public List<?> getIngredients() {
		return ingredientsMapper.findAll();
	}

	// 5. 발주
	@GetMapping("/purchases")
	public List<?> getPurchases() {
		return purchasesMapper.findAll();
	}

	// 6. 발주 상세
//	@GetMapping("/purchase-items/{purchaseId}")
//	public List<?> getPurchaseItems(@PathVariable long purchaseId) {
//		return purchaseItemsMapper.findByPurchaseId(purchaseId);
//	}

	@GetMapping("/purchase-items/all")
	public List<?> getAllPurchaseItems() {
		return purchaseItemsMapper.findAll();
	}

	// 7. 지출
	@GetMapping("/expenses")
	public List<?> getExpenses() {
		return financeMapper.selectExpenseList();
	}

	// 8. 급여
	@GetMapping("/payrolls")
	public List<?> getPayrolls() {
		return financeMapper.selectPayrollList();
	}

	// 9. 직원 (급여 직책 분류용: position 필드 포함)
	@GetMapping("/employees")
	public List<?> getEmployees() {
		return hrmMapper.selectAllEmployees();
	}
	
	// 10. 카테고리
	@GetMapping("/categories")
	public List<?> getCategories() {
		return productMapper.getCategoryList();
	}
//	@GetMapping("/stock-logs")
//	public List<?> getStockLogs() {
//		return stockLogsMapper.findAll();
//	}

	@GetMapping("/stock-logs")
	public List<StockLogDTO> getStockLogs() {

		List<StockLogs> logs = stockLogsMapper.findAll();

		return logs.stream().map((StockLogs s) -> {
			StockLogDTO dto = new StockLogDTO();
			dto.setId(s.getId());
			dto.setIngredientId(s.getIngredientId());
			dto.setChangeQty(s.getChangeQty());
			dto.setBeforeQty(s.getBeforeQty());
			dto.setAfterQty(s.getAfterQty());
			dto.setChangeType(s.getChangeType());
			dto.setCreatedAt(s.getCreatedAt().toString());
			return dto;
		}).toList();
	}

}