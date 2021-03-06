-- TITLE1: Rule List2
-- TITLE2: Displaying All of the Rules in a Rule Set
-- DESC:

COLUMN RULE_OWNER HEADING 'Rule Owner' FORMAT A10
COLUMN RULE_NAME HEADING 'Rule Name' FORMAT A20
COLUMN RULE_EVALUATION_CONTEXT_NAME HEADING 'Eval Context Name' FORMAT A27
COLUMN RULE_EVALUATION_CONTEXT_OWNER HEADING 'Eval Context|Owner' FORMAT A11

SELECT R.RULE_OWNER, 
       R.RULE_NAME, 
       R.RULE_EVALUATION_CONTEXT_NAME,
       R.RULE_EVALUATION_CONTEXT_OWNER
  FROM DBA_RULES R, DBA_RULE_SET_RULES RS 
WHERE RS.RULE_NAME = R.RULE_NAME AND 
      RS.RULE_OWNER = R.RULE_OWNER
ORDER BY RS.RULE_SET_OWNER , RS.RULE_SET_NAME;
