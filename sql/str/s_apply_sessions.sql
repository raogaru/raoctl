-- TITLE1: Apply Sessions
-- TITLE2: Displaying Session Information About Each Apply Process
-- DESC:

COLUMN ACTION HEADING 'Apply Process Component' FORMAT A30
COLUMN SID HEADING 'Session ID' FORMAT 99999
COLUMN SERIAL# HEADING 'Session|Serial|Number' FORMAT 99999999
COLUMN PROCESS HEADING 'Operating System|Process Number' FORMAT A17
COLUMN PROCESS_NAME HEADING 'Process|Names' FORMAT A7
 
SELECT /*+PARAM('_module_action_old_length',0)*/ ACTION,
       SID,
       SERIAL#,
       PROCESS,
       SUBSTR(PROGRAM,INSTR(PROGRAM,'(')+1,4) PROCESS_NAME
  FROM V$SESSION
  WHERE MODULE ='Streams' AND
        ACTION LIKE '%Apply%';
