set head off echo off feedback off verify off pagesi 10000 linesi 150 trims on
select distinct 
'SQL: '||SQL_ID||CHR(10)|| 
'PHV: '||PLAN_HASH_VALUE||CHR(10)|| 
'FORCE_MATCHING_SIGNATURE: '||FORCE_MATCHING_SIGNATURE||CHR(10)|| 
'EXACT_MATCHING_SIGNATURE: '||EXACT_MATCHING_SIGNATURE||CHR(10)
from v$sql 
where sql_id='&1';

select distinct 
'ADVISOR_TASK_NAME: '||TASK_NAME||CHR(10)||
'ADVISOR_EXEC_NAME: '||EXECUTION_NAME||CHR(10)||
'x'
from dba_advisor_sqlplans
where sql_id='&1';

