# ############################################################
# OEM RESOLUTION STATE FUNCTIONS - Oracle Enterprise Manager Resolution State Management
# ############################################################
# ------------------------------------------------------------
# OEM RESOLUTION STATE actions
action_L1="list create create_for_incident create_for_problem delete change_lablel change_position "
action_L2=""
action_L3=""
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_OEM_Resolution_States \
create,label_name:position,List_OEM_Resolution_States_for_both_Incident_and_Problems \
create_for_incident,label_name:position,List_OEM_Resolution_States_for_both_Incident \
create_for_problem,label_name:position,List_OEM_Resolution_States_for_both_Problem \
delete,label_name:alternate_label_name,Delete_OEM_Resolution_State \
modify_label,old_label_name:new_label_name,Modify_OEM_Resolution_State_Label \
modify_position,label_name:new_position,Modify_OEM_Resolution_State_Position \
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
f_resolstate_list () {
${EMCLI} get_resolution_states
}
# ------------------------------------------------------------
f_resolstate_create () {
INPUT 2
${EMCLI} create_resolution_state -label="${input1}" -position="${input2}"

# ------------------------------------------------------------
f_resolstate_create_for_incident () {
INPUT 2
${EMCLI} create_resolution_state -label="${input1}" -position="${input2}" -applies_to="INC"

# ------------------------------------------------------------
f_resolstate_create_for_problem () {
INPUT 2
${EMCLI} create_resolution_state -label="${input1}" -position="${input2}" -applies_to="PBLM"
}
# ------------------------------------------------------------
f_resolstate_delete () {
INPUT 2
${EMCLI} delete_resolution_state -label="${input1}" -alt_res_state_label="${input2}"
}
# ------------------------------------------------------------
f_resolstate_change_label () {
INPUT 2
${EMCLI} modify_resolution_state -label="${input1}" -new_label="${input2}"
}
# ------------------------------------------------------------
f_resolstate_change_position () {
INPUT 2
${EMCLI} modify_resolution_state -label="${input1}" -position="${input2}"
}
# ------------------------------------------------------------
