-- TITLE1:
-- TITLE2: Streams Alert History
-- DESC:

COLUMN REASON HEADING 'Reason for Alert' FORMAT A35
COLUMN SUGGESTED_ACTION HEADING 'Suggested Response' FORMAT A35
 
SELECT REASON, SUGGESTED_ACTION 
   FROM DBA_ALERT_HISTORY 
   WHERE MODULE_ID LIKE '%STREAMS%';
