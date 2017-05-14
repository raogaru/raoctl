# ############################################################
# AWS RDS SNG FUNCTIONS - AWS RDS DB Subnet Group Management
# ############################################################
# ------------------------------------------------------------
# AWS RDS SNG actions
action_L1="list create delete modify "
action_L2=" "
action_L3=" "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_DB_Subnet_Groups \
create,none,Create_DB_Subnet_Group \
delete,sng_name,Delete_DB_Subnet_Group \
modify,sng_name:subnet_ids,Modify_DB_Subnet_Group_Subnet_Ids \
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
f_sng_list () {
aws rds describe-db-subnet-groups
}
# ------------------------------------------------------------
f_sng_create () {
INPUT 3
aws rds create-db-subnet-group --db-subnet-group-name ${input1} --db-subnet-group-description "${input2}" --subnet-ids "${input3}"
}
# ------------------------------------------------------------
f_sng_delete () {
INPUT
aws rds delete-db-subnet-group --db-subnet-group-name ${input1}
}
# ------------------------------------------------------------
f_sng_modify () {
INPUT 2
aws rds create-db-subnet-group --db-subnet-group-name ${input1} --subnet-ids "${input2}"
}
# ------------------------------------------------------------
