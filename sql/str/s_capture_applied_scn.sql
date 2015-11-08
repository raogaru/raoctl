-- TITLE1: Capture Applied SCN
-- TITLE2:Determining the Applied SCN for All Capture Processes in a Database
-- DESC: The applied system change number (SCN) for a capture process is the SCN of the most recent message dequeued by the relevant apply processes. All changes below this applied SCN have been dequeued by all apply processes that apply changes captured by the capture process.

COLUMN CAPTURE_NAME HEADING 'Capture Process Name' FORMAT A30
COLUMN APPLIED_SCN HEADING 'Applied SCN' FORMAT 99999999999

SELECT CAPTURE_NAME, APPLIED_SCN FROM DBA_CAPTURE;
