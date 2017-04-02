--Storing Index Blocks in Reverse Order: Example 
--The following statement rebuilds index ord_customer_ix (created in "Creating an Index: Example") so that the bytes of the index block are stored in reverse order:

ALTER INDEX ord_customer_ix REBUILD REVERSE;
--Rebuilding an Index in Parallel: Example 
--The following statement causes the index to be rebuilt from the existing index by using parallel execution processes to scan the old and to build the new index:

ALTER INDEX ord_customer_ix REBUILD PARALLEL;
--Modifying Real Index Attributes: Example 
--The following statement alters the oe.cust_lname_ix index so that future data blocks within this index use 5 initial transaction entries:

ALTER INDEX oe.cust_lname_ix  
    INITRANS 5;
--If the oe.cust_lname_ix index were partitioned, then this statement would also alter the default attributes of future partitions of the index. Partitions added in the future would then use 5 initial transaction entries and an incremental extent of 100K.

--Enabling Parallel Queries: Example 
--The following statement sets the parallel attributes for index upper_ix (created in "Creating a Function-Based Index: Example") so that scans on the index will be parallelized:

ALTER INDEX upper_ix PARALLEL;
--Renaming an Index: Example 
--The following statement renames an index:

ALTER INDEX upper_ix RENAME TO upper_name_ix;
--Marking an Index Unusable: Examples 
--The following statements use the cost_ix index, which was created in "Creating a Range-Partitioned Global Index: Example". Partition p1 of that index was dropped in "Dropping an Index Partition: Example". The first statement marks index partition p2 as UNUSABLE:

ALTER INDEX cost_ix
   MODIFY PARTITION p2 UNUSABLE;
--The next statement marks the entire index cost_ix as UNUSABLE:

ALTER INDEX cost_ix UNUSABLE;
--Rebuilding Unusable Index Partitions: Example 
--The following statements rebuild partitions p2 and p3 of the cost_ix index, making the index once more usable: The rebuilding of partition p3 will not be logged:

ALTER INDEX cost_ix 
   REBUILD PARTITION p2;
ALTER INDEX cost_ix
   REBUILD PARTITION p3 NOLOGGING;
--Changing MAXEXTENTS: Example 
--The following statement changes the maximum number of extents for partition p3 and changes the logging attribute:

/* This example will fail if the tablespace in which partition p3
   resides is locally managed.
*/
ALTER INDEX cost_ix MODIFY PARTITION p3
   STORAGE(MAXEXTENTS 30) LOGGING;
--Renaming an Index Partition: Example 
--The following statement renames an index partition of the cost_ix index (created in "Creating a Range-Partitioned Global Index: Example"):

ALTER INDEX cost_ix
   RENAME PARTITION p3 TO p3_Q3;
--Splitting a Partition: Example 
--The following statement splits partition p2 of index cost_ix (created in "Creating a Range-Partitioned Global Index: Example") into p2a and p2b:

ALTER INDEX cost_ix
   SPLIT PARTITION p2 AT (1500) 
   INTO ( PARTITION p2a TABLESPACE tbs_01 LOGGING,
          PARTITION p2b TABLESPACE tbs_02);
--Dropping an Index Partition: Example 
--The following statement drops index partition p1 from the cost_ix index:

ALTER INDEX cost_ix
   DROP PARTITION p1;
--Modifying Default Attributes: Example  
--The following statement alters the default attributes of local partitioned index prod_idx, which was created in "Creating an Index on a Hash-Partitioned Table: Example". Partitions added in the future will use 5 initial transaction entries:

ALTER INDEX prod_idx
      MODIFY DEFAULT ATTRIBUTES INITRANS 5;
