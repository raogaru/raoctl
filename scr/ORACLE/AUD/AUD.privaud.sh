# ############################################################
# AUD PRIVAUD FUNCTIONS - Enable/Disable/Status Privilege Audit Implementation
# ############################################################
# ------------------------------------------------------------
# AUD PRIVAUD actions
action_L1="list audit noaudit check "
action_L2="show_misc "
action_L3="zz "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List Privilege Audit options implemented \
audit,none,Run AUDIT for Selected list of Privilege Audit options \
noaudit,none,Run NOAUDIT for Selected list of Privilege Audit options \
check,none,Check AUDIT enabled  or not for Selected list of Privilege Audit options \
show_misc,none,Show Miscelleaneous Privilege Audits implemented - by user/success/failure \
"
# ------------------------------------------------------------
# Global variable overwrites
RC_SYSAUD_SCHEMA="SYSAUD"
RC_SYSAUD_TABLE="SYSAUD"
v_priv_audit_cfg=${RC_DIR}/scr/${v_product}/${v_class}/cfg/priv_audit.cfg

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions

# ------------------------------------------------------------
f_privaud_list () {
SQLPLUS_LINE_1="set echo on feedback on verify off time off timing off"
SQLNEWF
SQLLINE "select privilege from dba_priv_audit_opts where success='BY ACCESS' and failure='BY ACCESS' and user_name is null;"
rc_SHOW_SQL=YES
SQLEXEC
}
# ------------------------------------------------------------
f_privaud_audit () {
SQLPLUS_LINE_1="set echo off feedback off verify off time off timing off"
SQLNEWF
cat ${v_priv_audit_cfg}| while read line
do
DEBUG "processing ${line}"
SQLLINE "Audit ${line} ;"
done
rc_SHOW_SQL=YES
SQLEXEC
}
# ------------------------------------------------------------
f_privaud_noaudit () {
SQLPLUS_LINE_1="set echo off feedback off verify off time off timing off"
SQLNEWF
cat ${v_priv_audit_cfg}| while read line
do
DEBUG "processing ${line}"
SQLLINE "Noaudit ${line} ;"
done
rc_SHOW_SQL=YES
SQLEXEC
}
# ------------------------------------------------------------
f_privaud_check () {
SQLPLUS_LINE_1="set echo on feedback on verify off time off timing off"
SQLNEWF
SQLLINE "select privilege from dba_priv_audit_opts where success='BY ACCESS' and failure='BY ACCESS' and user_name is null"
cat ${v_priv_audit_cfg}| while read line
do
DEBUG "processing ${line}"
SQLLINE "minus"
SQLLINE "select '${line}' from dual"
done
SQLLINE ";"
rc_SHOW_SQL=YES
SQLEXEC
}
# ------------------------------------------------------------
f_privaud_show_misc () {
SQLPLUS_LINE_1="set echo on feedback on verify off time off timing off"
SQLNEWF
SQLLINE "select privilege, user_name, success, failure from dba_priv_audit_opts where success!='BY ACCESS' or failure!='BY ACCESS' or user_name is not null;"
rc_SHOW_SQL=YES
SQLEXEC
}
# ------------------------------------------------------------
f_privaud_noaudid_misc () {
SQLPLUS_LINE_1="set echo off feedback off verify off time off timing off"
SQLPLUS_LINE_2="set pagesi 0 linesi 1000 trims on"
SQLNEWF
SQLLINE "declare"
SQLLINE "v_sql varchar2(1000);"
SQLLINE "begin"
SQLLINE "for c in (select privilege, user_name, success, failure from dba_priv_audit_opts where success!='BY ACCESS' or failure!='BY ACCESS' or user_name is not null)"
SQLLINE "loop"
SQLLINE "v_sql:='noaudit '||c.privilege||"
SQLLINE ""
SQLLINE ""
SQLLINE "end loop;"

SQLLINE "end;"
SQLLINE "/"

rc_SHOW_SQL=YES
SQLEXEC
}
# ------------------------------------------------------------
