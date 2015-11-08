-- TITLE1:Propagation Receivers
-- TITLE2: Displaying Information About Propagation Receivers
-- DESC: A propagation receiver enqueues messages sent by propagation senders into a destination queue. 

COLUMN PROPAGATION_NAME HEADING 'Propagation|Name' FORMAT A15
COLUMN SESSION_ID HEADING 'Session ID' FORMAT 999999
COLUMN SERIAL# HEADING 'Session|Serial|Number' FORMAT 999999
COLUMN SPID HEADING 'Operating|System|Process ID' FORMAT 999999
COLUMN STATE HEADING 'State' FORMAT A16
 
SELECT PROPAGATION_NAME, 
       SESSION_ID, 
       SERIAL#, 
       SPID, 
       STATE
  FROM V$PROPAGATION_RECEIVER;
