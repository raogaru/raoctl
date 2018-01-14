# ############################################################
# STREAMS CONFIG FUNCTIONS - Oracle Streams
# ############################################################
# ------------------------------------------------------------
# STREAMS CONFIG actions
action_L1="all_phases config phase1 phase2 phase3 phase4 phase5 phase6 phase7 rmdmlh  "
action_L2="test1 test2 test3  "
action_L3="start stop restart delete1 delete report "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
all_phases,None,Phase1_Setup_Streams_IDs \
config,None,Phase0_Read_Config \
phase1,None,Phase1_Setup_Streams_IDs \
phase2,None,Phase2_Setup_DB_Links \
phase3,None,Phase3_Setup_Rules \
phase4,None,Phase4_Setup_Queues \
phase5,None,Phase5_Set_Rules \
phase6,None,Phase6_Instantiate \
phase7,None,Phase7_Set_DML_Handler \
test1,None,Test1_Test_connections \
test2,None,Test2_Test_Flows \
test3,None,Test3_Replication_Delay \
stop,None,Stop_queues \
start,None,Start_queues \
restart,None,ReStart_queues \
delete,None,Delete_streams_config \
report,None,Report_streams_config \
diag,None,Diag_streams_config \
"
# ------------------------------------------------------------
# Module specific environment variables
v_debug=1
# ------------------------------------------------------------
INCLIB_c
# ------------------------------------------------------------
# REPLICATION SITES CONFIGURATION INFO in MultiMaster.cfg
#STREAM_SITES:SMS1,SMS2,SMS3
#SITE_INFO=SITE:DBO:ORALCE_SID
#SITE_INFO_SMS1=SMS:SMS1
#SITE_INFO_SMS2=SMS:SMS2
#SITE_INFO_SMS3=SMS:SMS3
# ------------------------------------------------------------
TestSysConnection () {
DEBUG Test SYS Connection on ${ON_SID}
SQLNEWF
SQLLINE "select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss')||user from dual;"
STREXEC as sysdba ${ON_SID} 
}
# ------------------------------------------------------------
TestDbaConnection () {
DEBUG Test DBA Connection on ${ON_SID}
SQLNEWF
SQLLINE "select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss')||user from dual;"
STREXEC ${STRDBA} ${STRDBA_PWD} ${ON_SID} 
}
# ------------------------------------------------------------
TestAdmConnection () {
DEBUG Test Stream Admin Connection on ${ON_SID}
SQLNEWF
SQLLINE "select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss')||user from dual;"
STREXEC ${STRADM} ${STRADM_PWD} ${ON_SID}
}
# ------------------------------------------------------------
TestDboConnection () {
DEBUG Test DBO Connection on ${ON_SID}
SQLNEWF
SQLLINE "select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss')||user from dual;"
STREXEC ${ON_DBO} ${STRDBO_PWD} ${ON_SID}
}
# ------------------------------------------------------------
TestDblinkConnection () {
DEBUG Test DB Link Connection on ${ON_SID} TO ${TO_SID}
SQLNEWF
SQLLINE "select 'Connection From:'||user||'@'||global_name from global_name;"
SQLLINE "select 'Connection To:'||user||'@'||global_name from global_name@${TO_SID};"
STREXEC ${STRADM} ${STRADM_PWD} ${ON_SID}
}
# ------------------------------------------------------------
CreateSchemaUser () {
DEBUG CreateSchemaUser ${ON_DBO} on ${ON_SID}
SQLNEWF
SQLLINE "create user ${ON_DBO} identified by ${STRDBO_PWD} "
SQLLINE "default tablespace raogaru temporary tablespace temp quota unlimited on raogaru;"
SQLLINE "grant create session, dba to ${ON_DBO};"
SQLLINE "grant execute on dbms_flashback to ${ON_DBO};"
#SQLLINE "grant select on v\$database to ${ON_DBO};"
STREXEC ${STRDBA} ${STRDBA_PWD} ${ON_SID}
}
# ------------------------------------------------------------
CreateAdminUser () { 
DEBUG CreateAdminUser ${STRADM} on ${ON_SID}
SQLNEWF
SQLLINE "create user ${STRADM} identified by ${STRADM_PWD} "
SQLLINE "default tablespace raogaru temporary tablespace temp quota unlimited on raogaru;"
SQLLINE "grant create session,dba,select_catalog_role to ${STRADM};"
SQLLINE "exec dbms_streams_auth.grant_admin_privilege(grantee => '${STRADM}');"
SQLLINE "grant execute on dbms_pipe to ${STRADM};" # needed for debugging
SQLLINE "grant execute on dbms_lock to ${STRADM};" # needed for utl_spadv (stream pool advisor)
STREXEC ${STRDBA} ${STRDBA_PWD} ${ON_SID}
}

# ------------------------------------------------------------
EnableSupplementalLogging () { 
DEBUG EnableSupplementalLogging on ${ON_SID}
SQLNEWF
SQLLINE "alter database add supplemental log data;"
#SQLLINE "select supplemental_log_data_min FROM v$\database;"
STREXEC ${STRDBA} ${STRDBA_PWD} ${ON_SID}
}
# ------------------------------------------------------------
GetFlashbackSCN () {
ON_SID=${1}
SQLNEWF
SQLLINE "select dbms_flashback.get_system_change_number from dual;"
STREXEC ${STRADM} ${STRADM_PWD} ${ON_SID}
}
# ------------------------------------------------------------
SetSchemaInstantiationSCN () {
DEBUG SetSchemaInstantiationSCN ${START_SCN} on ${TO_SID} for_source ${ON_DBO}@${ON_SID} 
SQLNEWF
SQLLINE "BEGIN"
SQLLINE "dbms_apply_adm.set_schema_instantiation_scn("
SQLLINE "   source_schema_name => '${ON_DBO}',"
SQLLINE "   source_database_name => '${ON_SID}',"
SQLLINE "   instantiation_scn => ${START_SCN},"
SQLLINE "   recursive => true);"
SQLLINE "END;"
SQLLINE "/"
STREXEC ${STRADM} ${STRADM_PWD} ${TO_SID}
}
# ------------------------------------------------------------
CreateSchemaObjects () {
DEBUG CreateSchemaObjects in ${ON_DBO} on ${ON_SID}
SQLNEWF
SQLLINE "create sequence ${ON_DBO}.seq;"
SQLLINE "create table ${ON_DBO}.hb ("
SQLLINE "source_db varchar2(8), target_db varchar2(8),"
SQLLINE "source_scn number, target_scn number,"
SQLLINE "source_time timestamp, target_time timestamp, id number(8)) "
SQLLINE "tablespace raogaru;"
SQLLINE "alter table ${ON_DBO}.hb modify (source_db default '${ON_SID}');"
SQLLINE "alter table ${ON_DBO}.hb add constraint hb_pk primary key (source_db, target_db);"
#SQLLINE "alter table ${ON_DBO}.hb add supplemental log data (all) columns;"
#SQLLINE "alter table ${ON_DBO}.xxx add supplemental log data (foreign_key) columns;"
#SQLLINE "alter table ${ON_DBO}.xxx add supplemental log data (unique) columns;"
SQLLINE "alter table ${ON_DBO}.hb add supplemental log data (primary key) columns;"
#SQLLINE "alter table ${ON_DBO}.xxx add supplemental log group (first unique index columns) always;"
#SQLLINE "alter table ${ON_DBO}.xxx add supplemental log data (primary key, foreign key, unique) columns;"
SQLLINE "grant all on ${ON_DBO}.hb to ${STRADM};"
SQLLINE "create public synonym hb for ${ON_DBO}.hb;"

#SQLLINE "create table ${ON_DBO}.log (db varchar2(8), usr varchar2(30), obj varchar2(30), operation varchar2(30), scn1 number, txt varchar2(60));"

STREXEC ${ON_DBO} ${STRDBO_PWD} ${ON_SID}
}
# ------------------------------------------------------------
HeartBeatInsert () {
DEBUG HeartBeatInsert source_db ${ON_SID} target_db ${TO_SID}
SQLNEWF
SQLLINE "select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss')||user from dual;"
SQLLINE "insert into ${ON_DBO}.hb values ('${ON_SID}','${TO_SID}', dbms_flashback.get_system_change_number, null, sysdate, null, ${ON_DBO}.seq.nextval);"
STREXEC ${ON_DBO} ${STRDBO_PWD} ${ON_SID}
}
# ------------------------------------------------------------
HeartBeatMerge () {
DEBUG HeartBeatMerge in ${ON_SID} data from ${TO_SID}
SQLNEWF
SQLLINE "merge into ${ON_DBO}.hb l using (select source_db, target_db, source_scn, target_scn, source_time, target_time, id from ${ON_DBO}.hb@${TO_SITE} ) r"
SQLLINE "on (l.source_db=r.source_db and l.target_db=r.target_db)"
SQLLINE "when not matched then"
SQLLINE "    INSERT (source_db, target_db, source_scn, source_time, target_scn, target_time,id)"
SQLLINE "    VALUES (r.source_db, r.target_db, r.source_scn, r.source_time, r.target_scn, r.target_time, r.id);"
STREXEC ${STRADM} ${STRADM_PWD} ${ON_SID}
}
# ------------------------------------------------------------
StreamAdminObjects() {
DEBUG StreamAdminObjects on ${ON_SID}
SQLNEWF
SQLLINE "@hb_upd.sql"
SQLLINE "@stradmin.pks"
SQLLINE "@stradmin.pkb"
SQLLINE "@strdebug.pks"
SQLLINE "@strdebug.pkb"
STREXEC ${STRADM} ${STRADM_PWD} ${ON_SID}
}
# ------------------------------------------------------------
HeartBeatUpdateJob () {
DEBUG HeartBeatUpdateJob on ${ON_SID}
SQLNEWF
SQLLINE "@hb_job.sql"
STREXEC ${STRADM} ${STRADM_PWD} ${ON_SID}
}
# ------------------------------------------------------------
HeartBeatDmlHandProc () {
DEBUG HeartBeatDmlHandProc on ${TO_SID}
SQLNEWF
SQLLINE "@hb_dml_h.sql"
#SQLLINE "@txn_dml_h.sql"
STREXEC ${TO_DBO} ${STRDBO_PWD} ${TO_SID}
}
# ------------------------------------------------------------
HeartBeatDmlHandSet () {
DEBUG HeartBeatDmlHandSet on ${TO_SID}
SQLNEWF
#SQLLINE "@hb_dml_h.sql"
DBMS_APPLY_ADM "set_dml_handler( object_name=> '${TO_DBO}.HB', object_type=> 'TABLE', operation_name=> 'UPDATE', error_handler=> FALSE, user_procedure=> '${TO_DBO}.HB_DML_H', apply_database_link=> NULL, apply_name=> '${APPLY_NAME}')"
STREXEC ${STRADM} ${STRADM_PWD} ${TO_SID}
}
# ------------------------------------------------------------
HeartBeatDmlHandUnSet () {
DEBUG HeartBeatDmlHandUnSet on ${TO_SID}
SQLNEWF
DBMS_APPLY_ADM "set_dml_handler( object_name=> '${TO_DBO}.HB', object_type=> 'TABLE', operation_name=> 'UPDATE', error_handler=> FALSE, user_procedure=> NULL, apply_database_link=> NULL, apply_name=> '${APPLY_NAME}')"
STREXEC ${STRADM} ${STRADM_PWD} ${TO_SID}
}
# ------------------------------------------------------------
CreateDatabaseLink () { 
DEBUG CreateDatabaseLink ${TO_SITE} on ${ON_SID} to ${TO_SID}
SQLNEWF
SQLLINE "create database link ${TO_SITE} connect to ${STRADM} identified by ${STRADM_PWD} using '${TO_SID}';"
STREXEC ${STRADM} ${STRADM_PWD} ${ON_SID}
}
# ------------------------------------------------------------
DBMS_CAPTURE_ADM (){
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_capture_adm.${vLine};"
STREXEC ${STRADM} ${STRADM_PWD} ${ON_SID}
}
# ------------------------------------------------------------
DBMS_APPLY_ADM (){
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_apply_adm.${vLine};"
STREXEC ${STRADM} ${STRADM_PWD} ${TO_SID}
}
# ------------------------------------------------------------
DBMS_PROPAGATION_ADM (){
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_propagation_adm.${vLine};"
STREXEC ${STRADM} ${STRADM_PWD} ${ON_SID}
}
# ------------------------------------------------------------
DBMS_STREAMS_ADM (){
vSID="$1"
vLine="$2"
SQLNEWF
SQLLINE "exec dbms_streams_adm.${vLine};"
STREXEC ${STRADM} ${STRADM_PWD} ${vSID}
}
# ------------------------------------------------------------
DBMS_RULE_ADM (){
vSID="$1"
vLine="$2"
SQLNEWF
SQLLINE "exec dbms_rule_adm.${vLine};"
STREXEC ${STRADM} ${STRADM_PWD} ${vSID}
}
# ============================================================
# RULE FUNCTIONS
# ============================================================
# ------------------------------------------------------------
CreateRuleSet () {
DEBUG CreateRuleSet ${2} on ${1}
DBMS_RULE_ADM ${1} "create_rule_set(rule_set_name=> '${STRADM}.${2}', evaluation_context=>'SYS.STREAMS\$_EVALUATION_CONTEXT')"
}
# ------------------------------------------------------------
DropRuleSet () {
DEBUG DropRuleSet ${2} on ${1}
DBMS_RULE_ADM ${1} "drop_rule_set(rule_set_name=> '${STRADM}.${2}', delete_rules=>FALSE)"
}
# ------------------------------------------------------------
CreateRule () {
DEBUG CreateRule ${2} on ${1}
DBMS_RULE_ADM ${1} "create_rule(rule_name=>'${STRADM}.${2}', condition=>' ${3} ')"
}
# ------------------------------------------------------------
DropRule () {
DEBUG DropRule ${2} on ${1}
DBMS_RULE_ADM ${1} "drop_rule(rule_name=>'${STRADM}.${2}', force=>FALSE)"
}
# ------------------------------------------------------------
AddRule () {
DEBUG AddRule ${2} on ${1}
DBMS_RULE_ADM ${1} "add_rule(rule_name=>'${STRADM}.${2}', rule_set_name=>'${STRADM}.${3}', evaluation_context=>NULL)"
}
# ------------------------------------------------------------
RemoveRule () {
DEBUG RemoveRule ${2} on ${1}
DBMS_RULE_ADM ${1} "remove_rule(rule_name=>'${STRADM}.${2}', rule_set_name=>'${STRADM}.${3}')"
}
# ------------------------------------------------------------
CreateQueue () { # 1=Q-type (CAPTURE/APPLY) 2=SID
Q_TYPE=${1}
vSID=${2}
Q_TYPEC=$(echo ${Q_TYPE}|cut -c1)
Q_NAME="${Q_TYPEC}_${ON_SITE}_TO_${TO_SITE}_Q"
QT_NAME="${Q_NAME}T"
DEBUG CreateQueue ${Q_NAME} on ${vSID}
SQLNEWF
SQLLINE "BEGIN"
SQLLINE "dbms_streams_adm.set_up_queue ("
SQLLINE "   queue_table  => '${QT_NAME}',"
SQLLINE "   queue_name   => '${Q_NAME}',"
SQLLINE "   queue_user   => '${STRADM}');"
SQLLINE "END;"
SQLLINE "/"
STREXEC ${STRADM} ${STRADM} ${vSID}
}
# ============================================================
# CAPTURE FUNCTIONS
# ============================================================
# ------------------------------------------------------------
DictionaryBuild () {
DEBUG DictionaryBuild on ${ON_SID}
DBMS_CAPTURE_ADM "build"
}
# ------------------------------------------------------------
CreateCaptureQueue () {
DEBUG CreateCaptureQueue ${CAPTURE_QUEUE_NAME} on ${ON_SID}
SQLNEWF
SQLLINE "BEGIN"
SQLLINE "dbms_streams_adm.set_up_queue ("
SQLLINE "   queue_table  => '${CAPTURE_QUEUE_TABLE_NAME}',"
SQLLINE "   queue_name   => '${CAPTURE_QUEUE_NAME}',"
SQLLINE "   queue_user   => '${STRADM}');"
SQLLINE "END;"
SQLLINE "/"
STREXEC ${STRADM} ${STRADM_PWD} ${ON_SID}
}
# ------------------------------------------------------------
CreateCapture () {
DEBUG CreateCapture ${CAPTURE_NAME} on ${ON_SID}
DBMS_CAPTURE_ADM "create_capture(queue_name=> '${CAPTURE_QUEUE_NAME}', capture_name=> '${CAPTURE_NAME}')"
}
# ------------------------------------------------------------
StartCapture () {
DEBUG StartCapture ${CAPTURE_NAME} on ${ON_SID}
DBMS_CAPTURE_ADM "start_capture('${CAPTURE_NAME}')"
}
# ------------------------------------------------------------
StopCapture () {
DEBUG StopCapture ${CAPTURE_NAME} on ${ON_SID}
DBMS_CAPTURE_ADM "stop_capture('${CAPTURE_NAME}')"
}
# ------------------------------------------------------------
DropCapture () {
DEBUG DropCapture ${CAPTURE_NAME} on ${ON_SID}
DBMS_CAPTURE_ADM "drop_capture('${CAPTURE_NAME}')"
}
# ------------------------------------------------------------
SetCaptureParameter () {
DEBUG SetCaptureParameter on ${ON_SID} 
DBMS_CAPTURE_ADM "set_parameter(capture_name=>'${CAPTURE_NAME}', parameter=> '${1}', value=> '${2}')"
}
# ------------------------------------------------------------
SetCapturePositiveRule () {
DEBUG SetCapturePositiveRule ${CAPTURE_NAME} on ${ON_SID}
DBMS_CAPTURE_ADM "alter_capture(capture_name=> '${CAPTURE_NAME}', rule_set_name=>'${CAPTURE_RULESET_NAME}_P')"
}
# ------------------------------------------------------------
SetCaptureNegativeRule () {
DEBUG SetCaptureNegativeRule ${CAPTURE_NAME} on ${ON_SID}
DBMS_CAPTURE_ADM "alter_capture(capture_name=> '${CAPTURE_NAME}', negative_rule_set_name=>'${CAPTURE_RULESET_NAME}_N')"
}
# ------------------------------------------------------------
CreateStream () { # 1=Q-type 2=dbo 3=sid
Q_TYPE=${1}
DBO=${2}
SID=${3}
Q_TYPEC=$(echo ${Q_TYPE}|cut -c1)
S_NAME="${Q_TYPEC}_${ON_SITE}_TO_${TO_SITE}"
Q_NAME="${S_NAME}_Q"
DEBUG CreateStream ${Q_TYPE} ${S_NAME} on ${SID}
SQLNEWF
SQLLINE "BEGIN"
SQLLINE "dbms_streams_adm.add_schema_rules("
SQLLINE "   schema_name    =>'${DBO}',"
SQLLINE "   streams_type   =>'${Q_TYPE}',"
SQLLINE "   streams_name   =>'${S_NAME}',"
SQLLINE "   queue_name     =>'${STRADM}.${Q_NAME}',"
SQLLINE "   include_dml    =>TRUE,"
SQLLINE "   include_ddl    =>TRUE,"
SQLLINE "   source_database=>'${ON_SID}');"
SQLLINE "END;"
SQLLINE "/"
STREXEC ${STRADM} ${STRADM_PWD} ${SID}
}
# ============================================================
# APPLY FUNCTIONS
# ============================================================
# ------------------------------------------------------------
CreateApplyQueue () {
DEBUG CreateApplyQueue ${APPLY_QUEUE_NAME} on ${TO_SID}
SQLNEWF
SQLLINE "BEGIN"
SQLLINE "dbms_streams_adm.set_up_queue ("
SQLLINE "   queue_table  => '${APPLY_QUEUE_TABLE_NAME}',"
SQLLINE "   queue_name   => '${APPLY_QUEUE_NAME}',"
SQLLINE "   queue_user   => '${STRADM}');"
SQLLINE "END;"
SQLLINE "/"
STREXEC ${STRADM} ${STRADM_PWD} ${TO_SID}
}
# ------------------------------------------------------------
CreateApply () {
DEBUG CreateApply ${APPLY_NAME} on ${ON_SID}
DBMS_APPLY_ADM "create_apply(queue_name=> '${APPLY_QUEUE_NAME}', apply_name=> '${APPLY_NAME}',apply_captured=>true)"
}
# ------------------------------------------------------------
StartApply () {
DEBUG StartApply ${APPLY_NAME} on ${TO_SID}
DBMS_APPLY_ADM "start_apply('${APPLY_NAME}')"
}
# ------------------------------------------------------------
StopApply () {
DEBUG StopApply ${APPLY_NAME} on ${TO_SID}
DBMS_APPLY_ADM "stop_apply('${APPLY_NAME}')"
}
# ------------------------------------------------------------
DropApply () {
DEBUG DropApply ${APPLY_NAME} on ${TO_SID}
DBMS_APPLY_ADM "drop_apply('${APPLY_NAME}')"
}
# ------------------------------------------------------------
SetApplyParameter () {
DEBUG SetApplyParameter on ${TO_SID} 
DBMS_APPLY_ADM "set_parameter(apply_name=>'${APPLY_NAME}', parameter=> '${1}', value=> '${2}')"
}
# ------------------------------------------------------------
SetApplyPositiveRule () {
DEBUG SetApplyPositiveRule ${APPLY_NAME} on ${ON_SID}
DBMS_APPLY_ADM "alter_apply(apply_name=> '${APPLY_NAME}', rule_set_name=>'${APPLY_RULESET_NAME}_P')"
}
# ------------------------------------------------------------
SetApplyNegativeRule () {
DEBUG SetApplyNegativeRule ${APPLY_NAME} on ${ON_SID}
DBMS_APPLY_ADM "alter_apply(apply_name=> '${APPLY_NAME}', negative_rule_set_name=>'${APPLY_RULESET_NAME}_N')"
}
# ============================================================
# PROPAGATION FUNCTIONS
# ============================================================
# ------------------------------------------------------------
CreatePropagation () {
DEBUG CreatePropagation ${PROPAGATION_NAME} on ${ON_SID}
DBMS_PROPAGATION_ADM "create_propagation(propagation_name=>'${PROPAGATION_NAME}', source_queue=>'${CAPTURE_QUEUE_NAME}',destination_queue=>'${APPLY_QUEUE_NAME}',destination_dblink=>'${TO_SITE}',queue_to_queue=>true)"
}
# ------------------------------------------------------------
PropagationAddSchemaRule () {
DEBUG PropagationAddSchemaRule ${PROPAGATION_NAME} on ${ON_SID}
DBMS_STREAMS_ADM ${ON_SID} "add_schema_propagation_rules ( schema_name=> '${ON_DBO}', streams_name=> '${PROPAGATION_NAME}', source_queue_name=> '${CAPTURE_QUEUE_NAME}', destination_queue_name=> '${APPLY_QUEUE_NAME}@${TO_SITE}', include_dml=>  TRUE, include_ddl=>  TRUE)"
}
# ------------------------------------------------------------
StartPropagation () {
DEBUG StartPropagation ${PROPAGATION_NAME} on ${ON_SID}
DBMS_PROPAGATION_ADM "start_propagation(propagation_name=>'${PROPAGATION_NAME}')"
}
# ------------------------------------------------------------
StopPropagation () {
DEBUG StopPropagation ${PROPAGATION_NAME} on ${ON_SID}
DBMS_PROPAGATION_ADM "stop_propagation(propagation_name=>'${PROPAGATION_NAME}', force=>TRUE)"
}
# ------------------------------------------------------------
SetPropagationPositiveRule () {
DEBUG SetPropagationPositiveRule ${PROPAGATION_NAME} on ${ON_SID}
DBMS_PROPAGATION_ADM "alter_propagation(propagation_name=> '${PROPAGATION_NAME}', rule_set_name=>'${PROPAGATION_RULESET_NAME}_P')"
}
# ------------------------------------------------------------
SetPropagationNegativeRule () {
DEBUG SetPropagationNegativeRule ${PROPAGATION_NAME} on ${ON_SID}
DBMS_PROPAGATION_ADM "alter_propagation(propagation_name=> '${PROPAGATION_NAME}', negative_rule_set_name=>'${PROPAGATION_RULESET_NAME}_N')"
}
# ------------------------------------------------------------
DropPropagation () {
DEBUG DropPropagation ${PROPAGATION_NAME} on ${ON_SID}
DBMS_PROPAGATION_ADM "drop_propagation('${PROPAGATION_NAME}')"
}
# ------------------------------------------------------------
RemoveStreams () {
DEBUG RemoveStreams from ${ON_SID}
SQLNEWF
SQLLINE "exec dbms_streams_adm.remove_streams_configuration;"
STREXEC ${STRADM} ${STRADM_PWD} ${ON_SID}
}
# ------------------------------------------------------------
DropSchemaUser () {
DEBUG DropSchemaUser ${ON_DBO}
SQLNEWF
SQLLINE "drop user ${ON_DBO} cascade;"
STREXEC ${STRDBA} ${STRDBA_PWD} ${ON_SID}
}
# ------------------------------------------------------------
DropStreamAdminUser () {
DEBUG DropStreamAdminUser on ${ON_SID}
SQLNEWF
SQLLINE "drop user ${STRADM} cascade;"
STREXEC ${STRDBA} ${STRDBA_PWD} ${ON_SID}
}
# ------------------------------------------------------------
ReadConfigInfo () {
[[ ! -f ${STREAMS_CONF} ]] && ERROR "${STREAMS_CONF} config file not found !!!"
site_A=$(grep "^STREAM_SITES=" ${STREAMS_CONF} | cut -f2 -d"=" | sed -e 's/,/ /g')
SITEA=(${site_A})		#bash shell
#set -A SITEA ${site_A}		#ksh shell
#set -A SIDA
#set -A DBOA
i=0
for SITE in ${SITEA[*]}
do
	#DEBUG ========== SITE:${SITE}:
	X=$(grep "^SITE_INFO_${SITE}" ${STREAMS_CONF} |cut -f2 -d"=")
	DBOA[$i]=$(echo $X|cut -f1 -d":")
	SIDA[$i]=$(echo $X|cut -f2 -d":")
	#echo X=${X}
	DEBUG SITE=${SITEA[$i]}:SID=${SIDA[$i]}:DBO=${DBOA[$i]}
	(( i = i+1 ))
done
}
# ------------------------------------------------------------
ShowConfigInfo () {
i=0
for SITE in ${SITEA[*]}
do
	ECHO "SITE=${SITEA[$i]}    :    SID=${SIDA[$i]}    :    DBO=${DBOA[$i]}"
	(( i = i+1 ))
done
ECHO "DBA User is ${STRDBA} ${STRDBA_PWD}"
ECHO "ADM User is ${STRADM} ${STRADM_PWD}"
ECHO "DBO User is ${STRDBO} ${STRDBO_PWD}"
}
# ------------------------------------------------------------
SetupStreams () {
ACTION=${1}
i=0
while  [ $i -lt ${#SITEA[*]} ] # for each site
do
	ON_SITE=${SITEA[$i]}
	ON_SID=${SIDA[$i]}
	ON_DBO=${DBOA[$i]}
	#RAO1
	ECHO ${cLINE1}
	ECHO "ON site ${SITEA[$i]}"
	ECHO ${cLINE1}
	if [ "${ACTION}" = "test1" ]; then
		TestSysConnection
		TestDbaConnection
		TestDboConnection
		TestAdmConnection
	fi
	if [ "${ACTION}" = "test3" ]; then
		DEBUG "Captures in disabled state"
		STRQRY "select 'On '||source_database||' capture '||capture_name||' in '||status||' status' from dba_capture where status='DISABLED';"
		DEBUG "Captures in aborted state"
		STRQRY "select 'On '||source_database||' capture '||capture_name||' in '||status||' status with '||error_number||error_message from dba_capture where status='ABORTED';"
		DEBUG "Applys in disabled state"
		STRQRY "select 'On '||source_database||' capture '||capture_name||' in '||status||' status' from dba_capture where status='DISABLED';"
		DEBUG "Checking applys in disabled state"
		STRQRY "select 'On '||source_database||' capture '||capture_name||' in '||status||' status' from dba_capture where status='DISABLED';"
	fi
	if [ "${ACTION}" = "phase1" ]; then
		TestDbaConnection
		CreateSchemaUser
		CreateAdminUser
		EnableSupplementalLogging
		CreateSchemaObjects
	fi

	j=0
	while  [ $j -lt ${#SITEA[*]} ] 
	do
		TO_SITE=${SITEA[$j]}
		TO_SID=${SIDA[$j]}
		TO_DBO=${DBOA[$j]}
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~
		DIRECTION_NAME=${ON_SITE}_TO_${TO_SITE}

		CAPTURE_NAME=C_${DIRECTION_NAME}
		CAPTURE_QUEUE_NAME=${CAPTURE_NAME}_Q
		CAPTURE_QUEUE_TABLE_NAME=${CAPTURE_QUEUE_NAME}T
		CAPTURE_RULESET_NAME=${CAPTURE_NAME}_RS
		CAPTURE_RULE_NAME=${CAPTURE_NAME}_R
		POS_RULE_CONDITION=" :dml.get_object_owner()=''${ON_DBO}'' "
		NEG_RULE_CONDITION=" :dml.get_object_owner()!=''${ON_DBO}'' "

		APPLY_NAME=A_${DIRECTION_NAME}
		APPLY_QUEUE_NAME=${APPLY_NAME}_Q
		APPLY_QUEUE_TABLE_NAME=${APPLY_QUEUE_NAME}T
		APPLY_RULESET_NAME=${APPLY_NAME}_RS
		APPLY_RULE_NAME=${APPLY_NAME}_R
		
		PROPAGATION_NAME=P_${ON_SITE}_TO_${TO_SITE}
		PROPAGATION_RULESET_NAME=${PROPAGATION_NAME}_RS
		PROPAGATION_RULE_NAME=${PROPAGATION_NAME}_R
		
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~
		if [[ ${ON_SITE} != ${TO_SITE} ]]; then # for each of other site
			ECHO ${cLINE2}
			ECHO "On site ${ON_SITE} to site ${TO_SITE}"
			ECHO ${cLINE2}
		#RAO2
			if [ "${ACTION}" = "test2" ]; then
				TestDblinkConnection
			fi
			if [ "${ACTION}" = "phase2" ]; then
				CreateDatabaseLink 
				TestDblinkConnection
				StreamAdminObjects
				HeartBeatUpdateJob
			fi
			if [ "${ACTION}" = "phase3" ]; then
				# --- Capture Rules
				CreateRuleSet ${ON_SID} ${CAPTURE_RULESET_NAME}_P
				CreateRule ${ON_SID} ${CAPTURE_RULE_NAME}_P " ${POS_RULE_CONDITION} "
				AddRule ${ON_SID} ${CAPTURE_RULE_NAME}_P ${CAPTURE_RULESET_NAME}_P

				CreateRuleSet ${ON_SID} ${CAPTURE_RULESET_NAME}_N
				CreateRule ${ON_SID} ${CAPTURE_RULE_NAME}_N " ${NEG_RULE_CONDITION} "
				AddRule ${ON_SID} ${CAPTURE_RULE_NAME}_N ${CAPTURE_RULESET_NAME}_N

				# --- Propagation Rules
				CreateRuleSet ${ON_SID} ${PROPAGATION_RULESET_NAME}_P
				CreateRule ${ON_SID} ${PROPAGATION_RULE_NAME}_P " ${POS_RULE_CONDITION} "
				AddRule ${ON_SID} ${PROPAGATION_RULE_NAME}_P ${PROPAGATION_RULESET_NAME}_P

				CreateRuleSet ${ON_SID} ${PROPAGATION_RULESET_NAME}_N
				CreateRule ${ON_SID} ${PROPAGATION_RULE_NAME}_N " ${NEG_RULE_CONDITION} "
				AddRule ${ON_SID} ${PROPAGATION_RULE_NAME}_N ${PROPAGATION_RULESET_NAME}_N

				# --- Apply Rules
				CreateRuleSet ${TO_SID} ${APPLY_RULESET_NAME}_P
				CreateRule ${TO_SID} ${APPLY_RULE_NAME}_P " ${POS_RULE_CONDITION} "
				AddRule ${TO_SID} ${APPLY_RULE_NAME}_P ${APPLY_RULESET_NAME}_P

				CreateRuleSet ${TO_SID} ${APPLY_RULESET_NAME}_N
				CreateRule ${TO_SID} ${APPLY_RULE_NAME}_N " ${NEG_RULE_CONDITION} "
				AddRule ${TO_SID} ${APPLY_RULE_NAME}_N ${APPLY_RULESET_NAME}_N
			fi
			if [ "${ACTION}" = "phase4" ]; then
				DictionaryBuild
				# ---
				CreateCaptureQueue
				CreateCapture
				CreateStream CAPTURE ${ON_DBO} ${ON_SID}
				SetCaptureParameter PARALLELISM 1
				SetCaptureParameter WRITE_ALERT_LOG N
				# ---
				CreateApplyQueue
				CreateApply
				CreateStream APPLY ${TO_DBO} ${TO_SID}
				SetApplyParameter DISABLE_ON_ERROR N
				SetApplyParameter PARALLELISM 1
				## ---
				CreatePropagation 
				PropagationAddSchemaRule
			fi
			if [ "${ACTION}" = "phase5" ]; then
				# ---
				SetCapturePositiveRule 
				SetCaptureNegativeRule 
				# ---
				SetApplyPositiveRule 
				SetApplyNegativeRule 
				# ---
				SetPropagationPositiveRule 
				SetPropagationNegativeRule 
			fi
			if [ "${ACTION}" = "phase6" ]; then
				START_SCN=$(GetFlashbackSCN ${ON_SID})
				#ECHO ${cLINE2}
				ECHO Flashback SCN of ${ON_SID} is ${START_SCN}
				SetSchemaInstantiationSCN 
				StartApply 
				StartCapture
				#StartPropagation
				HeartBeatInsert
				#HeartBeatMerge
			fi
			if [ "${ACTION}" = "phase7" ]; then
				HeartBeatDmlHandProc
				HeartBeatDmlHandSet
			fi
			if [ "${ACTION}" = "rmdmlh" ]; then
				HeartBeatDmlHandUnSet
			fi
			if [ "${ACTION}" = "start" ]; then
				StartApply 
				#StartPropagation
				StartCapture
			fi
			if [ "${ACTION}" = "restart" ]; then
				StopCapture 
				StopPropagation
				StopApply 
				START_SCN=$(GetFlashbackSCN ${ON_SID})
				SetSchemaInstantiationSCN 
				StartApply 
				#StartPropagation
				StartCapture
			fi
			if [ "${ACTION}" = "stop" ]; then
				StopCapture 
				StopApply 
				#StopPropagation
			fi
			if [ "${ACTION}" = "delete1" ]; then
				StopCapture 
				StopApply 
				#StopPropagation
				DropCapture
				DropApply

				# ---
				if [ 1 = 0 ]; then
				RemoveRule ${ON_SID} ${CAPTURE_RULE_NAME}_P ${CAPTURE_RULESET_NAME}_P
				RemoveRule ${ON_SID} ${CAPTURE_RULE_NAME}_N ${CAPTURE_RULESET_NAME}_N
				DropRule ${ON_SID} ${CAPTURE_RULE_NAME}_P
				DropRule ${ON_SID} ${CAPTURE_RULE_NAME}_N
				DropRuleSet ${ON_SID} ${CAPTURE_RULESET_NAME}_P
				DropRuleSet ${ON_SID} ${CAPTURE_RULESET_NAME}_N

				# ---
				RemoveRule ${ON_SID} ${PROPAGATION_RULE_NAME}_P ${PROPAGATION_RULESET_NAME}_P
				RemoveRule ${ON_SID} ${PROPAGATION_RULE_NAME}_N ${PROPAGATION_RULESET_NAME}_N
				DropRule ${ON_SID} ${PROPAGATION_RULE_NAME}_P
				DropRule ${ON_SID} ${PROPAGATION_RULE_NAME}_N
				DropRuleSet ${ON_SID} ${PROPAGATION_RULESET_NAME}_P
				DropRuleSet ${ON_SID} ${PROPAGATION_RULESET_NAME}_N

				# ---
				RemoveRule ${TO_SID} ${APPLY_RULE_NAME}_P ${APPLY_RULESET_NAME}_P
				RemoveRule ${TO_SID} ${APPLY_RULE_NAME}_N ${APPLY_RULESET_NAME}_N
				DropRule ${TO_SID} ${APPLY_RULE_NAME}_P
				DropRule ${TO_SID} ${APPLY_RULE_NAME}_N
				DropRuleSet ${TO_SID} ${APPLY_RULESET_NAME}_P
				DropRuleSet ${TO_SID} ${APPLY_RULESET_NAME}_N
				fi
			fi
			if [ "${ACTION}" = "test3" ]; then
				DEBUG Test Replication Delay
				#STRQRY "select s.source_db, s.target_db, s.source_time, t.source_time, t.source_time-s.source_time delay from ${ON_DBO}.HB s, ${TO_DBO}.HB@${TO_SITE} t where s.source_db='${ON_SITE}' and s.target_db='${TO_SITE}' and s.source_db=t.source_db and s.target_db=t.target_db  ;"
				STRQRY "select s.source_db||'->'||s.target_db||' delay='|| to_char(t.source_time-s.source_time) delay from ${ON_DBO}.HB s, ${TO_DBO}.HB@${TO_SITE} t where s.source_db='${ON_SITE}' and s.target_db='${TO_SITE}' and s.source_db=t.source_db and s.target_db=t.target_db  ;"
			fi
		fi
		(( j = j+1 ))
	done
	if [ "${ACTION}" = "delete" ]; then
		TestDbaConnection
		RemoveStreams
		DropSchemaUser
		DropStreamAdminUser
	fi
	(( i = i+1 ))
done
}
# ------------------------------------------------------------
f_config_common () {
ReadConfigInfo
#ALERTLOG "Oracle Streams Configuration"
SetupStreams ${1}
ECHO Done
}
# ------------------------------------------------------------
f_config_all_phases () {
f_config_common phase1
f_config_common phase2
#f_config_common phase3
f_config_common phase4
#f_config_common phase5
f_config_common phase6
#f_config_common phase7
}
# ------------------------------------------------------------
f_config_config () {
ReadConfigInfo
ShowConfigInfo
}
# ------------------------------------------------------------
f_config_phase1 () {
f_config_common phase1
}
# ------------------------------------------------------------
f_config_phase2 () {
f_config_common phase2
}
# ------------------------------------------------------------
f_config_phase3 () {
ERROR programatically DISABLED
f_config_common phase3
}
# ------------------------------------------------------------
f_config_phase4 () {
f_config_common phase4
}
# ------------------------------------------------------------
f_config_phase5 () {
ERROR programatically DISABLED
f_config_common phase5
}
# ------------------------------------------------------------
f_config_phase6 () {
f_config_common phase6
}
# ------------------------------------------------------------
f_config_phase7 () {
f_config_common phase7
}
# ------------------------------------------------------------
f_config_rmdmlh () {
f_config_common rmdmlh
}
# ------------------------------------------------------------
f_config_test1 () {
f_config_common test1
}
# ------------------------------------------------------------
f_config_test2 () {
f_config_common test2
}
# ------------------------------------------------------------
f_config_test3 () {
f_config_common test3
}
# ------------------------------------------------------------
f_config_start () {
f_config_common start
}
# ------------------------------------------------------------
f_config_stop () {
f_config_common stop
}
# ------------------------------------------------------------
f_config_restart () {
f_config_common restart
}
# ------------------------------------------------------------
f_config_delete () {
f_config_common delete
}
# ------------------------------------------------------------
f_config_report () {
INCLIB_c RPT
ECHO "Calling f_html_report"
f_html_report
}
# ------------------------------------------------------------
