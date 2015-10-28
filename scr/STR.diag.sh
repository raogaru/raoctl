# ############################################################
# STREAMS DIAGNOSTIC FUNCTIONS - Oracle Streams Diagnostics
# ############################################################
# ------------------------------------------------------------
# STREAMS DIAG actions
action_L1="capture apply prop rule "
action_L2="xx "
action_L3="pp "
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
f_diag_capture () {
SQLQRY "select 'On '||source_database||' capture '||capture_name||' in '||status||' status with '||error_number||error_message from dba_capture where status in ('ABORTED','DISABLED');"
SQLQRY "select 'On '||d.name||' capture '||c.capture_name||' in '||c.state||' state' from v\$streams_capture c, v\$database d where state not in ('CAPTURING CHANGES');"
}
# ------------------------------------------------------------
f_diag_apply () {
ECHO "not coded yet"
}
# ------------------------------------------------------------
f_diag_rule () {
ECHO "not coded yet"
}
