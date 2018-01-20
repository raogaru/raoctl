SET PAGESI 1000 LINES 100 TRIMSPOOL ON
col username format a25
col default_tablespace format a20 heading "default_ts"
col temporary_tablespace format a20 heading "temp_ts"

select username, created, expiry_date, lock_date, default_tablespace, temporary_tablespace
from dba_users 
where username like upper('&1%')
order by username ;
