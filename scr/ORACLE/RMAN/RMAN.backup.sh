# ############################################################
# RMAN BACKUP FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# RMAN BACKUP actions
action_L1="db ts df cf al  "
action_L2="cold_db "
action_L3="xxx "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
db,None,Backup_Database
ts,None,Backup_Tablespace
df,None,Backup_Datafile
cf,None,Backup_ControlFile
al,None,Backup_AlertLogs
"
# ------------------------------------------------------------
# local variables
v_debug=0
RMAN_TIME=$(date '+%Y%m%d%H%M%S')
RMAN_DIR=/oracle/backup/rman/${ORACLE_SID}/${RMAN_TIME}
RMAN_CMD=${RMAN_DIR}/${v_class}_${v_module}_${v_action}_${RMAN_TIME}.cmd
RMAN_LOG=${RMAN_DIR}/${v_class}_${v_module}_${v_action}_${RMAN_TIME}.log
mkdir -p ${RMAN_DIR}
# ------------------------------------------------------------
RMAN_STR_LOG="log=${TMPLOG}"
# ------------------------------------------------------------
f_backup_db () { 
RMANLINE "BACKUP DATABASE;"
}
# ------------------------------------------------------------
f_backup_ts () { 
INPUT
RMANLINE "BACKUP TABLESPACE ${input};"
}
# ------------------------------------------------------------
f_backup_df () { 
INPUT
RMANLINE "BACKUP DATAFILE ${1};"
}
# ------------------------------------------------------------
f_backup_cf () { 
RMANLINE "BACKUP CURRENT CONTROLFILE;"
}
# ------------------------------------------------------------
f_backup_al () { 
RMANLINE "BACKUP ARCHIVELOG ALL;"
}
# ------------------------------------------------------------
f_backup_cold_db () {
echo "
shutdown immediate;
startup mount;
run {
configure device type disk parallelism 4;
configure controlfile autobackup on;
configure controlfile autobackup format for device type disk to '${RMAN_DIR}/rman_cf_%F';
configure snapshot controlfile name to '${RMAN_DIR}/rman_snapcf_${RMAN_TIME}';
backup 
as compressed backupset 
incremental level 0 
check logical database
tag 'RMAN_COLD_BACKUP_${RMAN_TIME}'
filesperset 1
diskratio 0
format '${RMAN_DIR}/rman_df_%s_%p_%t';
}
alter database open;
quit;" > ${RMAN_CMD}

RMANRUN ${RMAN_CMD} ${RMAN_LOG}
}
# ------------------------------------------------------------
