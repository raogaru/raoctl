# ############################################################
# OEM RULESET FUNCTIONS - Oracle Enterprise Manager RuleSet Management
# ############################################################
# ------------------------------------------------------------
# OEM RULESET actions
action_L1=" "
action_L2="export import import_to_ruleset"
action_L3="add_target remove_target "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
export,ruleset_name,Export_OEM_Ruleset_to_XML \
import,export_file,Import_OEM_Ruleset_from_XML \
import_to_ruleset,export_file:new_ruleset_name,Import_OEM_Ruleset_from_XML_to_Alternate_Ruleset \
add_target,ruleset_name:target_name:target_type,Add_Target_to_OEM_Ruleset \
remove_target,ruleset_name:target_name:target_type,Remove_Target_to_OEM_Ruleset \
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
f_ruleset_export () {
INPUT
${EMCLI} export_incident_rule_set -rule_set_name="${input1}" -export_file="${RPT_DIR}/"
}
# ------------------------------------------------------------
f_ruleset_import () {
INPUT
${EMCLI} import_incident_rule_set -import_file="${RPT_DIR}/${input1}"
}
# ------------------------------------------------------------
f_ruleset_import_to_ruleset () {
INPUT 2
${EMCLI} import_incident_rule_set -import_file="${input1}" -alt_rule_set_name="${input2}" 
}
# ------------------------------------------------------------
f_ruleset_add_target () {
INPUT 3
${EMCLI} add_target_to_rule_set -rule_set_name="${input1}" -target_name="${input2}" -target_type="${input3}"
}
# ------------------------------------------------------------
f_ruleset_remove_target () {
INPUT 3
${EMCLI} remove_target_from_rule_set -rule_set_name="${input1}" -target_name="${input2}" -target_type="${input3}"
}
# ------------------------------------------------------------
