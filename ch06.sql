SELECT a.employee_id     AS 사번,
       a.emp_name        AS 사원명,
       d.job_title       AS job명칭,
       b.start_date      AS job시작일자,
       b.end_date        AS job종료일자,
       c.department_name AS job수행부서명
  FROM employees a, job_history b, departments c, jobs d
 WHERE a.employee_id   = b.employee_id
   AND b.department_id = c.department_id
   AND b.job_id        = d.job_id
   AND a.employee_id   = 101
 ORDER BY b.start_date;


select a.employee_id, a.emp_name, b.job_id, b.department_id
  from employees a,
       job_history b
 where a.employee_id      = b.employee_id(+)
   and a.department_id(+) = b.department_id;
select a.employee_id, a.emp_name, b.job_id, b.department_id
  from employees a,
       job_history b
 where a.employee_id   = b.employee_id(+)
   and a.department_id = b.department_id(+);


SELECT a.department_id, a.department_name, b.emp_name
  FROM departments a, employees b
 WHERE a.department_id    = b.department_id(+)
   AND b.department_id(+) IN (10);

SELECT a.department_id, a.department_name, b.emp_name
  FROM departments a, employees b
 WHERE a.department_id    = b.department_id(+)
   AND b.department_id(+) IN (10, 20);


SELECT a.department_id, a.department_name
  FROM departments a
 INNER JOIN employees b
    ON a.department_id = b.department_id
 WHERE b.salary > 3000
 ORDER BY a.department_name;


SELECT a.department_id, a.department_name
  FROM departments a
 WHERE a.department_id IN ( SELECT b.department_id
                              FROM job_history b );


SELECT emp.years,
       CASE WHEN emp.amount_sold = sale.max_sold THEN '최대' ELSE '최소' END AS 구분,
       emp.employee_id,
       emp2.emp_name,
       emp.amount_sold
  FROM ( SELECT SUBSTR(a.sales_month, 1, 4) AS years,
                a.employee_id,
                SUM(a.amount_sold) AS amount_sold
           FROM sales a, customers b, countries c
          WHERE a.cust_id      = b.cust_id
            AND b.country_id   = c.country_id
            AND c.country_name = 'Italy'
          GROUP BY SUBSTR(a.sales_month, 1, 4), a.employee_id
       ) emp,
       ( SELECT years,
                MAX(amount_sold) AS max_sold,
                MIN(amount_sold) AS min_sold
           FROM ( SELECT SUBSTR(a.sales_month, 1, 4) AS years,
                         a.employee_id,
                         SUM(a.amount_sold) AS amount_sold
                    FROM sales a, customers b, countries c
                   WHERE a.cust_id      = b.cust_id
                     AND b.country_id   = c.country_id
                     AND c.country_name = 'Italy'
                   GROUP BY SUBSTR(a.sales_month, 1, 4), a.employee_id )
          GROUP BY years
       ) sale,
       employees emp2
 WHERE emp.years = sale.years
   AND emp.amount_sold IN (sale.max_sold, sale.min_sold)
   AND emp.employee_id = emp2.employee_id
 ORDER BY emp.years, 구분;