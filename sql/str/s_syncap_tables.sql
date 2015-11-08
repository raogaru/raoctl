-- TITLE1:Synchronous Capture Tables
-- TITLE2:Displaying the Tables For Which Synchronous Capture Captures Changes
-- DESC: The DBA_SYNC_CAPTURE_TABLES view displays the tables whose DML changes are captured by any synchronous capture in the local database. The DBA_STREAMS_TABLE_RULES view has information about each synchronous capture name and the rules used by each synchronous capture. You can display the following information by running the query in this section:

COLUMN STREAMS_NAME HEADING 'Synchronous|Capture Name' FORMAT A15
COLUMN RULE_NAME HEADING 'Rule Name' FORMAT A15
COLUMN SUBSETTING_OPERATION HEADING 'Subsetting|Operation' FORMAT A10
COLUMN TABLE_OWNER HEADING 'Table|Owner' FORMAT A10
COLUMN TABLE_NAME HEADING 'Table Name' FORMAT A15
COLUMN ENABLED HEADING 'Enabled?' FORMAT A8

SELECT r.STREAMS_NAME, 
       r.RULE_NAME, 
       r.SUBSETTING_OPERATION,
       t.TABLE_OWNER, 
       t.TABLE_NAME, 
       t.ENABLED
   FROM DBA_STREAMS_TABLE_RULES r,
        DBA_SYNC_CAPTURE_TABLES t
   WHERE r.STREAMS_TYPE = 'SYNC_CAPTURE' AND
         r.TABLE_OWNER  = t.TABLE_OWNER AND
         r.TABLE_NAME   = t.TABLE_NAME;
