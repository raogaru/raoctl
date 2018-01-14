DG_HOME=${CFG_DIR}
DG_CONF=${DG_HOME}/DG.cfg
set -A SITEA $(grep "^DG_SITES=" ${DG_CONF}|cut -f2 -d"=" | sed -e 's/,/ /g')
set -A HOSTA
set -A SIDA
set -A TNSA
set -A ROLEA
# ------------------------------------------------------------
# Data Guard configuration
#DG_SITES=DB50a,DB50b
#SITE_INFO_DB50a=itusa81:DB50a:DB50a
#SITE_INFO_DB50b=itusa81:DB50b:DB50b
#SITE_INFO_DB50c=itusa81:DB50c:DB50c
# ------------------------------------------------------------
USAGE3 () {
ECHO "Usage: $0 -s <Site> -t <task>"
ECHO "\t <site> is TNS alias of one of the Data Guard sites" 
ECHO "\t <task> is startup|shut|abort|openro|start_mrp|cancel_mrp"
ECHO "\t <task> is switch2primary|switch2standby"
ECHO "\t <task> is status|config"
exit 1
}
# ------------------------------------------------------------
SQLEXEC_ON () {
export ORACLE_SID=${1}
#constr="sys/sys123@${ORACLE_SID} as sysdba"
constr="/ as sysdba"
#cat $TMPSQL >> $ELOG
${ORACLE_HOME}/bin/sqlplus -s /nolog <<-EOFsql
connect $constr
@${TMPSQL}
EOFsql
}
# ------------------------------------------------------------
SQL_GETVAL () {
export ORACLE_SID=${1}
vLine=$2
#constr="sys/sys123@${ORACLE_SID} as sysdba"
constr="/ as sysdba"
#cat $TMPSQL >> $ELOG
${ORACLE_HOME}/bin/sqlplus -s /nolog <<-EOFsql
connect $constr
set feedback off pause off pagesize 0 heading off verify off linesize 500 term on trimspool on
${vLine}
EOFsql
}
# ------------------------------------------------------------
SQL_RUNSTR () {
export ORACLE_SID=${1}
vLine=$2
#constr="sys/sys123@${ORACLE_SID} as sysdba"
constr="/ as sysdba"
#cat $TMPSQL >> $ELOG
${ORACLE_HOME}/bin/sqlplus -s /nolog <<-EOFsql
connect $constr
set feedback off pause off pagesize 0 heading off verify off linesize 500 term on trimspool on
${vLine}
EOFsql
}

# ------------------------------------------------------------
GetMyRole () {
SQLNEWF
SQLLINE "set feedback off pause off pagesize 0 heading off verify off linesize 500 term on trimspool on"
SQLLINE "select database_role from v\$database;"
SQLEXEC_ON ${1}
}
# ------------------------------------------------------------
GetAppliedLogSeqNum () {
SQLNEWF
SQLLINE "set feedback off pause off pagesize 0 heading off verify off linesize 500 term on trimspool on"
SQLLINE "select min(sequence#) from v\$archived_log where standby_dest='YES' and applied='NO';"
SQLEXEC_ON ${1}
}

# ------------------------------------------------------------
DeleteAppliedArchiveLogs () {
untilseq=$(GetAppliedLogSeqNum ${1}|sed -e 's/[:space:]//g'|sed -e 's/[:tab:]//g')
ECHO "delete archivelogs untilseq :${untilseq}:"
ARCH_DEST=/oracle/archive/${ORACLE_SID}
ECHO Archive destination is ${ARCH_DEST}
ls ${ARCH_DEST} | while read ARCH_FILE
do
	archseq=$(echo ${ARCH_FILE} | cut -f3 -d"_" | cut -f1 -d"_")
	if [ ${archseq} -lt ${untilseq} ]; then
		ECHO Deleting archive log ${ARCH_FILE}
		rm -f ${ARCH_FILE}
	fi
done
}

# ------------------------------------------------------------
PrintMyStatus () { 
DEBUG Status of ${1}
DEBUG "==================="
SQLNEWF
SQLLINE "set feedback off pause off pagesize 0 heading off "
SQLLINE "set verify off linesize 500 term on trimspool on"
SQLLINE "select rpad('DBID              ',20)||dbid from v\$database;"
SQLLINE "select rpad('DB Name           ',20)||name from v\$database;"
SQLLINE "select rpad('Instance Name     ',20)||instance_name from v\$instance;"
SQLLINE "select rpad('DB Unique Name    ',20)||db_unique_name from v\$database;"
SQLLINE "select rpad('Host Name         ',20)||host_name from v\$instance;"
SQLLINE "select rpad('Database Role     ',20)||database_role from v\$database;"
SQLLINE "select rpad('Switchover Status ',20)||switchover_status from v\$database;"
SQLLINE "select rpad('Open Mode         ',20)||open_mode from v\$database;"
SQLLINE "select rpad('Log Mode          ',20)||log_mode from v\$database;"
SQLLINE "select rpad('Protection Mode   ',20)||protection_mode from v\$database;"
SQLLINE "select rpad('Flashback On      ',20)||flashback_on from v\$database;"
SQLLINE "select rpad('Current Redo Seq  ',20)||max(sequence#) from v\$log;"
SQLEXEC_ON ${1}
DEBUG "==================="
}

# ------------------------------------------------------------
PrintAllStatus () { 
DEBUG Print Status of all DG sites 
i=0
while  [ $i -lt ${#SITEA[*]} ] # for each site
do
	#ON_SITE=${SITEA[$i]}
	#ON_SID=${SIDA[$i]}
	#ON_HOST=${HOSTA[$i]}
	#ON_TNS=${TNSA[$i]}
	PrintMyStatus ${TNSA[$i]}
	(( i = i+1 ))
done
}
# ------------------------------------------------------------
ShutdownImmediate () {
DEBUG Shutdown immediate ${1}
SQLNEWF
SQLLINE "shutdown immediate;"
SQLEXEC_ON ${1}
}
# ------------------------------------------------------------
ShutdownAbort () {
DEBUG Shutdown Abort ${1}
SQLNEWF
SQLLINE "shutdown abort;"
SQLEXEC_ON ${1}
}
# ------------------------------------------------------------
StartupPrimaryDB () {
DEBUG Starting Database ${1}
SQLNEWF
SQLLINE "startup;"
SQLEXEC_ON ${1}
}
# ------------------------------------------------------------
StartupStandbyDB () {
DEBUG Starting Database ${1}
SQLNEWF
SQLLINE "startup mount;"
SQLLINE "alter database open read only;"
SQLLINE "alter database recover managed standby database disconnect from session;"
SQLEXEC_ON ${1}
}
# ------------------------------------------------------------
StartupMount () {
DEBUG Startup Mount ${1}
SQLNEWF
SQLLINE "startup mount;"
SQLEXEC_ON ${1}
}
# ------------------------------------------------------------
OpenReadOnly () {
DEBUG "alter Database open read only ${1}"
SQLNEWF
SQLLINE "alter database open read only;"
SQLEXEC_ON ${1}
}
# ------------------------------------------------------------
f_start_mrp () { 
DEBUG Starting MRP process on Standby ${1}
SQLNEWF
SQLLINE "alter database recover managed standby database disconnect from session;"
SQLEXEC_ON ${1}
}
# ------------------------------------------------------------
f_cancel_mrp () { 
DEBUG Cancelling MRP process on Standby ${1}
SQLNEWF
SQLLINE "alter database recover managed standby database cancel;"
SQLEXEC_ON ${1}
}
# ------------------------------------------------------------
Switch2Primary () {
DEBUG Making ${1} Primary
SQLNEWF
#SQLLINE "shutdown abort;"
#SQLLINE "startup mount;"
SQLLINE "alter database commit to switchover to primary with session shutdown;"
SQLLINE "shutdown abort;"
SQLLINE "startup mount;"
SQLLINE "alter database set standby database to maximize performance;"
SQLLINE "alter database open;"
SQLEXEC_ON ${1}
}

# ------------------------------------------------------------
Switch2Standby () {
DEBUG Making ${1} Standby
SQLNEWF
SQLLINE "shutdown abort;"
SQLLINE "startup mount;"
SQLLINE "alter database commit to switchover to standby with session shutdown;"
SQLLINE "shutdown abort;"
SQLLINE "startup mount;"
#SQLLINE "alter database mount standby database;"
SQLLINE "alter database open read only;"
SQLEXEC_ON ${1}
}
# ------------------------------------------------------------
f_DG_ReadConfig () {
i=0
for SITE in ${SITEA[*]}
do
	#DEBUG ========== SITE:${SITE}:
	X=$(grep "^SITE_INFO_${SITE}" ${DG_CONF} |cut -f2 -d"=")
	HOSTA[$i]=$(echo $X|cut -f1 -d":")
	SIDA[$i]=$(echo $X|cut -f2 -d":")
	TNSA[$i]=$(echo $X|cut -f3 -d":")
	#echo X=${X}
	ROLEA[$i]=$(GetMyRole ${TNSA[$i]})
	ECHO SITE=${SITEA[$i]}:SID=${SIDA[$i]}:HOST=${HOSTA[$i]}:TNS=${TNSA[$i]}:ROLE=${ROLEA[$i]}
	(( i = i+1 ))
done
}

# ############################################################


