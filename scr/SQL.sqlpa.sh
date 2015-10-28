# ############################################################
# SQLPA FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# SQLPA actions
action_L1="list_task list_exec convert explain execute compare report "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
execute,task_name:exec_identifier_PRE_or_POST,Execute_ANALYSIS_TASK \
compare,task_name,Compare_ANALYSIS_TASK \
report,task_name,Report_ANALYSIS_TASK \
"
# ------------------------------------------------------------
# local variables
typeset -u REPORTS_DIR="REPORTS_DIR"
# ------------------------------------------------------------
SQLPA_p () {
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_sqlpa.${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
SQLPA_f () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "x varchar2(1000);"
SQLLINE "begin"
SQLLINE "x:=dbms_sqlpa.${vLine};"
SQLLINE "dbms_output.put_line('Return value:'||x);"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
SQLPA_clob2file () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "v_clob clob;"
SQLLINE "begin"
SQLLINE "v_clob:=dbms_sqlpa.${vLine};"
SQLLINE "dbms_advisor.create_file(buffer=>v_clob,location=>'${REPORTS_DIR}',filename=>'${v_file_name}');"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
f_sqlpa_list_task () { 
SQLNEWF
SQLLINE "set pagesi 1000 head on feedback on"
SQLLINE "col task_name format a30"
SQLLINE "col status format a12"
SQLLINE "col source format a30"
SQLLINE "select task_name, execution_type, execution_start, execution_end,status from dba_advisor_tasks where advisor_name='SQL Performance Analyzer' order by task_name;"
SQLEXEC
}
# ------------------------------------------------------------
f_sqlpa_list_exec () { 
SQLNEWF
SQLLINE "set pagesi 1000 head on feedback on"
SQLLINE "col task_name format a30"
SQLLINE "col status format a12"
SQLLINE "col source format a30"
SQLLINE "select task_name, execution_type, execution_name, execution_start, execution_end,status from dba_advisor_executions where advisor_name='SQL Performance Analyzer' order by task_name;"
SQLEXEC
}
# ------------------------------------------------------------
f_sqlpa_convert () { 
INPUT
SQLPA_f "create_analysis_task(task_name=>'SPA_TASK_${input1}',sqlset_name=>'${input1}')"
SQLPA_p "execute_analysis_task(task_name=>'SPA_TASK_${input1}',execution_type=>'CONVERT SQLSET',execution_name=>'SPA_EXEC_CONV_${input1}')"
}
# ------------------------------------------------------------
f_sqlpa_explain () { 
INPUT 2
SQLPA_p "execute_analysis_task(task_name=>'${input1}',execution_type=>'EXPLAIN PLAN',execution_name=>'EXEC_${input1}_${input2}')"
}
# ------------------------------------------------------------
f_sqlpa_execute () { 
INPUT 2
SQLPA_p "execute_analysis_task(task_name=>'${input1}',execution_type=>'TEST EXECUTE',execution_name=>'EXEC_${input1}_${input2}')"
}
# ------------------------------------------------------------
f_sqlpa_compare () { 
INPUT
SQLPA_p "execute_analysis_task(task_name=>'${input}',execution_type=>'COMPARE PERFORMANCE',execution_name=>'COMPARE_${input}',execution_params => dbms_advisor.arglist('comparison_metric','buffer_gets'));"
}
# ------------------------------------------------------------
f_sqlpa_report () {
INPUT
v_file_name="SQLPA_REPORT_${ORACLE_SID}_${input1}_$(date +%Y%m%d-%H%M%S).text"
ECHO Report is $v_file_name
SQLPA_clob2file "REPORT_ANALYSIS_TASK(task_name=>'${input1}',type=>'TEXT',level=>'ALL',section=>'ALL')"
}
# ------------------------------------------------------------
f_sqlpa_report2 () {
# test 
DEBUG "report2 is empty"
#VAR rep   CLOB;
#EXEC :rep := DBMS_SQLPA.REPORT_ANALYSIS_TASK('my_spa_task', -
#                'text', 'typical', 'summary');
#SET LONG 100000 LONGCHUNKSIZE 100000 LINESIZE 130
#PRINT :rep
}
# ------------------------------------------------------------
