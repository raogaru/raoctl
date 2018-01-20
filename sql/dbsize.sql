col type format a5
col size_mb format 999999999
select 'DATA' type, sum(bytes)/1024/1024 size_mb from v$datafile
union all
select 'TEMP' type, sum(bytes)/1024/1024 size_mb from v$tempfile
union all
select 'REDO' type, sum(bytes)/1024/1024 size_mb from v$log
;
