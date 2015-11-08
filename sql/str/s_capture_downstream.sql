-- TITLE1:Downstream Capture
-- TITLE2:Displaying Information About Each Downstream Capture Process
-- DESC: A downstream capture is a capture process that runs on a database other than the source database. You can display the following information about each downstream capture process in a database by running the query in this section:

COLUMN CAPTURE_NAME HEADING 'Capture|Process|Name' FORMAT A15
COLUMN SOURCE_DATABASE HEADING 'Source|Database' FORMAT A15
COLUMN QUEUE_NAME HEADING 'Capture|Process|Queue' FORMAT A15
COLUMN STATUS HEADING 'Capture|Process|Status' FORMAT A15
COLUMN USE_DATABASE_LINK HEADING 'Uses|Database|Link?' FORMAT A8

SELECT CAPTURE_NAME, 
       SOURCE_DATABASE, 
       QUEUE_NAME, 
       STATUS, 
       USE_DATABASE_LINK
   FROM DBA_CAPTURE
   WHERE CAPTURE_TYPE = 'DOWNSTREAM';
