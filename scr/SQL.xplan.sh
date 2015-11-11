# ############################################################
# SQL XPLAN FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# XPLAN actions
action_L1="plan cursor awr sqlset baseline "
action_L2="diff_awr diff_cursor diff_baseline  "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
plan,statement_id:dir_object:file_name  \
cursor,sql_id:child_number:dir_object:file_name  \
awr,sql_id:child_number:dir_object:file_name  \
sqlset,sql_id:child_number:dir_object:file_name  \
baseline,sql_handle:plan_name,Display_XPLAN_from_SQL_BASELINE \
cursor,sql_id:child_number:dir_object:file_name  \
"
# ------------------------------------------------------------
# local variables

# ------------------------------------------------------------
XPLAN_p () {
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_xplan.${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
XPLAN_s () {
vLine="$*"
SQLNEWF
SQLLINE "select plan_table_output from table(dbms_xplan.${vLine});"
SQLEXEC
}
# ------------------------------------------------------------
XPLAN_f () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "x varchar2(1000);"
SQLLINE "begin"
SQLLINE "x:=dbms_xplan.${vLine};"
SQLLINE "dbms_output.put_line('Return value:'||x);"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
XPLAN_clob2file () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "v_clob clob;"
SQLLINE "begin"
SQLLINE "v_clob:=dbms_xplan.${vLine};"
SQLLINE "dbms_advisor.create_file(buffer=>v_clob,location=>'${input2}',filename=>'${input3}');"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
f_xplan_plan () {  # returns CLOB - check it tout - not working
INPUT 1
XPLAN_clob2file "DISPLAY_PLAN(statement_id=>'${input1}',format=>'ADVANCED')"
}
# ------------------------------------------------------------
f_xplan_cursor () { 
INPUT 2
XPLAN_s "DISPLAY_CURSOR(sql_id=>'${input1}',cursor_child_no=>${input2},format=>'ADVANCED')"
}
# ------------------------------------------------------------
f_xplan_awr () { 
INPUT 2
XPLAN_s "DISPLAY_AWR(sql_id=>'${input1}',plan_hash_value=>${input2},format=>'ADVANCED')"
}
# ------------------------------------------------------------
f_xplan_sqlset () { 
INPUT 3
XPLAN_s "DISPLAY_SQLSET(sqlset_name=>'${input1}',sql_id=>'${input2}',plan_hash_value=>${input3},format=>'ADVANCED')"
}
# ------------------------------------------------------------
f_xplan_baseline () { 
INPUT 2
XPLAN_s "DISPLAY_SQL_PLAN_BASELINE(sql_handle=>'${input1}',plan_name=>'${input2}',format=>'ADVANCED')"
}
# ------------------------------------------------------------
f_xplan_diff_cursor () { 
INPUT 2
XPLAN_f "DIFF_PLAN_CURSOR(sql_id=>'${input1}',cursor_child_num1=>${input2},cursor_child_num2=>'${input3}')"
}
# ------------------------------------------------------------
f_xplan_diff_awr () { 
INPUT 2
XPLAN_f "DIFF_PLAN_AWR(sql_id=>'${input1}',plan_hash_value1=>${input2},plan_hash_value2=>'${input3}')"
}
# ------------------------------------------------------------
f_xplan_diff_baseline () { 
INPUT 2
XPLAN_s "DIFF_PLAN_SQL_BASELINE(baseline_plan_name1=>'${input1}',baseline_plan_name2=>'${input2}')"
}
