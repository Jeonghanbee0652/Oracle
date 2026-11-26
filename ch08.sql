SET SERVEROUTPUT ON

BEGIN
   FOR i IN 1..9
   LOOP
      DBMS_OUTPUT.PUT_LINE('3 * ' || i || ' = ' || 3 * i);
   END LOOP;
END;
/



DECLARE
   vs_emp_name  employees.emp_name%TYPE;
   vs_email     employees.email%TYPE;
BEGIN
   SELECT emp_name, email
     INTO vs_emp_name, vs_email
     FROM employees
    WHERE employee_id = 201;

   DBMS_OUTPUT.PUT_LINE('이름 : ' || vs_emp_name || ', 이메일 : ' || vs_email);
END;
/



DECLARE
   vn_max_empno  employees.employee_id%TYPE;
BEGIN
   SELECT MAX(employee_id)
     INTO vn_max_empno
     FROM employees;

   INSERT INTO employees ( employee_id, emp_name, email, hire_date, department_id )
                  VALUES ( vn_max_empno + 1, 'Harrison Ford', 'HARRIS', SYSDATE, 50 );

   COMMIT;

   DBMS_OUTPUT.PUT_LINE((vn_max_empno + 1) || '번 사원 입력 완료');
END;
/

SELECT employee_id, emp_name, email, hire_date, department_id
  FROM employees
 WHERE emp_name = 'Harrison Ford';