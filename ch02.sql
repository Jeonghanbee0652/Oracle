CREATE TABLE orders (
       order_id      NUMBER(12,0),
       order_date    DATE,
       order_mode    VARCHAR2(8 BYTE),
       customer_id   NUMBER(6,0),
       order_status  NUMBER(2,0),
       order_total   NUMBER(8,2) DEFAULT 0,
       sales_rep_id  NUMBER(6,0),
       promotion_id  NUMBER(6,0),
       CONSTRAINT pk_orders PRIMARY KEY (order_id),
       CONSTRAINT ck_orders_mode CHECK (order_mode IN ('direct', 'online'))
);

SELECT column_name, data_type, data_length, data_precision, data_scale, data_default
  FROM user_tab_columns
 WHERE table_name = 'ORDERS'
 ORDER BY column_id;

SELECT constraint_name, constraint_type, search_condition
  FROM user_constraints
 WHERE table_name = 'ORDERS';


-- 2장-2. ORDER_ITEMS 테이블
CREATE TABLE order_items (
       order_id      NUMBER(12,0),
       line_item_id  NUMBER(3,0),
       product_id    NUMBER(3,0),
       unit_price    NUMBER(8,2) DEFAULT 0,
       quantity      NUMBER(8,0) DEFAULT 0,
       CONSTRAINT pk_order_items PRIMARY KEY (order_id, line_item_id)
);

SELECT column_name, data_type, data_precision, data_scale, data_default
  FROM user_tab_columns
 WHERE table_name = 'ORDER_ITEMS'
 ORDER BY column_id;


-- 2장-3. PROMOTIONS 테이블
CREATE TABLE promotions (
       promo_id    NUMBER(6,0),
       promo_name  VARCHAR2(20),
       CONSTRAINT pk_promotions PRIMARY KEY (promo_id)
);

SELECT constraint_name, constraint_type, table_name
  FROM user_constraints
 WHERE table_name IN ('ORDERS', 'ORDER_ITEMS', 'PROMOTIONS')
 ORDER BY table_name;


-- 2장-4. FLOAT(126)에 0.30103을 곱하는 이유
-- [답] FLOAT의 자릿수는 2진수 자릿수이므로 10진수 자릿수로 바꿔야 한다.
--      2진수 n자리로 표현 가능한 수는 2^n 이고, 이것이 10진수 몇 자리인지는 log10(2^n) = n * log10(2) 이다.
--      log10(2) = 0.30103 이므로 126 * 0.30103 = 37.93 ≒ 38자리 (NUMBER의 최대 38자리와 같다)
SELECT LOG(10, 2) AS log10_2,
       126 * LOG(10, 2) AS float126_digits
  FROM dual;


-- 2장-5. ORDERS_SEQ 시퀀스
CREATE SEQUENCE orders_seq
       INCREMENT BY 1
       START WITH 1000
       MINVALUE 1
       MAXVALUE 99999999
       NOCYCLE
       NOCACHE;

SELECT orders_seq.NEXTVAL FROM dual;   -- 1000