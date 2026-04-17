-- ================================================================
-- 카페 ERP 예시 데이터 (2022-01-01 ~ 2026-03-27)
-- ================================================================
-- 조건1. employees / users 기존 데이터 삭제 없음
-- 조건2. 메뉴 원가 = 레시피 재료 원가 합계 (UPDATE로 자동 계산)
-- 조건3. ingredients.category = 재고 현황 프론트 카테고리만
--        (원두, 유제품, 시럽/소스, 파우더, 차류, 소모품, 기타)
-- ================================================================

SET NAMES utf8mb4;
SET time_zone = '+09:00';
SET FOREIGN_KEY_CHECKS = 0;

-- ================================================================
-- 1. 메뉴 카테고리 (없는 것만 추가)
-- ================================================================
INSERT IGNORE INTO categories (name) VALUES
('커피류'), ('논커피류'), ('디저트'), ('스무디/프라푸치노'),
('티/한방'), ('에이드'), ('베이커리'), ('샌드위치/브런치'), ('기타');

-- ================================================================
-- 2. 공급업체
-- ================================================================
INSERT INTO suppliers (supplier_name, supplier_type, ceo_name, address, is_active) VALUES
('신선원두',   '원두/차류',       '김원두',   '서울시 마포구 원두로 1길 5',   1),
('대한유업',   '유제품',          '이우유',   '경기도 파주시 유업로 10길 3',  1),
('시럽월드',   '시럽/소스/파우더', '박시럽',   '서울시 중구 시럽대로 5',      1),
('소모마트',   '소모품',          '최소모',   '서울시 강남구 소모로 3길 7',   1),
('기타농산',   '기타식재료',      '정농산',   '경기도 광주시 농산로 20길 2',  1);

-- ================================================================
-- 3. 직원 (기존 데이터 삭제 없음, 신규 추가)
-- ================================================================
INSERT INTO employees (emp_num, name, age, phone, position, contract_type, hourly_wage, monthly_salary, hire_date, is_active) VALUES
('E-2022-001', '김지훈', 38, '010-1111-2222', '점장',   '풀',   0,      3800000, '2022-01-03', 1),
('E-2022-002', '이소연', 32, '010-2222-3333', '매니저', '풀',   0,      3200000, '2022-01-03', 1),
('E-2022-003', '박현우', 25, '010-3333-4444', '스탭',   '파트', 10000,  0,       '2022-01-10', 1),
('E-2022-004', '최다혜', 22, '010-4444-5555', '스탭',   '파트', 9500,   0,       '2022-02-01', 1),
('E-2022-005', '정유진', 24, '010-5555-6666', '스탭',   '파트', 9500,   0,       '2022-03-01', 1),
('E-2022-006', '한민준', 26, '010-6666-7777', '스탭',   '파트', 10000,  0,       '2022-04-01', 1);

-- ================================================================
-- 4. 사용자 계정 (점장, 매니저만)
-- ================================================================
-- 비밀번호: password123 (BCrypt)
INSERT INTO users (id, user_pw, is_active)
SELECT id, '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lh32', 1
FROM employees WHERE emp_num IN ('E-2022-001', 'E-2022-002')
ON DUPLICATE KEY UPDATE is_active = VALUES(is_active);

-- ================================================================
-- 5. 원재료
-- ================================================================
INSERT INTO ingredients (name, category, unit, stock_qty, min_stock, unit_cost, supplier_id) VALUES
-- 원두 (unit=kg, unit_cost=원/kg)
('에티오피아 원두', '원두',     'kg',     12.0,  5.0, 45000, (SELECT id FROM suppliers WHERE supplier_name='신선원두' LIMIT 1)),
('콜롬비아 원두',   '원두',     'kg',      8.0,  5.0, 38000, (SELECT id FROM suppliers WHERE supplier_name='신선원두' LIMIT 1)),
-- 유제품 (unit=L, unit_cost=원/L)
('전지우유',       '유제품',    'L',      25.0, 10.0,  2200, (SELECT id FROM suppliers WHERE supplier_name='대한유업' LIMIT 1)),
('오트밀크',       '유제품',    'L',      12.0,  5.0,  4500, (SELECT id FROM suppliers WHERE supplier_name='대한유업' LIMIT 1)),
('생크림',         '유제품',    'L',       6.0,  3.0,  8000, (SELECT id FROM suppliers WHERE supplier_name='대한유업' LIMIT 1)),
-- 시럽/소스 (unit=bottle, unit_cost=원/bottle, 1bottle=750ml)
('바닐라시럽',     '시럽/소스', 'bottle',  4.0,  2.0, 12000, (SELECT id FROM suppliers WHERE supplier_name='시럽월드' LIMIT 1)),
('카라멜소스',     '시럽/소스', 'bottle',  3.0,  2.0, 11000, (SELECT id FROM suppliers WHERE supplier_name='시럽월드' LIMIT 1)),
('초코시럽',       '시럽/소스', 'bottle',  3.0,  2.0, 10000, (SELECT id FROM suppliers WHERE supplier_name='시럽월드' LIMIT 1)),
('딸기시럽',       '시럽/소스', 'bottle',  2.0,  2.0, 13000, (SELECT id FROM suppliers WHERE supplier_name='시럽월드' LIMIT 1)),
-- 파우더 (unit=kg, unit_cost=원/kg)
('코코아파우더',   '파우더',    'kg',      2.5,  1.0, 18000, (SELECT id FROM suppliers WHERE supplier_name='시럽월드' LIMIT 1)),
('말차파우더',     '파우더',    'kg',      1.5,  1.0, 35000, (SELECT id FROM suppliers WHERE supplier_name='시럽월드' LIMIT 1)),
-- 차류 (unit=box, unit_cost=원/box, 1box=50개)
('얼그레이 티백',  '차류',      'box',     6.0,  3.0,  9000, (SELECT id FROM suppliers WHERE supplier_name='신선원두' LIMIT 1)),
('녹차 티백',      '차류',      'box',     5.0,  3.0,  8500, (SELECT id FROM suppliers WHERE supplier_name='신선원두' LIMIT 1)),
-- 소모품 (unit=box)
('종이컵(12oz)',   '소모품',    'box',    10.0,  5.0, 15000, (SELECT id FROM suppliers WHERE supplier_name='소모마트' LIMIT 1)),
('빨대',           '소모품',    'box',     8.0,  3.0,  8000, (SELECT id FROM suppliers WHERE supplier_name='소모마트' LIMIT 1)),
-- 기타
('레몬즙',         '기타',      'bottle',  3.0,  2.0, 12000, (SELECT id FROM suppliers WHERE supplier_name='기타농산' LIMIT 1)),
('딸기퓨레',       '기타',      'kg',      2.0,  1.0, 25000, (SELECT id FROM suppliers WHERE supplier_name='기타농산' LIMIT 1));

-- ================================================================
-- 6. 메뉴 (cost는 레시피 기반으로 UPDATE 예정)
-- ================================================================
INSERT INTO menus (category_id, name, price, cost, is_available) VALUES
-- 커피류
((SELECT id FROM categories WHERE name='커피류'              LIMIT 1), '아메리카노',         4000, 0, 1),
((SELECT id FROM categories WHERE name='커피류'              LIMIT 1), '카페라떼',           4500, 0, 1),
((SELECT id FROM categories WHERE name='커피류'              LIMIT 1), '카라멜마끼아또',     5000, 0, 1),
((SELECT id FROM categories WHERE name='커피류'              LIMIT 1), '바닐라라떼',         5000, 0, 1),
-- 논커피류
((SELECT id FROM categories WHERE name='논커피류'            LIMIT 1), '초코라떼',           4500, 0, 1),
((SELECT id FROM categories WHERE name='논커피류'            LIMIT 1), '말차라떼',           5000, 0, 1),
-- 티/한방
((SELECT id FROM categories WHERE name='티/한방'             LIMIT 1), '얼그레이 밀크티',    4500, 0, 1),
((SELECT id FROM categories WHERE name='티/한방'             LIMIT 1), '녹차라떼',           4500, 0, 1),
-- 에이드
((SELECT id FROM categories WHERE name='에이드'              LIMIT 1), '레몬에이드',         4000, 0, 1),
((SELECT id FROM categories WHERE name='에이드'              LIMIT 1), '딸기에이드',         4500, 0, 1),
-- 스무디/프라푸치노
((SELECT id FROM categories WHERE name='스무디/프라푸치노'   LIMIT 1), '딸기스무디',         5500, 0, 1),
((SELECT id FROM categories WHERE name='스무디/프라푸치노'   LIMIT 1), '바닐라스무디',       5000, 0, 1),
-- 디저트
((SELECT id FROM categories WHERE name='디저트'              LIMIT 1), '초코케이크',         6000, 0, 1),
-- 베이커리
((SELECT id FROM categories WHERE name='베이커리'            LIMIT 1), '버터크루아상',       3500, 0, 1),
-- 샌드위치/브런치
((SELECT id FROM categories WHERE name='샌드위치/브런치'     LIMIT 1), '클럽샌드위치',       8000, 0, 1);

-- ================================================================
-- 7. 레시피 (메뉴별 원재료 사용량 / 서빙 당)
-- ================================================================
-- 아메리카노: 원두 0.018kg, 종이컵 0.01box
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='아메리카노'      LIMIT 1),
    (SELECT id FROM ingredients WHERE name='에티오피아 원두' LIMIT 1),
    0.018, '에티오피아 원두 18g';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='아메리카노'      LIMIT 1),
    (SELECT id FROM ingredients WHERE name='종이컵(12oz)'    LIMIT 1),
    0.010, '종이컵 1개';

-- 카페라떼: 원두 0.018kg, 우유 0.2L, 종이컵 0.01box
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='카페라떼'        LIMIT 1),
    (SELECT id FROM ingredients WHERE name='에티오피아 원두' LIMIT 1),
    0.018, '에티오피아 원두 18g';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='카페라떼'        LIMIT 1),
    (SELECT id FROM ingredients WHERE name='전지우유'        LIMIT 1),
    0.200, '전지우유 200ml';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='카페라떼'        LIMIT 1),
    (SELECT id FROM ingredients WHERE name='종이컵(12oz)'    LIMIT 1),
    0.010, '종이컵 1개';

-- 카라멜마끼아또: 원두 0.018kg, 우유 0.2L, 카라멜소스 0.02bottle, 종이컵
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='카라멜마끼아또'  LIMIT 1),
    (SELECT id FROM ingredients WHERE name='콜롬비아 원두'   LIMIT 1),
    0.018, '콜롬비아 원두 18g';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='카라멜마끼아또'  LIMIT 1),
    (SELECT id FROM ingredients WHERE name='전지우유'        LIMIT 1),
    0.200, '전지우유 200ml';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='카라멜마끼아또'  LIMIT 1),
    (SELECT id FROM ingredients WHERE name='카라멜소스'      LIMIT 1),
    0.020, '카라멜소스 15ml';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='카라멜마끼아또'  LIMIT 1),
    (SELECT id FROM ingredients WHERE name='종이컵(12oz)'    LIMIT 1),
    0.010, '종이컵 1개';

-- 바닐라라떼: 원두, 우유 0.18L, 바닐라시럽 0.02bottle, 종이컵
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='바닐라라떼'      LIMIT 1),
    (SELECT id FROM ingredients WHERE name='에티오피아 원두' LIMIT 1),
    0.018, '에티오피아 원두 18g';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='바닐라라떼'      LIMIT 1),
    (SELECT id FROM ingredients WHERE name='전지우유'        LIMIT 1),
    0.180, '전지우유 180ml';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='바닐라라떼'      LIMIT 1),
    (SELECT id FROM ingredients WHERE name='바닐라시럽'      LIMIT 1),
    0.020, '바닐라시럽 15ml';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='바닐라라떼'      LIMIT 1),
    (SELECT id FROM ingredients WHERE name='종이컵(12oz)'    LIMIT 1),
    0.010, '종이컵 1개';

-- 초코라떼: 우유 0.25L, 초코시럽 0.03bottle, 코코아파우더 0.01kg, 종이컵
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='초코라떼'        LIMIT 1),
    (SELECT id FROM ingredients WHERE name='전지우유'        LIMIT 1),
    0.250, '전지우유 250ml';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='초코라떼'        LIMIT 1),
    (SELECT id FROM ingredients WHERE name='초코시럽'        LIMIT 1),
    0.030, '초코시럽 22ml';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='초코라떼'        LIMIT 1),
    (SELECT id FROM ingredients WHERE name='코코아파우더'    LIMIT 1),
    0.010, '코코아파우더 10g';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='초코라떼'        LIMIT 1),
    (SELECT id FROM ingredients WHERE name='종이컵(12oz)'    LIMIT 1),
    0.010, '종이컵 1개';

-- 말차라떼: 오트밀크 0.25L, 말차파우더 0.01kg, 종이컵
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='말차라떼'        LIMIT 1),
    (SELECT id FROM ingredients WHERE name='오트밀크'        LIMIT 1),
    0.250, '오트밀크 250ml';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='말차라떼'        LIMIT 1),
    (SELECT id FROM ingredients WHERE name='말차파우더'      LIMIT 1),
    0.010, '말차파우더 10g';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='말차라떼'        LIMIT 1),
    (SELECT id FROM ingredients WHERE name='종이컵(12oz)'    LIMIT 1),
    0.010, '종이컵 1개';

-- 얼그레이 밀크티: 얼그레이 0.02box, 우유 0.2L, 종이컵
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='얼그레이 밀크티' LIMIT 1),
    (SELECT id FROM ingredients WHERE name='얼그레이 티백'   LIMIT 1),
    0.020, '얼그레이 티백 1개';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='얼그레이 밀크티' LIMIT 1),
    (SELECT id FROM ingredients WHERE name='전지우유'        LIMIT 1),
    0.200, '전지우유 200ml';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='얼그레이 밀크티' LIMIT 1),
    (SELECT id FROM ingredients WHERE name='종이컵(12oz)'    LIMIT 1),
    0.010, '종이컵 1개';

-- 녹차라떼: 녹차 0.02box, 오트밀크 0.2L, 종이컵
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='녹차라떼'        LIMIT 1),
    (SELECT id FROM ingredients WHERE name='녹차 티백'       LIMIT 1),
    0.020, '녹차 티백 1개';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='녹차라떼'        LIMIT 1),
    (SELECT id FROM ingredients WHERE name='오트밀크'        LIMIT 1),
    0.200, '오트밀크 200ml';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='녹차라떼'        LIMIT 1),
    (SELECT id FROM ingredients WHERE name='종이컵(12oz)'    LIMIT 1),
    0.010, '종이컵 1개';

-- 레몬에이드: 레몬즙 0.05bottle, 종이컵
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='레몬에이드'      LIMIT 1),
    (SELECT id FROM ingredients WHERE name='레몬즙'          LIMIT 1),
    0.050, '레몬즙 37ml';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='레몬에이드'      LIMIT 1),
    (SELECT id FROM ingredients WHERE name='종이컵(12oz)'    LIMIT 1),
    0.010, '종이컵 1개';

-- 딸기에이드: 딸기퓨레 0.05kg, 딸기시럽 0.02bottle, 종이컵
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='딸기에이드'      LIMIT 1),
    (SELECT id FROM ingredients WHERE name='딸기퓨레'        LIMIT 1),
    0.050, '딸기퓨레 50g';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='딸기에이드'      LIMIT 1),
    (SELECT id FROM ingredients WHERE name='딸기시럽'        LIMIT 1),
    0.020, '딸기시럽 15ml';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='딸기에이드'      LIMIT 1),
    (SELECT id FROM ingredients WHERE name='종이컵(12oz)'    LIMIT 1),
    0.010, '종이컵 1개';

-- 딸기스무디: 딸기퓨레 0.08kg, 생크림 0.05L, 종이컵
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='딸기스무디'      LIMIT 1),
    (SELECT id FROM ingredients WHERE name='딸기퓨레'        LIMIT 1),
    0.080, '딸기퓨레 80g';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='딸기스무디'      LIMIT 1),
    (SELECT id FROM ingredients WHERE name='생크림'          LIMIT 1),
    0.050, '생크림 50ml';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='딸기스무디'      LIMIT 1),
    (SELECT id FROM ingredients WHERE name='종이컵(12oz)'    LIMIT 1),
    0.010, '종이컵 1개';

-- 바닐라스무디: 오트밀크 0.2L, 바닐라시럽 0.03bottle, 생크림 0.05L, 종이컵
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='바닐라스무디'    LIMIT 1),
    (SELECT id FROM ingredients WHERE name='오트밀크'        LIMIT 1),
    0.200, '오트밀크 200ml';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='바닐라스무디'    LIMIT 1),
    (SELECT id FROM ingredients WHERE name='바닐라시럽'      LIMIT 1),
    0.030, '바닐라시럽 22ml';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='바닐라스무디'    LIMIT 1),
    (SELECT id FROM ingredients WHERE name='생크림'          LIMIT 1),
    0.050, '생크림 50ml';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='바닐라스무디'    LIMIT 1),
    (SELECT id FROM ingredients WHERE name='종이컵(12oz)'    LIMIT 1),
    0.010, '종이컵 1개';

-- 초코케이크: 코코아파우더 0.02kg, 생크림 0.1L
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='초코케이크'      LIMIT 1),
    (SELECT id FROM ingredients WHERE name='코코아파우더'    LIMIT 1),
    0.020, '코코아파우더 20g';
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='초코케이크'      LIMIT 1),
    (SELECT id FROM ingredients WHERE name='생크림'          LIMIT 1),
    0.100, '생크림 100ml';

-- 버터크루아상: 생크림 0.05L
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='버터크루아상'    LIMIT 1),
    (SELECT id FROM ingredients WHERE name='생크림'          LIMIT 1),
    0.050, '생크림 50ml (버터 대용)';

-- 클럽샌드위치: 없는 재료 비중이 높아 소모품 컵만
INSERT INTO recipes (menu_id, ingredient_id, quantity, recipe) SELECT
    (SELECT id FROM menus WHERE name='클럽샌드위치'    LIMIT 1),
    (SELECT id FROM ingredients WHERE name='종이컵(12oz)'    LIMIT 1),
    0.010, '포장용 컵 1개';

-- ================================================================
-- 8. 메뉴 원가 자동 계산 (레시피 기준)
-- ================================================================
UPDATE menus m
SET m.cost = (
    SELECT COALESCE(ROUND(SUM(r.quantity * i.unit_cost)), 0)
    FROM recipes r
    JOIN ingredients i ON r.ingredient_id = i.id
    WHERE r.menu_id = m.id
);

-- ================================================================
-- 9. 출근 기록 (2022-01 ~ 2026-03, 평일 기준)
-- ================================================================
-- 점장 김지훈: 09:00 - 18:00 (월~금)
-- 매니저 이소연: 09:00 - 18:00 (월~금)
-- 스탭 박현우: 10:00 - 18:00 (월, 수, 금, 토, 일 / 주 5일)
-- 스탭 최다혜: 2022-02부터
-- 스탭 정유진: 2022-03부터
-- 스탭 한민준: 2022-04부터

-- 주요 월 별 batch insert (월~금 대표 날짜들)
-- 실제 운영에서는 매일 자동 생성되므로 월별 대표 샘플 제공

DELIMITER $$
CREATE PROCEDURE gen_attendance()
BEGIN
  DECLARE v_date DATE DEFAULT '2022-01-03';  -- 2022-01-03 = 월요일
  DECLARE v_end  DATE DEFAULT '2026-03-27';
  DECLARE v_dow  INT;   -- 1=일,2=월,...7=토
  DECLARE v_emp1 BIGINT;
  DECLARE v_emp2 BIGINT;
  DECLARE v_emp3 BIGINT;
  DECLARE v_emp4 BIGINT;
  DECLARE v_emp5 BIGINT;
  DECLARE v_emp6 BIGINT;

  SET v_emp1 = (SELECT id FROM employees WHERE emp_num='E-2022-001' LIMIT 1);
  SET v_emp2 = (SELECT id FROM employees WHERE emp_num='E-2022-002' LIMIT 1);
  SET v_emp3 = (SELECT id FROM employees WHERE emp_num='E-2022-003' LIMIT 1);
  SET v_emp4 = (SELECT id FROM employees WHERE emp_num='E-2022-004' LIMIT 1);
  SET v_emp5 = (SELECT id FROM employees WHERE emp_num='E-2022-005' LIMIT 1);
  SET v_emp6 = (SELECT id FROM employees WHERE emp_num='E-2022-006' LIMIT 1);

  WHILE v_date <= v_end DO
    SET v_dow = DAYOFWEEK(v_date);  -- 1=일, 2=월 ... 7=토

    -- 점장/매니저: 월~금 (dow 2~6)
    IF v_dow BETWEEN 2 AND 6 THEN
      INSERT IGNORE INTO attendances (employee_id, work_date, clock_in, clock_out)
        VALUES (v_emp1, v_date, '09:00:00', '18:00:00');
      INSERT IGNORE INTO attendances (employee_id, work_date, clock_in, clock_out)
        VALUES (v_emp2, v_date, '09:00:00', '18:00:00');
    END IF;

    -- 스탭3 (박현우): 월~토 중 5일 근무 (월,화,수,금,토 = dow 2,3,4,6,7)
    IF v_dow IN (2,3,4,6,7) THEN
      INSERT IGNORE INTO attendances (employee_id, work_date, clock_in, clock_out)
        VALUES (v_emp3, v_date, '10:00:00', '18:00:00');
    END IF;

    -- 스탭4 (최다혜): 2022-02-01부터 (화,수,목,토,일 = dow 3,4,5,7,1)
    IF v_date >= '2022-02-01' AND v_dow IN (3,4,5,7,1) THEN
      INSERT IGNORE INTO attendances (employee_id, work_date, clock_in, clock_out)
        VALUES (v_emp4, v_date, '11:00:00', '19:00:00');
    END IF;

    -- 스탭5 (정유진): 2022-03-01부터 (월,수,금,토,일 = dow 2,4,6,7,1)
    IF v_date >= '2022-03-01' AND v_dow IN (2,4,6,7,1) THEN
      INSERT IGNORE INTO attendances (employee_id, work_date, clock_in, clock_out)
        VALUES (v_emp5, v_date, '12:00:00', '20:00:00');
    END IF;

    -- 스탭6 (한민준): 2022-04-01부터 (월,화,목,금,토 = dow 2,3,5,6,7)
    IF v_date >= '2022-04-01' AND v_dow IN (2,3,5,6,7) THEN
      INSERT IGNORE INTO attendances (employee_id, work_date, clock_in, clock_out)
        VALUES (v_emp6, v_date, '10:00:00', '18:00:00');
    END IF;

    SET v_date = DATE_ADD(v_date, INTERVAL 1 DAY);
  END WHILE;
END $$
DELIMITER ;
CALL gen_attendance();
DROP PROCEDURE gen_attendance;

-- ================================================================
-- 10. 급여 (payrolls) - 2022-01 ~ 2026-02 완납, 2026-03 미처리
--    pay_type: 0=급여, 1=인센티브
--    스탭: work_hours = 해당 월 출근일 × 8h
-- ================================================================
DELIMITER $$
CREATE PROCEDURE gen_payrolls()
BEGIN
  DECLARE v_year  INT DEFAULT 2022;
  DECLARE v_month INT DEFAULT 1;
  DECLARE v_emp1 BIGINT;
  DECLARE v_emp2 BIGINT;
  DECLARE v_emp3 BIGINT;
  DECLARE v_emp4 BIGINT;
  DECLARE v_emp5 BIGINT;
  DECLARE v_emp6 BIGINT;
  DECLARE v_hours3 DECIMAL(6,2);
  DECLARE v_hours4 DECIMAL(6,2);
  DECLARE v_hours5 DECIMAL(6,2);
  DECLARE v_hours6 DECIMAL(6,2);
  DECLARE v_last_day DATE;

  SET v_emp1 = (SELECT id FROM employees WHERE emp_num='E-2022-001' LIMIT 1);
  SET v_emp2 = (SELECT id FROM employees WHERE emp_num='E-2022-002' LIMIT 1);
  SET v_emp3 = (SELECT id FROM employees WHERE emp_num='E-2022-003' LIMIT 1);
  SET v_emp4 = (SELECT id FROM employees WHERE emp_num='E-2022-004' LIMIT 1);
  SET v_emp5 = (SELECT id FROM employees WHERE emp_num='E-2022-005' LIMIT 1);
  SET v_emp6 = (SELECT id FROM employees WHERE emp_num='E-2022-006' LIMIT 1);

  WHILE (v_year < 2026) OR (v_year = 2026 AND v_month <= 2) DO
    SET v_last_day = LAST_DAY(CONCAT(v_year, '-', LPAD(v_month,2,'0'), '-01'));

    -- 출근 기록 기반 스탭 근무시간 계산 (clock_out 있는 행만)
    SELECT COALESCE(SUM(work_hours), 0) INTO v_hours3
    FROM attendances
    WHERE employee_id = v_emp3
      AND YEAR(work_date) = v_year AND MONTH(work_date) = v_month
      AND clock_out IS NOT NULL;

    SELECT COALESCE(SUM(work_hours), 0) INTO v_hours4
    FROM attendances
    WHERE employee_id = v_emp4
      AND YEAR(work_date) = v_year AND MONTH(work_date) = v_month
      AND clock_out IS NOT NULL;

    SELECT COALESCE(SUM(work_hours), 0) INTO v_hours5
    FROM attendances
    WHERE employee_id = v_emp5
      AND YEAR(work_date) = v_year AND MONTH(work_date) = v_month
      AND clock_out IS NOT NULL;

    SELECT COALESCE(SUM(work_hours), 0) INTO v_hours6
    FROM attendances
    WHERE employee_id = v_emp6
      AND YEAR(work_date) = v_year AND MONTH(work_date) = v_month
      AND clock_out IS NOT NULL;

    -- 점장 (월급제, 공제 10%)
    INSERT INTO payrolls (employee_id, pay_year, pay_month, work_hours, base_pay, deduction, net_pay, paid_at, pay_type)
    VALUES (v_emp1, v_year, v_month, 176, 3800000, 380000, 3420000,
            DATE_ADD(v_last_day, INTERVAL 10 DAY), 0);

    -- 매니저 (월급제, 공제 10%)
    INSERT INTO payrolls (employee_id, pay_year, pay_month, work_hours, base_pay, deduction, net_pay, paid_at, pay_type)
    VALUES (v_emp2, v_year, v_month, 176, 3200000, 320000, 2880000,
            DATE_ADD(v_last_day, INTERVAL 10 DAY), 0);

    -- 스탭3 (시급 10,000)
    IF v_hours3 > 0 THEN
      INSERT INTO payrolls (employee_id, pay_year, pay_month, work_hours, base_pay, deduction, net_pay, paid_at, pay_type)
      VALUES (v_emp3, v_year, v_month, v_hours3,
              ROUND(v_hours3 * 10000), ROUND(v_hours3 * 10000 * 0.09),
              ROUND(v_hours3 * 10000 * 0.91),
              DATE_ADD(v_last_day, INTERVAL 10 DAY), 0);
    END IF;

    -- 스탭4 (시급 9,500, 2022-02부터)
    IF v_hours4 > 0 AND (v_year > 2022 OR v_month >= 2) THEN
      INSERT INTO payrolls (employee_id, pay_year, pay_month, work_hours, base_pay, deduction, net_pay, paid_at, pay_type)
      VALUES (v_emp4, v_year, v_month, v_hours4,
              ROUND(v_hours4 * 9500), ROUND(v_hours4 * 9500 * 0.09),
              ROUND(v_hours4 * 9500 * 0.91),
              DATE_ADD(v_last_day, INTERVAL 10 DAY), 0);
    END IF;

    -- 스탭5 (시급 9,500, 2022-03부터)
    IF v_hours5 > 0 AND (v_year > 2022 OR v_month >= 3) THEN
      INSERT INTO payrolls (employee_id, pay_year, pay_month, work_hours, base_pay, deduction, net_pay, paid_at, pay_type)
      VALUES (v_emp5, v_year, v_month, v_hours5,
              ROUND(v_hours5 * 9500), ROUND(v_hours5 * 9500 * 0.09),
              ROUND(v_hours5 * 9500 * 0.91),
              DATE_ADD(v_last_day, INTERVAL 10 DAY), 0);
    END IF;

    -- 스탭6 (시급 10,000, 2022-04부터)
    IF v_hours6 > 0 AND (v_year > 2022 OR v_month >= 4) THEN
      INSERT INTO payrolls (employee_id, pay_year, pay_month, work_hours, base_pay, deduction, net_pay, paid_at, pay_type)
      VALUES (v_emp6, v_year, v_month, v_hours6,
              ROUND(v_hours6 * 10000), ROUND(v_hours6 * 10000 * 0.09),
              ROUND(v_hours6 * 10000 * 0.91),
              DATE_ADD(v_last_day, INTERVAL 10 DAY), 0);
    END IF;

    -- 분기 인센티브 (3,6,9,12월 - 점장/매니저, pay_type=1)
    IF v_month IN (3, 6, 9, 12) THEN
      INSERT INTO payrolls (employee_id, pay_year, pay_month, work_hours, base_pay, deduction, net_pay, paid_at, pay_type)
      VALUES (v_emp1, v_year, v_month, 0, 500000, 0, 500000, DATE_ADD(v_last_day, INTERVAL 10 DAY), 1);
      INSERT INTO payrolls (employee_id, pay_year, pay_month, work_hours, base_pay, deduction, net_pay, paid_at, pay_type)
      VALUES (v_emp2, v_year, v_month, 0, 300000, 0, 300000, DATE_ADD(v_last_day, INTERVAL 10 DAY), 1);
    END IF;

    -- 다음 달 계산
    IF v_month = 12 THEN
      SET v_year  = v_year + 1;
      SET v_month = 1;
    ELSE
      SET v_month = v_month + 1;
    END IF;
  END WHILE;
END $$
DELIMITER ;
CALL gen_payrolls();
DROP PROCEDURE gen_payrolls;

-- ================================================================
-- 11. 지출 내역 (expenses) - status 항상 1
-- ================================================================
DELIMITER $$
CREATE PROCEDURE gen_expenses()
BEGIN
  DECLARE v_year  INT DEFAULT 2022;
  DECLARE v_month INT DEFAULT 1;
  DECLARE v_date  VARCHAR(10);
  DECLARE v_emp1  BIGINT;

  SET v_emp1 = (SELECT id FROM employees WHERE emp_num='E-2022-001' LIMIT 1);

  WHILE (v_year < 2026) OR (v_year = 2026 AND v_month <= 3) DO
    SET v_date = CONCAT(v_year, '-', LPAD(v_month,2,'0'), '-05');

    -- 임대료 (매월 5일)
    INSERT INTO expenses (expense_type, amount, expense_date, description, registered_by, status)
    VALUES ('임대료', 2500000, v_date, CONCAT(v_year,'년 ',v_month,'월 임대료'), v_emp1, 1);

    -- 공과금 (매월 10일)
    INSERT INTO expenses (expense_type, amount, expense_date, description, registered_by, status)
    VALUES ('공과금', ROUND(180000 + (RAND() * 60000)),
            CONCAT(v_year,'-',LPAD(v_month,2,'0'),'-10'),
            '전기/수도/가스', v_emp1, 1);

    -- 소모품 (매월)
    INSERT INTO expenses (expense_type, amount, expense_date, description, registered_by, status)
    VALUES ('소모품', ROUND(150000 + (RAND() * 100000)),
            CONCAT(v_year,'-',LPAD(v_month,2,'0'),'-15'),
            '청소용품, 포장재 등', v_emp1, 1);

    -- 마케팅 (짝수 달)
    IF v_month % 2 = 0 THEN
      INSERT INTO expenses (expense_type, amount, expense_date, description, registered_by, status)
      VALUES ('마케팅', ROUND(200000 + (RAND() * 300000)),
              CONCAT(v_year,'-',LPAD(v_month,2,'0'),'-20'),
              'SNS 광고 및 프로모션', v_emp1, 1);
    END IF;

    -- 인건비 (외부 용역) - 분기마다
    IF v_month IN (1, 4, 7, 10) THEN
      INSERT INTO expenses (expense_type, amount, expense_date, description, registered_by, status)
      VALUES ('인건비', 300000,
              CONCAT(v_year,'-',LPAD(v_month,2,'0'),'-25'),
              '청소 외부 용역', v_emp1, 1);
    END IF;

    -- 기타 (수시)
    IF v_month % 3 = 0 THEN
      INSERT INTO expenses (expense_type, amount, expense_date, description, registered_by, status)
      VALUES ('기타', ROUND(50000 + (RAND() * 100000)),
              CONCAT(v_year,'-',LPAD(v_month,2,'0'),'-28'),
              '기타 운영비', v_emp1, 1);
    END IF;

    IF v_month = 12 THEN
      SET v_year  = v_year + 1;
      SET v_month = 1;
    ELSE
      SET v_month = v_month + 1;
    END IF;
  END WHILE;
END $$
DELIMITER ;
CALL gen_expenses();
DROP PROCEDURE gen_expenses;

-- ================================================================
-- 12. 발주 (purchases + purchase_items + stock_logs 입고)
-- ================================================================
DELIMITER $$
CREATE PROCEDURE gen_purchases()
BEGIN
  DECLARE v_year  INT DEFAULT 2022;
  DECLARE v_month INT DEFAULT 1;
  DECLARE v_ordered DATE;
  DECLARE v_received DATE;
  DECLARE v_pur_id  BIGINT;
  DECLARE v_sup_coffee  BIGINT;
  DECLARE v_sup_dairy   BIGINT;
  DECLARE v_sup_syrup   BIGINT;
  DECLARE v_sup_supply  BIGINT;
  DECLARE v_ing_eth     BIGINT; -- 에티오피아 원두
  DECLARE v_ing_col     BIGINT; -- 콜롬비아 원두
  DECLARE v_ing_milk    BIGINT; -- 전지우유
  DECLARE v_ing_oat     BIGINT; -- 오트밀크
  DECLARE v_ing_cream   BIGINT; -- 생크림
  DECLARE v_ing_van     BIGINT; -- 바닐라시럽
  DECLARE v_ing_car     BIGINT; -- 카라멜소스
  DECLARE v_ing_cho     BIGINT; -- 초코시럽
  DECLARE v_ing_str_sy  BIGINT; -- 딸기시럽
  DECLARE v_ing_cocoa   BIGINT; -- 코코아파우더
  DECLARE v_ing_matcha  BIGINT; -- 말차파우더
  DECLARE v_ing_earl    BIGINT; -- 얼그레이 티백
  DECLARE v_ing_green   BIGINT; -- 녹차 티백
  DECLARE v_ing_cup     BIGINT; -- 종이컵
  DECLARE v_ing_straw   BIGINT; -- 빨대
  DECLARE v_ing_lemon   BIGINT; -- 레몬즙
  DECLARE v_ing_str_pu  BIGINT; -- 딸기퓨레

  SET v_sup_coffee = (SELECT id FROM suppliers WHERE supplier_name='신선원두' LIMIT 1);
  SET v_sup_dairy  = (SELECT id FROM suppliers WHERE supplier_name='대한유업' LIMIT 1);
  SET v_sup_syrup  = (SELECT id FROM suppliers WHERE supplier_name='시럽월드' LIMIT 1);
  SET v_sup_supply = (SELECT id FROM suppliers WHERE supplier_name='소모마트' LIMIT 1);
  SET v_ing_eth    = (SELECT id FROM ingredients WHERE name='에티오피아 원두' LIMIT 1);
  SET v_ing_col    = (SELECT id FROM ingredients WHERE name='콜롬비아 원두' LIMIT 1);
  SET v_ing_milk   = (SELECT id FROM ingredients WHERE name='전지우유' LIMIT 1);
  SET v_ing_oat    = (SELECT id FROM ingredients WHERE name='오트밀크' LIMIT 1);
  SET v_ing_cream  = (SELECT id FROM ingredients WHERE name='생크림' LIMIT 1);
  SET v_ing_van    = (SELECT id FROM ingredients WHERE name='바닐라시럽' LIMIT 1);
  SET v_ing_car    = (SELECT id FROM ingredients WHERE name='카라멜소스' LIMIT 1);
  SET v_ing_cho    = (SELECT id FROM ingredients WHERE name='초코시럽' LIMIT 1);
  SET v_ing_str_sy = (SELECT id FROM ingredients WHERE name='딸기시럽' LIMIT 1);
  SET v_ing_cocoa  = (SELECT id FROM ingredients WHERE name='코코아파우더' LIMIT 1);
  SET v_ing_matcha = (SELECT id FROM ingredients WHERE name='말차파우더' LIMIT 1);
  SET v_ing_earl   = (SELECT id FROM ingredients WHERE name='얼그레이 티백' LIMIT 1);
  SET v_ing_green  = (SELECT id FROM ingredients WHERE name='녹차 티백' LIMIT 1);
  SET v_ing_cup    = (SELECT id FROM ingredients WHERE name='종이컵(12oz)' LIMIT 1);
  SET v_ing_straw  = (SELECT id FROM ingredients WHERE name='빨대' LIMIT 1);
  SET v_ing_lemon  = (SELECT id FROM ingredients WHERE name='레몬즙' LIMIT 1);
  SET v_ing_str_pu = (SELECT id FROM ingredients WHERE name='딸기퓨레' LIMIT 1);

  WHILE (v_year < 2026) OR (v_year = 2026 AND v_month <= 3) DO
    -- 원두/차류 발주 (매월 1일, 수령 3일 후)
    SET v_ordered  = DATE(CONCAT(v_year,'-',LPAD(v_month,2,'0'),'-03'));
    SET v_received = DATE_ADD(v_ordered, INTERVAL 3 DAY);

    INSERT INTO purchases (supplier_id, total_cost, status, ordered_at, received_at)
    VALUES (v_sup_coffee, 0, 'received', v_ordered, v_received);
    SET v_pur_id = LAST_INSERT_ID();

    INSERT INTO purchase_items (purchase_id, ingredient_id, qty, unit_cost, subtotal) VALUES
    (v_pur_id, v_ing_eth,  10, 45000, 450000),
    (v_pur_id, v_ing_col,   8, 38000, 304000),
    (v_pur_id, v_ing_earl,  5,  9000,  45000),
    (v_pur_id, v_ing_green, 4,  8500,  34000);

    UPDATE purchases SET total_cost = (
        SELECT SUM(subtotal) FROM purchase_items WHERE purchase_id = v_pur_id
    ) WHERE id = v_pur_id;

    -- 입고 stock_log (in)
    INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id)
    SELECT v_ing_eth,   'in', 10, stock_qty - 10, stock_qty, 'purchase', v_pur_id FROM ingredients WHERE id=v_ing_eth;
    INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id)
    SELECT v_ing_col,   'in',  8, stock_qty -  8, stock_qty, 'purchase', v_pur_id FROM ingredients WHERE id=v_ing_col;
    INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id)
    SELECT v_ing_earl,  'in',  5, stock_qty -  5, stock_qty, 'purchase', v_pur_id FROM ingredients WHERE id=v_ing_earl;
    INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id)
    SELECT v_ing_green, 'in',  4, stock_qty -  4, stock_qty, 'purchase', v_pur_id FROM ingredients WHERE id=v_ing_green;

    -- 유제품 발주 (매월 5일)
    SET v_ordered  = DATE(CONCAT(v_year,'-',LPAD(v_month,2,'0'),'-05'));
    SET v_received = DATE_ADD(v_ordered, INTERVAL 2 DAY);

    INSERT INTO purchases (supplier_id, total_cost, status, ordered_at, received_at)
    VALUES (v_sup_dairy, 0, 'received', v_ordered, v_received);
    SET v_pur_id = LAST_INSERT_ID();

    INSERT INTO purchase_items (purchase_id, ingredient_id, qty, unit_cost, subtotal) VALUES
    (v_pur_id, v_ing_milk,  40,  2200,  88000),
    (v_pur_id, v_ing_oat,   20,  4500,  90000),
    (v_pur_id, v_ing_cream, 10,  8000,  80000);

    UPDATE purchases SET total_cost = (
        SELECT SUM(subtotal) FROM purchase_items WHERE purchase_id = v_pur_id
    ) WHERE id = v_pur_id;

    INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id)
    SELECT v_ing_milk,  'in', 40, stock_qty - 40, stock_qty, 'purchase', v_pur_id FROM ingredients WHERE id=v_ing_milk;
    INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id)
    SELECT v_ing_oat,   'in', 20, stock_qty - 20, stock_qty, 'purchase', v_pur_id FROM ingredients WHERE id=v_ing_oat;
    INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id)
    SELECT v_ing_cream, 'in', 10, stock_qty - 10, stock_qty, 'purchase', v_pur_id FROM ingredients WHERE id=v_ing_cream;

    -- 시럽/소스/파우더 발주 (매월 8일)
    SET v_ordered  = DATE(CONCAT(v_year,'-',LPAD(v_month,2,'0'),'-08'));
    SET v_received = DATE_ADD(v_ordered, INTERVAL 2 DAY);

    INSERT INTO purchases (supplier_id, total_cost, status, ordered_at, received_at)
    VALUES (v_sup_syrup, 0, 'received', v_ordered, v_received);
    SET v_pur_id = LAST_INSERT_ID();

    INSERT INTO purchase_items (purchase_id, ingredient_id, qty, unit_cost, subtotal) VALUES
    (v_pur_id, v_ing_van,    4, 12000, 48000),
    (v_pur_id, v_ing_car,    3, 11000, 33000),
    (v_pur_id, v_ing_cho,    3, 10000, 30000),
    (v_pur_id, v_ing_str_sy, 2, 13000, 26000),
    (v_pur_id, v_ing_cocoa,  2, 18000, 36000),
    (v_pur_id, v_ing_matcha, 1, 35000, 35000);

    UPDATE purchases SET total_cost = (
        SELECT SUM(subtotal) FROM purchase_items WHERE purchase_id = v_pur_id
    ) WHERE id = v_pur_id;

    -- 시럽/소스/파우더 입고 stock_log
    INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id)
    SELECT v_ing_van,    'in', 4, stock_qty -  4, stock_qty, 'purchase', v_pur_id FROM ingredients WHERE id=v_ing_van;
    INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id)
    SELECT v_ing_car,    'in', 3, stock_qty -  3, stock_qty, 'purchase', v_pur_id FROM ingredients WHERE id=v_ing_car;
    INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id)
    SELECT v_ing_cho,    'in', 3, stock_qty -  3, stock_qty, 'purchase', v_pur_id FROM ingredients WHERE id=v_ing_cho;
    INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id)
    SELECT v_ing_str_sy, 'in', 2, stock_qty -  2, stock_qty, 'purchase', v_pur_id FROM ingredients WHERE id=v_ing_str_sy;
    INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id)
    SELECT v_ing_cocoa,  'in', 2, stock_qty -  2, stock_qty, 'purchase', v_pur_id FROM ingredients WHERE id=v_ing_cocoa;
    INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id)
    SELECT v_ing_matcha, 'in', 1, stock_qty -  1, stock_qty, 'purchase', v_pur_id FROM ingredients WHERE id=v_ing_matcha;

    -- 소모품 발주 (2달마다, received)
    IF v_month % 2 = 1 THEN
      SET v_ordered  = DATE(CONCAT(v_year,'-',LPAD(v_month,2,'0'),'-10'));
      SET v_received = DATE_ADD(v_ordered, INTERVAL 1 DAY);

      INSERT INTO purchases (supplier_id, total_cost, status, ordered_at, received_at)
      VALUES (v_sup_supply, 0, 'received', v_ordered, v_received);
      SET v_pur_id = LAST_INSERT_ID();

      INSERT INTO purchase_items (purchase_id, ingredient_id, qty, unit_cost, subtotal) VALUES
      (v_pur_id, v_ing_cup,   10, 15000, 150000),
      (v_pur_id, v_ing_straw,  8,  8000,  64000);

      UPDATE purchases SET total_cost = (
          SELECT SUM(subtotal) FROM purchase_items WHERE purchase_id = v_pur_id
      ) WHERE id = v_pur_id;

      INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id)
      SELECT v_ing_cup,   'in', 10, stock_qty - 10, stock_qty, 'purchase', v_pur_id FROM ingredients WHERE id=v_ing_cup;
      INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id)
      SELECT v_ing_straw, 'in',  8, stock_qty -  8, stock_qty, 'purchase', v_pur_id FROM ingredients WHERE id=v_ing_straw;
    END IF;

    -- 기타 식재료 발주 (3달마다, 마지막 달은 ordered 상태 = 미착재고/부채)
    IF v_month % 3 = 0 THEN
      SET v_ordered = DATE(CONCAT(v_year,'-',LPAD(v_month,2,'0'),'-25'));
      -- 2026-03에는 아직 수령 못함 (ordered 상태)
      IF v_year = 2026 AND v_month = 3 THEN
        INSERT INTO purchases (supplier_id, total_cost, status, ordered_at)
        VALUES (v_sup_supply, 0, 'ordered', v_ordered);
      ELSE
        SET v_received = DATE_ADD(v_ordered, INTERVAL 3 DAY);
        INSERT INTO purchases (supplier_id, total_cost, status, ordered_at, received_at)
        VALUES (v_sup_supply, 0, 'received', v_ordered, v_received);
      END IF;
      SET v_pur_id = LAST_INSERT_ID();

      INSERT INTO purchase_items (purchase_id, ingredient_id, qty, unit_cost, subtotal) VALUES
      (v_pur_id, v_ing_lemon,  5, 12000, 60000),
      (v_pur_id, v_ing_str_pu, 4, 25000, 100000);

      UPDATE purchases SET total_cost = (
          SELECT SUM(subtotal) FROM purchase_items WHERE purchase_id = v_pur_id
      ) WHERE id = v_pur_id;

      -- 수령 완료된 경우에만 입고 stock_log 기록 (2026-03은 ordered 상태라 제외)
      IF NOT (v_year = 2026 AND v_month = 3) THEN
        INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id)
        SELECT v_ing_lemon,  'in', 5, stock_qty -  5, stock_qty, 'purchase', v_pur_id FROM ingredients WHERE id=v_ing_lemon;
        INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id)
        SELECT v_ing_str_pu, 'in', 4, stock_qty -  4, stock_qty, 'purchase', v_pur_id FROM ingredients WHERE id=v_ing_str_pu;
      END IF;
    END IF;

    IF v_month = 12 THEN
      SET v_year  = v_year + 1;
      SET v_month = 1;
    ELSE
      SET v_month = v_month + 1;
    END IF;
  END WHILE;
END $$
DELIMITER ;
CALL gen_purchases();
DROP PROCEDURE gen_purchases;

-- ================================================================
-- 13. 주문 (orders + order_items + stock_logs 출고)
-- ================================================================
DELIMITER $$
CREATE PROCEDURE gen_orders()
BEGIN
  DECLARE v_year  INT DEFAULT 2022;
  DECLARE v_month INT DEFAULT 1;
  DECLARE v_day   INT;
  DECLARE v_max_day INT;
  DECLARE v_order_date DATE;
  DECLARE v_order_no   VARCHAR(30);
  DECLARE v_order_id   BIGINT;
  DECLARE v_oi_cnt     INT;  -- 하루 주문 수 카운터
  DECLARE v_daily_orders INT;
  DECLARE v_status     VARCHAR(10);
  DECLARE v_menu1_id   BIGINT;
  DECLARE v_menu2_id   BIGINT;
  DECLARE v_menu3_id   BIGINT;
  DECLARE v_menu4_id   BIGINT;
  DECLARE v_menu5_id   BIGINT;
  DECLARE v_menu6_id   BIGINT;
  DECLARE v_menu7_id   BIGINT;
  DECLARE v_menu8_id   BIGINT;
  DECLARE v_menu9_id   BIGINT;
  DECLARE v_menu10_id  BIGINT;
  DECLARE v_menu11_id  BIGINT;
  DECLARE v_menu12_id  BIGINT;
  DECLARE v_menu13_id  BIGINT;
  DECLARE v_menu14_id  BIGINT;
  DECLARE v_menu15_id  BIGINT;
  DECLARE v_total INT;
  DECLARE v_final INT;
  DECLARE v_sel   INT;  -- 메뉴 선택용 랜덤
  DECLARE v_price INT;
  DECLARE v_qty   INT;
  DECLARE v_i     INT;

  SET v_menu1_id  = (SELECT id FROM menus WHERE name='아메리카노'      LIMIT 1);
  SET v_menu2_id  = (SELECT id FROM menus WHERE name='카페라떼'        LIMIT 1);
  SET v_menu3_id  = (SELECT id FROM menus WHERE name='카라멜마끼아또'  LIMIT 1);
  SET v_menu4_id  = (SELECT id FROM menus WHERE name='바닐라라떼'      LIMIT 1);
  SET v_menu5_id  = (SELECT id FROM menus WHERE name='초코라떼'        LIMIT 1);
  SET v_menu6_id  = (SELECT id FROM menus WHERE name='말차라떼'        LIMIT 1);
  SET v_menu7_id  = (SELECT id FROM menus WHERE name='얼그레이 밀크티' LIMIT 1);
  SET v_menu8_id  = (SELECT id FROM menus WHERE name='녹차라떼'        LIMIT 1);
  SET v_menu9_id  = (SELECT id FROM menus WHERE name='레몬에이드'      LIMIT 1);
  SET v_menu10_id = (SELECT id FROM menus WHERE name='딸기에이드'      LIMIT 1);
  SET v_menu11_id = (SELECT id FROM menus WHERE name='딸기스무디'      LIMIT 1);
  SET v_menu12_id = (SELECT id FROM menus WHERE name='바닐라스무디'    LIMIT 1);
  SET v_menu13_id = (SELECT id FROM menus WHERE name='초코케이크'      LIMIT 1);
  SET v_menu14_id = (SELECT id FROM menus WHERE name='버터크루아상'    LIMIT 1);
  SET v_menu15_id = (SELECT id FROM menus WHERE name='클럽샌드위치'    LIMIT 1);

  WHILE (v_year < 2026) OR (v_year = 2026 AND v_month <= 3) DO
    SET v_max_day = DAY(LAST_DAY(CONCAT(v_year,'-',LPAD(v_month,2,'0'),'-01')));
    -- 2026-03은 27일까지
    IF v_year = 2026 AND v_month = 3 THEN SET v_max_day = 27; END IF;

    SET v_day = 1;
    WHILE v_day <= v_max_day DO
      SET v_order_date = DATE(CONCAT(v_year,'-',LPAD(v_month,2,'0'),'-',LPAD(v_day,2,'0')));
      -- 평일 40~70건, 주말 60~90건
      IF DAYOFWEEK(v_order_date) IN (1,7) THEN
        SET v_daily_orders = 60 + FLOOR(RAND() * 31);
      ELSE
        SET v_daily_orders = 40 + FLOOR(RAND() * 31);
      END IF;

      SET v_i = 1;
      SET v_oi_cnt = 0;
      WHILE v_i <= v_daily_orders DO
        SET v_order_no = CONCAT(DATE_FORMAT(v_order_date,'%Y%m%d'), '-', LPAD(v_i, 4, '0'));

        -- 주문 상태: 95% 완료, 3% 취소, 2% 대기
        SET v_sel = FLOOR(RAND() * 100);
        IF v_sel < 95 THEN
          SET v_status = '완료';
        ELSEIF v_sel < 98 THEN
          SET v_status = '취소';
        ELSE
          SET v_status = '대기';
        END IF;

        -- 메뉴 랜덤 선택 (1~2개)
        SET v_sel = FLOOR(RAND() * 15) + 1;
        CASE v_sel
          WHEN 1  THEN SET v_menu1_id = v_menu1_id;  -- placeholder
          WHEN 2  THEN SET v_menu1_id = v_menu2_id;
          WHEN 3  THEN SET v_menu1_id = v_menu3_id;
          WHEN 4  THEN SET v_menu1_id = v_menu4_id;
          WHEN 5  THEN SET v_menu1_id = v_menu5_id;
          WHEN 6  THEN SET v_menu1_id = v_menu6_id;
          WHEN 7  THEN SET v_menu1_id = v_menu7_id;
          WHEN 8  THEN SET v_menu1_id = v_menu8_id;
          WHEN 9  THEN SET v_menu1_id = v_menu9_id;
          WHEN 10 THEN SET v_menu1_id = v_menu10_id;
          WHEN 11 THEN SET v_menu1_id = v_menu11_id;
          WHEN 12 THEN SET v_menu1_id = v_menu12_id;
          WHEN 13 THEN SET v_menu1_id = v_menu13_id;
          WHEN 14 THEN SET v_menu1_id = v_menu14_id;
          ELSE         SET v_menu1_id = v_menu15_id;
        END CASE;

        SET v_price = (SELECT price FROM menus WHERE id = v_menu1_id LIMIT 1);
        SET v_qty   = 1 + FLOOR(RAND() * 2);   -- 1~2개
        SET v_total = v_price * v_qty;
        -- 10% 확률로 소액 할인
        IF RAND() < 0.1 THEN
          SET v_final = v_total - 500;
        ELSE
          SET v_final = v_total;
        END IF;

        INSERT INTO orders (order_no, total_amount, discount_amount, final_amount, payment_type, status, ordered_at)
        VALUES (
          v_order_no,
          v_total,
          v_total - v_final,
          v_final,
          ELT(1 + FLOOR(RAND()*5), '카드','현금','카카오페이','네이버페이','토스페이'),
          v_status,
          CONCAT(v_order_date, ' ', LPAD(9 + FLOOR(RAND()*11), 2,'0'), ':',
                 LPAD(FLOOR(RAND()*60),2,'0'), ':00')
        );
        SET v_order_id = LAST_INSERT_ID();

        -- 주문 상세
        INSERT INTO order_items (order_id, menu_id, qty, unit_price, subtotal)
        VALUES (v_order_id, v_menu1_id, v_qty, v_price, v_price * v_qty);

        -- 완료 주문만 재고 차감 stock_log
        IF v_status = '완료' THEN
          -- 주 재료 차감 (레시피 기반 근사치)
          INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id, note)
          SELECT
            r.ingredient_id,
            'out',
            ROUND(r.quantity * v_qty, 3),
            i.stock_qty,
            GREATEST(0, i.stock_qty - ROUND(r.quantity * v_qty, 3)),
            'order',
            v_order_id,
            '주문 차감'
          FROM recipes r
          JOIN ingredients i ON r.ingredient_id = i.id
          WHERE r.menu_id = v_menu1_id
            AND i.stock_qty > 0;

          -- 재고 실제 차감
          UPDATE ingredients i
          JOIN recipes r ON r.ingredient_id = i.id
          SET i.stock_qty = GREATEST(0, i.stock_qty - ROUND(r.quantity * v_qty, 3))
          WHERE r.menu_id = v_menu1_id;
        END IF;

        SET v_i = v_i + 1;
      END WHILE;  -- 하루 주문 루프

      SET v_day = v_day + 1;
    END WHILE;  -- 날짜 루프

    IF v_month = 12 THEN
      SET v_year  = v_year + 1;
      SET v_month = 1;
    ELSE
      SET v_month = v_month + 1;
    END IF;
  END WHILE;  -- 월 루프
END $$
DELIMITER ;
CALL gen_orders();
DROP PROCEDURE gen_orders;

-- ================================================================
-- 14. 재고 수동 조정 (stock_logs adjust - loss 예시)
-- ================================================================
-- 딸기퓨레: 2025-06 유통기한 만료로 1kg 손실
INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id, note, created_at)
SELECT id, 'adjust', 1.0,
       stock_qty + 1.0,  -- before_qty
       stock_qty,         -- after_qty (감소)
       'adjust', NULL,
       '유통기한 만료 폐기',
       '2025-06-15 10:00:00'
FROM ingredients WHERE name = '딸기퓨레';

-- 전지우유: 2025-09 입고 시 확인 결과 2L 여분 발견 (gain)
INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id, note, created_at)
SELECT id, 'adjust', 2.0,
       stock_qty - 2.0,  -- before_qty
       stock_qty,         -- after_qty (증가)
       'adjust', NULL,
       '재고 실사 후 여분 발견',
       '2025-09-10 11:00:00'
FROM ingredients WHERE name = '전지우유';

-- 얼그레이 티백: 2025-11 박스 파손 1box 손실, 이후 반품 처리로 1box 복구 → net_loss = 0
INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id, note, created_at)
SELECT id, 'adjust', 1.0,
       stock_qty + 1.0,
       stock_qty,
       'adjust', NULL,
       '박스 파손 손실',
       '2025-11-05 09:30:00'
FROM ingredients WHERE name = '얼그레이 티백';

INSERT INTO stock_logs (ingredient_id, change_type, change_qty, before_qty, after_qty, ref_type, ref_id, note, created_at)
SELECT id, 'adjust', 1.0,
       stock_qty - 1.0,
       stock_qty,
       'adjust', NULL,
       '공급업체 반품 처리 복구',
       '2025-11-10 14:00:00'
FROM ingredients WHERE name = '얼그레이 티백';

-- ================================================================
-- 15. 공지사항
-- ================================================================
INSERT INTO notices (title, content, importance, writer, is_active) VALUES
('2022년 1월 운영 공지',   '1월 영업시간: 09:00-21:00입니다.',    'normal',    '김지훈', 1),
('설 연휴 휴무 안내',       '2022-02-01(화) ~ 02-03(목) 휴무',     'important', '김지훈', 1),
('여름 시즌 메뉴 출시',     '7월부터 아이스 스무디 라인업 추가',    'normal',    '이소연', 1),
('연말 파티 케이터링 안내', '12월 단체 주문 10% 할인 이벤트',       'urgent',    '김지훈', 1),
('2026년 신메뉴 출시',     '봄 시즌 딸기 라인업 정식 출시',        'important', '이소연', 1);

-- ================================================================
-- 완료
-- ================================================================
SET FOREIGN_KEY_CHECKS = 1;
SELECT '✅ 예시 데이터 삽입 완료' AS result;
