# ############################################################
# OEM TEMPLATE FUNCTIONS - Oracle Enterprise Manager Templates Management
# ############################################################
# ------------------------------------------------------------
# OEM TEMPLATE actions
action_L1="list_all list_for_target_type export export_archive import apply "
action_L2=" "
action_L3=" "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_OEM_Templates \
list_for_target,target_type,List_OEM_Templates_for_a_Target_Type \
export,template_name:target_type,Export_OEM_Templates \
export_archive,template_name:target_type,Export_OEM_Templates_in_ZIP_format \
import,XML_or_ZIP_file_name,Import_OEM_Templates_from_XML_or_ZIP_file \
apply,template_name:targets_list,Apply_OEM_Template_to_given_list_of_Targets \
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
${EMCLI} apply_template -name="template1"  
-targets="mydb1:oracle_database" 
  -input_file= "FILE1:/usr/template/apply_udm_credentials.txt"
}
# ------------------------------------------------------------
