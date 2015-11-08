-- TITLE1: Rule Current Condition 
-- TITLE2: Displaying the Current Condition for a Rule
-- DESC:

SET LONG  8000
SET PAGES 8000
SELECT RULE_CONDITION "Current Rule Condition"
  FROM DBA_STREAMS_RULES 
ORDER BY RULE_OWNER,RULE_NAME  ;
        
