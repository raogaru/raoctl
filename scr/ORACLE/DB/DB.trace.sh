# ############################################################
# DB ORADEBUG FUNCTIONS - oradebug commands
# ############################################################
# ------------------------------------------------------------
# ORADEBUG actions
action_L1="10046on 10046off 10053on 10053off spm_on spm_off opt_on opt_off "
action_L2="x "
action_L3="y "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
10046on,none,Enable_10046_trace \
10046off,none,Disable_10046_trace \
10053on,none,Enable_10053_trace \
10053off,none,Disable_10053_trace \
spm_on,sql_id,Enable_SQL_Baseline_Trace \
spm_off,sql_id,Disable_SQL_Baseline_Trace \
opt_on,sql_id,Enable_SQL_Optimizer_Trace \
opt_off,sql_id,Disable_SQL_Optimizer_Trace \
"
# ------------------------------------------------------------
# local variables

# ------------------------------------------------------------
TRACE_p2 () {
vLine="$*"
SQLNEWF
SQLLINE "alter session set tracefile_identifier='RAOCTL_${v_module}_${v_action}';"
SQLLINE "alter session set events '${vLine}';"
SQLEXEC
}
# ------------------------------------------------------------
ORADEBUG_p () {
vLine="$*"
SQLNEWF
SQLLINE "oradebug setospid ${input1}"
SQLLINE "oradebug tracefile_name"
SQLLINE "oradebug event ${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
f_trace_10046on () {
INPUT
TRACE_p "10046 trace name context forever, level 12"
}
# ------------------------------------------------------------
f_trace_10046off () {
INPUT
TRACE_p "10046 trace name context off"
}
# ------------------------------------------------------------
