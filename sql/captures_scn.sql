col capture_name format a20
col queue_name format a20

SELECT CAPTURE_NAME, FIRST_SCN, APPLIED_SCN, REQUIRED_CHECKPOINT_SCN
FROM DBA_CAPTURE
order by capture_name;
