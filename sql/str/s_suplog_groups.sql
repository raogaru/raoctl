-- TITLE1: Supplemental Log Groups
-- TITLE2:Displaying Supplemental Log Groups at a Source Database
-- DESC:

COLUMN LOG_GROUP_NAME HEADING 'Log Group' FORMAT A20
COLUMN TABLE_NAME HEADING 'Table' FORMAT A15
COLUMN ALWAYS HEADING 'Conditional or|Unconditional' FORMAT A14
COLUMN LOG_GROUP_TYPE HEADING 'Type of Log Group' FORMAT A20

SELECT 
    LOG_GROUP_NAME, 
    TABLE_NAME, 
    DECODE(ALWAYS,
             'ALWAYS', 'Unconditional',
             'CONDITIONAL', 'Conditional') ALWAYS,
    LOG_GROUP_TYPE
  FROM DBA_LOG_GROUPS;
