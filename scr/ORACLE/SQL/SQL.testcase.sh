# ############################################################
# SQL TESTCASE FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# TESTCASE actions
action_L1="list  "
action_L2="exp_inc_id exp_sql_id imp "
action_L3="load_sqlset "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,None,List_SQL_Patches \
exp_inc_id,incident_id,Export_Testcase_by_Incident_ID \
exp_sql_id,incident_id,Export_Testcase_by_SQL_ID \
imp,file_name,Import_Testcase_from_File \
load_sqlset,file_name:sqlset_name,Load_SQLSET_from_Testcase_Builder_file \
"
# ------------------------------------------------------------
#Local Variables & Overwrite global variables
v_expdir=${rc_TCB_EXPORT_DIR:="DATA_PUMP_DIR"}
rc_SHOW_SQL=YES
# ------------------------------------------------------------
TESTCASE_p () {
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_sqldiag.${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
TESTCASE_f () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "x varchar2(1000);"
SQLLINE "begin"
SQLLINE "x:=dbms_sqldiag.${vLine};"
SQLLINE "dbms_output.put_line('Return value:'||x);"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
TESTCASE_p2 () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "v_clob clob;"
SQLLINE "begin"
SQLLINE "dbms_sqldiag.${vLine};"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
f_testcase_list () { 
SQLQRY "select name, category, signature, created, status, task_id, task_exec_name from dba_sql_testcase_id;"
}
# ------------------------------------------------------------
f_testcase_exp_inc_id () {
INPUT
TESTCASE_p2 "export_sql_testcase(directory=>'${v_expdir}',incident_id=>'${input1}',testcase=>v_clob)"
}
# ------------------------------------------------------------
f_testcase_exp_sql_id () {
INPUT
TESTCASE_p2 "export_sql_testcase(directory=>'${v_expdir}',incident_id=>'${input1}',testcase=>v_clob)"
}
# ------------------------------------------------------------
f_testcase_imp () {
INPUT
TESTCASE_p2 "import_sql_testcase(directory=>'${v_expdir}',filename=>'${input1}')"
}
# ------------------------------------------------------------
f_testcase_load_sqlset () {
INPUT 2
TESTCASE_f "load_sqlset_from_tcb(directory=>'${v_expdir}',filename=>'${input1}',sqlset_name=>'${input2}')"
}
# ------------------------------------------------------------
