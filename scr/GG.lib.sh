#!/bin/bash
arg1=$1
arg2=$2

v_debug=0

. /u01/ogg/efs/bin/ogg.env

# ------------------------------------------------------------
DEBUG () {
[[ ${v_debug} -gt 0 ]] && echo "$*"
}
# ------------------------------------------------------------
ECHO () {
echo "$*"
}
# ------------------------------------------------------------
ECHODO () {
echo "$*"
"$*"
}
# ------------------------------------------------------------
ERROR () {
echo "ERROR:$*"; exit 1
}
# ----------------------------------------------------------------------
GGSCI () {
vLine="$*"
OLD_PWD=$PWD
cd ${GGHOME}
${GGHOME}/ggsci <<-EOFggsci
${vLine}
EOFggsci
echo "\n"
cd $OLD_PWD
}
# ----------------------------------------------------------------------
prepare_defgen_prm () {
DEFGEN_PRM=${DIRPRM}/${SVC_NAME}_defgen.prm
echo "
defsfile ${DIRDEF}/${SVC_NAME}, purge 
userid GGADM@OGGORA1, password YTZkNjQzNjU2MzgyYzhkYTI2MzU3Mj
table RAO1.*;
" > ${DEFGEN_PRM}
# ----------------------------------------------------------------------
}

execute_defgen_prm () {
DEFGEN_PRM=${DIRPRM}/${SVC_NAME}_defgen.prm
defgen paramfile ${DEFGEN_PRM}
retval=$?
if [[ $retval -eq 0 ]]; then
	echo "defgen successful. ${DEFGEN_PRM} generated."
else
	echo "defgen failed. Please check ${DEFGEN_PRM} for details."
	exit 1
fi

}
# ----------------------------------------------------------------------
start_mgr () {
[[ -z ${GGHNODE} ]] && echo "ERROR: GGHNODE env variable not defined" && exit 1
echo starting mgr on node ${GGHNODE} on port 7${GGHNODE}09
${GGHOME}/mgr port 7${GGHNODE}09 paramfile ${DIRPRM}/MGR-${GGHNODE}.prm cd ${GGHOME} reportfile ${DIRPRM}/MGR-${GGHNODE}.rpt &
}
# ----------------------------------------------------------------------
stop_mgr () {
[[ -z ${GGHNODE} ]] && echo "ERROR: GGHNODE env variable not defined" && exit 1
echo stoping mgr on node ${GGHNODE} 
GGSCI "stop manager !"
}
# ----------------------------------------------------------------------
info_mgr () {
GGSCI "info manager "
}
# ----------------------------------------------------------------------
status_mgr () {
GGSCI "status manager"
}
# ----------------------------------------------------------------------
send_mgr () {
GGSCI "send manager ChildStatus"
}
# ######################################################################
# ----------------------------------------------------------------------
show_svc () {
OGG_SVC_NAME=$arg2
OGG_SVC_CFG=${OGGNFS}/bin/oggsvc.cfg
OGG_DB_CFG=${OGGNFS}/bin/oggdb.cfg

echo Service ${OGG_SVC_NAME}
svcline=$(grep ^${OGG_SVC_NAME} ${OGG_SVC_CFG})
[[ $? -eq 1 ]] && echo "${OGG_SVC_NAME} service not found in ${OGG_SVC_CFG}" && exit 1
echo Service String ${svcline}

OGG_SVC_ENV=$(echo ${svcline}|cut -f2 -d":")
[[ ${OGG_SVC_ENV} == "D" ]] && echo "Service Environment ${OGG_SVC_ENV}=Development"
[[ ${OGG_SVC_ENV} == "T" ]] && echo "Service Environment ${OGG_SVC_ENV}=Test"
[[ ${OGG_SVC_ENV} == "X" ]] && echo "Service Environment ${OGG_SVC_ENV}=Performance"
[[ ${OGG_SVC_ENV} == "P" ]] && echo "Service Environment ${OGG_SVC_ENV}=Production"

OGG_SVC_TYPE=$(echo ${svcline}|cut -f3 -d":")
[[ ${OGG_SVC_TYPE} == "E" ]] && echo "Service Type ${OGG_SVC_TYPE}=Extract"
[[ ${OGG_SVC_TYPE} == "R" ]] && echo "Service Type ${OGG_SVC_TYPE}=Replicat"

OGG_SVC_SRC_TYPE=$(echo ${svcline}|cut -f4 -d":")
[[ ${OGG_SVC_SRC_TYPE} == "ORA" ]] && echo "Service Source Type ${OGG_SVC_SRC_TYPE}=Oracle"
[[ ${OGG_SVC_SRC_TYPE} == "PGS" ]] && echo "Service Source Type ${OGG_SVC_SRC_TYPE}=PostgreSQL"
[[ ${OGG_SVC_SRC_TYPE} == "MSQ" ]] && echo "Service Source Type ${OGG_SVC_SRC_TYPE}=MySQL"
[[ ${OGG_SVC_SRC_TYPE} == "BIG" ]] && echo "Service Source Type ${OGG_SVC_SRC_TYPE}=BigData"

echo Team $(echo ${svcline}|cut -f5 -d":")
echo Project/Database $(echo ${svcline}|cut -f6 -d":")
echo Source/Schema $(echo ${svcline}|cut -f7 -d":")
OGG_TRL_STR=$(echo ${svcline}|cut -f8 -d":")
echo Trail string ${OGG_TRL_STR}
OGG_TRL_SIZE=$(echo ${svcline}|cut -f9 -d":")
echo Trail sizeMB ${OGG_TRL_SIZE}

admtoken=$(echo ${svcline}|cut -f10 -d":")
echo GoldenGate Admin Token ${admtoken}
admline=$(grep ^${admtoken} ${OGG_DB_CFG})
OGG_ADM_TNS=$(echo ${admline}|cut -f2 -d":")
OGG_ADM_USR=$(echo ${admline}|cut -f3 -d":")
OGG_ADM_PWD=$(echo ${admline}|cut -f4 -d":")
echo GoldenGate Admin TNS ${OGG_ADM_TNS}
echo GoldenGate Admin User ${OGG_ADM_USR}
echo GoldenGate Admin Password ${OGG_ADM_PWD}

srctoken=$(echo ${svcline}|cut -f11 -d":")
echo GoldenGate Source String ${srctoken}
srcline=$(grep ^${srctoken} ${OGG_DB_CFG})

OGG_SRC_TNS=$(echo ${srcline}|cut -f2 -d":")
OGG_SRC_USR=$(echo ${srcline}|cut -f3 -d":")
OGG_SRC_PWD=$(echo ${srcline}|cut -f4 -d":")
echo GoldenGate Source TNS ${OGG_SRC_TNS}
echo GoldenGate Source User ${OGG_SRC_USR}
echo GoldenGate Source Password ${OGG_SRC_PWD}

OGG_SVC_NODE_NUM=$(echo ${svcline}|cut -f12 -d":")
echo GoldenGate Service Node Number ${OGG_SVC_NODE_NUM}

}
# ----------------------------------------------------------------------
status_all () {
GGSCI "status all"
}
# ----------------------------------------------------------------------
info_all () {
GGSCI "info all"
}
# ----------------------------------------------------------------------
init_ext () {
OGG_SVC_NAME=$arg2
show_svc

echo "
dblogin userid ${OGG_ADM_USR}@${OGG_ADM_TNS}, password ${OGG_ADM_PWD}
add CheckpointTable
add trandata ${OGG_SRC_USR}.*
add extract ${OGG_SVC_NAME} tranlog, integrated tranlog, begin now
add exttrail ${DIRDAT}/${OGG_TRL_STR} extract ${OGG_SVC_NAME}, MEGABYTES ${OGG_TRL_SIZE}
register extract ${OGG_SVC_NAME}, database
" > ${DIRSQL}/${OGG_SVC_NAME}_init.sql

echo "#####"
cat ${DIRSQL}/${OGG_SVC_NAME}_init.sql
echo "#####"

GGSCI "obey ${DIRSQL}/${OGG_SVC_NAME}_init.sql"
}
# ----------------------------------------------------------------------
start_ext () {
OGG_SVC_NAME=$arg2
show_svc


[[ ${OGG_SVC_NODE_NUM} -ne 0 && ${OGG_SVC_NODE_NUM} -ne ${GGHNODE} ]] && ERROR "Service ${OGG_SVC_NAME} can only be run on node#${OGG_SVC_NODE_NUM}. This is node ${GGHNODE}."

echo "
EXTRACT ${OGG_SVC_NAME}
SETENV (TNS_ADMIN=${DIRCFG})
SETENV (NLSLANG=AL32UTF8)
USERID ${OGG_ADM_USR}@${OGG_ADM_TNS}, PASSWORD ${OGG_ADM_PWD}
EXTTRAIL ${DIRDAT}/${OGG_TRL_STR}, MEGABYTES ${OGG_TRL_SIZE}
IGNOREREPLICATES
GETAPPLOPS
TRANLOGOPTIONS EXCLUDEUSER ${OGG_ADM_USR}
TABLE ${OGG_SRC_USR}.*;
" > ${DIRPRM}/${OGG_SVC_NAME}.prm
echo Parameter file ${DIRPRM}/${OGG_SVC_NAME}.prm  generated

echo "#####"
cat ${DIRPRM}/${OGG_SVC_NAME}.prm 
echo "#####"

GGSCI "start extract ${OGG_SVC_NAME}"
}
# ----------------------------------------------------------------------
info_ext () {
#show_svc
GGSCI "info extract ${arg2}"
}
# ----------------------------------------------------------------------
stop_ext () {
#show_svc
GGSCI "stop extract  ${arg2}"
}
# ----------------------------------------------------------------------

# ######################################################################
# MAIN
# ######################################################################
${arg1}
