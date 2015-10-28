# ############################################################
# STREAMS CAPTURE FUNCTIONS - Oracle Streams Administer Capture
# ############################################################
# ------------------------------------------------------------
# STREAMS CAPTURE actions
action_L1="list create drop start stop start_all stop_all "
action_L2="list_param list_all_param set_param unset_param set_rs unset_rs set_nrs unset_nrs list_scn set_start_scn set_first_scn "
action_L3="list_attrib include_attrib exclude_attrib "
action_L4="prepared "
action_L="$action_L1 $action_L2 $action_L3 $action_L4"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,,List_Captures \
create,capture_name:queue_name,Create_Capture \
drop,capture_name,Drop_Capture \
start,capture_name,Start_Capture \
stop,capture_name,Stop_Capture \
start_all,capture_name,Start_All_Captures \
stop_all,capture_name,Stop_All_Captures \
prepared,,List_prepared_DBs_Schemas_and_Objects \
list_param,capture_name,List_Set_Parameters \
list_all_param,capture_name,List_All_Parameters \
set_param,capture_name:parameter_name:parameter_value,Set_Parameter \
unset_param,capture_name:parameter_name,Unset_Parameter \
list_scn,None,List_SCNs \
set_start_scn,capture_name:start_scn,set_start_scn \
set_first_scn,capture_name:first_scn,set_first_scn \
list_attrib,[capture_name],List_Extra_Attributes_included \
include_attrib,capture_name:attribute_name,Include_Extra_Attribute \
exclude_attrib,capture_name:attribute_name,Exclude_Extra_Attribute \
"
# ------------------------------------------------------------
# Module specific environment variables
STREAMS_CONF=${CFG_DIR}/streams.cfg
STRLOG=${LOG_DIR}/streams_config.log
STRADM=ADM
# ------------------------------------------------------------
# Connect to SQLPLUS and execute script
STREXEC () {  #1-user 2=password 3=SID 4=sqlfile
if [[ $1 = "as" && $2 = "sysdba" ]] ; then
	constr="/ as sysdba"
else
	constr="${1}/${2}@${3}"
fi
if [[ -z $4 ]]; then
	SQLFILE=${TMPSQL}
else
	SQLFILE=$4
fi
#echo Executing SQL $SQLFILE as $constr
cat $SQLFILE >> $STRLOG
ECHO "-- ${cLINE5}" >> $STRLOG
export ORACLE_SID=$3
${ORACLE_HOME}/bin/sqlplus -s /nolog <<-EOFsql
connect $constr
--show user	
set echo off feedback off pagesi 0 termout on linesi 1000 trimspool on
set serveroutput on size 10000
spool ${TMPLOG} append
@${SQLFILE}
spool off
EOFsql
}
# ------------------------------------------------------------
DBMS_CAPTURE_ADM (){
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_capture_adm.${vLine};"
STREXEC ${STRADM} ${STRADM} ${ORACLE_SID}
}
# ------------------------------------------------------------
ALTER_CAPTURE (){
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_capture_adm.alter_capture(${vLine});"
STREXEC ${STRADM} ${STRADM} ${ORACLE_SID}
}
# ------------------------------------------------------------
f_capture_list () {
SQLQRY "select capture_name, status, rule_set_name, negative_rule_set_name from dba_capture;"
}
# ------------------------------------------------------------
f_capture_create () {
INPUT 2
DBMS_CAPTURE_ADM "create_capture(capture_name=> '${input1}',queue_name=> '${input2}')"
}
# ------------------------------------------------------------
f_capture_drop () {
INPUT
DBMS_CAPTURE_ADM "drop_capture('${input1}')"
}
# ------------------------------------------------------------
f_capture_start () {
INPUT
DBMS_CAPTURE_ADM "start_capture('${input1}')"
}
# ------------------------------------------------------------
f_capture_stop () {
INPUT
DBMS_CAPTURE_ADM "stop_capture('${input1}')"
}
# ------------------------------------------------------------
f_capture_start_all () {
SQL2LST "select capture_name from dba_capture where status='DISABLED';"
cat ${SQL2LST_LST} | grep '[a-zA-Z]' | while read input
do
ECHO "Start Capture ${input}"
DBMS_CAPTURE_ADM "start_capture('${input}')"
done
}
# ------------------------------------------------------------
f_capture_stop_all () {
SQL2LST "select capture_name from dba_capture where status='ENABLED';"
cat ${SQL2LST_LST} | grep '[a-zA-Z]' | while read input
do
ECHO "Stop Capture ${input}"
DBMS_CAPTURE_ADM "stop_capture('${input}')"
done
}
# ------------------------------------------------------------
f_capture_list_param () {
SQLQRY "select capture_name, substr(parameter,1,30) parameter , substr(value,1,30) value from dba_capture_parameters where set_by_user='YES' and upper(capture_name) like upper('%${input}%');"
}
# ------------------------------------------------------------
f_capture_list_all_param () {
SQLQRY "select capture_name, substr(parameter,1,30) parameter , substr(value,1,30) value from dba_capture_parameters where upper(capture_name) like upper('%${input}%') order by capture_name, parameter;"
}
# ------------------------------------------------------------
f_capture_set_param () {
INPUT 3
DBMS_CAPTURE_ADM "set_parameter(capture_name=>'${input1}', parameter=> '${input2}', value=> '${input3}')"
}
# ------------------------------------------------------------
f_capture_unset_param () {
INPUT 2
DBMS_CAPTURE_ADM "set_parameter(capture_name=>'${input1}', parameter=> '${input2}')"
}
# ------------------------------------------------------------
f_capture_set_rs () {
INPUT 2
ALTER_CAPTURE "capture_name=> '${input1}', rule_set_name=>'${input2}'"
}
# ------------------------------------------------------------
f_capture_unset_rs () {
INPUT
ALTER_CAPTURE "capture_name=> '${input1}', remove_rule_set=>true"
}
# ------------------------------------------------------------
f_capture_set_nrs () {
INPUT 2
ALTER_CAPTURE "capture_name=> '${input1}', negative_rule_set_name=>'${input2}'"
}
# ------------------------------------------------------------
f_capture_unset_nrs () {
INPUT
ALTER_CAPTURE "capture_name=> '${input1}', remove_negative_rule_set=>true"
}
# ------------------------------------------------------------
f_capture_list_scn () {
SQLQRY "select capture_name, start_scn ,first_scn ,captured_scn ,applied_scn from dba_capture;"
#,source_resetlogs_scn ,max_checkpoint_scn ,required_checkpoint_scn ,last_enqueued_scn
}
# ------------------------------------------------------------
f_capture_set_start_scn () {
INPUT
ALTER_CAPTURE "capture_name=> '${input1}', start_scn=>${input2}"
}
# ------------------------------------------------------------
f_capture_set_first_scn () {
INPUT
ALTER_CAPTURE "capture_name=> '${input1}', first_scn=>${input2}"
}
# ------------------------------------------------------------
f_capture_list_attrib () {
SQLQRY "select capture_name,attribute_name,include,row_attribute,ddl_attribute from dba_capture_extra_attributes where upper(capture_name) like upper('%${input}%');"
}
# ------------------------------------------------------------
f_capture_include_attrib () {
DBMS_CAPTURE_ADM "include_extra_attribute(capture_name=> '${input1}', attribute_name=>'${input2}',include=>true)"
}
# ------------------------------------------------------------
f_capture_exclude_attrib () {
DBMS_CAPTURE_ADM "include_extra_attribute(capture_name=> '${input1}', attribute_name=>'${input2}',include=>false)"
}
# ------------------------------------------------------------
f_capture_prepared () {
SQLQRY "@s_suplog_database.sql"
SQLQRY "@s_suplog_groups.sql"
SQLQRY "@s_suplog_schemas.sql"
SQLQRY "@s_suplog_specifications.sql"
SQLQRY "@s_suplog_tables.sql"
}
# ------------------------------------------------------------
