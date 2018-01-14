# ############################################################
# DBD SPLITSQL FUNCTIONS - Database Deployment Split SQL File to multiple files
# ############################################################
# ------------------------------------------------------------
# DBD SPLITSQL actions
action_L1="split testcase "
action_L="$action_L1 $action_L2 $action_L3 $action_L4"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
split,sql_file_name,Split_SQL_File \
testcase,SQL_Type_in_upper_case_with_under_scores,Process_TestCase_SQL_File \
"
# ------------------------------------------------------------
INCLIB_m
# ------------------------------------------------------------
f_sqlsplit_split () {
INPUT
v_debug=0
f_split_sql_to_files ${input1}
}
# ------------------------------------------------------------
f_sqlsplit_testcase () {
INPUT
v_debug=1
f_split_sql_to_files ${SCR_DIR}/${v_product}/${v_class}/testcase/${input}.sql
}
# ------------------------------------------------------------
