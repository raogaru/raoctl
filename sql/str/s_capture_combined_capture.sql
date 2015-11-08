-- TITLE1: Combined Captures
-- TITLE2:Determining Which Capture Processes Use Combined Capture and Apply
-- DESC: A combined capture and apply environment is efficient because the capture process acts as the propagation sender, and the buffered queue is optimized to make replication of changes more efficient.

COLUMN CAPTURE_NAME HEADING 'Capture Name' FORMAT A30
COLUMN OPTIMIZATION HEADING 'Optimized?' FORMAT A10

SELECT CAPTURE_NAME, 
       DECODE(OPTIMIZATION,
                0, 'No',
                   'Yes') OPTIMIZATION
  FROM V$STREAMS_CAPTURE;
