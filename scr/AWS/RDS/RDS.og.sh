# ############################################################
# AWS RDS OG FUNCTIONS - AWS RDS Option Group Management
# ############################################################
# ------------------------------------------------------------
# AWS RDS OG actions
action_L1="list create delete copy "
action_L2="list_opt add_opt del_opt "
action_L3=" "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_Option_Groups \
create,og_name:engine-name:major-engine-version,Create_Option_Group \
delete,og_name,Drop_Option_Group \
copy,source_og_name:target_og_name:target_og_description,Copy_Option_Group \
list_opt,og_name,List_Options_of_a_Option_Group \
add_opt,og_name:option_name,Add_Option_to_a_Option_Group \
del_opt,og_name:option_name,Delete_Option_from_a_Option_Group \
"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions

# ------------------------------------------------------------
[[ -z "${AWS_ACCESS_KEY_ID}" ]] && ERROR "AWS_ACCESS_KEY_ID env variable not defined !"
[[ -z "${AWS_SECRET_ACCESS_KEY}" ]] && ERROR "AWS_SECRET_ACCESS_KEY env variable not defined !"
# ------------------------------------------------------------
f_og_list () {
aws rds describe-option-groups
}
# ------------------------------------------------------------
f_og_create () {
INPUT 4
aws rds create-option-group --option-group-name ${input1} --engine-name ${input2} --major-engine-version ${input3} --option-group-description "${input4}"
}
# ------------------------------------------------------------
f_og_delete () {
INPUT
aws rds delete-option-group --option-group-name ${input1}
}
# ------------------------------------------------------------
f_og_copy () {
INPUT 3
aws rds copy-option-group --source-option-group-identifier "${input1}" --target-option-group-identifier "${input2}" --target-option-group-description "${input3}"
}
# ------------------------------------------------------------
f_og_list_opt () {
INPUT
aws rds describe-option-group-options --engine-name "${input1}"
}
# ------------------------------------------------------------
f_og_add_opt () {
INPUT 2
aws rds add-option-to-option-group --option-group-name "${input1}" --options "OptionName=${input2}" --apply-immediately 
}
# ------------------------------------------------------------
f_og_del_opt () {
INPUT 2
aws rds remove-option-from-option-group --option-group-name "${input1}" --options "${input2}" --apply-immediately 
}
# ------------------------------------------------------------
