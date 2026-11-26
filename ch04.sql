SELECT employee_id, emp_name, phone_number,
       '(02)' || SUBSTR(phone_number, 5) AS new_phone_number
  FROM employees
 ORDER BY employee_id;