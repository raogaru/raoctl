-- TITLE1: Apply Transactions Msg Spills
-- TITLE2: Transaction currently being applied for which the apply process has spilled messages
-- DESC: If the txn_lcr_spill_threshold apply process parameter is set to a value other than INFINITE, then an apply process can spill messages from memory to hard disk when the number of messages in a transaction exceeds the specified number.

COLUMN APPLY_NAME HEADING 'Apply Name' FORMAT A20
COLUMN 'Transaction ID' HEADING 'Transaction ID' FORMAT A15
COLUMN FIRST_SCN HEADING 'First SCN'   FORMAT 99999999
COLUMN MESSAGE_COUNT HEADING 'Message Count' FORMAT 99999999
 
SELECT APPLY_NAME,
       XIDUSN ||'.'|| 
       XIDSLT ||'.'||
       XIDSQN "Transaction ID",
       FIRST_SCN,
       MESSAGE_COUNT
  FROM DBA_APPLY_SPILL_TXN;
