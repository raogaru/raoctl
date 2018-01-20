set linesi 120 pagesi 1000 trimspool on
col prior_incarnation# format 999 noprint
col prior_resetlogs_change# format 9 noprint
select * from V$database_incarnation order by incarnation#;
