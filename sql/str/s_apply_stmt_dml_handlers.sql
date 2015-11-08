-- TITLE1: Statement DML Handlers
-- TITLE2: Displaying the Statement DML Handlers Used by Each Apply Process
-- DESC: When you specify a statement DML handler using the ADD_STMT_HANDLER procedure in the DBMS_APPLY_ADM package at a destination database, you can either specify that the handler runs for a specific apply process or that the handler is a general handler that runs for all apply processes in the database that apply changes locally. If a statement DML handler for an operation on a table is used by a specific apply process, and another statement DML handler is a general handler for the same operation on the same table, then both handlers are invoked when an apply process dequeues a row LCR with the operation on the table. Each statement DML handler receives the original row LCR, and the statement DML handlers can execute in any order.

COLUMN OBJECT_OWNER HEADING 'Table|Owner' FORMAT A10
COLUMN OBJECT_NAME HEADING 'Table Name' FORMAT A10
COLUMN OPERATION_NAME HEADING 'Operation' FORMAT A9
COLUMN APPLY_NAME HEADING 'Apply Process|Name' FORMAT A15
COLUMN HANDLER_NAME HEADING 'Statement DML|Handler Name' FORMAT A30

SELECT OBJECT_OWNER, 
       OBJECT_NAME, 
       OPERATION_NAME, 
       APPLY_NAME,
       HANDLER_NAME
  FROM DBA_APPLY_DML_HANDLERS
  WHERE HANDLER_TYPE='STMT HANDLER'
  ORDER BY OBJECT_OWNER, OBJECT_NAME, OPERATION_NAME;
