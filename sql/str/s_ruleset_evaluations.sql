-- TITLE1: Ruleset Evaluations
-- TITLE2: Displaying Information About Evaluations for Each Rule Set
-- DESC: You can query the V$RULE_SET dynamic performance view to display information about evaluations for each rule set since the database instance last started. The query in this section contains the following information about each rule set in a database:

COLUMN OWNER HEADING 'Rule Set|Owner' FORMAT A9
COLUMN NAME HEADING 'Rule Set|Name' FORMAT A11
COLUMN EVALUATIONS HEADING 'Total|Evaluations' FORMAT 99999999
COLUMN SQL_EXECUTIONS HEADING 'SQL|Executions' FORMAT 99999999
COLUMN SQL_FREE_EVALUATIONS HEADING 'SQL Free|Evaluations' FORMAT 99999999
COLUMN TRUE_RULES HEADING 'True|Rules' FORMAT 999999999
COLUMN MAYBE_RULES HEADING 'Maybe|Rules' FORMAT 99999999

SELECT OWNER, 
       NAME, 
       EVALUATIONS,
       SQL_EXECUTIONS,
       SQL_FREE_EVALUATIONS,
       TRUE_RULES,
       MAYBE_RULES
  FROM V$RULE_SET;
