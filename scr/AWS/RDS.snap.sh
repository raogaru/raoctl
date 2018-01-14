# ############################################################
# AWS RDS SNAP FUNCTIONS - AWS RDS Snapshots Management
# ############################################################
# ------------------------------------------------------------
# AWS RDS SNAP actions
action_L1="list_all list create delete copy modify show verion restore"
action_L2=" "
action_L3=" "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list_all,none,List_All_DB_Snapshots \
list,db_inst_name,List_DB_Snapshots_for_a_DB_instance \
create,db_inst_name,Create_DB_Snapshot_for_a_DB_instance \
delete,snapshot_name,Delete_DB_Snapshot \
copy,source_snapshot_name:targt_snapshot_name,Copy_DB_Snapshot \
modify,snapshot_name:attribute_name:attribute_value,Modify_DB_Snapshot_Attribute \
show,snapshot_name,Describe_DB_Snapshot_Attributes \
version,snapshot_name,Update_DB_Engin_Version_of_a_DB_Snapshot \
restore,snapshot_name:target_inst_name,Restore_DB_Snapshot_as_DB_Instance \
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
f_snap_list_all () {
aws rds describe-db-snapshots
}
# ------------------------------------------------------------
f_snap_list () {
INPUT
aws rds describe-db-snapshots --db-instance-identifier ${input1}
}
# ------------------------------------------------------------
f_snap_create () {
INPUT 2
aws rds create-db-snapshot --db-instance-identifier ${input1} --db-snapshot-identifier ${input2}
}
# ------------------------------------------------------------
f_snap_delete () {
INPUT
aws rds delete-db-snapshot --db-snapshot-identifier ${input1}
}
# ------------------------------------------------------------
f_snap_copy () {
INPUT 2
aws rds  copy-db-snapshot --source-db-snapshot-identifier ${input1} --target-db-snapshot-identifier ${input2}
}
# ------------------------------------------------------------
f_snap_modify () {
INPUT 2
aws rds modify-db-snapshot-attribute --db-snapshot-identifier ${input1} --attribute-name "${input2}"
}
# ------------------------------------------------------------
f_snap_show () {
INPUT 
aws rds describe-db-snapshot-attributes --db-snapshot-identifier ${input1}
}
# ------------------------------------------------------------
f_snap_verion () {
INPUT 2
aws rds modify-db-snapshot --db-snapshot-identifier ${input1} --engine-version ${input2}
}
# ------------------------------------------------------------
f_snap_restore () {
INPUT 2
aws rds restore-db-cluster-from-snapshot --db-snapshot-identifier ${input1} --db-instance-identifier ${input2}
}
# ------------------------------------------------------------
