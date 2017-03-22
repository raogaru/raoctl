# ############################################################
# OEM INCIDENT FUNCTIONS - Oracle Enterprise Manager Incident Management
# ############################################################
# ------------------------------------------------------------
# OEM INCIDENT actions
action_L1="add_comment supress_manual supress_severity supress_yyyymmdd supress_forever unsupress "
action_L2="clearable clear "
action_L3=""
action_L4=""
action_L="$action_L1 $action_L2 $action_L3 $action_L4"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
add_comment,incident_id,Add_Comment_to_Incident\
supress_manual,incident_id,Supress_Incident_UNTIL_MANUALLY_REMOVED \
supress_severity,incident_id,Supress_Incident_UNTIL_SEVERITY_CHANGE \
supress_yyyymmdd,incident_id:yyyymmdd,Supress_Incident_UNTIL_SPECIFIED_DATE \
supress_forever,incident_id,Supress_Incident_UNTIL_CLEARED \
unsupress,incident_id,Unsupress_Incident \
clearable,incident_id_list,List_of_Incidents_that_can_be_cleared \
clear,incident_id_list,Clear_Incidents \
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
f_incident_add_comment () {
INPUT 2
${EMCLI} add_comment_to_incident -incident_id="${input1}" -comment="${input2}"
}
# ------------------------------------------------------------
f_incident_supress_manual () {
INPUT
${EMCLI} suppress_incident -incident_id="${input1}" -suppress_type="UNTIL_MANUALLY_REMOVED"
}
# ------------------------------------------------------------
f_incident_supress_severity () {
INPUT
${EMCLI} suppress_incident -incident_id="${input1}" -suppress_type="UNTIL_SEVERITY_CHANGE"
}
# ------------------------------------------------------------
f_incident_supress_yyyymmdd () {
INPUT 2
${EMCLI} suppress_incident -incident_id="${input1}" -suppress_type="UNTIL_SPECIFIED_DATE" -date="${input2}"
}
# ------------------------------------------------------------
f_incident_supress_forever () {
INPUT
${EMCLI} suppress_incident -incident_id="${input1}" -suppress_type="UNTIL_CLEARED"
}
# ------------------------------------------------------------
f_incident_unsupress () {
INPUT
${EMCLI} unsuppress_incident -incident_id="${input1}"
}
# ------------------------------------------------------------
f_incident_clearable () {
INPUT
${EMCLI} delete_incident_record -incident_number_list="${input1}" -review
}
# ------------------------------------------------------------
f_incident_clear () {
INPUT
${EMCLI} delete_incident_record -incident_number_list="${input1}" -force
}
# ------------------------------------------------------------
