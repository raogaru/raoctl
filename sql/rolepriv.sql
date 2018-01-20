set linesi 100 trimspool on 
col grantee format a15
col privilege format a30
col priv_type format a10
select grantee, granted_role, 'ROLE' priv_type from dba_role_privs where granted_role='&1';
