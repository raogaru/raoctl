# ############################################################
# STREAMS PROPAGATION FUNCTIONS - Oracle Streams Administer Propagation
# ############################################################
# ------------------------------------------------------------
# STREAMS PROPAGATION actions
action_L1="list create drop start stop start_all stop_all set_rs unset_rs set_nrs unset_nrs  "
action_L2="xx "
action_L3="yy "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,,List_Propagation \
create,propagation_name:queue_name,Create_Propagation \
drop,propagation_name,Drop_Propagation \
start,propagation_name,Start_Propagation \
stop,propagation_name,Stop_Propagation \
start_all,propagation_name,Start_All_Propagation \
stop_all,propagation_name,Stop_All_Propagation \
set_rs,propagation_name:rule_set_name,Set_RuleSet \
unset_rs,propagation_name,Remove_RuleSet \
set_nrs,propagation_name:rule_set_name,Set_Negative_RuleSet \
unset_nrs,propagation_name,Remove_Negative_RuleSet \
"
# ------------------------------------------------------------
# Module specific environment variables
STREAMS_CONF=${CFG_DIR}/streams.cfg
STRLOG=${LOG_DIR}/streams_config.log
STRADM=ADM
v_debug=0
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
DBMS_PROPAGATION_ADM (){
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_propagation_adm.${vLine};"
STREXEC ${STRADM} ${STRADM} ${ORACLE_SID}
}
# ------------------------------------------------------------
ALTER_PROPAGATION (){
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_propagation_adm.alter_propagation(${vLine});"
STREXEC ${STRADM} ${STRADM} ${ORACLE_SID}
}
# ------------------------------------------------------------
f_propagation_list () {
SQLQRY "select propagation_name, status , source_queue_name, destination_queue_name, destination_dblink from dba_propagation;"
}
# ------------------------------------------------------------
f_propagation_create () {
INPUT 2
DBMS_PROPAGATION_ADM "create_propagation(propagation_name=> '${input1}',queue_name=> '${input2}')"
}
# ------------------------------------------------------------
f_propagation_drop () {
INPUT
DBMS_PROPAGATION_ADM "drop_propagation('${input1}')"
}
# ------------------------------------------------------------
f_propagation_start () {
INPUT
DBMS_PROPAGATION_ADM "start_propagation('${input1}')"
}
# ------------------------------------------------------------
f_propagation_stop () {
INPUT
DBMS_PROPAGATION_ADM "stop_propagation('${input1}')"
}
# ------------------------------------------------------------
f_propagation_start_all () {
SQL2LST "select propagation_name from dba_propagation where status='DISABLED';"
cat ${SQL2LST_LST} | grep '[a-zA-Z]' | while read input
do
ECHO "Start propagation ${input}"
DBMS_PROPAGATION_ADM "start_propagation('${input}')"
done
}
# ------------------------------------------------------------
f_propagation_stop_all () {
SQL2LST "select propagation_name from dba_propagation where status='ENABLED';"
cat ${SQL2LST_LST} | grep '[a-zA-Z]' | while read input
do
ECHO "Stop propagation ${input}"
DBMS_PROPAGATION_ADM "stop_propagation('${input}')"
done
}
# ------------------------------------------------------------
f_propagation_set_rs () {
INPUT 2
ALTER_PROPAGATION "propagation_name=> '${input1}', rule_set_name=>'${input2}'"
}
# ------------------------------------------------------------
f_propagation_unset_rs () {
INPUT
ALTER_PROPAGATION "propagation_name=> '${input1}', remove_rule_set=>true"
}
# ------------------------------------------------------------
f_propagation_set_nrs () {
INPUT 2
ALTER_PROPAGATION "propagation_name=> '${input1}', negative_rule_set_name=>'${input2}'"
}
# ------------------------------------------------------------
f_propagation_unset_nrs () {
INPUT
ALTER_PROPAGATION "propagation_name=> '${input1}', remove_negative_rule_set=>true"
}
# ------------------------------------------------------------
