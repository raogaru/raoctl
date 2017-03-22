# ############################################################
# OEM PROPERTY MASTER LIST FUNCTIONS - Oracle Enterprise Manager Property Master List
# ############################################################
# ------------------------------------------------------------
# OEM PROPERTY MASTER LIST actions
action_L1="list_names list_values add delete enable disable "
action_L2=""
action_L3=""
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list_names,property_name,List_of_Master_List_of_Property_Names \
list_values,none,List_of_Target_Property_Master_List_of_Values \
add,property_name:property_value,Add_Target_Property_Master_List_of_Values \
delete,property_name:property_value,Delete_Target_Property_Master_List_of_Values \
enable,property_name,Enable_Target_Property_Master_List_of_Values \
disable,property_name,Disable_Target_Property_Master_List_of_Values \
"
# ------------------------------------------------------------
# Global variable overwrites
EMCLI_HOME=${HOME}/emcli
EMCLI=${EMCLI_HOME}/emcli

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions

# ------------------------------------------------------------
f_propmas_list_names () {
${EMCLI} list_target_property_names
}
# ------------------------------------------------------------
f_propmas_list_values () {
INPUT
${EMCLI} list_target_properties_master_list_values  -property_name="${input1}" -details
}
# ------------------------------------------------------------
f_propmas_add () {
INPUT 2
${EMCLI} add_to_target_properties_master_list -property_name="${input1}" -property_value="${input2}"
}
# ------------------------------------------------------------
f_propmas_delete () {
INPUT 2
${EMCLI} delete_from_target_properties_master_list -property_name="${input1}" -property_value="${input2}"
}
# ------------------------------------------------------------
f_propmas_enable () {
INPUT
${EMCLI} use_target_properties_master_list -property_name="${input1}" -enable
}
# ------------------------------------------------------------
f_propmas_disable () {
INPUT
${EMCLI} use_target_properties_master_list -property_name="${input1}" -disable
}
# ------------------------------------------------------------
