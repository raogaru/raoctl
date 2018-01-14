# ############################################################
# WORKLOAD CAPTURE FUNCTIONS (REAL APPLICATION TESTING - CAPTURE)
# ############################################################
# ------------------------------------------------------------
# WLCAPTURE actions
action_L1="config unconfig status addfil delfil listfil start finish report export_awr delete systab "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
config,,Configure_Workload_Capture \
unconfig,,UnConfigure_Workload_Capture \
status,,Display_Status \
addfil,filter_name:attribute:value,Add_filter \
delfil,filter_name,Delete_filter \
listfil,None,List_filter \
start,capture_name,Start_RAT_Capture \
Stop,capture_name,Stop_RAT_Capture \
"
# ------------------------------------------------------------
# local variables
DBCAPTURE_DIR_OBJ="DBCAPTURE_DIR"
DBCAPTURE_USR="DBCAPTURE_ADM"
DBCAPTURE_DIR_LOC="/oracle/stage/${ORACLE_SID}/dbcapture"
REPORTS_DIR_OBJ="REPORTS_DIR"
# ------------------------------------------------------------
WORKLOAD_p () {
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_workload_capture.${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
WORKLOAD_f () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "v_clob clob;"
SQLLINE "begin"
SQLLINE "v_clob:=dbms_workload_capture.${vLine};"
SQLLINE "dbms_advisor.create_file(buffer=>v_clob,location=>'${REPORTS_DIR_OBJ}',filename=>'${v_file_name}');"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
f_wlcapture_status () { 
SQLQRY "select 'id='||to_char(id)||' name='||name||' directory_object='||directory||' status='||status||' filters_used='||to_char(filters_used) RAT_Capture_status from dba_workload_captures;"
}
# ------------------------------------------------------------
f_wlcapture_config () {
SQLNEWF
SQLLINE "set pagesi 0 head off feedback on verify off"
SQLLINE "CREATE USER ${DBCAPTURE_USR} IDENTIFIED BY ${DBCAPTURE_USR};"
SQLLINE "GRANT EXECUTE ON DBMS_WORKLOAD_CAPTURE TO ${DBCAPTURE_USR};"
SQLLINE "GRANT EXECUTE ON DBMS_WORKLOAD_REPLAY TO ${DBCAPTURE_USR};"
SQLLINE "GRANT CREATE SESSION TO ${DBCAPTURE_USR};"
SQLLINE "GRANT CREATE ANY DIRECTORY TO ${DBCAPTURE_USR};"
SQLLINE "GRANT SELECT_CATALOG_ROLE TO ${DBCAPTURE_USR};"
SQLLINE "GRANT BECOME USER TO ${DBCAPTURE_USR};"
SQLLINE "CREATE OR REPLACE DIRECTORY ${DBCAPTURE_DIR_OBJ} AS '${DBCAPTURE_DIR_LOC}';"
SQLLINE "CREATE OR REPLACE DIRECTORY REPORTS_DIR AS '${RPT_DIR}';"
SQLEXEC
}
# ------------------------------------------------------------
f_wlcapture_unconfig () {
SQLNEWF
SQLLINE "set pagesi 0 head off feedback off verify off"
SQLLINE "DROP USER ${DBCAPTURE_USR} CASCADE;"
SQLLINE "DROP DIRECTORY ${DBCAPTURE_DIR_OBJ};"
SQLEXEC
}
# ------------------------------------------------------------
f_wlcapture_addfil () {
INPUT 3
[[ ! ${input2} = @(INSTANCE_NUMBER|USER|MODULE|ACTION|PROGRAM|SERVICE) ]] && ERROR "Invalid Attribute \"${input2}\""
WORKLOAD_p "add_filter(FNAME=>'${input1}',FATTRIBUTE=>'${input2}',FVALUE=>'${input3}')"
}
# ------------------------------------------------------------
f_wlcapture_delfil () {
INPUT
WORKLOAD_p "delete_filter(FNAME=>'${input}')"
}
# ------------------------------------------------------------
f_wlcapture_listfil () {
SQLQRY "select 'type='||type||' status='||status||' name='||substr(name,1,30)||' attribute='||substr(attribute,1,30)||' value='||substr(value,1,30) filter_information from dba_workload_filters;"
}
# ------------------------------------------------------------
f_wlcapture_listfil_old () {
SQLNEWF
SQLLINE "set pagesi 1000 head on feedback off verify off linesi 130 trimspool on"
SQLLINE "col type format a10"
SQLLINE "col name format a30"
SQLLINE "col attribute format a30"
SQLLINE "col value format a30"
SQLLINE "select type, status,substr(name,1,30) name,substr(attribute,1,30) attribute, substr(value,1,30) value from dba_workload_filters;"
SQLEXEC
}
# ------------------------------------------------------------
f_wlcapture_start () {
INPUT
WORKLOAD_p "start_capture(NAME=>'${input}', DIR=>'${DBCAPTURE_DIR_OBJ}', DEFAULT_ACTION=>'EXCLUDE')"
}
# ------------------------------------------------------------
f_wlcapture_finish () {
WORKLOAD_p "finish_capture(TIMEOUT=>0, REASON =>'catpure_end')"
}
# ------------------------------------------------------------
f_wlcapture_report () {
INPUT
v_file_name="WLCAPTURE_REPORT_${ORACLE_SID}_${input}_$(date +%Y%m%d-%H%M%S).html"
WORKLOAD_f "report(capture_id=>${input}, format =>'HTML')"
ECHO "Report Location: ${REPORT_DIR_OBJ}  File Name: ${v_file_name}"
}
# ------------------------------------------------------------
f_wlcapture_export_awr () {
INPUT
WORKLOAD_p "export_awr(capture_id=>${input})"
}
# ------------------------------------------------------------
f_wlcapture_delete () {
INPUT
WORKLOAD_p "delete_capture_info(capture_id=>${input})"
}
# ------------------------------------------------------------
f_wlcapture_systab () {
SQLQRY "select object_type||'  '||owner||'.'||object_name from dba_objects where object_name like 'WRR\$%' and object_name not like 'WRR\$_REPLAY%' order by object_type, object_name;"
}
# ------------------------------------------------------------
