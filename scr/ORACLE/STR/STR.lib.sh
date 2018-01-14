# ------------------------------------------------------------
# Module specific environment variables
STREAMS_CONF=${CFG_DIR}/streams.cfg
STRLOG=${LOG_DIR}/streams_config.log
# ------------------------------------------------------------
STRADM=${rc_STREAMS_ADMIN_USR:="STRADM"}
STRADM_PWD=${rc_STREAMS_ADMIN_PWD:="StreamsAdminPassword"}
#
STRDBA=${rc_STREAMS_DBA_USR:="master"}
STRDBA_PWD=${rc_STREAMS_DBA_PWD:="DBAPassword"}
#
STRDBO=${rc_STREAMS_DBO_USR:="RAO"}
STRDBO_PWD=${rc_STREAMS_DBO_PWD:="SchemaPassword"}
rc_SHOW_LINE="NO"
rc_SHOW_SQL="NO"
# ------------------------------------------------------------
# Connect to SQLPLUS and execute script
STREXEC () {  #1-user 2=password 3=SID 4=sqlfile
if [[ $1 = "as" && $2 = "sysdba" ]] ; then
	constr="/ as sysdba"
else
	constr="${1}/${2}@${3}"
fi
if [[ -z $4 ]]; then
	SQLFILE=${TMPSQL}
else
	SQLFILE=$4
fi
#echo Executing SQL $SQLFILE as $constr
cat $SQLFILE >> $STRLOG
[[ "${rc_SHOW_LINE}" != "NO" ]] && ECHO ${cLINE3}
[[ "${rc_SHOW_SQL}" != "NO" ]] && cat ${TMPSQL}
ECHO "-- ${cLINE5}" >> $STRLOG
export ORACLE_SID=$3
${ORACLE_HOME}/bin/sqlplus -s /nolog <<-EOFsql
connect $constr
--show user	
set echo off feedback off pagesi 0 termout on linesi 1000 trimspool on
set serveroutput on size 10000
spool ${TMPLOG} append
@${SQLFILE}
spool off
EOFsql
}
# ------------------------------------------------------------
STRQRY () { 
SQLNEWF
SQLLINE "set echo off feedback off pause off pagesize 0 heading on "
SQLLINE "set verify off linesize 500 term on trimspool on"
SQLLINE "$*"
STREXEC ${STRADM} ${STRADM_PWD} ${ON_SID}
}
# ------------------------------------------------------------
