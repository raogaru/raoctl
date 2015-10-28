# ############################################################
# STREAMS TRANSFORMATION FUNCTIONS - Oracle Streams Transformations
# ############################################################
# ------------------------------------------------------------
# STREAMS TRANSFORMATION actions
action_L1="list "
action_L2="rensch rentab rencol addcol delcol keepcol "
action_L3="un_rensch un_rentab un_rencol un_addcol un_delcol un_keepcol "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,,List_Transformations \
rensch,rule_name:step_number:from_schema_name:to_schema_name,Rename_Schema \
rentab,rule_name:step_number:from_table_name:to_table_name,Rename_Table \
rencol,rule_name:step_number:table_name:from_column_name:to_column_name,Rename_Column \
addcol,rule_name:step_number:,Add_Column \
delcol,rule_name:step_number:,Delete_Column \
keepcol,rule_name:step_number:,Keep_Columns  \
"

# ------------------------------------------------------------
# Module specific environment variables
STRADM=ADM
STRDBO=DBO
v_debug=0
rc_SHOW_SQL=YES
# ------------------------------------------------------------
# Connect to SQLPLUS and execute script
STREXEC () {  #1-user 2=password 3=SID 4=sqlfile
[[ "${rc_SHOW_SQL}" != "NO" ]] && cat ${TMPSQL}
return 0 ###########@@@@@@@@@@@@@@@@@@@@@
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
set echo off feedback off pagesi 0 termout on linesi 1000 trimspool on
set serveroutput on size 10000
spool ${TMPLOG} append
@${SQLFILE}
spool off
EOFsql
}
# ------------------------------------------------------------
f_XFORM (){
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_streams_adm.${vLine},rule_name=>upper('${STRADM}.${input1}'),step_number=>${input2});"
STREXEC ${STRADM} ${STRADM} ${ORACLE_SID}
}
# ------------------------------------------------------------
f_xform_list () {
SQLQRY ";"
}
# ------------------------------------------------------------
f_xform_rensch () {
INPUT 4
f_XFORM "rename_schema(from_schema_name=>upper('${input3}'),to_schema_name=>upper('${input4}'),operation=>'ADD'"
}
# ------------------------------------------------------------
f_xform_un_rensch () {
INPUT 4
f_XFORM "rename_schema(from_schema_name=>upper('${input3}'),to_schema_name=>upper('${input4}'),operation=>'REMOVE'"
}
# ------------------------------------------------------------
f_xform_rentab () {
INPUT 4
f_XFORM "rename_table(from_table_name=>upper('${input3}'),to_table_name=>upper('${input4}'),operation=>'ADD'"
}
# ------------------------------------------------------------
f_xform_un_rentab () {
INPUT 4
f_XFORM "rename_table(from_table_name=>upper('${input3}'),to_table_name=>upper('${input4}'),operation=>'REMOVE'"
}
# ------------------------------------------------------------
f_xform_rencol () {
INPUT 5
f_XFORM "rename_column(table_name=>upper('${input3}'),from_column_name=>upper('${input4}'),to_column_name=>upper('${input5}'),operation=>'ADD'"
}
# ------------------------------------------------------------
f_xform_un_rencol () {
INPUT 5
f_XFORM "rename_column(table_name=>upper('${input3}'),from_column_name=>upper('${input4}'),to_column_name=>upper('${input5}'),operation=>'REMOVE'"
}
# ------------------------------------------------------------
f_xform_addcol () {
INPUT 6
f_XFORM "add_column(table_name=>upper('${input3}'),column_name=>upper('${input4}'),column_value=>SYS.ANYDATA.ConvertTo${input5}('${input6}'),operation=>'ADD'"
}
# ------------------------------------------------------------
f_xform_un_addcol () {
INPUT 6
f_XFORM "add_column(table_name=>upper('${input3}'),column_name=>upper('${input4}'),column_value=>SYS.ANYDATA.ConvertTo${input5}('${input6}'),operation=>'REMOVE'"
}
# ------------------------------------------------------------
f_xform_delcol () {
INPUT 4
f_XFORM "delete_column(table_name=>upper('${input3}'),column_name=>upper('${input4}'),operation=>'ADD'"
}
# ------------------------------------------------------------
f_xform_un_delcol () {
INPUT 4
f_XFORM "delete_column(table_name=>upper('${input3}'),column_name=>upper('${input4}'),operation=>'REMOVE'"
}
# ------------------------------------------------------------
f_xform_keepcol () {
INPUT 4
f_XFORM "keep_columns(table_name=>upper('${input3}'),column_list=>upper('${input4}'),operation=>'ADD'"
}
# ------------------------------------------------------------
f_xform_un_keepcol () {
INPUT 4
f_XFORM "keep_columns(table_name=>upper('${input3}'),column_list=>upper('${input4}'),operation=>'REMOVE'"
}
# ------------------------------------------------------------
