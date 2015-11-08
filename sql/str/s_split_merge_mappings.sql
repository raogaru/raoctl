-- TITLE1:
-- TITLE2:Displaying the Names of the Original and Cloned Oracle Streams Components
-- DESC: The query in this section shows the following information about the Oracle Streams components that are involved in a split and merge operation:

COLUMN ORIGINAL_CAPTURE_NAME HEADING 'Original|Capture|Process' FORMAT A15
COLUMN CLONED_CAPTURE_NAME HEADING 'Cloned|Capture|Process' FORMAT A15
COLUMN ORIGINAL_STREAMS_NAME HEADING 'Original|Streams|Name' FORMAT A15
COLUMN CLONED_STREAMS_NAME HEADING 'Cloned|Streams|Name' FORMAT A15
COLUMN STREAMS_TYPE HEADING 'Streams|Type' FORMAT A11
 
SELECT ORIGINAL_CAPTURE_NAME,
       CLONED_CAPTURE_NAME,
       ORIGINAL_STREAMS_NAME,
       CLONED_STREAMS_NAME,
       STREAMS_TYPE
 FROM DBA_STREAMS_SPLIT_MERGE;
