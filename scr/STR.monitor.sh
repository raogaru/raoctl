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
# Module specific environment variables
STREAMS_CONF=${CFG_DIR}/streams.cfg
STRLOG=${LOG_DIR}/streams_config.log
STRADM=ADM
v_debug=0
# ------------------------------------------------------------
# Connect to SQLPLUS and execute script
STREXEC () {  #1-user 2=password 3=SID 4=sqlfile
if [[ $1 = "as" && $2 = "sysdba" ]] ; then
	constr="/ as sysdba"
else
	constr="${1}/${2}@${3}"
fi
if [[ -z $4 ]]; then
	SQLFILE=${TMPSQL}
else
	SQLFILE=$4
fi
#echo Executing SQL $SQLFILE as $constr
cat $SQLFILE >> $STRLOG
ECHO "-- ${cLINE5}" >> $STRLOG
export ORACLE_SID=$3
${ORACLE_HOME}/bin/sqlplus -s /nolog <<-EOFsql
connect $constr
--show user	
set echo off feedback off pagesi 0 termout on linesi 1000 trimspool on
set serveroutput on size 10000
spool ${TMPLOG} append
@${SQLFILE}
spool off
EOFsql
}
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
