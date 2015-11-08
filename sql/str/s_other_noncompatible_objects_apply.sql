-- TITLE1:
-- TITLE2: Listing Database Objects and Columns Not Compatible with Apply Processes
-- DESC: A database object or a column in a table is not compatible with apply processes if apply processes cannot apply changes to it. For example, apply processes cannot apply changes to object tables. Apply processes can apply changes to relational tables, but they cannot apply changes to columns of some data types.

COLUMN OWNER HEADING 'Object|Owner' FORMAT A8
COLUMN TABLE_NAME HEADING 'Object Name' FORMAT A20
COLUMN COLUMN_NAME HEADING 'Column Name' FORMAT A20
COLUMN APPLY_REASON HEADING 'Apply Process Reason' FORMAT A25
 
SELECT OWNER,
       TABLE_NAME,
       COLUMN_NAME,
       APPLY_REASON
 FROM DBA_STREAMS_COLUMNS
 WHERE APPLY_VERSION IS NULL;

