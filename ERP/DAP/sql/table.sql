CREATE TABLE `attendances` (
	`id` BIGINT(20) NOT NULL AUTO_INCREMENT,
	`employee_id` BIGINT(20) NOT NULL DEFAULT '0' COMMENT '해당 직원 (employees 참조)',
	`work_date` DATE NOT NULL COMMENT '근무 날짜',
	`clock_in` TIME NULL DEFAULT NULL COMMENT '출근 시각',
	`clock_out` TIME NULL DEFAULT NULL COMMENT '퇴근 시각',
	`work_hours` DECIMAL(5,2) AS (timestampdiff(MINUTE,`clock_in`,`clock_out`) / 60.0) stored COMMENT '근무 시간',
	`note` VARCHAR(200) NULL DEFAULT NULL COMMENT '특이사항 (조퇴, 병가, 지각 등)' COLLATE 'utf8mb4_unicode_ci',
	`created_at` DATETIME NOT NULL DEFAULT current_timestamp(),
	PRIMARY KEY (`id`) USING BTREE,
	UNIQUE INDEX `uq_att` (`employee_id`, `work_date`) USING BTREE,
	INDEX `idx_att_emp_date` (`employee_id`, `work_date`) USING BTREE,
	CONSTRAINT `fk_att_employee` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE
)
COMMENT='직원 근태 기록'
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=6502
;
CREATE TABLE `categories` (
	`id` BIGINT(20) NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(50) NOT NULL COMMENT '카테고리명 (음료, 디저트, 원두 등)' COLLATE 'utf8mb4_unicode_ci',
	`created_at` DATETIME NOT NULL DEFAULT current_timestamp(),
	PRIMARY KEY (`id`) USING BTREE
)
COMMENT='메뉴 카테고리'
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=10
;
CREATE TABLE `employees` (
	`id` BIGINT(20) NOT NULL AUTO_INCREMENT,
	`emp_num` VARCHAR(50) NOT NULL COMMENT '사원번호' COLLATE 'utf8mb4_unicode_ci',
	`name` VARCHAR(50) NOT NULL COMMENT '직원 이름' COLLATE 'utf8mb4_unicode_ci',
	`age` INT(11) NULL DEFAULT NULL COMMENT '나이',
	`phone` VARCHAR(20) NULL DEFAULT NULL COMMENT '연락처' COLLATE 'utf8mb4_unicode_ci',
	`position` ENUM('점장','매니저','스탭') NOT NULL DEFAULT '스탭' COMMENT '직책 (바리스타, 매니저 등)' COLLATE 'utf8mb4_unicode_ci',
	`contract_type` ENUM('풀','파트') NOT NULL DEFAULT '파트' COMMENT 'full=정규직 / part=파트타임' COLLATE 'utf8mb4_unicode_ci',
	`hourly_wage` BIGINT(255) NOT NULL DEFAULT '0' COMMENT '시급 (파트타임일 때 사용)',
	`monthly_salary` BIGINT(255) NULL DEFAULT '0' COMMENT '월급 (정규직일 때 사용)',
	`hire_date` DATE NOT NULL COMMENT '입사일',
	`resign_date` DATE NULL DEFAULT NULL COMMENT '퇴사일 (재직 중이면 NULL)',
	`profile` VARCHAR(255) NULL DEFAULT NULL COMMENT '프로필 사진' COLLATE 'utf8mb4_unicode_ci',
	`bank_name` VARCHAR(30) NULL DEFAULT NULL COMMENT '급여 이체 은행명' COLLATE 'utf8mb4_unicode_ci',
	`account_no` VARCHAR(30) NULL DEFAULT NULL COMMENT '급여 이체 계좌번호' COLLATE 'utf8mb4_unicode_ci',
	`is_active` TINYINT(30) NULL DEFAULT '1' COMMENT '재직 여부',
	`created_at` DATETIME NOT NULL DEFAULT current_timestamp(),
	PRIMARY KEY (`id`) USING BTREE,
	UNIQUE INDEX `emp_num` (`emp_num`) USING BTREE
)
COMMENT='직원 마스터'
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=106
;
CREATE TABLE `expenses` (
	`id` BIGINT(20) NOT NULL AUTO_INCREMENT,
	`expense_type` VARCHAR(50) NOT NULL COMMENT '지출 유형 (임대료, 공과금, 소모품, 기타)' COLLATE 'utf8mb4_unicode_ci',
	`amount` BIGINT(20) NOT NULL DEFAULT '0' COMMENT '지출 금액',
	`expense_date` DATE NOT NULL COMMENT '지출 날짜',
	`description` VARCHAR(200) NULL DEFAULT NULL COMMENT '지출 상세 설명' COLLATE 'utf8mb4_unicode_ci',
	`receipt_path` VARCHAR(500) NULL DEFAULT NULL COMMENT '영수증 파일 저장 경로' COLLATE 'utf8mb4_unicode_ci',
	`registered_by` BIGINT(20) NULL DEFAULT NULL COMMENT '지출 등록한 ERP 계정 (users 참조)',
	`status` TINYINT(1) NOT NULL DEFAULT '0' COMMENT '지출 / 수입 : 1 / 0',
	`created_at` DATETIME NOT NULL DEFAULT current_timestamp(),
	PRIMARY KEY (`id`) USING BTREE,
	INDEX `idx_expenses_date` (`expense_date`) USING BTREE,
	INDEX `fk_exp_user` (`registered_by`) USING BTREE,
	CONSTRAINT `fk_exp_user` FOREIGN KEY (`registered_by`) REFERENCES `users` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE
)
COMMENT='지출 비용 내역'
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=214
;
CREATE TABLE `ingredients` (
	`id` BIGINT(20) NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(100) NOT NULL COMMENT '원재료명 (원두, 우유, 바닐라시럽 등)' COLLATE 'utf8mb4_unicode_ci',
	`category` VARCHAR(50) NULL DEFAULT NULL COMMENT '원재료 카테고리' COLLATE 'utf8mb4_unicode_ci',
	`unit` VARCHAR(10) NOT NULL COMMENT '개수 단위 (box, bottle, ea 등)' COLLATE 'utf8mb4_unicode_ci',
	`stock_qty` DECIMAL(10,2) NOT NULL DEFAULT '0.00' COMMENT '현재 재고량',
	`min_stock` DECIMAL(10,2) NOT NULL DEFAULT '0.00' COMMENT '최소 재고 기준량 (이하면 발주 알림)',
	`unit_cost` INT(11) NOT NULL DEFAULT '0' COMMENT '개당 원가',
	`supplier_id` BIGINT(20) NULL DEFAULT NULL COMMENT '거래처 FK (suppliers.id)',
	`created_at` DATETIME NOT NULL DEFAULT current_timestamp(),
	`updated_at` DATETIME NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
	PRIMARY KEY (`id`) USING BTREE,
	INDEX `fk_ing_supplier` (`supplier_id`) USING BTREE,
	CONSTRAINT `fk_ing_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE
)
COMMENT='원재료 마스터'
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=18
;
CREATE TABLE `menus` (
	`id` BIGINT(20) NOT NULL AUTO_INCREMENT,
	`category_id` BIGINT(20) NOT NULL COMMENT '속한 카테고리 (categories 참조)',
	`name` VARCHAR(100) NOT NULL COMMENT '메뉴명 (아메리카노, 카페라떼 등)' COLLATE 'utf8mb4_unicode_ci',
	`description` VARCHAR(500) NULL DEFAULT NULL COMMENT '메뉴 설명' COLLATE 'utf8mb4_unicode_ci',
	`price` INT(11) NOT NULL DEFAULT '0' COMMENT '판매가',
	`cost` INT(11) NOT NULL DEFAULT '0' COMMENT '원가 (recipes 기준으로 자동 계산)',
	`is_available` TINYINT(1) NOT NULL DEFAULT '1' COMMENT '판매 가능 여부 (품절 시 false)',
	`created_at` DATETIME NOT NULL DEFAULT current_timestamp(),
	`updated_at` DATETIME NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
	PRIMARY KEY (`id`) USING BTREE,
	INDEX `fk_menu_category` (`category_id`) USING BTREE,
	CONSTRAINT `fk_menu_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE
)
COMMENT='판매 메뉴'
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=17
;
CREATE TABLE `notices` (
	`id` BIGINT(20) NOT NULL AUTO_INCREMENT,
	`title` VARCHAR(200) NOT NULL COMMENT '공지 제목' COLLATE 'utf8mb4_unicode_ci',
	`content` TEXT NOT NULL COMMENT '공지 내용' COLLATE 'utf8mb4_unicode_ci',
	`importance` ENUM('normal','important','urgent') NOT NULL DEFAULT 'normal' COMMENT '중요도 (normal/important/urgent)' COLLATE 'utf8mb4_unicode_ci',
	`writer` VARCHAR(50) NOT NULL COMMENT '작성자' COLLATE 'utf8mb4_unicode_ci',
	`is_active` TINYINT(1) NOT NULL DEFAULT '1' COMMENT '활성 여부',
	`created_at` DATETIME NOT NULL DEFAULT current_timestamp(),
	`updated_at` DATETIME NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
	PRIMARY KEY (`id`) USING BTREE
)
COMMENT='본사 공지사항'
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=23
;
CREATE TABLE `orders` (
	`id` BIGINT(20) NOT NULL AUTO_INCREMENT,
	`order_no` VARCHAR(30) NOT NULL COMMENT '주문번호 (예: 20240315-0001)' COLLATE 'utf8mb4_unicode_ci',
	`total_amount` INT(11) NOT NULL DEFAULT '0' COMMENT '할인 전 총액',
	`discount_amount` INT(11) NOT NULL DEFAULT '0' COMMENT '할인 금액',
	`final_amount` INT(11) NOT NULL DEFAULT '0' COMMENT '실제 결제 금액 (total - discount)',
	`payment_type` ENUM('카드','현금','카카오페이','네이버페이','토스페이') NOT NULL DEFAULT '카드' COMMENT '결제수단' COLLATE 'utf8mb4_unicode_ci',
	`status` ENUM('대기','완료','취소') NOT NULL DEFAULT '대기' COMMENT 'pending=대기 / done=완료 / cancelled=취소' COLLATE 'utf8mb4_unicode_ci',
	`note` VARCHAR(200) NULL DEFAULT NULL COMMENT '주문 요청사항 (얼음 적게 등)' COLLATE 'utf8mb4_unicode_ci',
	`ordered_at` DATETIME NOT NULL DEFAULT current_timestamp() COMMENT '주문 일시',
	PRIMARY KEY (`id`) USING BTREE,
	UNIQUE INDEX `uq_order_no` (`order_no`) USING BTREE,
	INDEX `idx_orders_date` (`ordered_at`) USING BTREE,
	INDEX `idx_orders_status` (`status`) USING BTREE
)
COMMENT='주문 헤더'
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=93272
;
CREATE TABLE `order_items` (
	`id` BIGINT(20) NOT NULL AUTO_INCREMENT,
	`order_id` BIGINT(20) NOT NULL COMMENT '속한 주문 (orders 참조)',
	`menu_id` BIGINT(20) NOT NULL COMMENT '주문한 메뉴 (menus 참조)',
	`qty` INT(11) NOT NULL DEFAULT '1' COMMENT '주문 수량',
	`unit_price` INT(11) NOT NULL COMMENT '주문 시점의 단가 (메뉴 가격 변경에 대비해 별도 저장)',
	`subtotal` INT(11) NOT NULL COMMENT '소계 (qty × unit_price)',
	PRIMARY KEY (`id`) USING BTREE,
	INDEX `fk_oi_menu` (`menu_id`) USING BTREE,
	INDEX `fk_oi_order` (`order_id`) USING BTREE,
	CONSTRAINT `fk_oi_menu` FOREIGN KEY (`menu_id`) REFERENCES `menus` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE,
	CONSTRAINT `fk_oi_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE
)
COMMENT='주문 상세'
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=93272
;
CREATE TABLE `payrolls` (
	`id` BIGINT(20) NOT NULL AUTO_INCREMENT,
	`employee_id` BIGINT(20) NOT NULL COMMENT '해당 직원 (employees 참조)',
	`pay_year` SMALLINT(6) NOT NULL COMMENT '급여 지급 연도',
	`pay_month` TINYINT(4) NOT NULL COMMENT '급여 지급 월',
	`work_hours` DECIMAL(6,2) NOT NULL DEFAULT '0.00' COMMENT '해당 월 총 근무시간',
	`base_pay` BIGINT(20) NOT NULL DEFAULT '0' COMMENT '기본급',
	`deduction` BIGINT(20) NOT NULL DEFAULT '0' COMMENT '공제액 (4대보험, 세금 등)',
	`net_pay` BIGINT(20) NOT NULL DEFAULT '0' COMMENT '실수령액 (base + overtime + bonus - deduction)',
	`paid_at` DATE NULL DEFAULT NULL COMMENT '실제 지급일',
	`note` VARCHAR(200) NULL DEFAULT NULL COMMENT '급여 관련 메모' COLLATE 'utf8mb4_unicode_ci',
	`created_at` DATETIME NOT NULL DEFAULT current_timestamp(),
	`pay_type` TINYINT(10) NULL DEFAULT NULL COMMENT '0 / 1 : 급여 / 인센티브',
	PRIMARY KEY (`id`) USING BTREE,
	INDEX `employee_id` (`employee_id`) USING BTREE,
	CONSTRAINT `fk_pay_employee` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE
)
COMMENT='급여 지급 내역'
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=330
;
CREATE TABLE `purchases` (
	`id` BIGINT(20) NOT NULL AUTO_INCREMENT,
	`supplier_id` BIGINT(20) NULL DEFAULT NULL COMMENT '거래처 FK (suppliers.id)',
	`total_cost` INT(11) NOT NULL DEFAULT '0' COMMENT '발주 총액 (purchase_items 합산)',
	`status` ENUM('ordered','received','cancelled') NOT NULL DEFAULT 'ordered' COMMENT 'ordered=발주완료 / received=입고완료 / cancelled=취소' COLLATE 'utf8mb4_unicode_ci',
	`ordered_at` DATE NOT NULL COMMENT '발주일',
	`received_at` DATE NULL DEFAULT NULL COMMENT '입고일 (입고 전은 NULL)',
	`note` VARCHAR(200) NULL DEFAULT NULL COMMENT '발주 관련 메모' COLLATE 'utf8mb4_unicode_ci',
	`created_at` DATETIME NOT NULL DEFAULT current_timestamp(),
	PRIMARY KEY (`id`) USING BTREE,
	INDEX `idx_purchases_date` (`ordered_at`) USING BTREE,
	INDEX `idx_purchases_status` (`status`) USING BTREE,
	INDEX `fk_pur_supplier` (`supplier_id`) USING BTREE,
	CONSTRAINT `fk_pur_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE
)
COMMENT='발주 헤더 - 1건의 발주 행위'
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=199
;
CREATE TABLE `purchase_items` (
	`id` BIGINT(20) NOT NULL AUTO_INCREMENT,
	`purchase_id` BIGINT(20) NOT NULL COMMENT '속한 발주 헤더 (purchases 참조)',
	`ingredient_id` BIGINT(20) NULL DEFAULT NULL,
	`qty` DECIMAL(10,2) NOT NULL COMMENT '발주 수량',
	`unit_cost` INT(11) NOT NULL COMMENT '발주 단가',
	`subtotal` INT(11) NOT NULL COMMENT '소계 (qty × unit_cost)',
	`note` VARCHAR(200) NULL DEFAULT NULL COMMENT '해당 품목 메모' COLLATE 'utf8mb4_unicode_ci',
	PRIMARY KEY (`id`) USING BTREE,
	INDEX `idx_pi_purchase` (`purchase_id`) USING BTREE,
	INDEX `idx_pi_ingredient` (`ingredient_id`) USING BTREE,
	CONSTRAINT `fk_pi_ingredient` FOREIGN KEY (`ingredient_id`) REFERENCES `ingredients` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE,
	CONSTRAINT `fk_pi_purchase` FOREIGN KEY (`purchase_id`) REFERENCES `purchases` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE
)
COMMENT='발주 상세 - 발주 1건에 포함된 원재료 목록'
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=755
;
CREATE TABLE `recipes` (
	`id` BIGINT(20) NOT NULL AUTO_INCREMENT,
	`menu_id` BIGINT(20) NOT NULL COMMENT '어떤 메뉴의 레시피인지 (menus 참조)',
	`ingredient_id` BIGINT(20) NOT NULL COMMENT '사용하는 원재료 (ingredients 참조)',
	`quantity` DECIMAL(10,3) NOT NULL COMMENT '메뉴 1개 제조 시 사용하는 원재료 양',
	`recipe` TEXT NOT NULL COLLATE 'utf8mb4_unicode_ci',
	PRIMARY KEY (`id`) USING BTREE,
	UNIQUE INDEX `uq_recipe` (`menu_id`, `ingredient_id`) USING BTREE,
	INDEX `fk_rec_ingredient` (`ingredient_id`) USING BTREE,
	CONSTRAINT `fk_rec_ingredient` FOREIGN KEY (`ingredient_id`) REFERENCES `ingredients` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE,
	CONSTRAINT `fk_rec_menu` FOREIGN KEY (`menu_id`) REFERENCES `menus` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE
)
COMMENT='메뉴별 원재료 사용량 (BOM)'
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=44
;
CREATE TABLE `stock_logs` (
	`id` BIGINT(20) NOT NULL AUTO_INCREMENT,
	`ingredient_id` BIGINT(20) NOT NULL COMMENT '재고 변동이 발생한 원재료 (ingredients 참조)',
	`change_type` ENUM('in','out','adjust') NOT NULL COMMENT 'in=입고 / out=판매차감 / adjust=수동조정' COLLATE 'utf8mb4_unicode_ci',
	`change_qty` DECIMAL(10,2) NOT NULL COMMENT '변동 수량 (항상 양수로 저장)',
	`before_qty` DECIMAL(10,2) NOT NULL COMMENT '변동 전 재고량',
	`after_qty` DECIMAL(10,2) NOT NULL COMMENT '변동 후 재고량',
	`ref_type` ENUM('order','purchase','adjust') NULL DEFAULT NULL COMMENT '참조 테이블 유형' COLLATE 'utf8mb4_unicode_ci',
	`ref_id` BIGINT(20) NULL DEFAULT NULL COMMENT '참조 레코드 ID',
	`note` VARCHAR(200) NULL DEFAULT NULL COMMENT '메모 (수동조정 사유 등)' COLLATE 'utf8mb4_unicode_ci',
	`created_at` DATETIME NOT NULL DEFAULT current_timestamp(),
	PRIMARY KEY (`id`) USING BTREE,
	INDEX `idx_slog_ing_date` (`ingredient_id`, `created_at`) USING BTREE,
	INDEX `idx_slog_ref` (`ref_type`, `ref_id`) USING BTREE,
	CONSTRAINT `fk_slog_ingredient` FOREIGN KEY (`ingredient_id`) REFERENCES `ingredients` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE
)
COMMENT='재고 입출고 이력'
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=3800
;
CREATE TABLE `suppliers` (
	`id` BIGINT(20) NOT NULL AUTO_INCREMENT,
	`supplier_name` VARCHAR(100) NOT NULL COMMENT '공급업체 명' COLLATE 'utf8mb4_unicode_ci',
	`supplier_type` VARCHAR(50) NULL DEFAULT NULL COMMENT '공급업체 유형' COLLATE 'utf8mb4_unicode_ci',
	`ceo_name` VARCHAR(50) NULL DEFAULT NULL COMMENT '대표자 명' COLLATE 'utf8mb4_unicode_ci',
	`address` VARCHAR(200) NULL DEFAULT NULL COMMENT '주소' COLLATE 'utf8mb4_unicode_ci',
	`contract_file` VARCHAR(255) NULL DEFAULT NULL COMMENT '계약서' COLLATE 'utf8mb4_unicode_ci',
	`created_at` DATETIME NULL DEFAULT current_timestamp() COMMENT '생성일',
	`note` TEXT NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci',
	`is_active` TINYINT(1) NOT NULL DEFAULT '1' COMMENT '활성 여부 (0=삭제)',
	PRIMARY KEY (`id`) USING BTREE
)
COMMENT='공급업체'
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=6
;
CREATE TABLE `users` (
	`id` BIGINT(20) NOT NULL AUTO_INCREMENT,
	`user_pw` VARCHAR(255) NOT NULL COMMENT 'BCrypt 암호화 비밀번호' COLLATE 'utf8mb4_unicode_ci',
	`is_active` TINYINT(30) NOT NULL DEFAULT '1' COMMENT '계정 활성화 여부 (퇴사 시 false)',
	`created_at` DATETIME NOT NULL DEFAULT current_timestamp(),
	PRIMARY KEY (`id`) USING BTREE,
	CONSTRAINT `FK_users_employees` FOREIGN KEY (`id`) REFERENCES `employees` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION
)
COMMENT='ERP 로그인 계정'
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=97
;
