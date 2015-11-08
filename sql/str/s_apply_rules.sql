-- TITLE1: Apply Rules
-- TITLE2: Viewing Rules that Specify a Destination Queue on Apply
-- DESC: You can specify a destination queue for a rule using the SET_ENQUEUE_DESTINATION procedure in the DBMS_APPLY_ADM package. If an apply process has such a rule in its positive rule set, and a message satisfies the rule, then the apply process enqueues the message into the destination queue.

COLUMN RULE_OWNER HEADING 'Rule Owner' FORMAT A15
COLUMN RULE_NAME HEADING 'Rule Name' FORMAT A15
COLUMN DESTINATION_QUEUE_NAME HEADING 'Destination Queue' FORMAT A30

SELECT RULE_OWNER, RULE_NAME, DESTINATION_QUEUE_NAME
  FROM DBA_APPLY_ENQUEUE;
