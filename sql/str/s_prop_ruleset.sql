-- TITLE1:
-- TITLE2: Determining the Rule Sets for Each Propagation
-- DESC:

COLUMN PROPAGATION_NAME HEADING 'Propagation|Name' FORMAT A20
COLUMN RULE_SET_OWNER HEADING 'Positive|Rule Set|Owner' FORMAT A10
COLUMN RULE_SET_NAME HEADING 'Positive Rule|Set Name' FORMAT A15
COLUMN NEGATIVE_RULE_SET_OWNER HEADING 'Negative|Rule Set|Owner' FORMAT A10
COLUMN NEGATIVE_RULE_SET_NAME HEADING 'Negative Rule|Set Name' FORMAT A15

SELECT PROPAGATION_NAME, 
       RULE_SET_OWNER, 
       RULE_SET_NAME, 
       NEGATIVE_RULE_SET_OWNER, 
       NEGATIVE_RULE_SET_NAME
  FROM DBA_PROPAGATION;
