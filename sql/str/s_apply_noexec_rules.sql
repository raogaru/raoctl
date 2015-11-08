-- TITLE1: Apply NoExecution Rules
-- TITLE2: Viewing Rules that Specify No Execution on Apply
-- DESC: You can specify an execution directive for a rule using the SET_EXECUTE procedure in the DBMS_APPLY_ADM package. An execution directive controls whether a message that satisfies the specified rule is executed by an apply process. If an apply process has a rule in its positive rule set with NO for its execution directive, and a message satisfies the rule, then the apply process does not execute the message and does not send the message to any apply handler.

COLUMN RULE_OWNER HEADING 'Rule Owner' FORMAT A20
COLUMN RULE_NAME HEADING 'Rule Name' FORMAT A20

SELECT RULE_OWNER, RULE_NAME
  FROM DBA_APPLY_EXECUTE
  WHERE EXECUTE_EVENT = 'NO';
