-- TITLE1:Declarative Rule-Based Transformations
-- TITLE2: Displaying Declarative Rule-Based Transformations
-- DESC: A declarative rule-based transformation is a rule-based transformation that covers one of a common set of transformation scenarios for row LCRs. Declarative rule-based transformations are run internally without using PL/SQL.  Declarative transform types are : ADD COLUMN, DELETE COLUMN, KEEP COLUMNS, RENAME COLUMN, RENAME SCHEMA, and RENAME TABLE.

COLUMN RULE_OWNER HEADING 'Rule Owner' FORMAT A15
COLUMN RULE_NAME HEADING 'Rule Name' FORMAT A15
COLUMN DECLARATIVE_TYPE HEADING 'Declarative|Type' FORMAT A15
COLUMN PRECEDENCE HEADING 'Precedence' FORMAT 99999
COLUMN STEP_NUMBER HEADING 'Step Number' FORMAT 99999

SELECT RULE_OWNER, 
       RULE_NAME, 
       DECLARATIVE_TYPE,
       PRECEDENCE,
       STEP_NUMBER
  FROM DBA_STREAMS_TRANSFORMATIONS
  WHERE TRANSFORM_TYPE = 'DECLARATIVE TRANSFORMATION';
