
-- TITLE1:
-- TITLE2: Monitoring the Oracle Streams Pool
-- DESC: The Oracle Streams pool is a portion of memory in the System Global Area (SGA) that is used by Oracle Streams. The Oracle Streams pool stores enqueued messages in memory, and it provides memory for capture processes and apply processes. The Oracle Streams pool always stores LCRs captured by a capture process, and it can store other types of messages that are enqueued manually into a buffered queue.  The Oracle Streams pool size is managed automatically when the MEMORY_TARGET, MEMORY_MAX_TARGET, or SGA_TARGET initialization parameter is set to a nonzero value. If these parameters are all set to 0 (zero), then you can specify the size of the Oracle Streams pool in bytes using the STREAMS_POOL_SIZE initialization parameter. In this case, the V$STREAMS_POOL_ADVICE dynamic performance view provides information about an appropriate setting for the STREAMS_POOL_SIZE initialization parameter.

COLUMN STREAMS_POOL_SIZE_FOR_ESTIMATE HEADING 'Oracle Streams Pool Size|for Estimate(MB)' FORMAT 999999999999
COLUMN STREAMS_POOL_SIZE_FACTOR HEADING 'Oracle Streams Pool|Size|Factor' FORMAT 99.9
COLUMN ESTD_SPILL_COUNT HEADING 'Estimated|Spill|Count' FORMAT 99999999
COLUMN ESTD_SPILL_TIME HEADING 'Estimated|Spill|Time' FORMAT 99999999.99
COLUMN ESTD_UNSPILL_COUNT HEADING 'Estimated|Unspill|Count' FORMAT 99999999
COLUMN ESTD_UNSPILL_TIME HEADING 'Estimated|Unspill|Time' FORMAT 99999999.99

SELECT STREAMS_POOL_SIZE_FOR_ESTIMATE,
       STREAMS_POOL_SIZE_FACTOR, 
       ESTD_SPILL_COUNT, 
       ESTD_SPILL_TIME, 
       ESTD_UNSPILL_COUNT,
       ESTD_UNSPILL_TIME
  FROM V$STREAMS_POOL_ADVICE;
