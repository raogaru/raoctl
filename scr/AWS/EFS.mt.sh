# ############################################################
# AWS EFS MT FUNCTIONS - AWS EFS Mount Targets Management
# ############################################################
# ------------------------------------------------------------
# AWS EFS FS actions
action_L1="list create delete desc "
action_L2="modify_sg "
action_L3=" "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,fs_id,List_Mount_Targets \
create,fs_id:subnet_id,Create_Mount_Target \
delete,mt_id,Delete_Mount_Target \
desc,fs_id,Describe_Mount_Target \
modify_sg,mt_id:sg_list,Modify_Mount_Target_Security_Groups \
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
f_mt_list () {
INPUT
aws efs describe-mount-targets --file-system-id ${input1}
}
# ------------------------------------------------------------
f_mt_create () {
INPUT 2
aws efs create-mount-target --file-system-id "${input1}" --subnet-id "${input2}"
}
# ------------------------------------------------------------
f_mt_delete () {
INPUT
aws efs delete-mount-target --mount-target-id "${input1}"
}
# ------------------------------------------------------------
f_mt_desc () {
INPUT
aws efs describe-mount-targets --file-system-id "${input1}"
}
# ------------------------------------------------------------
f_mt_modify_sg () {
INPUT 2
aws efs modify-mount-target-security-groups --mount-target-id "${input1}" "${input2}"
}
# ------------------------------------------------------------
