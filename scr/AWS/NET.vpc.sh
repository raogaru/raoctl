# ############################################################
# VPC VPC FUNCTIONS - AWS Virtual Private Cloud
# ############################################################
# ------------------------------------------------------------
# VPC VPC actions
action_L1="list create delete desc desc_all "
action_L2="associate "
action_L3=" "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_VPCs \
create,vpc_id,Create_VPC \
delete,vpc_id,Delete_VPC \
desc,vpc_id,Describe_VPC \
desc_all,none,Describe_ALL_Route_Tables \
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
f_vpc_list () {
aws ec2 describe-vpcs
#|grep ROUTETABLES
}
# ------------------------------------------------------------
f_vpc_create () {
INPUT 
aws ec2 create-vpc --vpc-id ${input1}
}
# ------------------------------------------------------------
f_vpc_delete () {
INPUT
aws ec2 delete-vpc --vpc-id ${input1}
}
# ------------------------------------------------------------
f_vpc_desc () {
INPUT
aws ec2 describe-vpcs --vpc-ids "${input1}"
}
# ------------------------------------------------------------
f_vpc_desc_all () {
aws ec2 describe-vpcs
}
# ------------------------------------------------------------

