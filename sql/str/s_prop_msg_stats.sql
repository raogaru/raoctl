-- TITLE1: Propagation Message Stats
-- TITLE2: Determining the Total Number of Messages and Bytes Propagated

-- DESC: A propagation can be queue-to-queue or queue-to-database link (queue-to-dblink). A queue-to-queue propagation always has its own exclusive propagation job to propagate messages from the source queue to the destination queue. Because each propagation job has its own propagation schedule, the propagation schedule of each queue-to-queue propagation can be managed separately. All queue-to-dblink propagations that share the same database link have a single propagation schedule.

COLUMN PROPAGATION_NAME HEADING 'Propagation|Name' FORMAT A20
COLUMN TOTAL_TIME HEADING 'Total Time|Executing|in Seconds' FORMAT 999999
COLUMN TOTAL_NUMBER HEADING 'Total Messages|Propagated' FORMAT 999999999
COLUMN TOTAL_BYTES HEADING 'Total Bytes|Propagated' FORMAT 9999999999999

SELECT p.PROPAGATION_NAME, s.TOTAL_TIME, s.TOTAL_NUMBER, s.TOTAL_BYTES 
  FROM DBA_QUEUE_SCHEDULES s, DBA_PROPAGATION p
  WHERE s.DESTINATION LIKE '%' || p.DESTINATION_DBLINK
    AND s.SCHEMA = p.SOURCE_QUEUE_OWNER
    AND s.QNAME  = p.SOURCE_QUEUE_NAME
    AND s.MESSAGE_DELIVERY_MODE = 'BUFFERED';
