# ############################################################
# OEM PROFILE FUNCTIONS - Oracle Enterprise Manager Configuration
# ############################################################
# ------------------------------------------------------------
# OEM PROFILE actions
action_L1="create associate disassociate delete "
action_L2="modify_desc modify_users include_profiles "
action_L3="allocate_quota revoke_quota "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
create,profile_name,Create_OEM_User_Profile \
associate,profile_name:user_names,Associate_OEM_User_Profile_with_comma_seperated_list_of_users \
disassociate,profile_name:user_names,Dissssociate_OEM_User_Profile_with_comma_seperated_list_of_users \
delete,profile_name,Delete_OEM_User_Profile \
modify_desc,profile_name:description,Modify_OEM_User_Profile_Description \
modify_users,profile_name:user_names,Modify_OEM_User_Profile_List_of_Users \
include_profiles,profile_name:profile_names,Modify_OEM_User_Profile_to_include_list_of_profiles \
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
f_profile_create () {
INPUT
${EMCLI} create_user_profile -name="${input1}"
}
# ------------------------------------------------------------
f_profile_associate () {
INPUT 2
${EMCLI} associate_user_profile -name="${input1}" -users="${input2}"
}
# ------------------------------------------------------------
f_profile_disassociate () {
INPUT 2
${EMCLI} disassociate_user_profile -name="${input1}" -users="${input2}"
}
# ------------------------------------------------------------
f_profile_delete () {
INPUT
${EMCLI} delete_user_profile -name="${input1}"
}
# ------------------------------------------------------------
f_profile_modify_desc () {
INPUT 2
${EMCLI} modify_user_profile -name="${input1} -description=${input2}"
}
# ------------------------------------------------------------
f_profile_modify_users () {
INPUT 2
${EMCLI} modify_user_profile -name="${input1} -users=${input2}"
}
# ------------------------------------------------------------
f_profile_include_profiles () {
INPUT 2
${EMCLI} modify_user_profile -name="${input1} -included_profiles=${input2}"
}
# ------------------------------------------------------------
f_user_allocate_quota () {
INPUT 2
${EMCLI} allocate_quota -assignee_name="${input1}" -assignee_type="profile" -quota="${input2}"
}
# ------------------------------------------------------------
f_user_revoke_quota () {
INPUT 2
${EMCLI} revoke_quota -assignee_name="${input1}" -assignee_type="profile" -quota="${input2}"
}
# ------------------------------------------------------------
