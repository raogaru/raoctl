# ############################################################
# DBMS_SCHEDULER GROUP FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# group actions
action_L1="list create drop "
action_L2="list_member add_member remove_member "
action_L3="xxx "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,NONE,List_Groups \
create,group_name:group_type,Create_Group \
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
f_group_list () { 
SQLQRY "select group_name, group_type, enabled from dba_scheduler_groups;"
}
# ------------------------------------------------------------
f_group_create () { 
INPUT 2
SCHEDULER_p "create_group(group_name=>'${input1}', group_type=>'${input2}')"
}
# ------------------------------------------------------------
f_group_drop () { 
INPUT
SCHEDULER_p "drop_group(group_name=>'${input1}', force=>FALSE)"
}
# ------------------------------------------------------------
f_group_list_member () { 
SQLQRY "select group_name, member_name from dba_scheduler_group_members order by group_name;"
}
# ------------------------------------------------------------
f_group_add_member () { 
INPUT 2
SCHEDULER_p "add_group_member(group_name=>'${input1}', member=>'${input2}')"
}
# ------------------------------------------------------------
f_group_remove_member () { 
INPUT 2
SCHEDULER_p "remove_group_member(group_name=>'${input1}', member=>'${input2}')"
}
# ------------------------------------------------------------
