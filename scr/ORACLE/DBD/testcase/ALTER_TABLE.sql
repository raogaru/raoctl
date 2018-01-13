DOCUMENT
File: DBD.sqlrule.example.sql
This SQL file is to unit testing of DBD.sqlrule.sh
This SQL contains all +ve test cases
#
CREATE TABLE hr.admin_emp (
         empno      NUMBER(5) PRIMARY KEY,
         ename      VARCHAR2(15) NOT NULL,
         ssn        NUMBER(9) ENCRYPT,
         job        VARCHAR2(10),
         mgr        NUMBER(5),
         hiredate   DATE DEFAULT (sysdate),
         photo      BLOB,
         sal        NUMBER(7,2),
         hrly_rate  NUMBER(7,2) GENERATED ALWAYS AS (sal/2080),
         comm       NUMBER(7,2),
         deptno     NUMBER(3) NOT NULL)
   TABLESPACE admin_tbs
   STORAGE ( INITIAL 50K);


COMMENT ON TABLE hr.admin_emp IS 'Enhanced employee table';


CREATE GLOBAL TEMPORARY TABLE admin_work_area
        (startdate DATE,
         enddate DATE,
         class CHAR(20))
      ON COMMIT DELETE ROWS
      TABLESPACE tbs_t1;


CREATE TABLE hr.admin_emp_dept
     PARALLEL COMPRESS
     AS SELECT * FROM hr.employees
     WHERE department_id = 10;



ALTER TABLE t1 DROP COLUMN f1 DROP (f2);
ALTER TABLE t1 DROP COLUMN f1 SET UNUSED (f2);
ALTER TABLE t1 DROP (f1) ADD (f2 NUMBER);
ALTER TABLE t1 SET UNUSED (f3) 
   ADD (CONSTRAINT ck1 CHECK (f2 > 0));


ALTER TABLE print_media MODIFY NESTED TABLE ad_textdocs_ntab
   RETURN AS VALUE; 

ALTER TABLE customers
   PARALLEL;

ALTER TABLE employees
   ENABLE VALIDATE CONSTRAINT emp_manager_fk
   EXCEPTIONS INTO exceptions;


SELECT e.*
   FROM employees e, exceptions ex
   WHERE e.rowid = ex.row_id
      AND ex.table_name = 'EMPLOYEES'
      AND ex.constraint = 'EMP_MANAGER_FK';

ALTER TABLE employees
   ENABLE NOVALIDATE PRIMARY KEY
   ENABLE NOVALIDATE CONSTRAINT emp_last_name_nn;

ALTER TABLE locations
   MODIFY PRIMARY KEY DISABLE CASCADE;

ALTER TABLE countries
   ENABLE PRIMARY KEY
   EXCEPTIONS INTO except_table;


ALTER TABLE employees ADD CONSTRAINT check_comp 
   CHECK (salary + (commission_pct*salary) <= 5000)
   DISABLE;

ALTER TABLE employees
   ENABLE ALL TRIGGERS;


ALTER TABLE employees
    DEALLOCATE UNUSED;


ALTER TABLE customers
   RENAME COLUMN credit_limit TO credit_amount;

ALTER TABLE t1 DROP (pk);

ALTER TABLE t1 DROP (pk) CASCADE CONSTRAINTS;

ALTER TABLE t1 DROP (pk, fk, c1);


ALTER TABLE countries_demo INITRANS 4;

ALTER TABLE countries_demo ADD OVERFLOW;

ALTER TABLE countries_demo OVERFLOW INITRANS 4;


ALTER TABLE sales SPLIT PARTITION SALES_Q4_2000 
   AT (TO_DATE('15-NOV-2000','DD-MON-YYYY'))
   INTO (PARTITION SALES_Q4_2000, PARTITION SALES_Q4_2000b);

ALTER TABLE print_media_part
   SPLIT PARTITION p2 AT (150) INTO
   (PARTITION p2a TABLESPACE omf_ts1
      LOB ad_photo, ad_composite) STORE AS (TABLESPACE omf_ts2),
   PARTITION p2b 
      LOB (ad_photo, ad_composite) STORE AS (TABLESPACE omf_ts2));

ALTER TABLE print_media_part ADD PARTITION p3 VALUES LESS THAN (MAXVALUE)
   LOB (ad_photo, ad_composite) STORE AS (TABLESPACE omf_ts2)
   LOB (ad_sourcetext, ad_finaltext) STORE AS (TABLESPACE omf_ts1);

ALTER TABLE list_customers SPLIT PARTITION rest 
   VALUES ('MEXICO', 'COLOMBIA')
   INTO (PARTITION south, PARTITION rest);

ALTER TABLE list_customers 
   MERGE PARTITIONS asia, rest INTO PARTITION rest;

ALTER TABLE list_customers SPLIT PARTITION rest 
   VALUES ('CHINA', 'THAILAND')
   INTO (PARTITION asia, partition rest);

ALTER TABLE sales 
   MERGE PARTITIONS sales_q4_2000, sales_q4_2000b
   INTO PARTITION sales_q4_2000;


ALTER TABLE print_media_part DROP PARTITION p3;

CREATE TABLE exchange_table (
   customer_id     NUMBER(6),
   cust_first_name VARCHAR2(20),
   cust_last_name  VARCHAR2(20),
   cust_address    CUST_ADDRESS_TYP,
   nls_territory   VARCHAR2(30),
   cust_email      VARCHAR2(30));

ALTER TABLE list_customers 
   EXCHANGE PARTITION feb97 WITH TABLE sales_feb97 
   WITHOUT VALIDATION;

ALTER TABLE list_customers MODIFY PARTITION asia 
   UNUSABLE LOCAL INDEXES;

ALTER TABLE list_customers MODIFY PARTITION asia
   REBUILD UNUSABLE LOCAL INDEXES;

ALTER TABLE print_media_part 
   MOVE PARTITION p2b TABLESPACE omf_ts1;

ALTER TABLE sales RENAME PARTITION sales_q4_2003 TO sales_currentq;

ALTER TABLE print_media_demo
   TRUNCATE PARTITION p1 DROP STORAGE;

ALTER TABLE sales SPLIT PARTITION sales_q1_2000
   AT (TO_DATE('16-FEB-2000','DD-MON-YYYY'))
   INTO (PARTITION q1a_2000, PARTITION q1b_2000)
   UPDATE GLOBAL INDEXES;

CREATE INDEX cost_ix ON costs(channel_id) LOCAL;

ALTER TABLE costs
  SPLIT PARTITION costs_q4_2003 at
    (TO_DATE('01-Nov-2003','dd-mon-yyyy')) 
    INTO (PARTITION c_p1, PARTITION c_p2) 
  UPDATE INDEXES (cost_ix (PARTITION c_p1 tablespace tbs_02, 
                           PARTITION c_p2 tablespace tbs_03));

CREATE TYPE emp_t AS OBJECT (empno NUMBER, address CHAR(30));

CREATE TABLE emp OF emp_t (
   empno PRIMARY KEY)
   OBJECT IDENTIFIER IS PRIMARY KEY;

CREATE TABLE dept (dno NUMBER, mgr_ref REF emp_t SCOPE is emp);


ALTER TABLE dept ADD CONSTRAINT mgr_cons FOREIGN KEY (mgr_ref)
   REFERENCES emp;
ALTER TABLE dept ADD sr_mgr REF emp_t REFERENCES emp;

ALTER TABLE countries 
   ADD (duty_pct     NUMBER(2,2)  CHECK (duty_pct < 10.5),
        visa_needed  VARCHAR2(3)); 


CREATE TABLE emp2 AS SELECT * FROM employees;

ALTER TABLE emp2 ADD (income AS (salary + (salary*commission_pct)));


ALTER TABLE countries
   MODIFY (duty_pct NUMBER(3,2)); 

ALTER TABLE employees 
   PCTFREE 30
   PCTUSED 60; 

