# ############################################################
# OEM PROBLEM FUNCTIONS - Oracle Enterprise Manager Configuration
# ############################################################
# ------------------------------------------------------------
# OEM PROBLEM actions
action_L1="add_comment supress_manual supress_severity supress_yyyymmdd supress_forever unsupress "
action_L2="list_older notify_older clear_older "
action_L3="list_for_target notify_for_target clear_for_target "
action_L4="list_unacknowledged notify_unacknowledged clear_unacknowledged "
action_L="$action_L1 $action_L2 $action_L3 $action_L4"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
add_comment,problem_id,Add_Comment_to_Problem \
supress_manual,problem_id,Supress_Problem_UNTIL_MANUALLY_REMOVED \
supress_severity,problem_id,Supress_Problem_UNTIL_SEVERITY_CHANGE \
supress_yyyymmdd,problem_id:yyyymmdd,Supress_Problem_UNTIL_SPECIFIED_DATE \
supress_forever,problem_id,Supress_Problem_UNTIL_CLEARED \
unsupress,problem_id,Unsupress_Problem \
list_older,problem_key:problem_type:older_than,List_Problems_Older_than_date \
notify_older,problem_key:problem_type:older_than,Notify_Problems_Older_than_date \
clear_older,problem_key:problem_type:older_than,Clear_Problems_Older_than_date \
list_for_target,problem_key:problem_type:older_than:target_name,List_Problems_Older_than_date_for_a_given_Target \
notify_for_target,problem_key:problem_type:older_than:target_name,Notify_Problems_Older_than_date_for_a_given_Target \
clear_for_target,problem_key:problem_type:older_than:target_name,Clear_Problems_Older_than_date_for_a_given_Target \
list_unacknowledged,problem_key:problem_type:older_than,List_Problems_Older_than_date_and_Unacknowledged \
notify_unacknowledged,problem_key:problem_type:older_than,Notify_Problems_Older_than_date_and_Unacknowledged \
clear_unacknowledged,problem_key:problem_type:older_than,Clear_Problems_Older_than_date_and_Unacknowledged \
"
# ------------------------------------------------------------
# Global variable overwrites
EMCLI_HOME=${HOME}/emcli

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions

# ------------------------------------------------------------
f_problem_add_comment () {
INPUT 2
${EMCLI_HOME}/emcli add_comment_to_problem -problem_id="${input1}" -comment="${input2}"
}
# ------------------------------------------------------------
f_problem_supress_manual () {
INPUT
${EMCLI_HOME}/emcli suppress_problem -problem_id="${input1}" -problem_type="UNTIL_MANUALLY_REMOVED"
}
# ------------------------------------------------------------
f_problem_supress_severity () {
INPUT
${EMCLI_HOME}/emcli suppress_problem -problem_id="${input1}" -problem_type="UNTIL_SEVERITY_CHANGE"
}
# ------------------------------------------------------------
f_problem_supress_yyyymmdd () {
INPUT 2
${EMCLI_HOME}/emcli suppress_problem -problem_id="${input1}" -problem_type="UNTIL_SPECIFIED_DATE" -date="${input2}"
}
# ------------------------------------------------------------
f_problem_supress_forever () {
INPUT 2
${EMCLI_HOME}/emcli suppress_problem -problem_id="${input1}" -problem_type="UNTIL_CLEARED"
}
# ------------------------------------------------------------
f_problem_unsupress () {
INPUT
${EMCLI_HOME}/emcli unsuppress_problem -problem_id="${input1}"
}
# ------------------------------------------------------------
f_problem_list_older () {
INPUT 3
${EMCLI_HOME}/emcli clear_problem -problem_key="${input1}" -target_type="${input2}" -older_than="${input3}" -preview
}
# ------------------------------------------------------------
f_problem_notify_older () {
INPUT 3
${EMCLI_HOME}/emcli clear_problem -problem_key="${input1}" -target_type="${input2}" -older_than="${input3}" -send_notification
}
# ------------------------------------------------------------
f_problem_clear_older () {
INPUT 3
${EMCLI_HOME}/emcli clear_problem -problem_key="${input1}" -target_type="${input2}" -older_than="${input3}"
}
# ------------------------------------------------------------
f_problem_list_for_target () {
INPUT 4
${EMCLI_HOME}/emcli clear_problem -problem_key="${input1}" -target_type="${input2}" -older_than="${input3}" -target_name="${input4}" -preview
}
# ------------------------------------------------------------
f_problem_notify_for_target () {
INPUT 4
${EMCLI_HOME}/emcli clear_problem -problem_key="${input1}" -target_type="${input2}" -older_than="${input3}" -target_name="${input4}" -send_notification
}
# ------------------------------------------------------------
f_problem_clear_for_target () {
INPUT 4
${EMCLI_HOME}/emcli clear_problem -problem_key="${input1}" -target_type="${input2}" -older_than="${input3}" -target_name="${input4}"
}
# ------------------------------------------------------------
f_problem_list_unacknowledged () {
INPUT 3
${EMCLI_HOME}/emcli clear_problem -problem_key="${input1}" -target_type="${input2}" -older_than="${input3}" -unacknowledged_only -preview
}
# ------------------------------------------------------------
f_problem_notify_unacknowledged () {
INPUT 3
${EMCLI_HOME}/emcli clear_problem -problem_key="${input1}" -target_type="${input2}" -older_than="${input3}" -unacknowledged_only -send_notification
}
# ------------------------------------------------------------
f_problem_clear_unacknowledged () {
INPUT 3
${EMCLI_HOME}/emcli clear_problem -problem_key="${input1}" -target_type="${input2}" -older_than="${input3}" -unacknowledged_only
}
# ------------------------------------------------------------
