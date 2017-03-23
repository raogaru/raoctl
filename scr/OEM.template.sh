# ############################################################
# OEM TEMPLATE FUNCTIONS - Oracle Enterprise Manager Templates Management
# ############################################################
# ------------------------------------------------------------
# OEM TEMPLATE actions
action_L1="list_all list_for_target_type export export_archive import "
action_L2=" "
action_L3="apply apply_udm apply_replace_metrics apply_copy_flags "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_OEM_Templates \
list_for_target,target_type,List_OEM_Templates_for_a_Target_Type \
export,template_name:target_type,Export_OEM_Templates \
export_archive,template_name:target_type,Export_OEM_Templates_in_ZIP_format \
import,XML_or_ZIP_file_name,Import_OEM_Templates_from_XML_or_ZIP_file \
apply,template_name:target_name:target_type,Apply_OEM_Template_to_given_list_of_Targets \
apply_udm,template_name:target_name:target_type:file_with_UDM_credentials,Apply_OEM_Template_to_given_list_of_Targets_with_User_Defined_Metrics_Credentials \
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
f_template_list () {
${EMCLI} list_templates
}
# ------------------------------------------------------------
f_template_list_for_target () {
INPUT
${EMCLI} list_templates -target_type=“${input1}”
}
# ------------------------------------------------------------
f_template_export () {
INPUT 2
${EMCLI} export_template -name="${input1}" -target_type="${input2}"   -output_file=“${RPT_DIR}/${input1}.xml”
}
# ------------------------------------------------------------
f_template_export_archive() {
INPUT 2
${EMCLI} export_template -name="${input1}" -target_type="${input2}"   -output_file=“${RPT_DIR}/${input1}.xml” -archive
}
# ------------------------------------------------------------
f_template_import () {
INPUT
${EMCLI} import_template -files="${input1}"
}
# ------------------------------------------------------------
f_template_apply () {
INPUT
${EMCLI} apply_template -name="${input1}"  -targets="${input2}:${input3}" 
  -input_file= "FILE1:/usr/template/apply_udm_credentials.txt"
}
# ------------------------------------------------------------
f_template_apply_udm () {
INPUT 4
${EMCLI} apply_template -name="${input1}"  -targets="${input2}:${input3}" -input_file= "${input4}"
}
# ------------------------------------------------------------
f_template_apply_replace_metrics () {
INPUT 4
${EMCLI} apply_template -name="${input1}"  -targets="${input2}:${input3}" -replace_metrics="${input4}"
}
# ------------------------------------------------------------
f_template_apply_copy_flags () {
INPUT 4
${EMCLI} apply_template -name="${input1}"  -targets="${input2}:${input3}" -copy_flags="${input4}"
}
# ------------------------------------------------------------
