set pagesi 1000 linesi 1000 trimspool on head on 
col capture_name format a20
col queue_name format a20

select capture_name, status, queue_name, capture_type from dba_capture
order by capture_name;
