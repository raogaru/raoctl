# ############################################################
# CDB FUNCTIONS - MULTITENANT CONTAINER DATABASE (12c)
# ############################################################
# ------------------------------------------------------------
# CDB actions
action_L1="create drop shutdown startup up dn "
action_L2="tns_start tns_stop tns_status "
action_L3="x "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE data
usage_L=" \
create,ORACLE_SID,Create_CDB_from_CDB_seed \
drop,ORACLE_SID,Drop_CDB  \
shutdown,ORACLE_SID,Shutdown_CDB  \
startup,ORACLE_SID,Startup_CDB  \
tns_start,ORACLE_SID,Start_TNS \
tns_stop,ORACLE_SID,Stop_TNS  \
tns_status,ORACLE_SID,Status_of_TNS
"
# ------------------------------------------------------------
SEEDDIR=/media/sf_eDBA/SeedOracleCDB
ORADIR=/oracle
ORACRON=/var/spool/cron/oracle
ORATAB=${CFG_DIR}/oratab
TNSORA=${CFG_DIR}/tnsnames.ora
DBHOST=$(hostname)
TNSPORT=1521
# ------------------------------------------------------------
CreateDirectories () {
	ECHO Creating Directories
	EXECME "mkdir -p ${ORADIR}/data/${ORACLE_SID}"
	EXECME "mkdir -p ${ORADIR}/data/${ORACLE_SID}/pdbseed"
	EXECME "mkdir -p ${ORADIR}/archive/${ORACLE_SID}"
	EXECME "mkdir -p ${ORADIR}/backup/${ORACLE_SID}"
	EXECME "mkdir -p ${ORADIR}/recovery/${ORACLE_SID}"
	EXECME "mkdir -p ${ORADIR}/stage/${ORACLE_SID}/rat"
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
	#EXECME "cp -f ${SEEDDIR}/itusa01.dbf ${TARGETDIR}"

	EXECME "cp -f ${SEEDDIR}/pdbseed_system01.dbf ${TARGETDIR}/pdbseed/system01.dbf"
	EXECME "cp -f ${SEEDDIR}/pdbseed_sysaux01.dbf ${TARGETDIR}/pdbseed/sysaux01.dbf"
	EXECME "cp -f ${SEEDDIR}/pdbseed_temp01.dbf ${TARGETDIR}/pdbseed/temp01.dbf"

	EXECME "cp -f ${SEEDDIR}/redo01.log ${TARGETDIR}"
	EXECME "cp -f ${SEEDDIR}/redo02.log ${TARGETDIR}"
	EXECME "cp -f ${SEEDDIR}/redo03.log ${TARGETDIR}"

	EXECME "cp -f ${SEEDDIR}/control01.ctl ${TARGETDIR}"
	EXECME "cp -f ${SEEDDIR}/control02.ctl ${TARGETDIR}"

	EXECME "cp -f ${SEEDDIR}/initSEED.ora ${ORACLE_HOME}/dbs/"
	cat ${ORACLE_HOME}/dbs/initSEED.ora |sed -e "s/SEED/${ORACLE_SID}/g" > ${ORACLE_HOME}/dbs/init${ORACLE_SID}.ora
}

# ------------------------------------------------------------
CallCreateControlfileSQL () {
${ORACLE_HOME}/bin/sqlplus -s /nolog <<-EOFsql
connect / as sysdba
start ${SQL_DIR}/CreateContainerDatabaseFromSeed.sql ${ORACLE_SID} ${ORADIR}/data
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
f_cdb_create () {
INPUT
export ORACLE_SID=${input1}
CreateDirectories
CopySeedDB
CallCreateControlfileSQL
AddTnsnamesEntry
AddOratabEntry
#AddOracleCronEntry 
ECHO Done
}
# ------------------------------------------------------------
f_cdb_drop () {
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
f_cdb_shutdown () {
INPUT
export ORACLE_SID=${input1}
SQLRUN "shutdown immediate"
}
# ------------------------------------------------------------
f_cdb_startup () {
INPUT
export ORACLE_SID=${input1}
SQLRUN "startup"
}
# ------------------------------------------------------------
f_cdb_dn () {
INPUT
export ORACLE_SID=${input1}
SQLRUN "shutdown immediate"
}
# ------------------------------------------------------------
f_cdb_up () {
INPUT
export ORACLE_SID=${input1}
SQLRUN "startup"
}
# ------------------------------------------------------------
f_cdb_tns_start () {
export ORACLE_HOME=$ORACLE_HOME_LISTNER
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
ORACLE_HOME_LISTNER=$(cat ${ORATAB} | grep "^\*:" | awk -F: '{print $2}')
EXECME "$ORACLE_HOME_LISTNER/bin/lsnrctl start"
}
# ------------------------------------------------------------
f_cdb_tns_stop () {
export ORACLE_HOME=$ORACLE_HOME_LISTNER
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
ORACLE_HOME_LISTNER=$(cat ${ORATAB} | grep "^\*:" | awk -F: '{print $2}')
EXECME "$ORACLE_HOME_LISTNER/bin/lsnrctl stop"
}
# ------------------------------------------------------------
f_cdb_tns_status () {
export ORACLE_HOME=$ORACLE_HOME_LISTNER
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
ORACLE_HOME_LISTNER=$(cat ${ORATAB} | grep "^\*:" | awk -F: '{print $2}')
EXECME "$ORACLE_HOME_LISTNER/bin/lsnrctl status"
}
# ------------------------------------------------------------
