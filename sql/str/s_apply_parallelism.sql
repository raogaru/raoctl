-- TITLE1: Apply Parallelism
-- TITLE2: Displaying Effective Apply Parallelism for an Apply Process
-- DESC: In some environments, an apply process might not use all of the apply servers available to it. For example, apply process parallelism can be set to five, but only three apply servers are ever used by the apply process. In this case, the effective apply parallelism is three.

SELECT COUNT(SERVER_ID) "Effective Parallelism"
  FROM V$STREAMS_APPLY_SERVER
  WHERE APPLY_NAME = 'APPLY' AND
        TOTAL_MESSAGES_APPLIED > 0;
