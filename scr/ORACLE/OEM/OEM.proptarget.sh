# ############################################################
# OEM TARGET PROPERTY FUNCTIONS - Oracle Enterprise Manager Target Property Management
# ############################################################
# ------------------------------------------------------------
# OEM TARGET PROPERTY actions
action_L1="target_types prop_names "
action_L2="list add remove set_value "
action_L3=""
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
target_types,none,List_Target_Types \
prop_names,property_name,List_of_Master_List_of_Property_Names \
list,target_type,List_Properties_for_Target_Type \
add,target_type:property_name,Add_Property_to_Target_Type \
remove,target_type:property_name,Remove_Property_from_Target_Type \
set_value,property_name,Disable_Target_Property_Master_List_of_Values \
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
f_proptarget_target_types () {
${EMCLI} get_target_types
}
# ------------------------------------------------------------
f_proptarget_prop_names () {
${EMCLI} list_target_property_names
}
# ------------------------------------------------------------
f_proptarget_list () {
INPUT
${EMCLI} get_target_properties -target_type="${input1}"
}
# ------------------------------------------------------------
f_proptarget_add () {
INPUT 2
${EMCLI} add_target_property -target_type="${input1}" -property="${input2}" 
}
# ------------------------------------------------------------
f_proptarget_remove () {
INPUT 2
${EMCLI} remove_target_property -target_type="${input1}" -property="${input2}" 
}
# ------------------------------------------------------------
f_proptarget_set_value () {
INPUT 2
${EMCLI} set_target_property_value -target_type="${input1}" -values="${input2}"  -property_records="${input3}"
}
# ------------------------------------------------------------
