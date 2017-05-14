# ############################################################
# AWS RDS SG FUNCTIONS - AWS RDS DB Security Group Management
# ############################################################
# ------------------------------------------------------------
# AWS RDS SG actions
action_L1="list create delete modify "
action_L2="authorize_ingress revoke_ingress "
action_L3=" "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_DB_Security_Groups \
crete,sg_name,Create_DB_Security_Group \
delete,none,Create_DB_Security_Groups \
yy,none,yy_description \
zz,none,zz_description \
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
aws rds describe-db-security-groups
}
# ------------------------------------------------------------
f_sg_create () {
INPUT 2
aws rds create-db-security-group --db-security-group-name ${input1} --db-security-group-description "${input2}"
}
# ------------------------------------------------------------
f_sg_delete () {
INPUT
aws rds delete-db-security-group --db-security-group-name ${input1}
}
# ------------------------------------------------------------
f_sg_authorize_ingress () {
INPUT
aws rds authorize-db-security-group-ingress --db-security-group-name ${input1}
}
# ------------------------------------------------------------
f_sg_revoke_ingress () {
INPUT
aws rds revoke-db-security-group-ingress --db-security-group-name ${input1}
}
# ------------------------------------------------------------
