-- TITLE1:Supplemental Logging Schemas
-- TITLE2:Displaying Supplemental Logging Enabled by PREPARE_SCHEMA_INSTANTIATION
-- DESC:

COLUMN SCHEMA_NAME HEADING 'Schema Name' FORMAT A20
COLUMN log_pk HEADING 'Primary Key|Supplemental|Logging' FORMAT A12
COLUMN log_fk HEADING 'Foreign Key|Supplemental|Logging' FORMAT A12
COLUMN log_ui HEADING 'Unique|Supplemental|Logging' FORMAT A12
COLUMN log_all HEADING 'All Columns|Supplemental|Logging' FORMAT A12

SELECT SCHEMA_NAME,
       SUPPLEMENTAL_LOG_DATA_PK log_pk, 
       SUPPLEMENTAL_LOG_DATA_FK log_fk,
       SUPPLEMENTAL_LOG_DATA_UI log_ui,
       SUPPLEMENTAL_LOG_DATA_ALL log_all
  FROM DBA_CAPTURE_PREPARED_SCHEMAS;
