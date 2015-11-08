-- TITLE1: Apply Latency
-- TITLE2: Determining Capture to Dequeue Latency for a Message
-- DESC: For captured LCRs, the latency is the amount of time between when the message was created at a source database and when the message was dequeued by the apply process. For any other type of message, the latency is the amount of time between when the message enqueued at the local database and when the message was dequeued by the apply process.

COLUMN APPLY_NAME HEADING 'Apply Process|Name' FORMAT A17
COLUMN LATENCY HEADING 'Latency|in|Seconds' FORMAT 999999
COLUMN CREATION HEADING 'Message Creation' FORMAT A17
COLUMN LAST_DEQUEUE HEADING 'Last Dequeue Time' FORMAT A20
COLUMN DEQUEUED_MESSAGE_NUMBER HEADING 'Dequeued|Message Number' FORMAT 9999999999

SELECT APPLY_NAME,
     (DEQUEUE_TIME-DEQUEUED_MESSAGE_CREATE_TIME)*86400 LATENCY,
     TO_CHAR(DEQUEUED_MESSAGE_CREATE_TIME,'HH24:MI:SS MM/DD/YY') CREATION,
     TO_CHAR(DEQUEUE_TIME,'HH24:MI:SS MM/DD/YY') LAST_DEQUEUE,
     DEQUEUED_MESSAGE_NUMBER  
  FROM V$STREAMS_APPLY_READER;
