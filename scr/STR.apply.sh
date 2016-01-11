# ############################################################
# STREAMS APPLY FUNCTIONS - Oracle Streams Administer Apply
# ############################################################
# ------------------------------------------------------------
# STREAMS APPLY actions
action_L1="list create drop start stop start_all stop_all list_param list_all_param set_param unset_param set_rs unset_rs set_nrs unset_nrs  "
action_L2="set_tag unset_tag set_ddl_hand unset_ddl_hand set_msg_hand unset_msg_hand set_pch_hand unset_pch_hand "
action_L3="list_err show_err del_err del_all_err exe_err exe_all_err "
action_L4="instantiated "
action_L="$action_L1 $action_L2 $action_L3 $action_L4"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,,List_Apply \
create,apply_name:queue_name,Create_Apply \
drop,apply_name,Drop_Apply \
start,apply_name,Start_Apply \
stop,apply_name,Stop_Apply \
start_all,apply_name,Start_All_Apply \
stop_all,apply_name,Stop_All_Apply \
list_param,apply_name,List_Set_Parameters \
list_all_param,apply_name,List_All_Parameters \
set_param,apply_name:parameter_name:parameter_value,Set_Parameter \
unset_param,apply_name:parameter_name,Unset_Parameter \
set_rs,apply_name:rule_set_name,Set_RuleSet \
unset_rs,apply_name,Remove_RuleSet \
set_nrs,apply_name:rule_set_name,Set_Negative_RuleSet \
unset_nrs,apply_name,Remove_Negative_RuleSet \
set_tag,apply_name:tag_value,Set_Apply_Tag \
unset_tag,apply_name,Remove_Apply_Tag \
set_ddl_hand,apply_name:ddl_handler,Set_DDL_Handler \
unset_ddl_hand,apply_name,Remove_DDL_Handler \
set_msg_hand,apply_name:msg_handler,Set_Message_Handler \
unset_msg_hand,apply_name,Remove_Message_Handler \
set_pch_hand,apply_name:pch_handler,Set_PreCommit_Handler \
unset_pch_hand,apply_name,Remove_PreCommit_Handler \
"
# ------------------------------------------------------------
INCLIB_c
# ------------------------------------------------------------
DBMS_APPLY_ADM (){
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_apply_adm.${vLine};"
STREXEC ${STRADM} ${STRADM} ${ORACLE_SID}
}
# ------------------------------------------------------------
ALTER_APPLY (){
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_apply_adm.alter_apply(${vLine});"
STREXEC ${STRADM} ${STRADM} ${ORACLE_SID}
}
# ------------------------------------------------------------
f_apply_list () {
SQLQRY "select apply_name, status, apply_tag from dba_apply;"
}
# ------------------------------------------------------------
f_apply_create () {
INPUT 2
DBMS_APPLY_ADM "create_apply(apply_name=> '${input1}',queue_name=> '${input2}')"
}
# ------------------------------------------------------------
f_apply_drop () {
INPUT
DBMS_APPLY_ADM "drop_apply('${input1}')"
}
# ------------------------------------------------------------
f_apply_start () {
INPUT
DBMS_APPLY_ADM "start_apply('${input1}')"
}
# ------------------------------------------------------------
f_apply_stop () {
INPUT
DBMS_APPLY_ADM "stop_apply('${input1}')"
}
# ------------------------------------------------------------
f_apply_start_all () {
SQL2LST "select apply_name from dba_apply where status='DISABLED';"
cat ${SQL2LST_LST} | grep '[a-zA-Z]' | while read input
do
ECHO "Start Apply ${input}"
DBMS_APPLY_ADM "start_apply('${input}')"
done
}
# ------------------------------------------------------------
f_apply_stop_all () {
SQL2LST "select apply_name from dba_apply where status='ENABLED';"
cat ${SQL2LST_LST} | grep '[a-zA-Z]' | while read input
do
ECHO "Stop Apply ${input}"
DBMS_APPLY_ADM "stop_apply('${input}')"
done
}
# ------------------------------------------------------------
f_apply_list_param () {
SQLQRY "select apply_name, substr(parameter,1,30) parameter , substr(value,1,30) value from dba_apply_parameters where set_by_user='YES' and upper(apply_name) like upper('%${input}%');"
}
# ------------------------------------------------------------
f_apply_list_all_param () {
SQLQRY "select apply_name, substr(parameter,1,30) parameter , substr(value,1,30) value from dba_apply_parameters where upper(apply_name) like upper('%${input}%');"
}
# ------------------------------------------------------------
f_apply_set_param () {
INPUT 3
DBMS_APPLY_ADM "set_parameter(apply_name=>'${input1}', parameter=> '${input2}', value=> '${input3}')"
}
# ------------------------------------------------------------
f_apply_unset_param () {
INPUT 2
DBMS_APPLY_ADM "set_parameter(apply_name=>'${input1}', parameter=> '${input2}')"
}
# ------------------------------------------------------------
f_apply_set_rs () {
INPUT 2
ALTER_APPLY "apply_name=> '${input1}', rule_set_name=>'${input2}'"
}
# ------------------------------------------------------------
f_apply_unset_rs () {
INPUT
ALTER_APPLY "apply_name=> '${input1}', remove_rule_set=>true"
}
# ------------------------------------------------------------
f_apply_set_nrs () {
INPUT 2
ALTER_APPLY "apply_name=> '${input1}', negative_rule_set_name=>'${input2}'"
}
# ------------------------------------------------------------
f_apply_unset_nrs () {
INPUT
ALTER_APPLY "apply_name=> '${input1}', remove_negative_rule_set=>true"
}
# ------------------------------------------------------------
f_apply_set_tag () {
INPUT 2
ALTER_APPLY "apply_name=> '${input1}', apply_tag=>'${input2}'"
}
# ------------------------------------------------------------
f_apply_unset_tag () {
INPUT
ALTER_APPLY "apply_name=> '${input1}', remove_apply_tag=>true"
}
# ------------------------------------------------------------
f_apply_set_ddl_hand () {
INPUT 2
ALTER_APPLY "apply_name=> '${input1}', ddl_handler=>'${input2}'"
}
# ------------------------------------------------------------
f_apply_unset_ddl_hand () {
INPUT
ALTER_APPLY "apply_name=> '${input1}', remove_ddl_handler=>true"
}
# ------------------------------------------------------------
f_apply_set_msg_hand () {
INPUT 2
ALTER_APPLY "apply_name=> '${input1}', message_handler=>'${input2}'"
}
# ------------------------------------------------------------
f_apply_unset_msg_hand () {
INPUT
ALTER_APPLY "apply_name=> '${input1}', remove_message_handler=>true"
}
# ------------------------------------------------------------
f_apply_set_pch_hand () {
INPUT 2
ALTER_APPLY "apply_name=> '${input1}', precommit_handler=>'${input2}'"
}
# ------------------------------------------------------------
f_apply_unset_pch_hand () {
INPUT
ALTER_APPLY "apply_name=> '${input1}', remove_precommit_handler=>true"
}
# ------------------------------------------------------------
f_apply_list_err () {
SQLQRY "select local_transaction_id,to_char(error_creation_time,'YYYY-MM-DD HH24:MI:SS') error_creation_time from dba_apply_error;"
}
# ------------------------------------------------------------
f_apply_show_err () {
INPUT
SQLQRY "select APPLY_NAME ,QUEUE_NAME ,QUEUE_OWNER ,LOCAL_TRANSACTION_ID ,SOURCE_DATABASE ,SOURCE_TRANSACTION_ID ,SOURCE_COMMIT_SCN ,MESSAGE_NUMBER ,ERROR_NUMBER ,ERROR_MESSAGE ,RECIPIENT_ID ,RECIPIENT_NAME ,MESSAGE_COUNT ,ERROR_CREATION_TIME from DBA_APPLY_ERROR where LOCAL_TRANSACTION_ID='${input1}';"
}
# ------------------------------------------------------------
f_apply_del_err () {
INPUT
DBMS_APPLY_ADM "delete_error(local_transaction_id=>'${input}')"
}
# ------------------------------------------------------------
f_apply_del_all_err () {
DBMS_APPLY_ADM "delete_all_errors"
}
# ------------------------------------------------------------
f_apply_exe_err () {
INPUT
DBMS_APPLY_ADM "execute_error(local_transaction_id=>'${input}')"
}
# ------------------------------------------------------------
f_apply_exe_all_err () {
DBMS_APPLY_ADM "execute_all_errors"
}
# ------------------------------------------------------------
f_apply_instantiated () {
SQLQRY "@s_apply_instantiated.sql"
}
# ------------------------------------------------------------

