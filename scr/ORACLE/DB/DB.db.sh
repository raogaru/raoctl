# ############################################################
# DB FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# AWR actions
action_L1="create drop shutdown startup up dn create_sby "
action_L2="up_adg up_pdg up_ldg "
action_L3="tns_start tns_stop tns_status "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
create,ORACLE_SID,Create_DB_from_seed \
create_sby,standby_db:primary_db,Create_Standby_DB_from_Primary_DB \
drop,ORACLE_SID,Drop_DB \
shutdown,none,Shutdown_Database_for_current_ORACLE_SID \
startup,none,Startup_Database_for_current_ORACLE_SID \
dn,ORACLE_SID,Shutdown_Database_for_given_ORACLE_SID \
up,ORACLE_SID,Startup_Database_for_given_ORACLE_SID \
up_adg,ORACLE_SID,Startup_Active_Data_Guard_Standby_Database \
up_pdg,ORACLE_SID,Startup_Physical_Data_Guard_Standby_Database \
up_cdg,ORACLE_SID,Startup_Logical_Data_Guard_Standby_Database \
tns_start,none,Listener_Start \
tns_stop,none,Listener_Stop \
tns_status,none,Listener_Status \
"
# ------------------------------------------------------------
# module specific environment variables
SEEDDIR=${rc_DB_SEED_DIR:="/media/sf_eDBA/SeedOracleDB"}
ORADIR=/oracle
ORACRON=/var/spool/cron/oracle
ORATAB=${CFG_DIR}/oratab
TNSORA=${CFG_DIR}/tnsnames.ora
LISORA=${CFG_DIR}/listener.ora
DBHOST=$(hostname)
TNSPORT=1521
SYS_PASSWORD=sys123
# ------------------------------------------------------------
CreateDirectories () {
	ECHO Creating Directories
	EXECME "mkdir -p ${ORADIR}/data/${ORACLE_SID}"
	EXECME "mkdir -p ${ORADIR}/archive/${ORACLE_SID}"
	EXECME "mkdir -p ${ORADIR}/backup/${ORACLE_SID}"
	EXECME "mkdir -p ${ORADIR}/recovery/${ORACLE_SID}"
	EXECME "mkdir -p ${ORADIR}/stage/${ORACLE_SID}/dbcapture"
	EXECME "mkdir -p ${ORADIR}/admin/${ORACLE_SID}"
	EXECME "mkdir -p ${ORADIR}/admin/${ORACLE_SID}/wallet"
	EXECME "mkdir -p ${ORADIR}/admin/${ORACLE_SID}/audit"
	EXECME "mkdir -p ${ORADIR}/admin/${ORACLE_SID}/create"
	EXECME "mkdir -p ${ORADIR}/admin/${ORACLE_SID}/dpdump"
	EXECME "mkdir -p ${ORADIR}/admin/${ORACLE_SID}/pfile"
}
# ------------------------------------------------------------
CopySeedDB () {
	ECHO "Copy Seed Database ..."

	TARGETDIR="${ORADIR}/data/${ORACLE_SID}/"

	EXECME "cp -f ${SEEDDIR}/system01.dbf ${TARGETDIR}"
	EXECME "cp -f ${SEEDDIR}/sysaux01.dbf ${TARGETDIR}"
	EXECME "cp -f ${SEEDDIR}/undotbs01.dbf ${TARGETDIR}"
	EXECME "cp -f ${SEEDDIR}/users01.dbf ${TARGETDIR}"
	EXECME "cp -f ${SEEDDIR}/itusa01.dbf ${TARGETDIR}"

	EXECME "cp -f ${SEEDDIR}/redo01.log ${TARGETDIR}"
	EXECME "cp -f ${SEEDDIR}/redo02.log ${TARGETDIR}"
	EXECME "cp -f ${SEEDDIR}/redo03.log ${TARGETDIR}"

	EXECME "cp -f ${SEEDDIR}/control01.ctl ${TARGETDIR}"
	EXECME "cp -f ${SEEDDIR}/control02.ctl ${TARGETDIR}"
}
# ------------------------------------------------------------
CopyPrimaryDB2Standby () {
export ORACLE_SID=${PRIMARY_DB}
SOURCEDIR="${ORADIR}/data/${PRIMARY_DB}"
TARGETDIR="${ORADIR}/data/${STANDBY_DB}"
v_sby_ctl=/tmp/pri${PRIMARY_DB}_sby${STANDBY_DB}_$$.ctl
EXECME "rm -f $v_sby_ctl"

ECHO "\nAdding Standby Redo Logs"
SQLRUN "alter database add standby logfile group 11 ('${SOURCEDIR}/srdo1.log') SIZE 5M;"
SQLRUN "alter database add standby logfile group 12 ('${SOURCEDIR}/srdo2.log') SIZE 5M;"
SQLRUN "alter database add standby logfile group 13 ('${SOURCEDIR}/srdo3.log') SIZE 5M;"
SQLRUN "alter database add standby logfile group 14 ('${SOURCEDIR}/srdo4.log') SIZE 5M;"

ECHO "\nCreate Standby Controlfile"
SQLRUN "alter database create standby controlfile as '${v_sby_ctl}';"

ECHO "\nCopy Controlfiles"
EXECME "cp -f $v_sby_ctl ${TARGETDIR}/control01.ctl"
EXECME "cp -f $v_sby_ctl ${TARGETDIR}/control02.ctl"

ECHO "\nCopy Datafiles"
RMANLINE "
copy datafile '${SOURCEDIR}/system01.dbf' to '${TARGETDIR}/system01.dbf';
copy datafile '${SOURCEDIR}/sysaux01.dbf' to '${TARGETDIR}/sysaux01.dbf';
copy datafile '${SOURCEDIR}/undotbs01.dbf' to '${TARGETDIR}/undotbs01.dbf';
copy datafile '${SOURCEDIR}/users01.dbf' to '${TARGETDIR}/users01.dbf';
copy datafile '${SOURCEDIR}/itusa01.dbf' to '${TARGETDIR}/itusa01.dbf';
"

}
# ------------------------------------------------------------
PrepareInitOraFile () {
if [ "$rc_STANDBY" != "YES" ];then
	EXECME "cp -f ${SEEDDIR}/initSEED.ora ${ORACLE_HOME}/dbs/"
	cat ${ORACLE_HOME}/dbs/initSEED.ora |sed -e "s/SEED/${ORACLE_SID}/g" > ${ORACLE_HOME}/dbs/init${ORACLE_SID}.ora
else
	EXECME "cp -f ${SEEDDIR}/initDGSEED.ora ${ORACLE_HOME}/dbs/initSEED.ora"
	cat ${ORACLE_HOME}/dbs/initSEED.ora |sed -e "s/PRIMARY_SEED/${input2}/g" | sed -e "s/STANDBY_SEED/${ORACLE_SID}/g" > ${ORACLE_HOME}/dbs/init${ORACLE_SID}.ora
fi
}
# ------------------------------------------------------------
PreparePasswdFile () {
${ORACLE_HOME}/bin/orapwd file=${ORACLE_HOME}/dbs/orapw${ORACLE_SID} password=${SYS_PASSWORD} entries=5 force=y ignorecase=y
}
# ------------------------------------------------------------
CallCreateControlfileSQL () {
${ORACLE_HOME}/bin/sqlplus -s /nolog <<-EOFsql
connect / as sysdba
start ${SQL_DIR}/CreateDatabaseFromSeed.sql ${ORACLE_SID} /${ORADIR}/data
EOFsql
}
# ------------------------------------------------------------
AddTnsnamesEntry () {
grep "^${ORACLE_SID}.WORLD=" ${TNSORA} > /dev/null 2>&1
if [ $? -ne 0 ]; then 
	ECHO "Adding entry to ${TNSORA}"
	echo "${ORACLE_SID}.WORLD=(DESCRIPTION_LIST=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(COMMUNITY=TCPIP.WORLD)(PROTOCOL=TCP)(HOST=${DBHOST})(PORT=${TNSPORT})))(CONNECT_DATA=(SID=${ORACLE_SID})(GLOBAL_NAME=${ORACLE_SID}.WORLD))))" >> ${TNSORA}
else
	ECHO "${TNSORA} entry already exists"
fi
}
# ------------------------------------------------------------
AddOratabEntry () {
grep "^${ORACLE_SID}:" ${ORATAB} > /dev/null 2>&1
if [ $? -ne 0 ] ; then
	ECHO "Adding entry to ${ORATAB}"
	echo "${ORACLE_SID}:${ORACLE_HOME}:Y" >> ${ORATAB}
else
	ECHO "${ORATAB} entry already exists"
fi
}
# ------------------------------------------------------------
StartStandby () {
SQLRUN "startup"
SQLRUN "@mrp_adg"
}
# ------------------------------------------------------------
AddOracleCronEntry () {
ECHO "Add crontab entries for ${ORACLE_SID}"
echo "
#_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
#BEGIN_ORACLE_CRON_${ORACLE_SID}
#0,10,20,30,40,50 * * * * /home/oracle/bin/ora_clean_files.sh ${ORACLE_SID} archive
0,10,20,30,40,50 * * * * /home/oracle/bin/ora_clean_files.sh ${ORACLE_SID} trace
0,10,20,30,40,50 * * * * /home/oracle/bin/ora_clean_files.sh ${ORACLE_SID} logs
0,10,20,30,40,50 * * * * /home/oracle/bin/ora_clean_files.sh ${ORACLE_SID} audit
0,10,20,30,40,50 * * * * /home/oracle/bin/ora_clean_files.sh ${ORACLE_SID} coredump
#END_ORACLE_CRON_${ORACLE_SID}
#_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
"
}
# ------------------------------------------------------------
DropDatabase () {
SQLNEWF
SQLLINE "shutdown abort;"
SQLLINE "startup force mount;"
SQLLINE "alter system enable restricted session;"
SQLLINE "drop database;"
SQLEXEC
}
# ------------------------------------------------------------
CleanFilesAndDirs () {
	typeset -l oracle_sid=${ORACLE_SID}
	ECHO Cleanup Directories
	EXECME "rm -rf ${ORADIR}/data/${ORACLE_SID}"
	EXECME "rm -rf ${ORADIR}/archive/${ORACLE_SID}"
	EXECME "rm -rf ${ORADIR}/backup/${ORACLE_SID}"
	EXECME "rm -rf ${ORADIR}/recovery/${ORACLE_SID}"
	EXECME "rm -rf ${ORADIR}/stage/${ORACLE_SID}"
	EXECME "rm -rf ${ORADIR}/admin/${ORACLE_SID}"
	EXECME "rm -rf ${ORADIR}/diag/rdbms/${oracle_sid}"
	EXECME "rm -rf ${ORACLE_HOME}/dbs/peshm_${ORACLE_SID}_*"
	EXECME "rm -f ${ORACLE_HOME}/dbs/init${ORACLE_SID}.ora"
	EXECME "rm -f ${ORACLE_HOME}/dbs/init${ORACLE_SID}.ora.*"
	EXECME "rm -f ${ORACLE_HOME}/dbs/spfile${ORACLE_SID}.ora"
	EXECME "rm -f ${ORACLE_HOME}/dbs/spfile${ORACLE_SID}.ora.*"
	EXECME "rm -f ${ORACLE_HOME}/dbs/orapw${ORACLE_SID}"
	EXECME "rm -f ${ORACLE_HOME}/dbs/snapcf_${ORACLE_SID}.f"
	EXECME "rm -f ${ORACLE_HOME}/dbs/hc_${ORACLE_SID}.dat"
	EXECME "rm -f ${ORACLE_HOME}/dbs/lk${ORACLE_SID}"
	EXECME "rm -f ${ORACLE_HOME}/dbs/peshm_${ORACLE_SID}_*"
}

# ------------------------------------------------------------
RemoveTnsnamesEntry () {
grep "^${ORACLE_SID}.WORLD=" ${TNSORA} > /dev/null 2>&1
if [ $? -eq 0 ]; then 
	ECHO "Removing tnsnames.ora entry "
	cp -f ${TNSORA} ${TNSORA}.bak
	grep -v "^${ORACLE_SID}.WORLD=" ${TNSORA} > ${TMP}/tnsnames.tmp
	cp ${TMP}/tnsnames.tmp ${TNSORA}
else
	ECHO "tnsnames.ora entry already removed"
fi
}

# ------------------------------------------------------------
RemoveOratabEntry () {
grep "^${ORACLE_SID}:" ${ORATAB} > /dev/null 2>&1
if [ $? -eq 0 ] ; then
	ECHO "Removing oratab entry"
	cp -f ${ORATAB} ${ORATAB}.bak
	grep -v "^${ORACLE_SID}:" ${ORATAB} > ${TMP}/oratab.tmp
	cp ${TMP}/oratab.tmp ${ORATAB}
else
	ECHO "oratab entry already removed"
fi
}
# ------------------------------------------------------------
f_db_create () {
INPUT
export ORACLE_SID=${input1}
CreateDirectories
PrepareInitOraFile
PreparePasswdFile
CopySeedDB
CallCreateControlfileSQL
AddTnsnamesEntry
AddOratabEntry
#AddOracleCronEntry 
ECHO Done
}
# ------------------------------------------------------------
f_db_create_sby () {
INPUT 2
rc_STANDBY=YES
export STANDBY_DB=${input1}
export PRIMARY_DB=${input2}

[[ $(ps -ef|grep ora_pmon_${PRIMARY_DB} |grep -v grep |wc -l) -eq 0 ]] && ERROR "Primary DB ${PRIMARY_DB} is not up. Cannot proceed !"

[[ $(ps -ef|grep ora_pmon_${STANDBY_DB} |grep -v grep |wc -l) -ne 0 ]] && ERROR "Standby DB ${STANDBY_DB} is up. Cannot proceed !"

export ORACLE_SID=${STANDBY_DB}
CreateDirectories
PrepareInitOraFile
PreparePasswdFile
export ORACLE_SID=${PRIMARY_DB}
CopyPrimaryDB2Standby

#SQLRUN "alter tablespace TEMP add tempfile '${SOURCEDIR}/temp01.dbf' to '${TARGETDIR}/temp01.dbf';"

export ORACLE_SID=${STANDBY_DB}
AddTnsnamesEntry
AddOratabEntry
StartStandby
#AddOracleCronEntry 
ECHO Done
}
# ------------------------------------------------------------
f_db_drop () {
INPUT
export ORACLE_SID=${input1}

x=$(ps -ef|grep ora_pmon_${ORACLE_SID}|grep -v grep|awk '{print $NF}')
if [ "$x" = "ora_pmon_${ORACLE_SID}" ]; then
	ERROR "Database instance $ORACLE_SID is up. Cannot drop database"
fi

DropDatabase
CleanFilesAndDirs
RemoveTnsnamesEntry
RemoveOratabEntry
ECHO Done
}
# ------------------------------------------------------------
f_db_shutdown () {
SQLRUN "shutdown immediate"
}
# ------------------------------------------------------------
f_db_startup () {
SQLRUN "startup"
}
# ------------------------------------------------------------
f_db_dn () {
INPUT
export ORACLE_SID=${input1}
SQLRUN "shutdown immediate"
}
# ------------------------------------------------------------
f_db_mrp_pdg () {
SQLRUN "alter database recover managed standby database disconnect from session;"
}
# ------------------------------------------------------------
f_db_mrp_adg () {
SQLRUN "alter database recover managed standby database using current logfile disconnect from session;"
}
# ------------------------------------------------------------
f_db_mrp_cancel () {
SQLRUN "alter database recover managed standby database cancel;"
}
# ------------------------------------------------------------
f_db_up () {
INPUT
export ORACLE_SID=${input1}
SQLRUN "startup"
}
# ------------------------------------------------------------
f_db_up_adg () {
INPUT
export ORACLE_SID=${input1}
SQLRUN "startup"
f_db_mrp_adg 
}
# ------------------------------------------------------------
f_db_up_pdg () {
INPUT
export ORACLE_SID=${input1}
SQLRUN "startup"
f_db_mrp_pdg
}
# ------------------------------------------------------------
f_db_up_ldg () {
INPUT
export ORACLE_SID=${input1}
SQLRUN "startup"
SQLRUN "alter database start managed logical standby database disconnect from session;"
}
# ------------------------------------------------------------
f_db_tns_start () {
export ORACLE_HOME=$ORACLE_HOME_LISTNER
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
ORACLE_HOME_LISTNER=$(cat ${ORATAB} | grep "^\*:" | awk -F: '{print $2}')
EXECME "$ORACLE_HOME_LISTNER/bin/lsnrctl start"
}
# ------------------------------------------------------------
f_db_tns_stop () {
export ORACLE_HOME=$ORACLE_HOME_LISTNER
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
ORACLE_HOME_LISTNER=$(cat ${ORATAB} | grep "^\*:" | awk -F: '{print $2}')
EXECME "$ORACLE_HOME_LISTNER/bin/lsnrctl stop"
}
# ------------------------------------------------------------
f_db_tns_status () {
export ORACLE_HOME=$ORACLE_HOME_LISTNER
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
ORACLE_HOME_LISTNER=$(cat ${ORATAB} | grep "^\*:" | awk -F: '{print $2}')
EXECME "$ORACLE_HOME_LISTNER/bin/lsnrctl status"
}
# ------------------------------------------------------------
