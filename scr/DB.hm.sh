# ############################################################
# DB HEALTH MONITOR FUNCTIONS (DBMS_HM)
# ############################################################
# ------------------------------------------------------------
# HEALTHMON actions
action_L1="list_types list_param list_runs list_findings list_recommendations "
action_L2="run run_with_param report "
action_L3="x "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list_type,None,List_HealthMonitor_Check_Types \
list_param,None,List_HealthMonitor_Check_Parameters \
list_runs,None,List_HealthMonitor_Check_Runs \
list_findings,run_id,List_HealthMonitor_Check_Runs \
list_recommendations,run_id:finding_id,List_HealthMonitor_Check_Recommendations \
run,check_type_id,Run_HealthMonitor_Check_for_given_check_id \
run_with_param,check_type_id:param_name_param_value,Run_HealthMonitor_Check_for_given_check_id \
report,run_name,Report_HealthMonitor_Check_for_given_run_name \
"
# ------------------------------------------------------------
# local variables
typeset -u REPORTS_DIR="REPORTS_DIR"
# ------------------------------------------------------------
DBMS_HM_p () {
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_hm.${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
DBMS_HM_clob2file () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "v_clob clob;"
SQLLINE "begin"
SQLLINE "v_clob:=dbms_hm.${vLine};"
SQLLINE "dbms_advisor.create_file(buffer=>v_clob,location=>'${REPORTS_DIR}',filename=>'${v_file_name}');"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
fGetCheckName () {
SQLNEWF
SQLLINE "set head off feedback off verify off pagesi 0"
SQLLINE "select name from v\$hm_check where id=${1};"
v_check_type=$(SQLEXEC)
ECHO v_check_type=${v_check_type}
}
# ------------------------------------------------------------
f_hm_list_types () {
SQLQRY "select id, name, cls_name,internal_check, offline_capable from v\$hm_check order by id;"
}
# ------------------------------------------------------------
f_hm_list_param () {
SQLNEWF
SQLLINE "set pagesi 1000 linesi 1000 trimspool on"
SQLLINE "col check_name format a30"
SQLLINE "col param_name format a30"
SQLLINE "SELECT b.id, b.name check_name, a.id, a.name param_name, a.default_value"
SQLLINE "FROM v\$hm_check_param a, v\$hm_check b WHERE a.check_id = b.id"
SQLLINE "order by b.id,a.id,a.name;"
SQLEXEC
}
# ------------------------------------------------------------
f_hm_list_runs () {
SQLNEWF
SQLLINE "set pagesi 1000 linesi 1000 trimspool on"
SQLLINE "col run_name format a20"
SQLLINE "col start_time format a20"
SQLLINE "select run_id ,name run_name ,check_name ,run_mode ,to_char(start_time,'YYYY-MM-DD HH24:MI:SS') start_time ,status from v\$hm_run;"
SQLEXEC
}
# ------------------------------------------------------------
f_hm_list_findings () {
INPUT
SQLNEWF
SQLLINE "set pagesi 1000 linesi 1000 trimspool on"
SQLLINE "col description format a40"
SQLLINE "col damage_description format a40"
SQLLINE "SELECT run_id,finding_id, status, type, description, damage_description"
SQLLINE "FROM v\$hm_finding WHERE run_id = ${input};"
SQLEXEC
}
# ------------------------------------------------------------
f_hm_list_recommendations () {
INPUT 2
SQLNEWF
SQLLINE "set pagesi 1000 linesi 1000 trimspool on"
SQLLINE "col name format a10"
SQLLINE "col repair_script format a60"
SQLLINE "SELECT name, type, rank, status, repair_script FROM v\$hm_recommendation "
SQLLINE "WHERE run_id=${input1} and fdg_id=${input2} order by fdg_id ;"
SQLEXEC
}
# ------------------------------------------------------------
f_hm_run () {
INPUT
fGetCheckName ${input1}
DBMS_HM_p "run_check(check_name=>'${v_check_type}')"
}
# ------------------------------------------------------------
f_hm_run_with_param () {
INPUT 2
fGetCheckName ${input1}
DBMS_HM_p "run_check(check_name=>'${v_check_type}',input_params=>'${input2}')"
}
# ------------------------------------------------------------
f_hm_report () {
INPUT
v_file_name="DBMS_HM_REPORT_${ORACLE_SID}_${input}_$(date +%Y%m%d-%H%M%S).html"
DBMS_HM_clob2file "get_run_report(run_name=>'${input}',report_type=>'HTML',report_level=>'BASIC')"
}
# ------------------------------------------------------------
