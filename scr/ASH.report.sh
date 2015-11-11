# ############################################################
# ASH REPORT FUNCTIONS (DBMS_WORKLOAD_REPOSITORY)
# ############################################################
# ------------------------------------------------------------
# ASH REPORT actions
action_L1="report report2 report3 "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
report,NONE,ASH_Default_Report_30mins  \
report2,offset,ASH_Report_30mins  \
report3,start_time:duration,ASH_Report_StartTime_and_Duration  \
"
# ------------------------------------------------------------
# local variables

# ------------------------------------------------------------
ASHRPT_p () {
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_workload_repository.${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
ASHRPT_f () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "x varchar2(1000);"
SQLLINE "begin"
SQLLINE "x:=dbms_workload_repository.${vLine};"
SQLLINE "dbms_output.put_line('Return value:'||x);"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
ASHRPT_common () {
vLine="$*"
SQLLINE "set echo off head off feedback off termout off"
SQLLINE "col dbid new_value v_dbid"
SQLLINE "col instance_number new_value v_inst_num"
SQLLINE "col db_name new_value v_db_name"
SQLLINE "col instance_name new_value v_inst_name"
SQLLINE "select d.dbid, d.name db_name, i.instance_number, i.instance_name"
SQLLINE "from v\$database d, v\$instance i;"
SQLLINE "define dbid         = &v_dbid;"
SQLLINE "define db_name      = '&v_db_name';"
SQLLINE "define inst_num     = &v_inst_num;"
SQLLINE "define report_type  = 'html';"
SQLLINE "define num_days     = 0;"
SQLLINE "define slot_width  = '';"
SQLLINE "define target_session_id   = '';"
SQLLINE "define target_sql_id       = '';"
SQLLINE "define target_wait_class   = '';"
SQLLINE "define target_service_hash = '';"
SQLLINE "define target_module_name  = '';"
SQLLINE "define target_action_name  = '';"
SQLLINE "define target_client_id    = '';"
SQLLINE "define target_plsql_entry  = '';"
SQLLINE "@@${ORACLE_HOME}/rdbms/admin/${vLine}"
SQLEXEC
}
# ------------------------------------------------------------
f_report_report () { 
SQLNEWF
SQLLINE "define begin_time  = '-30';"
SQLLINE "define duration    = '';"   # NULL defaults to till current-time
SQLLINE "define report_name  = '${RPT_DIR}/ASH_REPORT_${ORACLE_SID}_$(date +%Y%m%d-%H%M%S).html';"
ASHRPT_common "ashrpti"
}
# ------------------------------------------------------------
f_report_report2 () { 
INPUT
SQLNEWF
SQLLINE "define begin_time  = '-${input1}';"
SQLLINE "define duration    = '';"   # NULL defaults to till current-time
SQLLINE "define report_name  = '${RPT_DIR}/ASH_REPORT_${ORACLE_SID}_$(date +%Y%m%d-%H%M%S).html';"
ASHRPT_common "ashrpti"
}
# ------------------------------------------------------------
f_report_report3 () { 
INPUT 2
SQLNEWF
SQLLINE "define begin_time  = '-${input1}';"
SQLLINE "define duration    = '${input2}';"
SQLLINE "define report_name  = '${RPT_DIR}/ASH_REPORT_${ORACLE_SID}_$(date +%Y%m%d-%H%M%S).html';"
ASHRPT_common "ashrpti"
}
