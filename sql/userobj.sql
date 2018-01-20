set linesi 1000 trimspool on
col object_name format a30 
select owner, object_name, object_type from dba_objects where owner like upper('&1') order by object_name;
