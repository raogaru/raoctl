-- TITLE1:Split Merge Jobs
-- TITLE2:Displaying Information About the Split and Merge Jobs
-- DESC:
COLUMN ORIGINAL_CAPTURE_NAME HEADING 'Original|Capture|Process' FORMAT A10
COLUMN JOB_OWNER HEADING 'Job Owner' FORMAT A10
COLUMN JOB_NAME HEADING 'Job Name' FORMAT A15
COLUMN JOB_STATE HEADING 'Job State' FORMAT A15
COLUMN JOB_NEXT_RUN_DATE HEADING 'Job Next|Run Date' FORMAT A20
 
SELECT ORIGINAL_CAPTURE_NAME,
       JOB_OWNER,
       JOB_NAME,
       JOB_STATE,
       JOB_NEXT_RUN_DATE
 FROM DBA_STREAMS_SPLIT_MERGE;