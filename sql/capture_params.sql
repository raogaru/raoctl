set pagesi 1000 head on feedback on linesi 1000 trimspool on
col capture_name format a15
col parameter format a30
col value format a10

select capture_name, parameter, value, set_by_user from dba_capture_parameters
order by parameter, capture_name;
