-- TITLE1: Rule Modified Conditions
-- TITLE2: Displaying Modified Rule Conditions for Oracle Streams Rules
-- DESC: It is possible to modify the rule condition of an Oracle Streams rule. These modifications can change the behavior of the Oracle Streams clients using the Oracle Streams rule. In addition, some modifications can degrade rule evaluation performance.

COLUMN RULE_NAME HEADING 'Rule Name' FORMAT A12
COLUMN ORIGINAL_RULE_CONDITION HEADING 'Original Rule Condition' FORMAT A33
COLUMN RULE_CONDITION HEADING 'Current Rule Condition' FORMAT A33

SET LONG  8000
SET PAGES 8000
SELECT RULE_NAME, ORIGINAL_RULE_CONDITION, RULE_CONDITION
  FROM DBA_STREAMS_RULES 
  WHERE SAME_RULE_CONDITION = 'NO';
