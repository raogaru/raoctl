# ############################################################
# RAC VD FUNCTIONS - RAC Voting Disk Management
# ############################################################
# ------------------------------------------------------------
# RAC votedisk  actions
action_L1="list add delete backup  "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_VoteDisks \
add,votedisk_path,Add_VoteDisk \
delete,votedisk_path,Delete_VoteDisk \
backuo,current_votedisk_path:backup_votedisk_path,Backup_VoteDisk_using_dd \
"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions

# ------------------------------------------------------------
f_votedisk_list () {
crsctl query css votedisk
}
# ------------------------------------------------------------
f_votedisk_add () {
INPUT
crsctl add css votedisk ${input1}
}
# ------------------------------------------------------------
f_votedisk_delete () {
INPUT
crsctl delee css votedisk ${input1}
}
# ------------------------------------------------------------
f_votedisk_backup () {
INPUT 2
dd if=${input1} of=${input2} bs=4k
}
# ------------------------------------------------------------
