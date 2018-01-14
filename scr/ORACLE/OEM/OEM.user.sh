# ############################################################
# OEM USER FUNCTIONS - Oracle Enterprise Manager User Management
# ############################################################
# ------------------------------------------------------------
# OEM USER actions
action_L1="create delete list "
action_L2="user_pwd user_type user_roles user_emails user_priv user_profile user_desc user_expire user_unexpire "
action_L3="user_prevent_pwd_change user_allow_pwd_change user_department user_cost_center user_line_of_business user_contact user_location "
action_L4="grant_roles revoke_roles grant_privs revoke_privs allocate_quota revoke_quota lock unlock "
action_L5=" "
action_L="$action_L1 $action_L2 $action_L3 $action_L4 $action_L5"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
create,user_name,Create_OEM_user \
delete,user_name,Drop_OEM_user \
list,none,Create_OEM_user \
user_pwd,user_name:new_password,Modify_OEM_User_Password \ 
user_type,user_name:new_password,Modify_OEM_User_Type \ 
user_roles,user_name:new_password,Modify_OEM_User_Roles \ 
user_emails,user_name:new_password,Modify_OEM_User_Emails \ 
user_priv,user_name:new_password,Modify_OEM_User_Privileges \ 
user_profile,user_name:new_password,Modify_OEM_User_Profile \ 
user_desc,user_name:new_password,Modify_OEM_User_Description \ 
user_expire,user_name:new_password,Expire_OEM_User \ 
user_unexpir,user_name:new_password,Unexpire_OEM_User \
user_prevent_pwd_change,user_name:new_password,Prevent_OEM_User_from_changing_password \ 
user_allow_pwd_change,user_name:new_password,Allow_OEM_User_to_changing_password \ 
user_department,user_name:new_password,Modify_OEM_User_Department \ 
user_cost_center,user_name:new_password,Modify_OEM_User_CostCenter \ 
user_line_of_business,user_name:new_password,Modify_OEM_User_Line_of_Business \ 
user_contact,user_name:new_password,Modify_OEM_User_Contact \ 
user_location,user_name:new_password,Modify_OEM_User_Location \
grant_roles,user_name:roles_list,Grant_Roles_to_OEM_User \
revoke_roles,user_name:roles_list,Revoke_Roles_from_OEM_User \
grant_privs,user_name:roles_list,Grant_Privileges_to_OEM_User \
revoke_privs,user_name:roles_list,Revoke_Privileges_from_OEM_User \
allocate_quota,user_name:roles_list,Allocate_Quota_to_OEM_User \
revoke_quota,user_name:roles_list,Revoke_Quota_from_OEM_User \
lock,user_name,Lock_OEM_User \
unlock,user_name,Unlock_OEM_User \
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
f_user_create () {
INPUT
${EMCLI} create_user -name="${input1}"
}
# ------------------------------------------------------------
f_user_delete () {
INPUT
${EMCLI} delete_user -name="${input1}"
}
# ------------------------------------------------------------
f_user_list () {
ECHO "Not coded yet"
}
# ------------------------------------------------------------
f_user_user_pwd () {
INPUT 2
${EMCLI} modify_user -name="${input1}" -password="${input2}"
}
# ------------------------------------------------------------
f_user_user_type () {
INPUT 2
${EMCLI} modify_user -name="${input1}" -type="${input2}"
}
# ------------------------------------------------------------
f_user_user_roles () {
INPUT 2
#[-roles="role1;role2;..."
${EMCLI} modify_user -name="${input1}" -roles="${input2}"
}
# ------------------------------------------------------------
f_user_user_emails () {
INPUT 2
${EMCLI} modify_user -name="${input1}" -email="${input2}"
}
# ------------------------------------------------------------
f_user_user_priv () {
INPUT 2
${EMCLI} modify_user -name="${input1}" -privilege="${input2}"
}
# ------------------------------------------------------------
f_user_user_profile () {
INPUT 2
${EMCLI} modify_user -name="${input1}" -profile="${input2}"
}
# ------------------------------------------------------------
f_user_user_desc () {
INPUT 2
${EMCLI} modify_user -name="${input1}" -desc="${input2}"
}
# ------------------------------------------------------------
f_user_user_expire () {
INPUT
${EMCLI} modify_user -name="${input1}" -expired="true"
}
# ------------------------------------------------------------
f_user_user_unexpire () {
INPUT
${EMCLI} modify_user -name="${input1}" -expired="false"
}
# ------------------------------------------------------------
f_user_user_prevent_pwd_change () {
INPUT
${EMCLI} modify_user -name="${input1}" -prevent_change_password="true"
}
# ------------------------------------------------------------
f_user_user_allow_pwd_change () {
INPUT
${EMCLI} modify_user -name="${input1}" -prevent_change_password="false"
}
# ------------------------------------------------------------
f_user_user_department () {
INPUT 2
${EMCLI} modify_user -name="${input1}" -department="${input2}"
}
# ------------------------------------------------------------
f_user_user_cost_center () {
INPUT 2
${EMCLI} modify_user -name="${input1}" -cost_center="${input2}"
}
# ------------------------------------------------------------
f_user_user_line_of_business () {
INPUT 2
${EMCLI} modify_user -name="${input1}" -line_of_business="${input2}"
}
# ------------------------------------------------------------
f_user_user_contact () {
INPUT 2
${EMCLI} modify_user -name="${input1}" -contact="${input2}"
}
# ------------------------------------------------------------
f_user_user_location () {
INPUT 2
${EMCLI} modify_user -name="${input1}" -location="${input2}"
}
# ------------------------------------------------------------
f_user_grant_roles () {
INPUT 2
${EMCLI} grant_roles -name="${input1}" -roles="${input2}"
}
# ------------------------------------------------------------
f_user_revoke_roles () {
INPUT 2
${EMCLI} revoke_roles -name="${input1}" -roles="${input2}"
}
# ------------------------------------------------------------
f_user_grant_privs () {
INPUT 2
${EMCLI} grant_privs -name="${input1}" -privilege="${input2}" -grant_all_targets_on_host="yes"
}
# ------------------------------------------------------------
f_user_revoke_privs () {
INPUT 2
${EMCLI} revoke_privs -name="${input1}" -privilege="${input2}"
}
# ------------------------------------------------------------
f_user_allocate_quota () {
INPUT 2
${EMCLI} allocate_quota -assignee_name="${input1}" -assignee_type="user" -quota="${input2}"
}
# ------------------------------------------------------------
f_user_revoke_quota () {
INPUT 2
${EMCLI} revoke_quota -assignee_name="${input1}" -assignee_type="user" -quota="${input2}"
}
# ------------------------------------------------------------
f_user_lock () {
INPUT
${EMCLI} lock_user_account -name="${input1}"
}
# ------------------------------------------------------------
f_user_unlock () {
INPUT
${EMCLI} lock_user_account -name="${input1}" -unlock
}
# ------------------------------------------------------------
f_user_get_supported_privileges () {
ECHO "Not coded yet"
}
# ------------------------------------------------------------
