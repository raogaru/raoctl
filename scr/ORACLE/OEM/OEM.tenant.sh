# ############################################################
# OEM TENANT FUNCTIONS - Oracle Enterprise Manager Tenants Managment
# ############################################################
# ------------------------------------------------------------
# OEM TENANT actions
action_L1="create delete owner active inactive "
action_L2=""
action_L3=""
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
create,tenant_name,Create_OEM_Tenant \
delete,tenant_name,Delete_OEM_Tenant \
list,none,List_OEM_Tenant \
owner,tenant_name:new_owner_name,Change_Owner_of_OEM_Tenant \
active,tenant_name,Activate_OEM_Tenant \
inactive,tenant_name,Deactivate_OEM_Tenant \
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
f_tenant_create () {
INPUT 3
${EMCLI} create_tenant -name="${input1}" -description="${input2}" -owner_name="${input3}"
}
# ------------------------------------------------------------
f_tenant_delete () {
INPUT
${EMCLI} delete_tenant -name="${input1}"
}
# ------------------------------------------------------------
f_tenant_list () {
ECHO "Not coded yet"
}
# ------------------------------------------------------------
f_tenant_owner () {
INPUT 2
${EMCLI} update_tenant_owner -name="${input1}" -new_owner="${input2}"
}
# ------------------------------------------------------------
f_tenant_active () {
INPUT
${EMCLI} update_tenant_state -name="${input1}" -active="true"
}
# ------------------------------------------------------------
f_tenant_inactive () {
INPUT
${EMCLI} update_tenant_state -name="${input1}" -active="false"
}
# ------------------------------------------------------------
