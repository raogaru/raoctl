set linesi 100 trimspool on pagesi 50
col grantee format a15
col privilege format a10
col priv_type format a10
col object_name format a30
select grantee, privilege, owner||'.'||table_name object_name,  'OBJECT' priv_type
from dba_tab_privs where table_name = upper('&1');
