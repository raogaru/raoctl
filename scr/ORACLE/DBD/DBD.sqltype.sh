# ############################################################
# DBD SQLTYPE FUNCTIONS - Database Deployment SQL-Type SQL-Subtype Parsing Engine
# ############################################################
# ------------------------------------------------------------
# DBD SQLTYPE actions
action_L1="sql_str "
action_L2=" "
action_L3=" "
action_L4=" "
action_L="$action_L1 $action_L2 $action_L3 $action_L4"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
"
# ------------------------------------------------------------
INCLIB_m
# ------------------------------------------------------------
f_sqltype_sql_str () {
INPUT
[[ "${rc_FIND_SQLTYPE}" != "NO" ]] && f_find_sql_type "${input1}"
[[ "${rc_FIND_SQLOBJECT}" != "NO" ]] && f_find_sql_object
[[ "${rc_FIND_SQLSUBTYPE}" = "YES" ]] && f_find_sql_sub_type 
}
# ------------------------------------------------------------
