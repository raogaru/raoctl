# ############################################################
# EC2 RTB FUNCTIONS - AWS EC2 Routes and Route Tables
# ############################################################
# ------------------------------------------------------------
# EC2 RTB actions
action_L1="list create delete desc desc_all "
action_L2="associate "
action_L3=" "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_Route_Tables \
create,vpc_id,Create_Route_Table \
delete,rtb_id,Delete_Route_Table \
desc,rtb_id,Describe_Route_Table \
desc_all,none,Describe_ALL_Route_Tables \
associate,rtb_id:subnet_id:Associate_subnet_with_Route_Table \
disassociate,rtb_id:subnet_id:Disassociate_subnet_with_Route_Table \
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
f_rtb_list () {
aws ec2 describe-route-tables|grep ROUTETABLES
}
# ------------------------------------------------------------
f_rtb_create () {
INPUT 
aws ec2 create-route-table --vpc-id ${input1}
}
# ------------------------------------------------------------
f_rtb_delete () {
INPUT
aws ec2 delete-route-table --route-table-id ${input1}
}
# ------------------------------------------------------------
f_rtb_desc () {
INPUT
aws ec2 describe-route-tables --route-table-ids "${input1}"
}
# ------------------------------------------------------------
f_rtb_desc_all () {
aws ec2 describe-route-tables 
}
# ------------------------------------------------------------
f_rtb_associate () {
INPUT 2
aws ec2 associate-route-table --route-table-id ${input1} --subnet-id ${input2}
}
# ------------------------------------------------------------
f_rtb_disassociate () {
INPUT
aws ec2 disassociate-route-table --association-id ${input1}
}
# ------------------------------------------------------------

