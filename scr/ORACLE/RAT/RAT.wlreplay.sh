# ############################################################
# WORKLOAD REPLAY FUNCTIONS (REAL APPLICATION TESTING - REPLAY)
# ############################################################
# ------------------------------------------------------------
# WLREPLAY actions
action_L1="config unconfig status addfil delfil listfil process  "
action_L2="process initialize prepare start pause resume cancel report compare_report export_awr delete systab "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
status,,Display_Status \
config,,Configure_Workload_Capture \
unconfig,,UnConfigure_Workload_Capture \
addfil,filter_name:attribute:value,Add_filter \
delfil,filter_name,Delete_filter \
listfil,None,List_filter \
start,,Start_Replay \
"
# ------------------------------------------------------------
# local variables
v_debug=0
DBCAPTURE_DIR_OBJ="DBCAPTURE_DIR"
DBREPLAY_DIR_OBJ="DBCAPTURE_DIR"
DBCAPTURE_USR="DBCAPTURE_ADM"
DBCAPTURE_DIR_LOC="/oracle/stage/${ORACLE_SID}/dbcapture"
REPORTS_DIR_OBJ="REPORTS_DIR"
# ------------------------------------------------------------
WORKLOAD_p () {
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_workload_replay.${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
WORKLOAD_f () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "v_clob clob;"
SQLLINE "begin"
SQLLINE "v_clob:=dbms_workload_replay.${vLine};"
SQLLINE "dbms_advisor.create_file(buffer=>v_clob,location=>'${REPORTS_DIR_OBJ}',filename=>'${v_file_name}');"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
f_wlreplay_status () { 
SQLNEWF
SQLLINE "set pagesi 1000 head on feedback off verify off linesi 130 trimspool on"
SQLLINE "col name format a20"
SQLLINE "col directory format a20"
SQLLINE "col status format a12"
SQLLINE "select id, name, dbname, directory, capture_id, status from DBA_WORKLOAD_REPLAYS;"
SQLEXEC
}
# ------------------------------------------------------------
f_wlreplay_config () {
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
f_wlreplay_unconfig () {
SQLNEWF
SQLLINE "set pagesi 0 head off feedback off verify off"
SQLLINE "DROP USER ${DBCAPTURE_USR} CASCADE;"
SQLLINE "DROP DIRECTORY ${DBCAPTURE_DIR_OBJ};"
SQLEXEC
}
# ------------------------------------------------------------
f_wlreplay_addfil () {
INPUT 3
[[ ! ${input2} = @(INSTANCE_NUMBER|USER|MODULE|ACTION|PROGRAM|SERVICE) ]] && ERROR "Invalid Attribute \"${input2}\""
WORKLOAD_p "add_filter(FNAME=>'${input1}',FATTRIBUTE=>'${input2}',FVALUE=>'${input3}')"
}
# ------------------------------------------------------------
f_wlreplay_delfil () {
INPUT
WORKLOAD_p "delete_filter(FNAME=>'${input}')"
}
# ------------------------------------------------------------
f_wlreplay_listfil () {
SQLQRY "select 'type='||type||' status='||status||' name='||substr(name,1,30)||' attribute='||substr(attribute,1,30)||' value='||substr(value,1,30) from dba_workload_filters;"
}
# ------------------------------------------------------------
f_wlreplay_process () {
WORKLOAD_p "process_capture(capture_dir=>'${DBCAPTURE_DIR_OBJ}')"
}
# ------------------------------------------------------------
f_wlreplay_initialize () {
INPUT
WORKLOAD_p "initialize_replay(replay_name=>'${input1}', replay_dir=>'${DBREPLAY_DIR_OBJ}')"
}
# ------------------------------------------------------------
f_wlreplay_prepare () {
WORKLOAD_p "prepare_replay"
}
# ------------------------------------------------------------
f_wlreplay_start () {
$ORACLE_HOME/bin/wrc userid=${DBCAPTURE_USR} password=${DBCAPTURE_USR} debug=off workdir=${DBCAPTURE_DIR_LOC} &
v_pid=$!
sleep 10
WORKLOAD_p "start_replay"
while [ 1 ]
do
	ps -ef|grep "$ORACLE_HOME/bin/wrc" > /dev/null 2>&1
	[[ $? -eq 0 ]] && ECHO WRC running ...
	sleep 10
done
}
# ------------------------------------------------------------
f_wlreplay_pause () {
WORKLOAD_p "pause_replay"
}
# ------------------------------------------------------------
f_wlreplay_resume () {
WORKLOAD_p "pause_replay"
}
# ------------------------------------------------------------
f_wlreplay_cancel () {
WORKLOAD_p "cancel_replay"
}
# ------------------------------------------------------------
f_wlreplay_delete () {
INPUT
WORKLOAD_p "delete_replay_info(replay_id=>${input})"
}
# ------------------------------------------------------------
f_wlreplay_report () {
INPUT
v_file_name="WLREPLAY_REPORT_${ORACLE_SID}_${input}_$(date +%Y%m%d-%H%M%S).html"
WORKLOAD_f "report(replay_id=>${input}, format =>'HTML')"
}
# ------------------------------------------------------------
f_wlreplay_compare_report () {
INPUT 2
v_file_name="WLREPLAY_COMPARE_REPORT_${ORACLE_SID}_${input1}_${input2}_$(date +%Y%m%d-%H%M%S).html"
WORKLOAD_f "compare_period_report(replay_id1=>${input1}, replay_id2=>${input2}, format =>'HTML')"
}
# ------------------------------------------------------------
f_wlreplay_export_awr () {
INPUT
WORKLOAD_p "export_awr(replay_id=>${input})"
}
# ------------------------------------------------------------
f_wlreplay_systab () {
SQLQRY "select object_type||'  '||owner||'.'||object_name from dba_objects where object_name like 'WRR\$_REPLAY%' order by object_type, object_name;"
}
#MARK ############################
