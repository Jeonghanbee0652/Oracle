SET SERVEROUTPUT ON

DECLARE
   vn_base_num NUMBER := 3;
BEGIN
   FOR i IN REVERSE 9..1
   LOOP
      DBMS_OUTPUT.PUT_LINE (vn_base_num || '*' || i || '= ' || vn_base_num * i);
   END LOOP;
END;
/



CREATE OR REPLACE FUNCTION my_initcap ( ps_string IN VARCHAR2 )
   RETURN VARCHAR2
IS
   vs_temp    VARCHAR2(4000) := LOWER(ps_string);
   vs_return  VARCHAR2(4000);
   vn_pos     NUMBER;
BEGIN
   IF ps_string IS NULL THEN
      RETURN NULL;
   END IF;

   LOOP
      vn_pos := INSTR(vs_temp, ' ');

      IF vn_pos = 0 THEN 
         vs_return := vs_return || UPPER(SUBSTR(vs_temp, 1, 1)) || SUBSTR(vs_temp, 2);
         EXIT;
      END IF;

      vs_return := vs_return || UPPER(SUBSTR(vs_temp, 1, 1)) || SUBSTR(vs_temp, 2, vn_pos - 1);
      vs_temp   := SUBSTR(vs_temp, vn_pos + 1);
   END LOOP;

   RETURN vs_return;
END;
/

SELECT my_initcap('hello oracle world') AS my_initcap,
       INITCAP('hello oracle world')    AS initcap
  FROM dual;



CREATE OR REPLACE FUNCTION my_last_day ( p_input_date IN VARCHAR2 )
   RETURN VARCHAR2
IS
   vd_date  DATE;
BEGIN

   vd_date := TO_DATE(REPLACE(p_input_date, '-', ''), 'YYYYMMDD');


   RETURN TO_CHAR(ADD_MONTHS(TRUNC(vd_date, 'MM'), 1) - 1, 'YYYYMMDD');

EXCEPTION WHEN OTHERS THEN
   RETURN '입력일자 오류';
END;
/

SELECT my_last_day('20240215')   AS feb_2024,
       my_last_day('2023-12-05') AS dec_2023,
       TO_CHAR(LAST_DAY(TO_DATE('20240215', 'YYYYMMDD')), 'YYYYMMDD') AS last_day_check
  FROM dual;



CREATE TABLE ch09_dept (
       department_id    NUMBER,
       department_name  VARCHAR2(100),
       levels           NUMBER );

CREATE OR REPLACE PROCEDURE my_hier_dept_proc
IS
BEGIN
   DELETE ch09_dept;

   INSERT INTO ch09_dept ( department_id, department_name, levels )
   SELECT department_id, LPAD(' ', 3 * (LEVEL - 1)) || department_name, LEVEL
     FROM departments
    START WITH parent_id IS NULL
  CONNECT BY PRIOR department_id = parent_id;

   COMMIT;
END;
/

EXEC my_hier_dept_proc;

SELECT * FROM ch09_dept;



CREATE OR REPLACE PROCEDURE my_new_job_proc2
          ( p_job_id    IN JOBS.JOB_ID%TYPE,
            p_job_title IN JOBS.JOB_TITLE%TYPE,
            p_min_sal   IN JOBS.MIN_SALARY%TYPE,
            p_max_sal   IN JOBS.MAX_SALARY%TYPE )
IS
BEGIN
   MERGE INTO jobs a
   USING ( SELECT p_job_id AS job_id FROM dual ) b
      ON ( a.job_id = b.job_id )
    WHEN MATCHED THEN
         UPDATE SET a.job_title   = p_job_title,
                    a.min_salary  = p_min_sal,
                    a.max_salary  = p_max_sal,
                    a.update_date = SYSDATE
    WHEN NOT MATCHED THEN
         INSERT ( a.job_id, a.job_title, a.min_salary, a.max_salary, a.create_date, a.update_date )
         VALUES ( p_job_id, p_job_title, p_min_sal, p_max_sal, SYSDATE, SYSDATE );

   COMMIT;
END;
/

EXEC my_new_job_proc2('SM_JOB1', 'Sample JOB1', 1000, 5000); 
SELECT * FROM jobs WHERE job_id = 'SM_JOB1';

EXEC my_new_job_proc2('SM_JOB1', 'Sample JOB1 수정', 2000, 6000);
SELECT * FROM jobs WHERE job_id = 'SM_JOB1';



CREATE TABLE ch09_departments AS
SELECT department_id, department_name, parent_id
  FROM departments;

CREATE OR REPLACE PROCEDURE my_dept_manage_proc
          ( p_department_id    IN ch09_departments.department_id%TYPE,
            p_department_name  IN ch09_departments.department_name%TYPE,
            p_parent_id        IN ch09_departments.parent_id%TYPE,
            p_flag             IN VARCHAR2 )
IS
   vn_dept_cnt  NUMBER := 0;
   vn_emp_cnt   NUMBER := 0;
BEGIN
   IF UPPER(p_flag) = 'UPSERT' THEN
      MERGE INTO ch09_departments a
      USING ( SELECT p_department_id AS department_id FROM dual ) b
         ON ( a.department_id = b.department_id )
       WHEN MATCHED THEN
            UPDATE SET a.department_name = p_department_name,
                       a.parent_id       = p_parent_id
       WHEN NOT MATCHED THEN
            INSERT ( a.department_id, a.department_name, a.parent_id )
            VALUES ( p_department_id, p_department_name, p_parent_id );

      DBMS_OUTPUT.PUT_LINE(p_department_id || '번 부서 저장 완료');

   ELSIF UPPER(p_flag) = 'DELETE' THEN
      SELECT COUNT(*) INTO vn_dept_cnt
        FROM ch09_departments
       WHERE department_id = p_department_id;

      IF vn_dept_cnt = 0 THEN
         DBMS_OUTPUT.PUT_LINE('해당 부서가 없어 삭제할 수 없습니다.');
         RETURN;
      END IF;

      SELECT COUNT(*) INTO vn_emp_cnt
        FROM employees
       WHERE department_id = p_department_id;

      IF vn_emp_cnt > 0 THEN
         DBMS_OUTPUT.PUT_LINE('경고 : 해당 부서에 속한 사원이 ' || vn_emp_cnt || '명 있어 삭제할 수 없습니다.');
         RETURN;
      END IF;

      DELETE ch09_departments
       WHERE department_id = p_department_id;

      DBMS_OUTPUT.PUT_LINE(p_department_id || '번 부서 삭제 완료');
   END IF;

   COMMIT;
END;
/

EXEC my_dept_manage_proc(300, '신규부서', 10, 'upsert');  
EXEC my_dept_manage_proc(300, '신규부서(수정)', 10, 'upsert'); 
SELECT * FROM ch09_departments WHERE department_id = 300;

EXEC my_dept_manage_proc(50, NULL, NULL, 'delete');       
EXEC my_dept_manage_proc(300, NULL, NULL, 'delete');       
SELECT * FROM ch09_departments WHERE department_id IN (50, 300);