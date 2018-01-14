# ############################################################
# SQL DIAGTASK FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# DIAGTASK actions
action_L1="list create_for_sqlset create_for_sqlid  drop "
action_L2="execute cancel reset interrupt resume  "
action_L3="listexec report "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
create_for_sqlset,sqlset_name:problem_type,Create_DIAGTASK_for_given_sqlset  \
create_for_sqlid,sql_id:problem_type,Create_DIAGTASK_for_given_sqlid  \
execute,task_name,Execute_DIAGTASK  \
implement,task_name,Implement_DIAGTASK  \
drop,task_name,Drop_DIAGTASK  \
cancel,task_name,Cancel_DIAGTASK  \
reset,task_name,Reset_DIAGTASK  \
interrupt,task_name,Interrupt_DIAGTASK  \
resume,task_name,Resume_DIAGTASK  \
drop_all,task_name,Drop_all_DIAGTASKs  \
listexec,task_name,List_DIAGTASK_Executions  \
report,task_name,Report_DIAGTASK_result  \
script,task_name,Script_DIAGTASK_result  \
"
# ------------------------------------------------------------
# local variables
typeset -u REPORTS_DIR="REPORTS_DIR"
# ------------------------------------------------------------
DIAGTASK_p () {
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_sqldiag.${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
DIAGTASK_f () {
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
DIAGTASK_clob2file () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "v_clob clob;"
SQLLINE "begin"
SQLLINE "v_clob:=dbms_sqldiag.${vLine};"
SQLLINE "dbms_advisor.create_file(buffer=>v_clob,location=>'${REPORTS_DIR}',filename=>'${v_file_name}');"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
DIAGTASK_l () {
x=/tmp/tmp.$$.diagtask.lst
SQLNEWF
SQLLINE "set pagesi 0 head off feedback off verify off"
SQLLINE "select task_name from dba_advisor_tasks;"
SQLEXEC > ${x}
}
# ------------------------------------------------------------
f_diagtask_list () { 
SQLQRY "select task_id, task_name, advisor_name, created, status, source from dba_advisor_tasks where advisor_name='SQL Repair Advisor' order by task_name;"
}
# ------------------------------------------------------------
f_diagtask_create_for_sqlset () { 
INPUT 2
# input2 is problem_type=1|2|3|4|5 (refer dbms_sqldiag in dbmsdiag.sql)
#  PROBLEM_TYPE_PERFORMANCE         CONSTANT   NUMBER := 1;
#  PROBLEM_TYPE_WRONG_RESULTS       CONSTANT   NUMBER := 2;
#  PROBLEM_TYPE_COMPILATION_ERROR   CONSTANT   NUMBER := 3;
#  PROBLEM_TYPE_EXECUTION_ERROR     CONSTANT   NUMBER := 4;
#  PROBLEM_TYPE_ALT_PLAN_GEN        CONSTANT   NUMBER := 5;
DIAGTASK_f "create_diagnosis_task(sqlset_name=>'${input1}',problem_type=>${input2})"
}
# ------------------------------------------------------------
f_diagtask_create_for_sqlid () { 
INPUT 2
# input2 is problem_type=1|2|3|4|5 (refer dbms_sqldiag in dbmsdiag.sql)
#  PROBLEM_TYPE_PERFORMANCE         CONSTANT   NUMBER := 1;
#  PROBLEM_TYPE_WRONG_RESULTS       CONSTANT   NUMBER := 2;
#  PROBLEM_TYPE_COMPILATION_ERROR   CONSTANT   NUMBER := 3;
#  PROBLEM_TYPE_EXECUTION_ERROR     CONSTANT   NUMBER := 4;
#  PROBLEM_TYPE_ALT_PLAN_GEN        CONSTANT   NUMBER := 5;
DIAGTASK_f "create_diagnosis_task(sql_id=>'${input1}',problem_type=>${input2})"
}
# ------------------------------------------------------------
f_diagtask_drop () { 
INPUT
DIAGTASK_p "drop_diagnosis_task(task_name=>'${input}')"
}
# ------------------------------------------------------------
f_diagtask_drop_all () { 
DIAGTASK_l
cat ${x} | while read input
do
DIAGTASK_p "drop_diagnosis_task(task_name=>'${input}')"
done
}
# ------------------------------------------------------------
f_diagtask_execute () { 
INPUT
DIAGTASK_p "execute_diagnosis_task(task_name=>'${input}')"
}
# ------------------------------------------------------------
f_diagtask_cancel () { 
INPUT
DIAGTASK_p "cancel_diagnosis_task(task_name=>'${input}')"
}
# ------------------------------------------------------------
f_diagtask_reset () { 
INPUT
DIAGTASK_p "reset_diagnosis_task(task_name=>'${input}')"
}
# ------------------------------------------------------------
f_diagtask_interrupt () { 
INPUT
DIAGTASK_p "interrupt_diagnosis_task(task_name=>'${input}')"
}
# ------------------------------------------------------------
f_diagtask_resume () { 
INPUT
DIAGTASK_p "resume_diagnosis_task(task_name=>'${input}')"
}
# ------------------------------------------------------------
f_diagtask_listexec () { 
SQLNEWF
SQLLINE "set pagesi 1000 head on feedback on verify off linesi 100 trimspool on"
SQLLINE "select task_name, execution_name from dba_advisor_executions where advisor_name='SQL Repair Advisor' and task_name like '%${input}%';"
SQLEXEC
}
# ------------------------------------------------------------
f_diagtask_report () { 
INPUT
v_file_name="DIAGTASK_REPORT_${ORACLE_SID}_${input}_$(date +%Y%m%d-%H%M%S).txt"
#HTML type will be supported in future releases
DIAGTASK_clob2file "REPORT_DIAGNOSIS_TASK(TASK_NAME=>'${input}',TYPE=>'TEXT',LEVEL=>'ALL',SECTION=>'ALL')"
}
# ------------------------------------------------------------

