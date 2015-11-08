# ############################################################
# ASHSTREAM FUNCTIONS V$ACTIVE_SESSION_HISTORY - ASH Continuous Streaming
# ############################################################
# ------------------------------------------------------------
# ASH Stream actions
action_L1="all "
action_L2="prepare_sql start stop"
action_L3="s_show s_default s_clear s_edit s_add "
action_L4="f_show f_default f_clear f_edit f_add sid sqlid phv uid "
action_L="$action_L1 $action_L2 $action_L3 $action_L4"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
all,none,show_ASH_stream
"
# ------------------------------------------------------------
# local variables
rc_ASHSTREAM_SELECT_FILE=${TMP}/${rc_ASHSTREAM_SELECT_FILE:="SQL.ashstream.select.txt"}
rc_ASHSTREAM_FILTER_FILE=${TMP}/${rc_ASHSTREAM_FILTER_FILE:="SQL.ashstream.filter.txt"}
rc_ASHSTREAM_TIME_FILE=${TMP}/${rc_ASHSTREAM_TIME_FILE:="SQL.ashstream.time.txt"}
rc_ASHSTREAM_SQL_FILE=${TMP}/${rc_ASHSTREAM_SQL_FILE:="SQL.ashstream.sql"}
# ------------------------------------------------------------
f_ashstream_prepare_sql () {
DEBUG "Preparing ${rc_ASHSTREAM_SQL_FILE} ..."
SQLNEWF
SQLLINE "select "
[[ ! -f ${rc_ASHSTREAM_SELECT_FILE} ]] && f_ashstream_s_default
cat ${rc_ASHSTREAM_SELECT_FILE} >> ${TMPSQL}
SQLLINE "from v\$active_session_history"
SQLLINE "where sample_time >= sysdate-1/24/60"
[[ ! -f ${rc_ASHSTREAM_FILTER_FILE} ]] && f_ashstream_f_default
cat ${rc_ASHSTREAM_FILTER_FILE} >> ${TMPSQL}
SQLLINE ";"
cp ${TMPSQL} ${rc_ASHSTREAM_SQL_FILE} 
cat ${rc_ASHSTREAM_SQL_FILE} 
}
# ------------------------------------------------------------
f_ashstream_s_show () {
[[ ! -f ${rc_ASHSTREAM_SELECT_FILE} ]] && ERROR "File ${rc_ASHSTREAM_SELECT_FILE} not found"
cat ${rc_ASHSTREAM_SELECT_FILE}
}
# ------------------------------------------------------------
f_ashstream_s_default () {
echo "sample_time,session_id,sql_id,sql_opname,session_state,event,p1,p2,p3" > ${rc_ASHSTREAM_SELECT_FILE}
f_ashstream_prepare_sql
}
# ------------------------------------------------------------
f_ashstream_s_clear () {
echo "sample_time" > ${rc_ASHSTREAM_SELECT_FILE}
f_ashstream_prepare_sql
}
# ------------------------------------------------------------
f_ashstream_s_edit () {
vi ${rc_ASHSTREAM_SELECT_FILE}
f_ashstream_prepare_sql
}
# ------------------------------------------------------------
f_ashstream_s_add () {
INPUT
[[ ! -f ${rc_ASHSTREAM_SELECT_FILE} ]] && f_ashstream_s_clear
echo ",${input}" >> ${rc_ASHSTREAM_SELECT_FILE}
f_ashstream_prepare_sql
}
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
f_ashstream_f_show () {
[[ ! -f ${rc_ASHSTREAM_FILTER_FILE} ]] && ERROR "File ${rc_ASHSTREAM_FILTER_FILE} not found"
cat ${rc_ASHSTREAM_FILTER_FILE}
}
# ------------------------------------------------------------
f_ashstream_f_default () {
echo "and session_type!='BACKGROUND'" > ${rc_ASHSTREAM_FILTER_FILE}
echo "and session_state='ON CPU'" >> ${rc_ASHSTREAM_FILTER_FILE}
f_ashstream_prepare_sql
}
# ------------------------------------------------------------
f_ashstream_f_clear () {
echo "" > ${rc_ASHSTREAM_FILTER_FILE}
f_ashstream_prepare_sql
}
# ------------------------------------------------------------
f_ashstream_f_edit () {
vi ${rc_ASHSTREAM_FILTER_FILE}
f_ashstream_prepare_sql
}
# ------------------------------------------------------------
f_ashstream_f_add () {
INPUT
echo "and ${input}" >> ${rc_ASHSTREAM_FILTER_FILE}
f_ashstream_prepare_sql
}
# ------------------------------------------------------------
f_ashstream_sid () {
INPUT
echo "and session_id=${input1}" >> ${rc_ASHSTREAM_FILTER_FILE}
f_ashstream_prepare_sql
}
# ------------------------------------------------------------
f_ashstream_sqlid () {
INPUT
echo "and sql_id=${input1}" >> ${rc_ASHSTREAM_FILTER_FILE}
f_ashstream_prepare_sql
}
# ------------------------------------------------------------
f_ashstream_phv () {
INPUT
echo "and sql_plan_hash_value=${input1}" >> ${rc_ASHSTREAM_FILTER_FILE}
f_ashstream_prepare_sql
}
# ------------------------------------------------------------
f_ashstream_uid () {
INPUT
echo "and user_id=${input1}" >> ${rc_ASHSTREAM_FILTER_FILE}
f_ashstream_prepare_sql
}
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
f_ashstream_start () {
f_ashstream_prepare_sql
while (1)
do
SQLEXEC 
done
}
# ------------------------------------------------------------
