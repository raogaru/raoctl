-- TITLE1:Propagation Senders
-- TITLE2: Displaying Information About Propagation Senders
-- DESC: A propagation sender sends messages from a source queue to a destination queue.

COLUMN PROPAGATION_NAME HEADING 'Propagation|Name' FORMAT A11
COLUMN SESSION_ID HEADING 'Session ID' FORMAT 9999
COLUMN SERIAL# HEADING 'Session|Serial Number' FORMAT 9999
COLUMN SPID HEADING 'Operating System|Process ID' FORMAT A24
COLUMN STATE HEADING 'State' FORMAT A16

SELECT p.PROPAGATION_NAME, 
       s.SESSION_ID, 
       s.SERIAL#, 
       s.SPID, 
       s.STATE
  FROM DBA_PROPAGATION p, V$PROPAGATION_SENDER s
  WHERE p.SOURCE_QUEUE_OWNER      = s.QUEUE_SCHEMA AND
        p.SOURCE_QUEUE_NAME       = s.QUEUE_NAME AND
        p.DESTINATION_QUEUE_OWNER = s.DST_QUEUE_SCHEMA AND
        p.DESTINATION_QUEUE_NAME  = s.DST_QUEUE_NAME;
