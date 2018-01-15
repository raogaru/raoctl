# ############################################################
# DEVOPS LIQUIBASE DEPLOY FUNCTIONS - Liquibase Database Deploymen Tool - Deploy (update)
# ############################################################
# ------------------------------------------------------------
# LIQUIBASE DEPLOY actions
action_L1="deploy deploy_next_n deploy_2_tag "
action_L2="show show_next_n show_2_tag "
action_L3=" "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
deploy,none,Run_liquibase_update \
deploy_next_n,none,Run_liquibase_update_with_next_N_change_sets \
deploy_2_tag,none,Run_liquibase_update_to_changeset_with_Tag \
show,none,Show_liquibase_update_SQLs \
show_next_n,none,Show_liquibase_update_SQLs_with_next_N_change_sets \
show_2_tag,none,Show_liquibase_update_SQLs_to_changeset_with_Tag \
"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables
INCENV liquibase
# ------------------------------------------------------------
# Module specific common functions
INCLIB_c
# ------------------------------------------------------------
f_deploy_deploy () {
LIQUIBASE update
}
# ------------------------------------------------------------
f_deploy_deploy_next_n () {
INPUT
LIQUIBASE updateCount ${input1}
}
# ------------------------------------------------------------
f_deploy_deploy_2_tag () {
INPUT
LIQUIBASE updateToTag=${input1}
}
# ------------------------------------------------------------
f_deploy_show () {
LIQUIBASE updateSQL
}
# ------------------------------------------------------------
f_deploy_show_next_n () {
INPUT
LIQUIBASE updateCountSQL ${input1}
}
# ------------------------------------------------------------
f_deploy_show_2_tag () {
INPUT
LIQUIBASE updateToTag=${input1}
}
# ------------------------------------------------------------
