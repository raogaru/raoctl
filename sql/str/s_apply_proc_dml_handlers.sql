-- TITLE1: Procedure DML Handlers
-- TITLE2: Displaying Information About Procedure DML Handlers
-- DESC: When you specify a local procedure DML handler using the SET_DML_HANDLER procedure in the DBMS_APPLY_ADM package at a destination database, you can either specify that the handler runs for a specific apply process or that the handler is a general handler that runs for all apply processes in the database that apply changes locally, when appropriate. A specific procedure DML handler takes precedence over a generic procedure DML handler. A DML handler is run for a specified operation on a specific table.

COLUMN OBJECT_OWNER HEADING 'Table|Owner' FORMAT A11
COLUMN OBJECT_NAME HEADING 'Table Name' FORMAT A15
COLUMN OPERATION_NAME HEADING 'Operation' FORMAT A9
COLUMN USER_PROCEDURE HEADING 'Handler Procedure' FORMAT A25
COLUMN APPLY_NAME HEADING 'Apply Process|Name' FORMAT A15

SELECT OBJECT_OWNER, 
       OBJECT_NAME, 
       OPERATION_NAME, 
       USER_PROCEDURE,
       APPLY_NAME
  FROM DBA_APPLY_DML_HANDLERS
  WHERE ERROR_HANDLER = 'N' AND
        USER_PROCEDURE IS NOT NULL
  ORDER BY OBJECT_OWNER, OBJECT_NAME;
