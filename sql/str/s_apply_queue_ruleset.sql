-- TITLE1:Apply List
-- TITLE2: Determining the Queue, Rule Sets, and Status for Each Apply Process
-- DESC:

COLUMN APPLY_NAME HEADING 'Apply|Process|Name' FORMAT A15
COLUMN APPLY_CAPTURED HEADING 'Applies Captured LCRs?' FORMAT A22
COLUMN APPLY_USER HEADING 'Apply User' FORMAT A20
COLUMN QUEUE_NAME HEADING 'Apply|Process|Queue' FORMAT A15
COLUMN RULE_SET_NAME HEADING 'Positive|Rule Set' FORMAT A15
COLUMN NEGATIVE_RULE_SET_NAME HEADING 'Negative|Rule Set' FORMAT A15
COLUMN STATUS HEADING 'Apply|Process|Status' FORMAT A15

SELECT APPLY_NAME, APPLY_CAPTURED, APPLY_USER
       QUEUE_NAME, RULE_SET_NAME, NEGATIVE_RULE_SET_NAME, STATUS
  FROM DBA_APPLY;