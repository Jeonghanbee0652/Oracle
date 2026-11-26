SELECT employee_id, emp_name, phone_number,
       '(02)' || SUBSTR(phone_number, 5) AS new_phone_number
  FROM employees
 ORDER BY employee_id;


SELECT employee_id AS 사원번호,
       emp_name    AS 사원명,
       hire_date   AS 입사일자,
       years       AS 근속년수
  FROM ( SELECT employee_id, emp_name, hire_date,
                TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date) / 12) AS years
           FROM employees )
 WHERE years >= 10
 ORDER BY years DESC, hire_date;


SELECT cust_name, cust_main_phone_number,
       REPLACE(cust_main_phone_number, '-', '/') AS new_phone_number
  FROM customers;


SELECT cust_name, cust_main_phone_number,
       TRANSLATE(cust_main_phone_number, '0123456789', 'acielsifke') AS new_phone_number
  FROM customers;


SELECT cust_name, cust_year_of_birth,
       DECODE( TRUNC((TO_CHAR(SYSDATE, 'YYYY') - cust_year_of_birth) / 10),
               3, '30대',
               4, '40대',
               5, '50대',
               '기타' ) AS generation
  FROM customers;


SELECT cust_name, cust_year_of_birth, age,
       CASE WHEN age < 10  THEN '10세 미만'
            WHEN age < 20  THEN '10대'
            WHEN age < 30  THEN '20대'
            WHEN age < 40  THEN '30대'
            WHEN age < 50  THEN '40대'
            WHEN age < 60  THEN '50대'
            WHEN age < 70  THEN '60대'
            WHEN age < 80  THEN '70대'
            WHEN age < 90  THEN '80대'
            WHEN age < 100 THEN '90대'
            ELSE '100세 이상'
       END AS generation
  FROM ( SELECT cust_name, cust_year_of_birth,
                TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY')) - cust_year_of_birth AS age
           FROM customers );