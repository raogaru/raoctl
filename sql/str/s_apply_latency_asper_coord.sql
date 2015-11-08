-- TITLE1: Apply Latency as per Coordinator
-- TITLE2: V$STREAMS_APPLY_COORDINATOR Query for Latency
-- DESC: Run the following query to display the capture to apply latency using the V$STREAMS_APPLY_COORDINATOR view for a captured LCR or a persistent LCR for each apply process:

COLUMN APPLY_NAME HEADING 'Apply Process|Name' FORMAT A13
COLUMN 'Latency in Seconds' FORMAT 999999
COLUMN 'Message Creation' FORMAT A17
COLUMN 'Apply Time' FORMAT A17
COLUMN HWM_MESSAGE_NUMBER HEADING 'Applied|Message|Number' FORMAT 9999999999

SELECT APPLY_NAME,
     (HWM_TIME-HWM_MESSAGE_CREATE_TIME)*86400 "Latency in Seconds",
     TO_CHAR(HWM_MESSAGE_CREATE_TIME,'HH24:MI:SS MM/DD/YY') 
        "Message Creation",
     TO_CHAR(HWM_TIME,'HH24:MI:SS MM/DD/YY') "Apply Time",
     HWM_MESSAGE_NUMBER  
  FROM V$STREAMS_APPLY_COORDINATOR;
