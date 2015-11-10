-- TITLE:Viewing the Databases in the Oracle Streams Environment
COLUMN GLOBAL_NAME HEADING 'Global Name' FORMAT A15
COLUMN LAST_QUERIED HEADING 'Last|Queried'
COLUMN VERSION HEADING 'Version' FORMAT A15
COLUMN COMPATIBILITY HEADING 'Compatibility' FORMAT A15
COLUMN MANAGEMENT_PACK_ACCESS HEADING 'Management Pack' FORMAT A20

SELECT GLOBAL_NAME, LAST_QUERIED, VERSION, COMPATIBILITY, MANAGEMENT_PACK_ACCESS
   FROM DBA_STREAMS_TP_DATABASE;