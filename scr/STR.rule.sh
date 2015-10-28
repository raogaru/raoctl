# ############################################################
# STREAMS RULE FUNCTIONS - Oracle Streams Administer Rules
# ############################################################
# ------------------------------------------------------------
# STREAMS RULE actions
action_L1="list_rs used_rs create_rs drop_rs "
action_L2="list used condition create drop add remove "
action_L3="yy "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list_rs,,List_RuleSets \
create_rs,,Create_RuleSets \
drop_rs,,Drop_RuleSets \
used_rs,None,List_Used_RuleSets \
list,,List_All_Rules \
used,None,List_Rules_used_in_RuleSets \
condition,None,List_Rules_conditions \
create,,Create_Rules \
drop,,Drop_Rules \
add,rule_name:rule_set_name,Add_Rule_to_RuleSet \
remove,rule_name:rule_set_name,Remove_Rule_from_RuleSet \
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
DBMS_RULE_ADM (){
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_rule_adm.${vLine};"
STREXEC ${STRADM} ${STRADM} ${ORACLE_SID}
}
# ------------------------------------------------------------
ALTER_RULE (){
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_rule_adm.alter_rule(${vLine});"
STREXEC ${STRADM} ${STRADM} ${ORACLE_SID}
}
# ------------------------------------------------------------
f_rule_list_rs () {
SQLQRY "select rule_set_owner, rule_set_name from dba_rule_sets;"
}
# ------------------------------------------------------------
f_rule_used_rs () {
#SQLQRY "select streams_name, rule_set_owner||'.'||rule_set_name rule_set, rule_name, rule_set_type from dba_streams_rules;"
SQLQRY "
select 'CAPTURE' type, capture_name stream_name, rule_set_name, negative_rule_set_name from dba_capture
union
select 'APPLY' , apply_name, rule_set_name, negative_rule_set_name from dba_apply
union
select 'PROPAGATION' , propagation_name, rule_set_name, negative_rule_set_name from dba_propagation ; "
}
# ------------------------------------------------------------
f_rule_create_rs () {
INPUT
DBMS_RULE_ADM "create_rule_set(rule_set_name=> '${input1}')"
}
# ------------------------------------------------------------
f_rule_drop_rs () {
INPUT
DBMS_RULE_ADM "drop_rule_set(rule_set_name=>'${input1}')"
}
# ------------------------------------------------------------
f_rule_list () {
SQLQRY "select rule_owner, rule_name from dba_rules;"
}
# ------------------------------------------------------------
f_rule_used () {
SQLQRY "select rule_set_name, rule_name, rule_set_rule_enabled status from dba_rule_set_rules;"
}
# ------------------------------------------------------------
f_rule_condition () {
SQLQRY "select rule_name, rule_condition from dba_rules;"
}
# ------------------------------------------------------------
f_rule_create () {
INPUT 2
DBMS_RULE_ADM "create_rule(rule_name=> '${input1}',condition=> '${input2}')"
}
# ------------------------------------------------------------
f_rule_drop () {
INPUT
DBMS_RULE_ADM "drop_rule('${input1}')"
}
# ------------------------------------------------------------
f_rule_add () {
INPUT 2
DBMS_RULE_ADM "add_rule(rule_name=>'${input1}',rule_set_name=>'${input2}')"
}
# ------------------------------------------------------------
f_rule_remove () {
INPUT 2
DBMS_RULE_ADM "remove_rule(rule_name=>'${input1}',rule_set_name=>'${input2}')"
}
# ------------------------------------------------------------
