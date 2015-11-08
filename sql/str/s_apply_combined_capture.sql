-- TITLE1: Apply combined Captures 
-- TITLE2: Determining Which Apply Processes Use Combined Capture and Apply
-- DESC: A combined capture and apply environment is efficient because the capture process acts as the propagation sender that sends logical change records (LCRs) directly to the propagation receiver.

COLUMN APPLY_NAME HEADING 'Apply Process Name' FORMAT A20
COLUMN PROXY_SID HEADING 'Propagation|Receiver|Session ID' FORMAT 99999999
COLUMN PROXY_SERIAL HEADING 'Propagation|ReceiverSerial|Number' FORMAT 99999999
COLUMN PROXY_SPID HEADING 'Propagation|Receiver|Process ID' FORMAT 99999999999
COLUMN CAPTURE_BYTES_RECEIVED HEADING 'Number of|Bytes Received' FORMAT 9999999999

SELECT APPLY_NAME,
       PROXY_SID,
       PROXY_SERIAL,
       PROXY_SPID,
       CAPTURE_BYTES_RECEIVED
   FROM V$STREAMS_APPLY_READER;
