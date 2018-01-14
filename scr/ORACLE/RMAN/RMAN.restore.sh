# ############################################################
# RMAN RESTORE FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# RMAN RESTORE actions
action_L1="db ts df cf al  "
action_L2="cold_db soil "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
db,backup_dir,Restore_Database \
ts,backup_dir,Restore_Tablespace \
df,backup_dir,Restore_DataFile \
al,backup_dir,Restore_AlertLog \
cold_db,backup_dir,RMAN_restore_from_cold_db \
"
# ------------------------------------------------------------
# local variables
v_debug=0
RMAN_TIME=$(date '+%Y%m%d%H%M%S')
RMAN_DIR=/oracle/backup/rman/${ORACLE_SID}/${RMAN_TIME}
RMAN_LOG=${RMAN_DIR}/${v_class}_${v_module}_${v_action}_${RMAN_TIME}.log
mkdir -p ${RMAN_DIR}
# ------------------------------------------------------------
RMAN_STR_LOG="log=${TMPLOG}"
# ------------------------------------------------------------
f_restore_cold_db () {
INPUT
SQLRUN "startup nomount pfile=${ORACLE_HOME}/dbs/init${ORACLE_SID}.ora;"
rman  auxiliary / <<-EOFrman >${RMAN_LOG}
run
{
allocate auxiliary channel ch01 device type disk;
allocate auxiliary channel ch02 device type disk;
allocate auxiliary channel ch03 device type disk;
allocate auxiliary channel ch04 device type disk;

duplicate target database to '${ORACLE_SID}'
pfile=${ORACLE_HOME}/dbs/init${ORACLE_SID}.ora
backup location '${input1}'
nofilenamecheck noredo;
}
quit;
EOFrman
}
# ------------------------------------------------------------
f_restore_soil () { # temporary action. remove this later. 11/17/2015
INPUT
SQLRUN "startup nomount pfile=${ORACLE_HOME}/dbs/init${ORACLE_SID}.ora;"
rman debug auxiliary / <<-EOFrman >${RMAN_LOG}
run
{
allocate auxiliary channel ch01 device type disk;

duplicate target database to '${ORACLE_SID}'
pfile=${ORACLE_HOME}/dbs/init${ORACLE_SID}.ora
backup location '${input1}'
nofilenamecheck noredo;
}
quit;
EOFrman
}
# ------------------------------------------------------------
