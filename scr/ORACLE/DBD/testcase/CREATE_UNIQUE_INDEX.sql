
CREATE UNIQUE INDEX promo_ix ON orders
   (CASE WHEN promotion_id =2 THEN customer_id ELSE NULL END,
    CASE WHEN promotion_id = 2 THEN promotion_id ELSE NULL END);

/*

INSERT INTO orders (order_id, order_date, customer_id, order_total, promotion_id)
   VALUES (2459, systimestamp, 106, 251, 2);
1 row created.

INSERT INTO orders (order_id, order_date, customer_id, order_total, promotion_id)
   VALUES (2460, systimestamp+1, 106, 110, 2);
insert into orders (order_id, order_date, customer_id, order_total, promotion_id)
*
ERROR at line 1:
ORA-00001: unique constraint (OE.PROMO_IX) violated
The objective is to remove from the index any rows where the promotion_id is not equal to 2. Oracle Database does not store in the index any rows where all the keys are NULL. Therefore, in this example, both customer_id and promotion_id are mapped to NULL unless promotion_id is equal to 2. The result is that the index constraint is violated only if promotion_id is equal to 2 for two rows with the same customer_id value.

Partitioned Index Examples

Creating a Range-Partitioned Global Index: Example 
The following statement creates a global prefixed index cost_ix on the sample table sh.sales with three partitions that divide the range of costs into three groups:

*/

CREATE UNIQUE INDEX nested_tab_ix
      ON textdocs_nestedtab(NESTED_TABLE_ID, document_typ);
Including pseudocolumn NESTED_TABLE_ID ensures distinct rows in nested table column ad_textdocs_ntab.
