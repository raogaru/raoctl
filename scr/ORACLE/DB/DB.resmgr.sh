# ############################################################
# ORACLE DATABASE RESOURCE MANAGER - FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# ORM actions
action_L1="pa_clear pa_create pa_validate pa_submit"
action_L2="create_plan update_plan delete_plan delete_plan_cascade switch_plan switch_plan_for_sid "
action_L3="update_plan_ "
action_L4=" "
action_L="$action_L1 $action_L2 $action_L3 $action_L4"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
pa_clear,none,Clear_ORM_pending_area \
pa_create,none,Create_ORM_pending_area \
pa_validate,none,Validate_ORM_pending_area \
pa_submit,none,Submit_ORM_pending_area \
"
# ------------------------------------------------------------
#local variables
# local variables
typeset -u REPORTS_DIR="REPORTS_DIR"
rc_SHOW_SQL=YES
# ------------------------------------------------------------
ORM_p () {
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_resource_manager.${vLine};"
#SQLEXEC
SQLSHOW
}
# ------------------------------------------------------------
f_resmgr_pa_clear () {
ORM_p "clear_pending_area"
}
# ------------------------------------------------------------
f_resmgr_pa_create () {
ORM_p "create_pending_area"
}
# ------------------------------------------------------------
f_resmgr_pa_validate () {
ORM_p "validate_pending_area"
}
# ------------------------------------------------------------
f_resmgr_pa_submit () {
ORM_p "submit_pending_area"
}
# ------------------------------------------------------------
f_resmgr_create_plan () {
INPUT
ORM_p "create_plan(plan=>'${input1}',comment=>'${input1}')"
}
# ------------------------------------------------------------
f_resmgr_update_plan () {
INPUT 3
typeset -l INPUT2=${input2}
x="new_active_sess_pool_mth new_parallel_degree_limit_mth new_queueing_mth new_mgmt_mth "
[[ ! ${INPUT2} = @($x) ]] && ERROR "Invalid plan parameter \"$INPUT2\". Valid values are $x"
ORM_p "update_plan(plan=>'${input1}',${input2}=>'${input3}')"
}
# ------------------------------------------------------------
f_resmgr_delete_plan () {
INPUT
ORM_p "delete_plan(plan=>'${input1}')"
}
# ------------------------------------------------------------

action_L2="create_plan delete_plan delete_plan_cascade switch_plan switch_plan_for_sid "
