# ############################################################
# SQL MONITOR FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# SQL Monitor actions
action_L1="config list report "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_of_SQLs_being_monitored \
report,sql_id,Generate_SQL_MONITOR_Report \
"
# ------------------------------------------------------------
# local variables
v_rpt_type=${rc_SQL_MONITOR_REPORT_TYPE:="ACTIVE"}
# ------------------------------------------------------------
f_monitor_config () {
ECHO "SQL monitoring requires the STATISTICS_LEVEL parameter to be set to 'TYPICAL' or 'ALL'"
ECHO "SQL monitoring requires the CONTROL_MANAGEMENT_PACK_ACCESS parameter set to 'DIAGNOSTIC+TUNING'"
SQLQRY "show parameter statistics_level"
SQLQRY "show parameter control_management_pack_access"
}
# ------------------------------------------------------------
f_monitor_list () {
SQLQRY "select sql_id, sql_exec_id, status, sql_exec_start from v\$sql_monitor order by sql_exec_start;"
}
# ------------------------------------------------------------
f_monitor_report () {
INPUT
[[ ! "${v_rpt_type}" = @(TEXT|HTML|ACTIVE|XML) ]] && ERROR "Invalid report type $v_rpt_type"
v_file_name=${RPT_DIR}/SQL_MONITOR_REPORT_${input1}.html
SQLNEWF
SQLLINE "set long 1000000 longchunksize 1000000 linesize 1000 pagesize 0 trim on trimspool on echo off feedback off"
SQLLINE "select dbms_sqltune.report_sql_monitor(sql_id=>'${input1}',type=>'${v_rpt_type}',report_level => 'ALL') from dual;"
SQLEXEC >  ${v_file_name}
}
# ------------------------------------------------------------
