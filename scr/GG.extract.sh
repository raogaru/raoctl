# ############################################################
# GG Extract FUNCTIONS - Oracle GoldenGate Extract
# ############################################################
# ------------------------------------------------------------
# GG EXTRACT actions
action_L1="list info status init prmgen defgen "
action_L2="start stop report details tasks ckpts "
action_L3="stats lag log_stats trace_on trace_off "
action_L4="cleanup delete register_integrated register_classic unregister "
action_L="$action_L1 $action_L2 $action_L3 $action_L4"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,extract_name,List_Extracts \
info,extract_name,Information_of_Extract \
status,extract_name,Status_of_Extract \
init,extract_name,Initialize_Extract_and_register \
prmgen,extract_name,Generate_Extract_Parameter_File \
defgen,extract_name,Generate_Extract_Definitions_File \
start,extract_name,Start_Extract \
stop,extract_name,Stop_Extract \
report,extract_name,Report_Extract_General_Statistics \
details,extract_name,Show_Extract_Details \
tasks,extract_name,Show_Extract_Tasks \
ckpts,extract_name,Show_Extract_CheckPoints \
stats,extract_name,Show_Extract_Performance_Statistics \
lag,extract_name,Show_Extract_Lag_Details \
log_stats,extract_name,Show_LogSwitch_Statistics \
trace_on,extract_name,Trace_ON_Extract \
trace_off,extract_name,Trace_OFF_Extract \
"
# ------------------------------------------------------------
INCLIB_c
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions

# ------------------------------------------------------------
f_extract_list () {
INPUT
GGSCI "info extract \*"
}
# ------------------------------------------------------------
f_extract_info () {
INPUT
GGSCI "info extract ${input1}"
}
# ------------------------------------------------------------
f_extract_status () {
INPUT
GGSCI "status extract ${input1}"
}
# ------------------------------------------------------------
f_extract_init () {
INPUT
OGG_SVC_NAME=${input1}
echo "
dblogin userid ${OGG_ADM_USR}@${OGG_ADM_TNS}, password ${OGG_ADM_PWD}
add CheckpointTable
add trandata ${OGG_SRC_USR}.*
add extract ${OGG_SVC_NAME} tranlog, integrated tranlog, begin now
add exttrail ${OGG_DAT}/${OGG_TRL_STR} extract ${OGG_SVC_NAME}, MEGABYTES ${OGG_TRL_SIZE}
register extract ${OGG_SVC_NAME}, database
" > ${OGG_SQL}/${OGG_SVC_NAME}_init.sql

ECHO "${vLINE4}"
cat ${OGG_SQL}/${OGG_SVC_NAME}_init.sql
ECHO "${vLINE4}"

GGSCI "obey ${OGG_SQL}/${OGG_SVC_NAME}_init.sql"
}
# ------------------------------------------------------------
f_extract_prmgen () {
INPUT
OGG_SVC_NAME=${input1}
echo "
EXTRACT ${OGG_SVC_NAME}
SETENV (TNS_ADMIN=${OGG_CFG})
SETENV (NLSLANG=AL32UTF8)
USERID ${OGG_ADM_USR}@${OGG_ADM_TNS}, PASSWORD ${OGG_ADM_PWD}
EXTTRAIL ${OGG_DAT}/${OGG_TRL_STR}, MEGABYTES ${OGG_TRL_SIZE}
IGNOREREPLICATES
GETAPPLOPS
TRANLOGOPTIONS EXCLUDEUSER ${OGG_ADM_USR}
TABLE ${OGG_SRC_USR}.*;
" > ${OGG_PRM}/${OGG_SVC_NAME}.prm
ECHO "OGG parameter file generated: ${OGG_PRM}/${OGG_SVC_NAME}.prm"

ECHO "${cLINE4}"
cat ${OGG_PRM}/${OGG_SVC_NAME}.prm 
ECHO "${cLINE4}"
}
# ------------------------------------------------------------
f_extract_defgen () {
INPUT
ReadServiceCfg ${input1}
DEFGEN_PRM=${OGG_PRM}/${OGG_SVC_NAME}_defgen.prm
DEFGEN_DEF= ${OGG_DEF}/${OGG_SVC_NAME}.def
echo "
defsfile ${DEFGEN_DEF}, purge 
USERID ${OGG_ADM_USR}@${OGG_ADM_TNS}, PASSWORD ${OGG_ADM_PWD}
TABLE ${OGG_SRC_USR}.*;
" > ${DEFGEN_PRM}

CHKFILE ${DEFGEN_PRM}

ECHO "defgen parameter file created: ${DEFGEN_PRM}"

ECHO "${vLINE4}"
cat ${DEFGEN_PRM}
ECHO "${vLINE4}"

ECHO "Running defgen using ${DEFGEN_PRM}"
defgen ParamFile ${DEFGEN_PRM}
retval=$?
[[ $retval -eq 0 ]] && ERROR "defgen failed. Please check ${DEFGEN_PRM} for details."

CHKFILE ${DEFGEN_DEF}

ECHO "defgen successful. ${DEFGEN_DEF} generated."
}
# ------------------------------------------------------------
f_extract_start () {
INPUT
ReadServiceCfg ${input1}
[[ ${GGHNODE} -ne 0 && ${OGG_SVC_NODE_NUM} -ne ${GGHNODE} ]] && ERROR "Service ${OGG_SVC_NAME} can only be run on node#${OGG_SVC_NODE_NUM}. This is node ${GGHNODE}."
CHKFILE ${OGG_PRM}/${OGG_SVC_NAME}.prm
GGSCI "start extract ${OGG_SVC_NAME}"
}
# ------------------------------------------------------------
f_extract_stop () {
INPUT
ReadServiceCfg ${input1}
GGSCI "stop extract ${OGG_SVC_NAME}"
}
# ------------------------------------------------------------
f_extract_report () {
INPUT
GGSCI "view report ${input1}"
}
# ------------------------------------------------------------
f_extract_details () {
INPUT
GGSCI "info extract ${input1} Detail"
}
# ------------------------------------------------------------
f_extract_tasks () {
INPUT
GGSCI "info extract ${input1} AllProcesses"
}
# ------------------------------------------------------------
f_extract_ckpts () {
INPUT
GGSCI "info extract ${input1} ShowCh"
}
# ------------------------------------------------------------
f_extract_stats () {
INPUT
GGSCI "stats extract ${input1}"
}
# ------------------------------------------------------------
f_extract_lag () {
INPUT
GGSCI "lag extract ${input1}"
}
# ------------------------------------------------------------
f_extract_log_stats () {
INPUT
GGSCI "send extract ${input1} LogStats"
}
# ------------------------------------------------------------
f_extract_trace_on () {
INPUT
GGSCI "send extract ${input1} Trace2 ${OGG_TRC}/${input1}.trc"
}
# ------------------------------------------------------------
f_extract_trace_off () {
INPUT
GGSCI "send extract ${input1} Trace2 off"
}
# ------------------------------------------------------------
f_extract_cleanup () {
INPUT
GGSCI "cleanup extract ${input1} "
}
# ------------------------------------------------------------
f_extract_delete () {
INPUT
GGSCI "delete extract ${input1}"
}
# ------------------------------------------------------------
f_extract_register_integrated () {
INPUT
ECHO "Resiter as Integrated Extract"
GGSCI "register extract ${input1} LogRetention"
}
# ------------------------------------------------------------
f_extract_register_classic () {
INPUT
ECHO "Resiter as Classic Extract"
GGSCI "register extract ${input1} database"
}
# ------------------------------------------------------------
f_extract_unregister () {
INPUT
GGSCI "unregister extract ${input1} "
}
# ------------------------------------------------------------

