# ############################################################
# OEM GROUP FUNCTIONS - Oracle Enterprise Manager Groups Management
# ############################################################
# ------------------------------------------------------------
# OEM GROUP actions
action_L1="create delete list list_csv list_script export import "
action_L2="modify_type add_target delete_target "
action_L3="enable_priv_propagation disable_priv_propagation drop_existing_grants "
action_L4="list_members list_members_csv list_members_script "
action_L="$action_L1 $action_L2 $action_L3 $action_L4"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
create,group_name,Create_OEM_Groups \
delete,group_name,Delete_OEM_Groups \
list,none,List_OEM_Groups \
list_csv,none,List_OEM_Groups_in_CSV_Format \
list_script,none,Get_OEM_Groups_Script \
export,none,Export_Admin_Group_Hierarchy \
import,none,Import_Admin_Group_Hierarchy \
enable_priv_propagation,group_name,Enable_Privielge_Propagation \
disable_priv_propagation,group_name,disable_Privielge_Propagation \
drop_existing_grants,group_name,Drop_Existing_Privileges
list_members,group_name,List_Members_of_OEM_Group \
list_members_csv,group_name,List_Members_of_OEM_Group_in_CSV_Format \
list_members_script,group_name,Get_OEM_Group_Members_Script \
"
# ------------------------------------------------------------
# Global variable overwrites
EMCLI_HOME=${HOME}/emcli

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions

# ------------------------------------------------------------
f_group_create () {
INPUT
${EMCLI_HOME}/emcli create_group -name="${input1}"
}
# ------------------------------------------------------------
f_group_delete () {
INPUT
${EMCLI_HOME}/emcli delete_group -name="${input1}"
}
# ------------------------------------------------------------
f_group_list () {
${EMCLI_HOME}/emcli get_groups -format="name:pretty" 
}
# ------------------------------------------------------------
f_group_list_csv () {
${EMCLI_HOME}/emcli get_groups -format="name:csv" 
}
# ------------------------------------------------------------
f_group_list_script () {
${EMCLI_HOME}/emcli get_groups -format="name:script" 
}
# ------------------------------------------------------------
f_group_export () {
${EMCLI_HOME}/emcli export_admin_group 
}
# ------------------------------------------------------------
f_group_import () {
${EMCLI_HOME}/emcli import_admin_group -property_file="null"
}
# ------------------------------------------------------------
f_group_modify_type () {
INPUT 2
${EMCLI_HOME}/emcli modify_group -name="${input1}" -type="${input2}"
}
# ------------------------------------------------------------
f_group_add_target () {
INPUT 3
${EMCLI_HOME}/emcli modify_group -name="${input1}" -add_targets="${input2}:${input3}"
}
# ------------------------------------------------------------
f_group_delete_target () {
INPUT 3
${EMCLI_HOME}/emcli modify_group -name="${input1}" -delete_targets="${input2}:${input3}"
}
# ------------------------------------------------------------
f_group_enable_priv_prop () {
INPUT
${EMCLI_HOME}/emcli -name="${input1}" -privilege_propagation=true
}
# ------------------------------------------------------------
f_group_disable_priv_prop () {
INPUT
${EMCLI_HOME}/emcli -name="${input1}" -privilege_propagation=false
}
# ------------------------------------------------------------
f_group_drop_existing_grants () {
INPUT
${EMCLI_HOME}/emcli -name="${input1}" -drop_existing_grants=yes
}
# ------------------------------------------------------------
f_group_list_members () {
INPUT
${EMCLI_HOME}/emcli get_group_members -name="${input1}" -format="name:pretty"
}
# ------------------------------------------------------------
f_group_list_members_csv () {
INPUT
${EMCLI_HOME}/emcli get_group_members -name="${input1}" -format="name:csv"
}
# ------------------------------------------------------------
f_group_list_members_script () {
INPUT
${EMCLI_HOME}/emcli get_group_members -name="${input1}" -format="name:script"
}
# ------------------------------------------------------------
