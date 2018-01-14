# ############################################################
# AWS EFS FS FUNCTIONS - AWS EFS File System Management
# ############################################################
# ------------------------------------------------------------
# AWS EFS FS actions
action_L1="list create delete desc desc_all "
action_L2="create_tag delete_tag desc_tags "
action_L3=" "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_File_System \
create,fs_name,Create_File_System \
delete,fs_name,Delete_File_System \
desc,fs_name,Describe_File_System \
desc_all,none,Describe_ALL_File_Systems \
create_tag,fs_id:key:value,Add_Tag_for_File_System \
delete_tag,fs_id:key:value,Delete_Tag_for_File_System \
desc_tags,fs_id,Descibe_Tags_for_File_System \
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
f_fs_list () {
aws efs describe-file-systems |grep FileSystemId
}
# ------------------------------------------------------------
f_fs_create () {
INPUT
aws efs create-file-system --creation-token "${input1}"
}
# ------------------------------------------------------------
f_fs_delete () {
INPUT
aws efs delete-file-system --file-system-id "${input1}"
}
# ------------------------------------------------------------
f_fs_desc () {
INPUT
aws efs describe-file-systems --file-system-id "${input1}"
}
# ------------------------------------------------------------
f_fs_desc_all () {
aws efs describe-file-systems
}
# ------------------------------------------------------------
f_fs_create_tag () {
INPUT 3
aws efs create-tags --file-system-id "${input1}" --tags "Key=${input2},Value=${input3}"
}
# ------------------------------------------------------------
f_fs_delete_tag () {
INPUT 2
aws efs delete-tags --file-system-id "${input1}" --tag-keys "Key=${input2}"
}
# ------------------------------------------------------------
f_fs_desc_tags () {
INPUT
aws efs describe-tags --file-system-id "${input1}"
}
# ------------------------------------------------------------
