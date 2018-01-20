PROMPT System Privileges
select privilege, admin_option from dba_sys_privs where grantee=upper('&1')
order by privilege;

PROMPT Role Privileges
select granted_role, admin_option, default_role from dba_role_privs where grantee=upper('&1')
order by granted_role;

PROMPT Tab Privileges
select owner, table_name, privielge, grantor, grantable, hierarchy from dba_tab_privs where grantee=upper('&1')
order table_name, privilege;
