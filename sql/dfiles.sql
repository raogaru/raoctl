set linesi 1000 trimspool on
col name format a60
select file#, bytes/1024/1024 size_mb , name from v$datafile
/
