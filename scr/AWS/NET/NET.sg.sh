# ############################################################
# EC2 SG FUNCTIONS - AWS EC2 Security Groups
# ############################################################
# ------------------------------------------------------------
# EC2 SG actions
action_L1="list create delete desc desc_all "
action_L2="desc_ref desc_stale "
action_L3=" "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_Security_Groups \
create,sg_name:sg_description:vpc_id,Create_Security_Group_in_a_VPC \
delete,sg_name,Delete_Security_Group_from_a_VPC \
desc,sg_name,Describe_Security_Group_by_Name \
desc_all,none,Describe_ALL_Security_Groups \
desc_ref,sg_name,Describe_Security_Group_which_is_refers \
desc_stale,none,Describe_Security_Groups_which_are_no_longer_referenced_in_VPC_peering \
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
f_sg_list () {
aws ec2 describe-security-groups |grep SECURITYGROUPS
}
# ------------------------------------------------------------
f_sg_create () {
INPUT 3
aws ec2 create-security-group --group-name ${input1} --description "${input2}" --vpc-id ${input3}
}
# ------------------------------------------------------------
f_sg_delete () {
INPUT
aws ec2 delete-security-group --group-name ${input1}
}
# ------------------------------------------------------------
f_sg_desc () {
INPUT
aws ec2 describe-security-groups --group-names "${input1}"
}
# ------------------------------------------------------------
f_sg_desc_all () {
aws ec2 describe-security-groups 
}
# ------------------------------------------------------------
f_sg_desc_ref () {
INPUT
aws ec2 describe-security-group-references --group-id ${input1}
}
# ------------------------------------------------------------
f_sg_desc_stale () {
INPUT
aws ec2 describe-stale-security-groups --vpc-id ${input1}
}
# ------------------------------------------------------------

