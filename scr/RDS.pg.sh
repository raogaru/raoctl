# ############################################################
# AWS RDS PG FUNCTIONS - AWS RDS Parameter Group Management
# ############################################################
# ------------------------------------------------------------
# AWS RDS PG actions
action_L1="list create delete copy modify reset desc_defaults "
action_L2="show "
action_L3=" "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
xx,none,xx_description \
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
f_pg_list () {
aws rds describe-db-parameter-groups
}
# ------------------------------------------------------------
f_pg_show () {
INPUT
aws rds describe-db-parameters --db-parameter-group-name "${input1}"
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
f_pg_modify () {
INPUT 3
#aws rds modify-db-parameter-group --db-parameter-group-name "${input1}" --parameters "ParameterName=${input2}",ParameterValue="${input3},ApplyMethod=immediate"
aws rds modify-db-parameter-group --db-parameter-group-name "${input1}" --parameters "ParameterName=${input2}",ParameterValue="${input3},ApplyMethod=pending-reboot"
}
# ------------------------------------------------------------
f_pg_reset () {
INPUT
aws rds reset-db-parameter-group --db-parameter-group-name "${input1}" --reset-all-parameters
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


