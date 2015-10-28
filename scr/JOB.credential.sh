# ############################################################
# DBMS_SCHEDULER CREDENTIAL FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# credential actions
action_L1="list create drop "
action_L2="xxx "
action_L3="ppp "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,NONE,List_Groups \
create,credential_name:group_type,Create_Group \
drop,group_name,Drop_Group \
list_member,NONE,List_Group_Members \
add_member,group_name:member,Add_Group_Member \
remove_member,group_name:member,Remove_Group_Member \
"
# ------------------------------------------------------------
# local variables
v_debug=0
# ------------------------------------------------------------
INCLIB_c
# ------------------------------------------------------------
f_credential_list () { 
SQLQRY "select credential_name, substr(username,1,30) username, database_role dbrole, windows_domain from dba_scheduler_credentials;"
}
# ------------------------------------------------------------
f_credential_create () { 
INPUT 3
SCHEDULER_p "create_credential(credential_name=>'${input1}', username=>'${input2}',password=>'${input3}')"
}
# ------------------------------------------------------------
f_credential_drop () { 
INPUT
SCHEDULER_p "drop_credential(credential_name=>'${input1}', force=>FALSE)"
}
# ------------------------------------------------------------
