# ############################################################
# STREAMS MONITOR FUNCTIONS - Oracle Streams Monitoring
# ############################################################
# ------------------------------------------------------------
# STREAMS MONITOR actions
action_L1="install collect start stop status show "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
capture,,Monitor_Capture \
"
# ------------------------------------------------------------
INCLIB_c
# ------------------------------------------------------------
UTL_SPADV (){
vLine="$*"
SQLNEWF
SQLLINE "exec utl_spadv.${vLine};"
STREXEC ${STRADM} ${STRADM} ${ORACLE_SID}
}
# ------------------------------------------------------------
f_monitor_install () {
SQLNEWF
SQLLINE "@?/rdbms/admin/utlspadv.sql"
STREXEC ${STRADM} ${STRADM} ${ORACLE_SID}
}
# ------------------------------------------------------------
f_monitor_start () {
UTL_SPADV "start_monitoring"
}
# ------------------------------------------------------------
f_monitor_stop () {
UTL_SPADV "stop_monitoring"
}
# ------------------------------------------------------------
f_monitor_status () {
SQLQRY " select UTL_SPADV.IS_MONITORING (job_name=> 'STREAMS$_MONITORING_JOB', client_name => NULL) from dual;"
}
