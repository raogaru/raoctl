# ############################################################
# TUNETASK FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# TUNETASK actions
action_L1="create_for_sqlset create_for_sqlid list_task list_exec "
action_L2="execute implement drop cancel reset interrupt resume "
action_L3="drop_all listexec report report2 script "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
create_for_sqlset,sqlset_name,Create_TUNETASK_for_given_sqlset \
create_for_sqlid,sql_id,Create_TUNETASK_for_given_sqlid \
execute,task_name,Execute_TUNETASK \
implement,task_name,Implement_TUNETASK \
drop,task_name,Drop_TUNETASK \
cancel,task_name,Cancel_TUNETASK \
reset,task_name,Reset_TUNETASK \
interrupt,task_name,Interrupt_TUNETASK \
resume,task_name,Resume_TUNETASK \
drop_all,task_name,Drop_all_TUNETASKs \
list_task,task_name,List_TUNETASKs \
list_exec,task_name,List_TUNETASK_Executions \
report,task_name,Report_TUNETASK_result \
script,task_name,Script_TUNETASK_result \
"
# ------------------------------------------------------------
# local variables
typeset -u REPORTS_DIR="REPORTS_DIR"
# ------------------------------------------------------------
TUNETASK_p () {
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_sqltune.${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
TUNETASK_f () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "x varchar2(1000);"
SQLLINE "begin"
SQLLINE "x:=dbms_sqltune.${vLine};"
SQLLINE "dbms_output.put_line('Return value:'||x);"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
TUNETASK_clob2file () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "v_clob clob;"
SQLLINE "begin"
SQLLINE "v_clob:=dbms_sqltune.${vLine};"
SQLLINE "dbms_advisor.create_file(buffer=>v_clob,location=>'${REPORTS_DIR}',filename=>'${v_file_name}');"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
TUNETASK_l () {
x=/tmp/tmp.$$.tunetask.lst
SQLNEWF
SQLLINE "set pagesi 0 head off feedback off verify off"
SQLLINE "select task_name from dba_advisor_tasks where advisor_name='SQL Tuning Advisor' order by task_id;"
SQLEXEC > ${x}
}
# ------------------------------------------------------------
f_tunetask_create_for_sqlset () { 
INPUT
TUNETASK_f "CREATE_TUNING_TASK(SQLSET_NAME=>'${input}')"
}
# ------------------------------------------------------------
f_tunetask_create_for_sqlid () { 
INPUT
TUNETASK_f "CREATE_TUNING_TASK(SQL_ID=>'${input}')"
}
# ------------------------------------------------------------
f_tunetask_list_task () { 
SQLQRY "select task_name, status, advisor_name from dba_advisor_tasks where advisor_name='SQL Tuning Advisor' order by task_id;"
}
# ------------------------------------------------------------
f_tunetask_list_exec () { 
SQLQRY "select task_name, execution_type, execution_name, execution_start, execution_end,status from dba_advisor_executions where advisor_name='SQL Tuning Advisor' order by task_name;"
}
# ------------------------------------------------------------
f_tunetask_execute () { 
INPUT
TUNETASK_f "EXECUTE_TUNING_TASK(TASK_NAME=>'${input}')"
}
# ------------------------------------------------------------
f_tunetask_implement () { 
INPUT
TUNETASK_f "IMPLEMENT_TUNING_TASK(TASK_NAME=>'${input}')"
}
# ------------------------------------------------------------
f_tunetask_drop () { 
INPUT
TUNETASK_p "DROP_TUNING_TASK(TASK_NAME=>'${input}')"
}
# ------------------------------------------------------------
f_tunetask_cancel () { 
INPUT
TUNETASK_p "CANCEL_TUNING_TASK(TASK_NAME=>'${input}')"
}
# ------------------------------------------------------------
f_tunetask_reset () { 
INPUT
TUNETASK_p "RESET_TUNING_TASK(TASK_NAME=>'${input}')"
}
# ------------------------------------------------------------
f_tunetask_interrupt () { 
INPUT
TUNETASK_p "INTERRUPT_TUNING_TASK(TASK_NAME=>'${input}')"
}
# ------------------------------------------------------------
f_tunetask_resume () { 
INPUT
TUNETASK_p "RESUME_TUNING_TASK(TASK_NAME=>'${input}')"
}
# ------------------------------------------------------------
f_tunetask_drop_all () { 
TUNETASK_l
cat ${x} | while read input
do
TUNETASK_p "DROP_TUNING_TASK(TASK_NAME=>'${input}')"
done
}
# ------------------------------------------------------------
f_tunetask_listexec () { 
SQLNEWF
SQLLINE "set pagesi 1000 head on feedback on verify off linesi 100 trimspool on"
SQLLINE "select task_name, execution_name from dba_advisor_executions where advisor_name='SQL Tuning Advisor' and task_name like '%${input}%';"
SQLEXEC
}
# ------------------------------------------------------------
f_tunetask_report () { 
INPUT
v_file_name="TUNETASK_REPORT_${ORACLE_SID}_${input}_$(date +%Y%m%d-%H%M%S).txt"
#HTML type will be supported in future releases
TUNETASK_clob2file "REPORT_TUNING_TASK(TASK_NAME=>'${input}',TYPE=>'TEXT',LEVEL=>'ALL',SECTION=>'ALL')"
}
# ------------------------------------------------------------
f_tunetask_report2 () { 
INPUT
v_file_name="TUNETASK_REPORT_${ORACLE_SID}_${input}_$(date +%Y%m%d-%H%M%S).txt"
#HTML type will be supported in future releases
# report2 is created to see if HTML version works in dbms_advisor instead of dbms_sqltune
SQLNEWF
SQLLINE "declare"
SQLLINE "v_clob clob;"
SQLLINE "begin"
SQLLINE "v_clob:=dbms_advisor.GET_TASK_REPORT(TASK_NAME=>'${input}',TYPE=>'TEXT',LEVEL=>'ALL',SECTION=>'ALL');"
SQLLINE "dbms_advisor.create_file(buffer=>v_clob,location=>'${REPORTS_DIR}',filename=>'${v_file_name}');"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
f_tunetask_script () { 
INPUT
v_file_name="TUNETASK_SCRIPT_${ORACLE_SID}_${input}_$(date +%Y%m%d-%H%M%S).sql"
TUNETASK_clob2file "SCRIPT_TUNING_TASK(TASK_NAME=>'${input}')"
}
