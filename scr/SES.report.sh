# ############################################################
# SESSION REPORT FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# STREAMS SETUP actions
action_L1="sid "
action_L1="xxx "
action_L1="ppp "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
sid,None,Report_all \
"
# ------------------------------------------------------------
# Module specific environment variables
# ------------------------------------------------------------
# Connect to SQLPLUS and execute script
REPEXEC () {  #1-user 2=password 3=SID 4=sqlfile
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
info_db () {
# ========
ADD_H2_LINK "Database"
ADD_H2_HEADER "DATABASE INFO"
ADD_H3_DETAIL "\
DATABASE:dbinfo,\
INSTANCE:instinfo,\
CONTROL_FILES:cfiles,\
DATA_FILES:dfiles,\
REDO_LOG_FILES:lfiles" 
}
#V_$ACTIVE_SESSION_HISTORY
#V_$ACTIVE_SESS_POOL_MTH
#V_$ARCHIVE_PROCESSES
#V_$AW_SESSION_INFO
#V_$MAX_ACTIVE_SESS_TARGET_MTH
#V_$PQ_SESSTAT
#V_$PX_SESSION
#V_$PX_SESSTAT
#V_$RSRC_SESSION_INFO
#V_$SESSION
#V_$SESSION_BLOCKERS
#V_$SESSION_CONNECT_INFO
#V_$SESSION_CURSOR_CACHE
#V_$SESSION_EVENT
#V_$SESSION_FIX_CONTROL
#V_$SESSION_LONGOPS
#V_$SESSION_OBJECT_CACHE
#V_$SESSION_WAIT
#V_$SESSION_WAIT_CLASS
#V_$SESSION_WAIT_HISTORY
#V_$SESSMETRIC
#V_$SESSTAT
#V_$SESS_IO
#V_$SESS_TIME_MODEL
#V_$SES_OPTIMIZER_ENV
#V_$SSCR_SESSIONS
#V_$TSM_SESSIONS
#V_$HS_SESSION
#V_$LATCH_MISSES
#V_$LOGMNR_SESSION
#V_$DATAPUMP_SESSION
#V_$DETACHED_SESSION
# ========
info_session() {
ADD_H2_LINK "Session"
ADD_H2_HEADER "SESSION INFO"
ADD_H3_DETAIL "\
WINDOW_GROUPS:j_wingrp.sql,\
WINDOW_GROUP_MEMBERS:j_wingrp_members.sql,\
WINDOWS:j_windows.sql,\
WINDOW_DETAILS:j_window_details.sql,\
WINDOW_LOG:j_window_log.sql"
}
# ========
info_dests() {
ADD_H2_LINK "Destinations"
ADD_H2_HEADER "DESTINATIONS INFO"
ADD_H3_DETAIL "\
DESTINATIONS:j_dests.sql,\
EXTERNAL_DESTINATIONS:j_external_dests.sql"
}
# ========
info_programs() {
ADD_H2_LINK "Programs"
ADD_H2_HEADER "PROGRAMS INFO"
ADD_H3_DETAIL "\
PROGRAMS:j_programs.sql,\
PROGRAM_ARGUMENTS:j_program_args.sql"
}
# ========
info_schedules() {
ADD_H2_LINK "Schedules"
ADD_H2_HEADER "SCHEDULES INFO"
ADD_H3_DETAIL "\
SCHEDULES:j_schedules.sql"
}
# ========
info_credentials() {
ADD_H2_LINK "Credentials"
ADD_H2_HEADER "CREDENTIALS INFO"
ADD_H3_DETAIL "\
CREDENTIALS:j_credentials.sql"
}
# ========
info_notifications() {
ADD_H2_LINK "Notifications"
ADD_H2_HEADER "NOTIFICATIONS INFO"
ADD_H3_DETAIL "\
NOTIFICATIONS:j_notifications.sql"
}
# ========
info_file_watchers() {
ADD_H2_LINK "File Watchers"
ADD_H2_HEADER "FILE_WATCHERS INFO"
ADD_H3_DETAIL "\
FILE_WATCHERS:j_file_watchers.sql"
}
# ========
info_remote() {
ADD_H2_LINK "Remote DBs"
ADD_H2_HEADER "REMOTE_DBS INFO"
ADD_H3_DETAIL "\
REMOTE_DBS:j_remote_dbs.sql,\
REMOTE_JOB_STATE:j_remote_jobstate.sql"
}
# ========
info_jobs () {
ADD_H2_LINK "Jobs"
ADD_H2_HEADER "JOBS INFO"
ADD_H3_DETAIL "\
JOB_LIST:j_jobs.sql,\
JOB_ARGUMENTS:j_job_args.sql,\
JOB_CLASSES:j_job_classes.sql,\
JOB_DESTINATIONS:j_job_dests.sql,\
JOB_ROLES:j_job_roles.sql,\
JOB_RUNNNING:j_job_running.sql,\
JOB_DETAILS:j_job_run_details.sql,\
JOB_LOG:j_job_log.sql"
}
# ========
info_chains () {
ADD_H2_LINK "Chains"
ADD_H2_HEADER "CHAINS INFO"
ADD_H3_DETAIL "\
CHAIN_LIST:j_chains.sql,\
CHAIN_STEPS:j_chain_steps.sql,\
CHAIN_RULES:j_chain_rules.sql,\
CHAIN_RUNNING:j_chain_running.sql,\
CHAIN_LIST:j_chains.sql"
}
# ========
info_groups () {
ADD_H2_LINK "Groups"
ADD_H2_HEADER "GROUPS INFO"
ADD_H3_DETAIL "\
GROUP_LIST:j_groups.sql,\
GROUP_MEMBERS:j_group_members.sql"
}
# ========
# ------------------------------------------------------------
f_report_windows () {
INCLIB_c RPT
# ========
info_db
info_windows
# ========
ECHO "Preparing SQL to generate HTML report"
f_html_report "DBMS_SCHEDULER Windows Report" "DBMS_SCHEDULER_Windows_Report" "DBMS_SCHEDULER_Windows Report"
REPEXEC as sysdba $ORACLE_SID
#SQLEXEC
}
# ------------------------------------------------------------
f_report_jobs () {
INCLIB_c RPT
# ========
info_db 
info_jobs
# ========
ECHO "Preparing SQL to generate HTML report"
f_html_report "DBMS_SCHEDULER Jobs Report" "DBMS_SCHEDULER_Jobs_Report" "DBMS_SCHEDULER_Jobs Report"
REPEXEC as sysdba $ORACLE_SID
#SQLEXEC
}
# ------------------------------------------------------------
f_report_all () {
INCLIB_c RPT
# ========
info_db
info_windows 
info_jobs
info_dests
info_programs
info_schedules
info_credentials
info_notifications
info_file_watchers
info_remote
info_chains
info_groups
# ========
ECHO "Preparing SQL to generate HTML report"
f_html_report "DBMS_SCHEDULER_Report" "DBMS_SCHEDULER_Report" "DBMS_SCHEDULER Report"
REPEXEC as sysdba $ORACLE_SID
}
# ------------------------------------------------------------
