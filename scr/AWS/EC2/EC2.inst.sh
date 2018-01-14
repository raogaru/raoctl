# ############################################################
# AWS EC2 INST FUNCTIONS - AWS EC2 Instance Management
# ############################################################
# ------------------------------------------------------------
# AWS EC2 inst actions
action_L1="list show start stop "
action_L2=" "
action_L3=" "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_EC2_Instances \
start,none,Start_EC2_Instance \
stop,none,Stop_EC2_Instance \
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
f_inst_list () {
aws ec2 describe-instances
}
# ------------------------------------------------------------
f_inst_show () {
INPUT
aws ec2 describe-instances --instance-ids "${input1}"
}
# ------------------------------------------------------------
f_inst_start () {
INPUT
aws ec2 start-instances --instance-ids "${input1}"
}
# ------------------------------------------------------------
f_inst_stop () {
INPUT
aws ec2 stop-instances --instance-ids "${input1}"
}
# ------------------------------------------------------------
