-- TITLE1:
-- TITLE2: Viewing the Messaging Clients in a Database
-- DESC:

COLUMN STREAMS_NAME HEADING 'Messaging|Client' FORMAT A25
COLUMN QUEUE_OWNER HEADING 'Queue|Owner' FORMAT A10
COLUMN QUEUE_NAME HEADING 'Queue Name' FORMAT A18
COLUMN RULE_SET_NAME HEADING 'Positive|Rule Set' FORMAT A11
COLUMN NEGATIVE_RULE_SET_NAME HEADING 'Negative|Rule Set' FORMAT A11

SELECT STREAMS_NAME, 
       QUEUE_OWNER, 
       QUEUE_NAME, 
       RULE_SET_NAME, 
       NEGATIVE_RULE_SET_NAME 
  FROM DBA_STREAMS_MESSAGE_CONSUMERS;