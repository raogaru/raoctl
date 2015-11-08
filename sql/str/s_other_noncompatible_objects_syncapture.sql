-- TITLE1:
-- TITLE2: Listing Database Objects and Columns Not Compatible with Synchronous Captures
-- DESC: A database object or a column in a table is not compatible with synchronous captures if synchronous captures cannot capture changes to it. For example, synchronous captures cannot capture changes to object tables. Synchronous captures can capture changes to relational tables, but they cannot capture changes to columns of some data types.

COLUMN OWNER HEADING 'Object|Owner' FORMAT A8
COLUMN TABLE_NAME HEADING 'Object Name' FORMAT A20
COLUMN COLUMN_NAME HEADING 'Column Name' FORMAT A20
COLUMN SYNC_CAPTURE_REASON HEADING 'Synchronous|Capture Reason' FORMAT A25
 
SELECT OWNER,
       TABLE_NAME,
       COLUMN_NAME,
       SYNC_CAPTURE_REASON
 FROM DBA_STREAMS_COLUMNS
 WHERE SYNC_CAPTURE_VERSION IS NULL;
