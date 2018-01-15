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
info_db () {
# ========
ADD_H2_LINK "Database"
ADD_H2_HEADER "DATABASE INFO"
ADD_H3_DETAIL "\
DATABASE:dbinfo,\
INSTANCE:instinfo"
}
# ------------------------------------------------------------
#V_$ACTIVE_SESSION_HISTORY
#V_$ACTIVE_SESS_POOL_MTH
#V_$ARCHIVE_PROCESSES
#V_$AW_SESSION_INFO
#V_$MAX_ACTIVE_SESS_TARGET_MTH
#V_$PQ_SESSTAT
#V_$PX_SESSION
#V_$PX_SESSTAT
#V_$RSRC_SESSION_INFO
#done V_$SESSION_CONNECT_INFO
#n/a	V_$SESSION_CURSOR_CACHE
#V_$SESSION_FIX_CONTROL
#V_$SESSION_LONGOPS
#n/a	V_$SESSION_OBJECT_CACHE
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
#done V_$SESSION
#done V_$SESSION_BLOCKERS
#done V_$SESSION_EVENT
# ========
info_session() {
ADD_H2_LINK "Session"
ADD_H2_HEADER "SESSION INFO"
ADD_H3_DETAIL "\
WINDOW_GROUPS:sesinfo.sql,\
WINDOW_GROUP_MEMBERS:j_wingrp_members.sql,\
"
}
# ------------------------------------------------------------
f_report_sid () {
INPUT 
INCLIB_c RPT
# ========
info_db
info_session
# ========
ECHO "Preparing SQL to generate HTML report"
f_html_report "SESSION_Info_Report" "SESSION_INFO_Report" "Session Info Report"
SQLEXEC
}
# ------------------------------------------------------------
