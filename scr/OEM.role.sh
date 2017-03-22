# ############################################################
# OEM ROLE FUNCTIONS - Oracle Enterprise Manager Roles Management
# ############################################################
# ------------------------------------------------------------
# OEM ROLE actions
action_L1="create delete list "
action_L2="desc priv "
action_L3="roles users"
action_L="$action_L1 $action_L2 $action_L3 "

 ------------------------------------------------------------
# USAGE DATA
usage_L=" \
create,role_name,Create_OEM_Role \
delete,role_name,Delete_OEM_Role \
list,none,List_OEM_Roles \
desc,description,Modify_OEM_Role_Description \
priv,privielge_list,Modify_OEM_Role_Privileges \
roles,roles_list,Modify_OEM_Role_Member-Roles (Semicolon seperated) \
users,users_list,Modify_OEM_Role_Member-Users (Semicolon seperated) \
"
# ------------------------------------------------------------
# Global variable overwrites
EMCLI_HOME=${HOME}/emcli

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions

# ------------------------------------------------------------
f_role_create () {
INPUT
${EMCLI_HOME}/emcli create_role -name="${input1}"
}
# ------------------------------------------------------------
f_role_delete () {
INPUT
${EMCLI_HOME}/emcli delete_role -name="${input1}"
}
# ------------------------------------------------------------
f_role_list () {
ECHO "Not coded yet"
}
# ------------------------------------------------------------
f_role_desc () {
INPUT 2
${EMCLI_HOME}/emcli modify_role -name="${input1}" -description="${input2}"
}
# ------------------------------------------------------------
f_role_priv () {
INPUT 2
${EMCLI_HOME}/emcli modify_role -name="${input1}" -privilege="${input2}"
}
# ------------------------------------------------------------
f_role_member_roles () {
INPUT 2
${EMCLI_HOME}/emcli modify_role -name="${input1}" -roles="${input2}"
}
# ------------------------------------------------------------
f_role_member_users () {
INPUT 2
#[-users="user1;user2;..."]
${EMCLI_HOME}/emcli modify_role -name="${input1}" -users="${input2}"
}
# ------------------------------------------------------------
