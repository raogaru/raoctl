# ############################################################
# DBMS_SCHEDULER LOG FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# job actions
action_L1="purge purge1 1min 5min 15min 30min 1hr 4hr 12hr 1day 7day "
action_L2="1min_count 5min_count 15min_count 30min_count 1hr_count 4hr_count 12hr_count 1day_count 7day_count "
action_L3="xxx "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
purge,NONE,Purge_all_log_entries \
purge1,NONE,Purge_1_job_log_entries \
1min,NONE,List_log_entries_last_1_min \
5min,NONE,List_log_entries_last_5_min \
15min,NONE,List_log_entries_last_15_min \
30min,NONE,List_log_entries_last_30_min \
1hr,NONE,List_log_entries_last_1_hr \
4hr,NONE,List_log_entries_last_4_hr \
12hr,NONE,List_log_entries_last_12_hr \
1day,NONE,List_log_entries_last_1_day \
7day,NONE,List_log_entries_last_7_day \
1min_count,NONE,Count_log_entries_last_1_min \
5min_count,NONE,Count_log_entries_last_5_min \
15min_count,NONE,Count_log_entries_last_15_min \
30min_count,NONE,Count_log_entries_last_30_min \
1hr_count,NONE,Count_log_entries_last_1_hr \
4hr_count,NONE,Count_log_entries_last_4_hr \
12hr_count,NONE,Count_log_entries_last_12_hr \
1day_count,NONE,Count_log_entries_last_1_day \
7day_count,NONE,Count_log_entries_last_7_day \
"
# ------------------------------------------------------------
# local variables
v_debug=0
# ------------------------------------------------------------
INCLIB_c
# ------------------------------------------------------------
f_log_purge () {
SQLQRY "exec dbms_scheduler.purge_log;"
}
# ------------------------------------------------------------
f_log_purge1 () {
INPUT
SQLQRY "exec dbms_scheduler.purge_log(job_name=>'${input};"
}
# ------------------------------------------------------------
JOBLOG_LIST () {
SQLNEWF
SQLLINE "set echo off feedback on pause off pagesi 1000 heading on "
SQLLINE "set verify off linesi 500 term on trimspool on"
SQLLINE "col job_name format a30"
SQLLINE "select substr(job_name,1,30) job_name, status,log_date from dba_scheduler_job_log where log_date>=sysdate-${1} order by log_date;"
}
# ------------------------------------------------------------
f_log_1min () {
JOBLOG_LIST "1/(24*60)"
}
# ------------------------------------------------------------
f_log_5min () {
JOBLOG_LIST "5/(24*60)"
}
# ------------------------------------------------------------
f_log_15min () {
JOBLOG_LIST "15/(24*60)"
}
# ------------------------------------------------------------
f_log_30min () {
JOBLOG_LIST "30/(24*60)"
}
# ------------------------------------------------------------
f_log_1hr () {
JOBLOG_LIST "1/24"
}
# ------------------------------------------------------------
f_log_4hr () {
JOBLOG_LIST "4/24"
}
# ------------------------------------------------------------
f_log_12hr () {
JOBLOG_LIST "12/24"
}
# ------------------------------------------------------------
f_log_1day () {
JOBLOG_LIST "1"
}
# ------------------------------------------------------------
f_log_7day () {
JOBLOG_LIST "7"
}
# ------------------------------------------------------------
JOBLOG_COUNT () {
SQLQRY "select substr(job_name,1,30) job_name, status,count(1) from dba_scheduler_job_log where log_date>=sysdate-${1} group by substr(job_name,1,30), status order by substr(job_name,1,30), status ;"
}
# ------------------------------------------------------------
f_log_1min_count () {
JOBLOG_COUNT "1/(24*60)"
}
# ------------------------------------------------------------
f_log_5min_count () {
JOBLOG_COUNT "5/(24*60)"
}
# ------------------------------------------------------------
f_log_15min_count () {
JOBLOG_COUNT "15/(24*60)"
}
# ------------------------------------------------------------
f_log_30min_count () {
JOBLOG_COUNT "30/(24*60)"
}
# ------------------------------------------------------------
f_log_1hr_count () {
JOBLOG_COUNT "1/24"
}
# ------------------------------------------------------------
f_log_4hr_count () {
JOBLOG_COUNT "4/24"
}
# ------------------------------------------------------------
f_log_12hr_count () {
JOBLOG_COUNT "12/24"
}
# ------------------------------------------------------------
f_log_1day_count () {
JOBLOG_COUNT "1"
}
# ------------------------------------------------------------
f_log_7day_count () {
JOBLOG_COUNT "7"
}
# ------------------------------------------------------------
