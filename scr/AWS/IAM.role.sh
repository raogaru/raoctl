# ############################################################
# AWS RDS ROLE FUNCTIONS - AWS IAM Roles Management
# ############################################################
# ------------------------------------------------------------
# AWS IAM ROLE actions
action_L1="list create delete copy reset modify modify_later desc_defaults show "
action_L2=" "
action_L3=" "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_Parameter_Groups \
create,pg_family:pg_name:pg_desc,Create_Parameter_Group \
delete,pg_name,Delete_Parameter_Group \
copy,source_pg_name:target_pg_name:target_pg_desc,Copy_Parameter_Group \
reset,pg_name,Reset_Parameter_Group_Parameter_Values \
modify,pg_name:parameter_name:parameter_value,Modify_Parameter_Group_Parameters_Immediately \
modify_later,pg_name:parameter_name:parameter_value,Modify_Parameter_Group_Parameters_During_Next_Reboot \
show,pg_name,Show_all_parameter_details \
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
f_role_list () {
aws iam list-roles
}
# ------------------------------------------------------------
f_role_create () {
INPUT
aws iam create-role --role-name "${input1}" --assume-role-policy-document "${input2}"
}
# ------------------------------------------------------------
f_pg_create () {
INPUT 3
aws rds create-db-parameter-group --db-parameter-group-family "${input1}" --db-parameter-group-name "${input2}" --description "${input3}"
}
# ------------------------------------------------------------
f_pg_delete () {
INPUT
aws rds delete-db-parameter-group --db-parameter-group-name "${input1}"
}
# ------------------------------------------------------------
f_pg_copy () {
INPUT 3
aws rds copy-db-parameter-group --source-db-parameter-group-identifier "${input1}" --target-db-parameter-group-identifier "${input2}" --target-db-parameter-group-description "${input3}"
}
# ------------------------------------------------------------
f_pg_reset () {
INPUT
aws rds reset-db-parameter-group --db-parameter-group-name "${input1}" --reset-all-parameters
}
# ------------------------------------------------------------
f_pg_modify () {
INPUT 3
aws rds modify-db-parameter-group --db-parameter-group-name "${input1}" --parameters "ParameterName=${input2}",ParameterValue="${input3},ApplyMethod=immediate"
}
# ------------------------------------------------------------
f_pg_modify_later () {
INPUT 3
aws rds modify-db-parameter-group --db-parameter-group-name "${input1}" --parameters "ParameterName=${input2}",ParameterValue="${input3},ApplyMethod=pending-reboot"
}
# ------------------------------------------------------------
f_pg_desc_defaults () {
INPUT
aws rds describe-engine-default-parameters --db-parameter-group-family  "${input1}"
}
# ------------------------------------------------------------
f_pg_show () {
INPUT
aws rds describe-db-parameters --db-parameter-group-name "${input1}"
}
# ------------------------------------------------------------
