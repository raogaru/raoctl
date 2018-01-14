# ############################################################
# ADDM FUNCTIONS (DBMS_ADDM)
# ############################################################
# ------------------------------------------------------------
# ADDM actions
action_L1="list list_system_dir list_task_dir list_findings "
action_L2="analyze_db analyze_inst delete report "
action_L3="xx "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,,List_ADDM_Tasks  \
analyze_db,begin_snap_id:end_snap_id,Analyze_Database_using_ADDM  \
analyze_inst,begin_snap_id:end_snap_id:inst_number,Analyze_Instance_using_ADDM  \
delete,NONE,Delete_ADDM_Task_name  \
"
# ------------------------------------------------------------
# local variables
REPORTS_DIR=REPORTS_DIR
# ------------------------------------------------------------
ADDM_p () {
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_addm.${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
ADDM_f () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "x varchar2(1000);"
SQLLINE "begin"
SQLLINE "x:=dbms_addm.${vLine};"
SQLLINE "dbms_output.put_line('Return value:'||x);"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
ADDM_clob2file () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "v_clob clob;"
SQLLINE "begin"
SQLLINE "v_clob:=dbms_addm.${vLine};"
SQLLINE "dbms_advisor.create_file(buffer=>v_clob,location=>'${REPORTS_DIR}',filename=>'${v_file_name}');"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
f_addm_list () { 
SQLQRY "
set linesi 120 trims on
col task_name format a30
select task_id, task_name, created,begin_snap_id, end_snap_id from dba_addm_tasks order by task_id;
"
}
# ------------------------------------------------------------
f_addm_list_system_dir () { 
SQLQRY "select instance_id, instance_name, directive_name, description from dba_addm_system_directives order by instance_id;"
}
# ------------------------------------------------------------
f_addm_list_task_dir () { 
SQLQRY "select task_name, seq_id, instance_name, directive_name, description 
from dba_addm_task_directives order by seq_id;"
}
# ------------------------------------------------------------
f_addm_list_findings () { 
SQLQRY "select task_name, instance_name, directive_name, description 
from dba_addm_task_directives order by seq_id;"
}
# ------------------------------------------------------------
f_addm_list () { 
SQLQRY "select task_id, task_name, created,begin_snap_id, end_snap_id from dba_addm_tasks order by task_id;"
}
# ------------------------------------------------------------
f_addm_delete () { 
INPUT
ADDM_p "delete(task_name=>'${input1}')"
}
# ------------------------------------------------------------
f_addm_analyze_db () {
INPUT 2
SQLNEWF
SQLLINE "whenever sqlerror exit 1;"
SQLLINE "variable t_name varchar2(100)"
SQLLINE "execute dbms_addm.analyze_db(begin_snapshot=>${input1},end_snapshot=>${input2},task_name=>:t_name)"
SQLLINE "print :t_name"
SQLEXEC
}
# ------------------------------------------------------------
f_addm_analyze_inst () {
INPUT 3
SQLNEWF
SQLLINE "whenever sqlerror exit 1;"
SQLLINE "variable t_name varchar2(100)"
SQLLINE "execute dbms_addm.analyze_inst(begin_snapshot=>${input1},end_snapshot=>${input2},instance_number=>${input3},task_name=>:t_name)"
SQLLINE "print :t_name"
SQLEXEC
}
# ------------------------------------------------------------
f_addm_report () {
INPUT
v_file_name="ADDM_REPORT_${ORACLE_SID}_${input1}_$(date +%Y%m%d-%H%M%S).txt"
ADDM_clob2file "get_report(task_name=>'${input1}')"
ECHO "Report file : $v_file_name"
}
# ------------------------------------------------------------
