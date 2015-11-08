-- TITLE1:
-- TITLE2:Determining the Source Queue and Destination Queue for Each Propagation
-- DESC:

COLUMN PROPAGATION_NAME HEADING 'Propagation|Name' FORMAT A20
COLUMN SOURCE_QUEUE_OWNER HEADING 'Source|Queue|Owner' FORMAT A10
COLUMN 'Source Queue' HEADING 'Source|Queue' FORMAT A15
COLUMN DESTINATION_QUEUE_OWNER HEADING 'Dest|Queue|Owner'   FORMAT A10
COLUMN 'Destination Queue' HEADING 'Destination|Queue' FORMAT A15

SELECT p.PROPAGATION_NAME,
       p.SOURCE_QUEUE_OWNER,
       p.SOURCE_QUEUE_NAME ||'@'|| 
       g.GLOBAL_NAME "Source Queue",
       p.DESTINATION_QUEUE_OWNER,
       p.DESTINATION_QUEUE_NAME ||'@'|| 
       p.DESTINATION_DBLINK "Destination Queue"
  FROM DBA_PROPAGATION p, GLOBAL_NAME g;
