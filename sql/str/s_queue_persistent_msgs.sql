-- TITLE1:
-- TITLE2: Determining the Consumer of Each Message in a Persistent Queue
-- DESC: To determine the consumer for each message in a persistent queue, query AQ$queue_table_name in the queue owner's schema, where queue_table_name is the name of the queue table. 

COLUMN MSG_ID HEADING 'Message ID' FORMAT 9999
COLUMN MSG_STATE HEADING 'Message State' FORMAT A13
COLUMN CONSUMER_NAME HEADING 'Consumer' FORMAT A30

SELECT MSG_ID, MSG_STATE, CONSUMER_NAME FROM AQ$OE_Q_TABLE_ANY;
