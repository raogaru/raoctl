# ############################################################
# DATA COMPARE FUNCTIONS - DBMS_COMPARISON
# ############################################################
# ------------------------------------------------------------
# DATA COMPARE actions
action_L1="list create  "
action_L2="list_scans "
action_L3="x "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list_rs,,List_RuleSets \
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
DBMS_COMPARISON (){
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_comparison.${vLine};"
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
f_compare_list () {
SQLNEWF
SQLLINE "set linesi 200 trimspool on head on feedback on pagesi 1000 linesi 200 trimspool on"
SQLLINE "col comparison_name format a20"
SQLLINE "col local_object format a30"
SQLLINE "col remote_object format a30"
SQLLINE "select owner||'.'||comparison_name comparison_name,comparison_mode, scan_mode,scan_percent"
#SQLLINE ",schema_name||'.'||object_name local_object"
#SQLLINE ",remote_schema_name||'.'||remote_object_name||'@'||DBLINK_NAME remote_object"
SQLLINE ",object_type||':'||schema_name||'.'||object_name local_object"
SQLLINE ",remote_object_type||':'||remote_schema_name||'.'||remote_object_name||'@'||DBLINK_NAME remote_object"
SQLLINE "from dba_comparison;"
SQLEXEC
}
# ------------------------------------------------------------
f_compare_create () {
INPUT 4
DBMS_COMPARISON "create_comparison( comparison_name=>'${input1}', schema_name=>'${input2}', object_name=>'${input3}', dblink_name=>'${input4}')"
}
# ------------------------------------------------------------
f_compare_drop () {
INPUT
DBMS_COMPARISON "drop_comparison(comparison_name=>'${input1}')"
}
# ------------------------------------------------------------
f_compare_compare () {
INPUT 4
DBMS_COMPARISON "compare( )"
}
# ------------------------------------------------------------
f_compare_list_scans () {
SQLQRY "select comparison_name, scan_id, parent_scan_id, root_scan_id, status, count_rows from dba_comparison_scan order by 1,2;"
}
# ------------------------------------------------------------
f_compare_purge () {
INPUT
DBMS_COMPARISON "purge_comparison(comparison_name=>'${input1}')"
}
# ------------------------------------------------------------
f_compare_recheck () {
INPUT 2
SQLQRY "select dbms_comparison.recheck(comparison_name=>'${input1}',scan_id=>${input2}) from dual;"
}
# ------------------------------------------------------------
