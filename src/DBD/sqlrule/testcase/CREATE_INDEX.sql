--General Index Examples

--Creating an Index: Example 
--The following statement shows how the sample index ord_customer_ix on the customer_id column of the sample table oe.orders was created:

CREATE INDEX ord_customer_ix
   ON orders (customer_id);
--Compressing an Index: Example 
--To create the ord_customer_ix_demo index with the COMPRESS clause, you might issue the following statement:

CREATE INDEX ord_customer_ix_demo 
   ON orders (customer_id, sales_rep_id)
   COMPRESS 1;
--The index will compress repeated occurrences of customer_id column values.

--Creating an Index in NOLOGGING Mode: Example 
--If the sample table orders had been created using a fast parallel load (so all rows were already sorted), then you could issue the following statement to quickly create an index.

/* Unless you first sort the table oe.orders, this example fails
   because you cannot specify NOSORT unless the base table is
   already sorted.
*/
CREATE INDEX ord_customer_ix_demo
   ON orders (order_mode)
   NOSORT
   NOLOGGING;
--Creating a Cluster Index: Example 
--To create an index for the personnel cluster, which was created in "Creating a Cluster: Example", issue the following statement:

CREATE INDEX idx_personnel ON CLUSTER personnel; 
--No index columns are specified, because cluster indexes are automatically built on all the columns of the cluster key. For cluster indexes, all rows are indexed.

--Creating an Index on an XMLType Table: Example 
--The following example creates an index on the area element of the xwarehouses table (created in "XMLType Table Examples"):

CREATE INDEX area_index ON xwarehouses e 
   (EXTRACTVALUE(VALUE(e),'/Warehouse/Area'));
--Such an index would greatly improve the performance of queries that select from the table based on, for example, the square footage of a warehouse, as shown in this statement:

--The following examples show how to create and use function-based indexes.

--Creating a Function-Based Index: Example 
--The following statement creates a function-based index on the employees table based on an uppercase evaluation of the last_name column:

CREATE INDEX upper_ix ON employees (UPPER(last_name)); 
document
See the "Prerequisites" for the privileges and parameter settings required when creating function-based indexes.

To increase the likelihood that Oracle Database will use the index rather than performing a full table scan, be sure that the value returned by the function is not null in subsequent queries. For example, this statement will use the index, unless some other condition exists that prevents the optimizer from doing so:

SELECT first_name, last_name 
   FROM employees WHERE UPPER(last_name) IS NOT NULL
   ORDER BY UPPER(last_name);
Without the WHERE clause, Oracle Database may perform a full table scan.

In the next statements showing index creation and subsequent query, Oracle Database will use index income_ix even though the columns are in reverse order in the query:
#
CREATE INDEX income_ix 
   ON employees(salary + (salary*commission_pct));

/*
SELECT first_name||' '||last_name "Name"
   FROM employees 
   WHERE (salary*commission_pct) + salary > 15000
   ORDER BY employee_id;
Creating a Function-Based Index on a LOB Column: Example 
The following statement uses the text_length function to create a function-based index on a LOB column in the sample pm schema. See Oracle Database PL/SQL Language Reference for the example that creates this function. The example selects rows from the sample table print_media where that CLOB column has fewer than 1000 characters.
*/

CREATE INDEX src_idx ON print_media(text_length(ad_sourcetext));

/*
SELECT product_id FROM print_media 
   WHERE text_length(ad_sourcetext) < 1000
   ORDER BY product_id;

PRODUCT_ID
----------
      2056
      2268
      3060
      3106
Creating a Function-based Index on a Type Method: Example 
This example entails an object type rectangle containing two number attributes: length and width. The area() method computes the area of the rectangle.
CREATE TYPE rectangle AS OBJECT  
( length   NUMBER, 
  width    NUMBER, 
  MEMBER FUNCTION area RETURN NUMBER DETERMINISTIC 
); 
 
CREATE OR REPLACE TYPE BODY rectangle AS 
  MEMBER FUNCTION area RETURN NUMBER IS 
  BEGIN 
   RETURN (length*width); 
  END; 
END; 
Now, if you create a table rect_tab of type rectangle, you can create a function-based index on the area() method as follows:

*/
CREATE TABLE rect_tab OF rectangle; 
CREATE INDEX area_idx ON rect_tab x (x.area()); 
--You can use this index efficiently to evaluate a query of the form:

SELECT * FROM rect_tab x WHERE x.area() > 100; 
--Using a Function-based Index to Define Conditional Uniqueness: Example  
--The following statement creates a unique function-based index on the oe.orders table that prevents a customer from taking advantage of promotion ID 2 ("blowout sale") more than once:


CREATE INDEX cost_ix ON sales (amount_sold)
   GLOBAL PARTITION BY RANGE (amount_sold)
      (PARTITION p1 VALUES LESS THAN (1000),
       PARTITION p2 VALUES LESS THAN (2500),
       PARTITION p3 VALUES LESS THAN (MAXVALUE));
--Creating a Hash-Partitioned Global Index: Example 
--The following statement creates a hash-partitioned global index cust_last_name_ix on the sample table sh.customers with four partitions:

CREATE INDEX cust_last_name_ix ON customers (cust_last_name)
  GLOBAL PARTITION BY HASH (cust_last_name)
  PARTITIONS 4;
--Creating an Index on a Hash-Partitioned Table: Example 
--The following statement creates a local index on the category_id column of the hash_products partitioned table (which was created in "Hash Partitioning Example"). The STORE IN clause immediately following LOCAL indicates that hash_products is hash partitioned. Oracle Database will distribute the hash partitions between the tbs1 and tbs2 tablespaces:

CREATE INDEX prod_idx ON hash_products(category_id) LOCAL
   STORE IN (tbs_01, tbs_02);
--The creator of the index must have quota on the tablespaces specified. See CREATE TABLESPACE for examples that create tablespaces tbs_01 and tbs_02.

--Creating an Index on a Composite-Partitioned Table: Example 
--The following statement creates a local index on the composite_sales table, which was created in "Composite-Partitioned Table Examples". The STORAGE clause specifies default storage attributes for the index. However, this default is overridden for the five subpartitions of partitions q3_2000 and q4_2000, because separate TABLESPACE storage is specified.

--The creator of the index must have quota on the tablespaces specified. See CREATE TABLESPACE for examples that create tablespaces tbs_02 and tbs_03.

CREATE INDEX sales_ix ON composite_sales(time_id, prod_id)
   STORAGE (INITIAL 1M)
   LOCAL
   (PARTITION q1_1998,
    PARTITION q2_1998,
    PARTITION q3_1998,
    PARTITION q4_1998,
    PARTITION q1_1999,
    PARTITION q2_1999,
    PARTITION q3_1999,
    PARTITION q4_1999,
    PARTITION q1_2000,
    PARTITION q2_2000
      (SUBPARTITION pq2001, SUBPARTITION pq2002, 
       SUBPARTITION pq2003, SUBPARTITION pq2004,
       SUBPARTITION pq2005, SUBPARTITION pq2006, 
       SUBPARTITION pq2007, SUBPARTITION pq2008),
    PARTITION q3_2000
      (SUBPARTITION c1 TABLESPACE tbs_02, 
       SUBPARTITION c2 TABLESPACE tbs_02, 
       SUBPARTITION c3 TABLESPACE tbs_02,
       SUBPARTITION c4 TABLESPACE tbs_02,
       SUBPARTITION c5 TABLESPACE tbs_02),
    PARTITION q4_2000
      (SUBPARTITION pq4001 TABLESPACE tbs_03, 
       SUBPARTITION pq4002 TABLESPACE tbs_03,
       SUBPARTITION pq4003 TABLESPACE tbs_03,
       SUBPARTITION pq4004 TABLESPACE tbs_03)
);


--Indexes on Nested Tables: Example

--The sample table pm.print_media contains a nested table column ad_textdocs_ntab, which is stored in storage table textdocs_nestedtab. The following example creates a unique index on storage table textdocs_nestedtab:

CREATE INDEX salary_i 
   ON books (TREAT(author AS employee_t).salary);
--The target type in the argument of the TREAT function must be the type that added the attribute being referenced. In the example, the target of TREAT is employee_t, which is the type that added the salary attribute.

--If this condition is not satisfied, then Oracle Database interprets the TREAT function as any functional expression and creates the index as a function-based index. For example, the following statement creates a function-based index on the salary attribute of part-time employees, assigning nulls to instances of all other types in the type hierarchy.

CREATE INDEX salary_func_i ON persons p
   (TREAT(VALUE(p) AS part_time_emp_t).salary);
--You can also build an index on the type-discriminant column underlying a substitutable column by using the SYS_TYPEID function.

--Note:
--Oracle Database uses the type-discriminant column to evaluate queries that involve the IS OF type condition. The cardinality of the typeid column is normally low, so Oracle recommends that you build a bitmap index in this situation.
--The following statement creates a bitmap index on the typeid of the author column of the books table:

