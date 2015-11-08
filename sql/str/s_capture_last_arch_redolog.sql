-- TITLE1:
-- TITLE2:Displaying the Last Archived Redo Entry Available to Each Capture Process
-- DESC: For a local capture process, the last archived redo entry available is the last entry from the online redo log flushed to an archived log file. For a downstream capture process, the last archived redo entry available is the redo entry with the most recent system change number (SCN) in the last archived log file added to the LogMiner session used by the capture process.

COLUMN CAPTURE_NAME HEADING 'Capture|Name' FORMAT A20
COLUMN LOGMINER_ID HEADING 'LogMiner ID' FORMAT 9999
COLUMN AVAILABLE_MESSAGE_NUMBER HEADING 'Highest|Available SCN' FORMAT 9999999999
COLUMN AVAILABLE_MESSAGE_CREATE_TIME HEADING 'Time of|Highest|Available SCN'

SELECT CAPTURE_NAME,
       LOGMINER_ID,
       AVAILABLE_MESSAGE_NUMBER,
       TO_CHAR(AVAILABLE_MESSAGE_CREATE_TIME, 'HH24:MI:SS MM/DD/YY') 
         AVAILABLE_MESSAGE_CREATE_TIME
  FROM V$STREAMS_CAPTURE;
