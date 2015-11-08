-- TITLE1:
-- TITLE2:Displaying Performance Statistics for Propagations that Send Buffered Messages
-- DESC: The query in this section displays the amount of time that a propagation sending buffered messages spends performing various tasks. Each propagation sends messages from the source queue to the destination queue. 

COLUMN PROPAGATION_NAME HEADING 'Propagation' FORMAT A15
COLUMN QUEUE_NAME HEADING 'Queue|Name' FORMAT A13
COLUMN DBLINK HEADING 'Database|Link' FORMAT A9
COLUMN ELAPSED_DEQUEUE_TIME HEADING 'Dequeue|Time' FORMAT 99999999.99
COLUMN ELAPSED_PICKLE_TIME HEADING 'Pickle|Time' FORMAT 99999999.99
COLUMN ELAPSED_PROPAGATION_TIME HEADING 'Propagation|Time' FORMAT 99999999.99

SELECT p.PROPAGATION_NAME,
       s.QUEUE_NAME,
       s.DBLINK,
       (s.ELAPSED_DEQUEUE_TIME / 100) ELAPSED_DEQUEUE_TIME,
       (s.ELAPSED_PICKLE_TIME / 100) ELAPSED_PICKLE_TIME,
       (s.ELAPSED_PROPAGATION_TIME / 100) ELAPSED_PROPAGATION_TIME
  FROM DBA_PROPAGATION p, V$PROPAGATION_SENDER s
  WHERE p.SOURCE_QUEUE_OWNER      = s.QUEUE_SCHEMA AND
        p.SOURCE_QUEUE_NAME       = s.QUEUE_NAME AND
        p.DESTINATION_QUEUE_OWNER = s.DST_QUEUE_SCHEMA AND
        p.DESTINATION_QUEUE_NAME  = s.DST_QUEUE_NAME;
