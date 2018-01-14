# ----------------------------------------------------------------------
# Environment variables
OGG_BASE=/app/ogg	# GoldenGate software Base location
OGG_HOME=${OGG_BASE}/Oracle	# GoldenGate software location
OGG_NFS=/data/ogg	# GoldenGate Hub commong location
#OGG_CFG=${OGG_NFS}/cfg	# configuration files (network file system location)
OGG_CFG=${RC_DIR}/src/GG/cfg	# configuration files (local location)
OGG_DAT=${OGG_NFS}/dat	# data files
OGG_PRM=${OGG_NFS}/prm	# parameter files
OGG_SQL=${OGG_NFS}/sql	# obey files
OGG_CHK=${OGG_NFS}/chk	# checkpoint info
OGG_OUT=${OGG_NFS}/out	# output files
OGG_PCS=${OGG_NFS}/pcs	# process id info
OGG_RPT=${OGG_NFS}/rpt	# report files
OGG_TMP=${OGG_NFS}/tmp	# temporary files
OGG_DEF=${OGG_NFS}/def	# definition files
OGG_TRC=${OGG_NFS}/trc	# trace files
OGG_HUB_CFG_FILE=${OGG_CFG}/ogg-hub.cfg
OGG_DB_CFG_FILE=${OGG_CFG}/ogg-db.cfg
OGG_SVC_CFG_FILE=${OGG_CFG}/ogg-svc.cfg
# ----------------------------------------------------------------------
# Local variables
GGHNAME=${rc_OGG_HUB_NAME:=""}
GGHNODE=${rc_OGG_NODE_NUMBER:=0}
# ----------------------------------------------------------------------
CHKFILE ${OGG_HUB_CFG_FILE}
CHKFILE ${OGG_DB_CFG_FILE}
CHKFILE ${OGG_SVC_CFG_FILE}
# ----------------------------------------------------------------------
# 
GGSCI () {
vLine="$*"
OLD_PWD=$PWD
cd ${OGG_HOME}
${OGG_HOME}/ggsci <<-EOFggsci
${vLine}
EOFggsci
echo "\n"
cd $OLD_PWD
}
# ----------------------------------------------------------------------
ReadServiceCfg () {
OGG_SVC_NAME=$1

ECHO "Service ${OGG_SVC_NAME}"
svcline=$(grep ^${OGG_SVC_NAME} ${OGG_SRV_CFG_FILE})
[[ $? -eq 1 ]] && ECHO "${OGG_SVC_NAME} service not found in ${OGG_SRV_CFG_FILE}" && exit 1
DEBUG  "Service Config Line ${svcline}"

OGG_SVC_ENV=$(echo ${svcline}|cut -f2 -d":")
[[ ${OGG_SVC_ENV} == "D" ]] && ECHO "Service Environment ${OGG_SVC_ENV}=Development"
[[ ${OGG_SVC_ENV} == "T" ]] && ECHO "Service Environment ${OGG_SVC_ENV}=Test"
[[ ${OGG_SVC_ENV} == "X" ]] && ECHO "Service Environment ${OGG_SVC_ENV}=Performance"
[[ ${OGG_SVC_ENV} == "P" ]] && ECHO "Service Environment ${OGG_SVC_ENV}=Production"

OGG_SVC_TYPE=$(echo ${svcline}|cut -f3 -d":")
[[ ${OGG_SVC_TYPE} == "E" ]] && ECHO "Service Type ${OGG_SVC_TYPE}=Extract"
[[ ${OGG_SVC_TYPE} == "R" ]] && ECHO "Service Type ${OGG_SVC_TYPE}=Replicat"

OGG_SVC_SRC_TYPE=$(echo ${svcline}|cut -f4 -d":")
[[ ${OGG_SVC_SRC_TYPE} == "ORA" ]] && ECHO "Service Source Type ${OGG_SVC_SRC_TYPE}=Oracle"
[[ ${OGG_SVC_SRC_TYPE} == "PGS" ]] && ECHO "Service Source Type ${OGG_SVC_SRC_TYPE}=PostgreSQL"
[[ ${OGG_SVC_SRC_TYPE} == "MSQ" ]] && ECHO "Service Source Type ${OGG_SVC_SRC_TYPE}=MySQL"
[[ ${OGG_SVC_SRC_TYPE} == "BIG" ]] && ECHO "Service Source Type ${OGG_SVC_SRC_TYPE}=BigData"

ECHO Team $(echo ${svcline}|cut -f5 -d":")
ECHO Project/Database $(echo ${svcline}|cut -f6 -d":")
ECHO Source/Schema $(echo ${svcline}|cut -f7 -d":")
OGG_TRL_STR=$(echo ${svcline}|cut -f8 -d":")
ECHO Trail string ${OGG_TRL_STR}
OGG_TRL_SIZE=$(echo ${svcline}|cut -f9 -d":")
ECHO Trail sizeMB ${OGG_TRL_SIZE}

admtoken=$(echo ${svcline}|cut -f10 -d":")
ECHO GoldenGate Admin Token ${admtoken}
admline=$(grep ^${admtoken} ${OGG_DB_CFG_FILE})
OGG_ADM_TNS=$(echo ${admline}|cut -f2 -d":")
OGG_ADM_USR=$(echo ${admline}|cut -f3 -d":")
OGG_ADM_PWD=$(echo ${admline}|cut -f4 -d":")
ECHO GoldenGate Admin TNS ${OGG_ADM_TNS}
ECHO GoldenGate Admin User ${OGG_ADM_USR}
ECHO GoldenGate Admin Password ${OGG_ADM_PWD}

srctoken=$(echo ${svcline}|cut -f11 -d":")
ECHO GoldenGate Source String ${srctoken}
srcline=$(grep ^${srctoken} ${OGG_DB_CFG_FILE})

OGG_SRC_TNS=$(echo ${srcline}|cut -f2 -d":")
OGG_SRC_USR=$(echo ${srcline}|cut -f3 -d":")
OGG_SRC_PWD=$(echo ${srcline}|cut -f4 -d":")
ECHO GoldenGate Source TNS ${OGG_SRC_TNS}
ECHO GoldenGate Source User ${OGG_SRC_USR}
ECHO GoldenGate Source Password ${OGG_SRC_PWD}

OGG_SVC_NODE_NUM=$(echo ${svcline}|cut -f12 -d":")
ECHO GoldenGate Service Node Number ${OGG_SVC_NODE_NUM}

}
# ----------------------------------------------------------------------
