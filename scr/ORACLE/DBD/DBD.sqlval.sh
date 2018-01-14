# ############################################################
# DBD SQLVAL FUNCTIONS - Database Deployment - SQL File validation
# ############################################################
# SQLVAL = SQLSPLIT + SQLTYPE + SQLRULE
# ------------------------------------------------------------
# DBD SQLTYPE actions
action_L1="sql_str sql_file testcase "
action_L2=" "
action_L3=" "
action_L4=" "
action_L="$action_L1 $action_L2 $action_L3 $action_L4"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
"
# ------------------------------------------------------------
INCLIB_m sqlsplit
INCLIB_m sqltype
INCLIB_m sqlrule
INCLIB_m
# ------------------------------------------------------------
# split NotApplicable. Find SqlType and SqlSubType. And run SqlType Rules and SqlSubTypeRules
f_sqlval_sql_str () {
INPUT
[[ "${rc_FIND_SQLTYPE}" != "NO" ]] && f_find_sql_type "${input1}"
[[ "${rc_FIND_SQLOBJECT}" != "NO" ]] && f_find_sql_object
[[ "${rc_FIND_SQLSUBTYPE}" = "YES" ]] && f_find_sql_sub_type 
}
# ------------------------------------------------------------
f_sqlval_sql_file () {
INPUT
f_split_sql_to_files ${input1}
SQLVAL_N_FILES 
}
# ------------------------------------------------------------
f_sqlval_testcase () {
f_split_sql_to_files ${SCR_DIR}/${v_product}/${v_class}/testcase/${input}.sql
SQLVAL_N_FILES
}
# ------------------------------------------------------------
