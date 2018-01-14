# ############################################################
# AWS RDS DB FUNCTIONS - AWS RDS DB Instances Management
# ############################################################
# ------------------------------------------------------------
# AWS RDS DB actions
action_L1="list create_ora delete "
action_L2="modify "
action_L3="stop start reboot "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_DB_Instances \
crete,sg_name,Create_DB_Instance \
delete,none,Create_DB_Instance \
stop,db_inst_name,Stop_DB_Instance \
start,db_inst_name,Start_DB_Instance \
reboot,db_inst_name,Reboot_DB_Instance \
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
f_db_list () {
aws rds describe-db-instances |grep "DBInstanceIdentifier" | cut -f2 -d":"
}
# ------------------------------------------------------------
f_db_create_ora () {
INPUT 2
aws rds create-db-instance --db-instance-identifier ${input1} \
--allocated-storage 20 --db-instance-class db.m1.small --engine mysql \
--master-username "master" --master-user-password "master123"

aws rds create-db-instance
--db-instance-identifier "${input1}"
--engine "oracle-se2"
--engine-version "12.1.0.2.v9"
--license-model "license-included"
--db-instance-class "db.t2.micro"
--no-multi-az
--storage-type "gp2"
--allocated-storage "20G"
--master-username "master"
--master-user-password "master123"
--vpc-security-group-ids "vpc-devl"
--db-subnet-group-name "sng-devl"
--db-name "ODB1"
--db-security-groups "sng-devl"
--db-parameter-group-name "oracle-se2-12102"
--backup-retention-period "0"
--port 1521
--no-auto-minor-version-upgrade
--option-group-name 
--publicly-accessible | --no-publicly-accessible]
[--storage-encrypted | --no-storage-encrypted]
[--kms-key-id <value>]
[--domain <value>]
[--copy-tags-to-snapshot | --no-copy-tags-to-snapshot]
[--monitoring-interval <value>]
[--monitoring-role-arn <value>]
[--domain-iam-role-name <value>]
[--promotion-tier <value>]
[--timezone <value>]
[--enable-iam-database-authentication | --no-enable-iam-database-authentication]
[--enable-performance-insights | --no-enable-performance-insights]
[--performance-insights-kms-key-id <value>]
[--cli-input-json <value>]
[--generate-cli-skeleton <value>]

}
# ------------------------------------------------------------
f_db_delete () {
INPUT
aws rds delete-db-instance --db-instance-identifier ${input1} --skip-final-snapshot 
}
# ------------------------------------------------------------
f_db_stop () {
INPUT
aws rds stop-db-instance --db-instance-identifier ${input1}
}
# ------------------------------------------------------------
f_db_start () {
INPUT
aws rds start-db-instance --db-instance-identifier ${input1}
}
# ------------------------------------------------------------
f_db_reboot () {
INPUT
aws rds reboot-db-instance --db-instance-identifier ${input1}
}
# ------------------------------------------------------------
