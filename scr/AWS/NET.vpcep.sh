# ############################################################
# VPC VPCEP FUNCTIONS - AWS Virtual Private Cloud Endpoints
# ############################################################
# ------------------------------------------------------------
# VPC VPC actions
action_L1="list create delete desc desc_all "
action_L2="list_services "
action_L3="add_rtb remove_rtb "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_VPC_Endpoints \
create,vpc_id,Create_VPC_Endpoint \
delete,vpc_id,Delete_VPC_Endpoint \
desc,vpc_id,Describe_VPC_Endpoint \
desc_all,none,Describe_ALL_VPC_Endpoints \
list_services,none,List_VPC_Endpoint_Services \
add_rtb,vpcep_id:rtb_id,Add_Routing_Table_to_VPC_Endpoint \
remove_rtb,vpcep_id:rtb_id,Remove_Routing_Table_remove_VPC_Endpoint \
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
f_vpcep_list () {
aws ec2 describe-vpc-endpoints
#|grep ROUTETABLES
}
# ------------------------------------------------------------
f_vpcep_create () {
INPUT 2
aws ec2 create-vpc-endpoint --vpc-id ${input1} --service-name "${input2}"
}
# ------------------------------------------------------------
f_vpcep_delete () {
INPUT
aws ec2 delete-vpc-endpoints --vpc-endpoint-ids ${input1}
}
# ------------------------------------------------------------
f_vpcep_desc () {
INPUT
aws ec2 describe-vpc-endpoints --vpc-endpoint-ids "${input1}"
}
# ------------------------------------------------------------
f_vpcep_desc_all () {
aws ec2 describe-vpc-endpoints
}
# ------------------------------------------------------------
f_vpcep_list_services () {
aws ec2 describe-vpc-endpoint-services
}
# ------------------------------------------------------------
f_vpcep_add_rtb () {
INPUT 2
aws ec2 modify-vpc-endpoint --vpc-endpoint-id ${input1} --add-route-table-ids "${input2}" --reset-policy
}
# ------------------------------------------------------------
f_vpcep_remove_rtb () {
INPUT 2
aws ec2 modify-vpc-endpoint --vpc-endpoint-id ${input1} --remove-route-table-ids "${input2}" --reset-policy
}
# ------------------------------------------------------------
