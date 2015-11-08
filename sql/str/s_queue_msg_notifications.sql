-- TITLE1: Message Notifications
-- TITLE2: Displaying Message Notifications
-- DESC: You can configure a message notification to send a notification when a message that can be dequeued by a messaging client is enqueued into a queue. The notification can be sent to an e-mail address, to an HTTP URL, or to a PL/SQL procedure. 

COLUMN STREAMS_NAME HEADING 'Messaging|Client' FORMAT A10
COLUMN QUEUE_OWNER HEADING 'Queue|Owner' FORMAT A5
COLUMN QUEUE_NAME HEADING 'Queue Name' FORMAT A20
COLUMN NOTIFICATION_TYPE HEADING 'Notification|Type' FORMAT A15
COLUMN NOTIFICATION_ACTION HEADING 'Notification|Action' FORMAT A25

SELECT STREAMS_NAME, 
       QUEUE_OWNER, 
       QUEUE_NAME, 
       NOTIFICATION_TYPE, 
       NOTIFICATION_ACTION 
  FROM DBA_STREAMS_MESSAGE_CONSUMERS
  WHERE NOTIFICATION_TYPE IS NOT NULL;
