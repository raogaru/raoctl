-- TITLE1:Apply Reader Servers
-- TITLE2: Displaying Information About the Reader Server for Each Apply Process
-- DESC: The reader server for an apply process dequeues messages from the queue. The reader server is a process that computes dependencies between LCRs and assembles messages into transactions. The reader server then returns the assembled transactions to the coordinator, which assigns them to idle apply servers.

COLUMN APPLY_NAME HEADING 'Apply Process|Name' FORMAT A15
COLUMN APPLY_CAPTURED HEADING 'Dequeues Captured|Messages?' FORMAT A17
COLUMN PROCESS_NAME HEADING 'Process|Name' FORMAT A7
COLUMN STATE HEADING 'State' FORMAT A17
COLUMN TOTAL_MESSAGES_DEQUEUED HEADING 'Total Messages|Dequeued' FORMAT 99999999

SELECT r.APPLY_NAME,
       ap.APPLY_CAPTURED,
       SUBSTR(s.PROGRAM,INSTR(s.PROGRAM,'(')+1,4) PROCESS_NAME,
       r.STATE,
       r.TOTAL_MESSAGES_DEQUEUED
       FROM V$STREAMS_APPLY_READER r, V$SESSION s, DBA_APPLY ap 
       WHERE r.SID = s.SID AND 
             r.SERIAL# = s.SERIAL# AND 
             r.APPLY_NAME = ap.APPLY_NAME;
