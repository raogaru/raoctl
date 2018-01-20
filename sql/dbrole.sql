set head on feedback off linesi 1000 trimspool on
col name format a5 
col db_unique_name format a5 heading "uniq"
col dbid format 9999999999

select name, db_unique_name, database_role, switchover_status, open_mode 
from v$database;

