-- TITLE1:Buffered Queue Message Counts
-- TITLE2: Determining the Number of Messages in Each Buffered Queue
-- DESC:

COLUMN QUEUE_SCHEMA HEADING 'Queue Owner' FORMAT A15
COLUMN QUEUE_NAME HEADING 'Queue Name' FORMAT A15
COLUMN MEM_MSG HEADING 'Messages|in Memory' FORMAT 99999999
COLUMN SPILL_MSGS HEADING 'Messages|Spilled' FORMAT 99999999
COLUMN NUM_MSGS HEADING 'Total Messages|in Buffered Queue' FORMAT 99999999

SELECT QUEUE_SCHEMA, 
       QUEUE_NAME, 
       (NUM_MSGS - SPILL_MSGS) MEM_MSG, 
       SPILL_MSGS, 
       NUM_MSGS
  FROM V$BUFFERED_QUEUES;
