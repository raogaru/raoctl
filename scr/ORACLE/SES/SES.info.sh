# ############################################################
# SESSION INFO FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# STREAMS INFO actions
action_L1="sid one"
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
sid,None,Report_all \
"
# ------------------------------------------------------------
# Module specific environment variables
# ------------------------------------------------------------
SESINFO_p () {
PRINTTAB "select $* from v\$session where sid=${input1}"
}
# ------------------------------------------------------------
f_info_sid () {
INPUT

ECHO "Connection Info"
SESINFO_p "sid, serial#, username, osuser, status, schemaname , logon_time"

ECHO "Program Info"
SESINFO_p "server, machine, process, program, terminal, port, type "

ECHO "Module Client Info"
SESINFO_p "module, action, client_info, terminal, port, type, service_name"

ECHO "Current SQL"
SESINFO_p "sql_id, sql_child_number, sql_address, sql_hash_value, sql_exec_start, sql_exec_id"

ECHO "Previous SQL"
SESINFO_p "prev_sql_id, prev_child_number, prev_sql_addr, prev_hash_value, prev_exec_start, prev_exec_id"

ECHO "Event Info"
SESINFO_p "event#, event, p1,p1text, p2, p2text, p3, p3text"

ECHO "Wait Info"
SESINFO_p "wait_class#, wait_class, wait_time,seconds_in_wait"

ECHO "Trace Info"
SESINFO_p "sql_trace"

ECHO "Edition Info"
SESINFO_p "session_edition_id"

ECHO "Blocking Info"
SESINFO_p "blocking_session_status, blocking_instance, blocking_session"

ECHO "Session Statistics"
SQLQRY "select a.statistic#, a.name, b.value from v\$statname a, v\$sesstat b where a.statistic#=b.statistic# and b.value!=0 and b.sid=${input1} order by b.value;"

ECHO "Session Blockers"
SQLQRY "select wait_id, wait_event, blocker_instance_id, blocker_sid, blocker_sess_serial# from v\$session_blockers where sid=${input1};"

ECHO "Session Event"
SQLQRY "select event, total_waits, total_timeouts, time_waited, average_wait, max_wait, wait_class from v\$session_event where sid=${input1};"

ECHO "Session xxx"
SQLQRY "select '*' from v\$xxx where sid=${input1};"

ECHO "Session xxx"
SQLQRY "select '*' from v\$xxx where sid=${input1};"

ECHO "Session xxx"
SQLQRY "select '*' from v\$xxx where sid=${input1};"

ECHO "Session xxx"
SQLQRY "select '*' from v\$xxx where sid=${input1};"

}
# ------------------------------------------------------------
f_info_one () {
INPUT
SQLQRY "@sesinfo ${input1}"
}
# ------------------------------------------------------------
