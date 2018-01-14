# ############################################################
# DBMS_SCHEDULER JOB FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# job actions
action_L1="list create drop enable disable run stop "
action_L2="xx "
action_L3="ppp "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,NONE,List_windows \
"
# ------------------------------------------------------------
# local variables
INCLIB_c
# ------------------------------------------------------------
f_job_list () {
SQLQRY "select job_name, substr(schedule_name,1,30) schedule_name, enabled from DBA_SCHEDULER_JOBS;"
}
# ------------------------------------------------------------
f_job_log_count_1hr () {
SQLQRY "select substr(job_name,1,30) job_name, status,count(1) from dba_scheduler_job_log where job_name like 'JOB_SMS_SIM%' and log_date>=sysdate-1/(24) group by substr(job_name,1,30), status order by substr(job_name,1,30), status ;"
}
# ------------------------------------------------------------
# ------------------------------------------------------------
f_job_create () { 
SCHEDULER_p "create_job ( job_name=> upper('JOB_SMS_${1}'), job_type=> 'STORED_PROCEDURE', job_action=> 'SMS.SMSPKG.${1}', schedule_name=> 'SYS.${2}', enabled=> TRUE, comments=> 'SMS Simulation Job');"
}
# ------------------------------------------------------------
f_job_drop () { 
SCHEDULER_p "drop_job (job_name=> upper('JOB_SMS_${1}'), force=>TRUE);"
}
# ------------------------------------------------------------
f_job_run () { 
SCHEDULER_p "run_job (job_name=> upper('JOB_SMS_${1}'));"
}
# ------------------------------------------------------------
f_job_stop () { 
SCHEDULER_p "stop_job (job_name=> upper('JOB_SMS_${1}'));"
}
# ------------------------------------------------------------
f_job_enable () { 
SCHEDULER_p "enable (name=> upper('JOB_SMS_${1}'));"
}
# ------------------------------------------------------------
f_job_disable () { 
SCHEDULER_p "disable (name=> upper('JOB_SMS_${1}'));"
}
