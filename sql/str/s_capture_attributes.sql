-- TITLE1: Capture Extra Attributes 
-- TITLE2:Viewing the Extra Attributes Captured by Implicit Capture
-- DESC: You can use the INCLUDE_EXTRA_ATTRIBUTE procedure in the DBMS_CAPTURE_ADM package to instruct a capture process or synchronous capture to capture one or more extra attributes and include the extra attributes in LCRs. 

COLUMN CAPTURE_NAME HEADING 'Capture Process or|Synchronous Capture' FORMAT A20
COLUMN ATTRIBUTE_NAME HEADING 'Attribute Name' FORMAT A15
COLUMN INCLUDE HEADING 'Include Attribute in LCRs?' FORMAT A30

SELECT CAPTURE_NAME, ATTRIBUTE_NAME, INCLUDE 
  FROM DBA_CAPTURE_EXTRA_ATTRIBUTES
  ORDER BY CAPTURE_NAME;
