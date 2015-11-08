-- TITLE1:
-- TITLE2: Displaying Custom Rule-Based Transformations
-- DESC: A custom rule-based transformation is a rule-based transformation that requires a user-defined PL/SQL function. 

COLUMN RULE_OWNER HEADING 'Rule Owner' FORMAT A20
COLUMN RULE_NAME HEADING 'Rule Name' FORMAT A15
COLUMN TRANSFORM_FUNCTION_NAME HEADING 'Transformation Function' FORMAT A30
COLUMN CUSTOM_TYPE HEADING 'Type' FORMAT A11
 
SELECT RULE_OWNER, RULE_NAME, TRANSFORM_FUNCTION_NAME, CUSTOM_TYPE
  FROM DBA_STREAMS_TRANSFORM_FUNCTION;
