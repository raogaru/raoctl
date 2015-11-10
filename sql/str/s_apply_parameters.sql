-- TITLE1:
-- TITLE2: Listing the Parameter Settings for Each Apply Process
-- DESC:

COLUMN APPLY_NAME HEADING 'Apply Process|Name' FORMAT A15
COLUMN PARAMETER HEADING 'Parameter' FORMAT A30
COLUMN VALUE HEADING 'Value' FORMAT A22
COLUMN SET_BY_USER HEADING 'Set by|User?' FORMAT A10

SELECT APPLY_NAME,
       PARAMETER, 
       VALUE,
       SET_BY_USER  
  FROM DBA_APPLY_PARAMETERS 
ORDER BY SET_BY_USER, APPLY_NAME;
