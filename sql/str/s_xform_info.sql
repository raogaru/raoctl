-- TITLE1:Rule-Based Transformations
-- TITLE2: Displaying Information About All Rule-Based Transformations
-- DESC: SUBSET RULE is displayed for subset rules, which use internal rule-based transformations.  DECLARATIVE TRANSFORMATION is displayed for declarative rule-based transformations.  CUSTOM TRANSFORMATION is displayed for custom rule-based transformations. 

COLUMN RULE_OWNER HEADING 'Rule Owner' FORMAT A20
COLUMN RULE_NAME HEADING 'Rule Name' FORMAT A20
COLUMN TRANSFORM_TYPE HEADING 'Transformation Type' FORMAT A30

SELECT RULE_OWNER, 
       RULE_NAME, 
       TRANSFORM_TYPE
  FROM DBA_STREAMS_TRANSFORMATIONS;
