# ############################################################
# SQL NOTES FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# SQL NOTES actions
action_L1="list new show edit delete search collect "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,NONE,List \
"
# ------------------------------------------------------------
# local variables
NOTES_DIR=${RC_DIR}/dat
# ------------------------------------------------------------
# local common functions
NOTES_f () {
x_cmd=$1
INPUT
v_file_name=${NOTES_DIR}/SQL.notes.${input1}.txt
[[ $v_check_file != "NO" ]] && [[ ! -f ${v_file_name} ]] && ERROR "File ${v_file_name} not found !"
${1} ${v_file_name}
}
# ------------------------------------------------------------
f_notes_list () {
find ${NOTES_DIR} -type f -name "SQL.notes.*.txt" -print
}
# ------------------------------------------------------------
f_notes_new () {
INPUT
v_file_name=${NOTES_DIR}/SQL.notes.${input1}.txt
[[ -f ${v_file_name} ]] && ERROR "File ${v_file_name} already exists !"
ECHO "SQL_ID:${input1}" > ${v_file_name}
}
# ------------------------------------------------------------
f_notes_show () {
NOTES_f cat 
}
# ------------------------------------------------------------
f_notes_edit () {
NOTES_f vi 
}
# ------------------------------------------------------------
f_notes_delete () {
NOTES_f rm 
}
# ------------------------------------------------------------
f_notes_add () {
INPUT 3
v_file_name=${NOTES_DIR}/SQL.notes.${input1}.txt
[[ ! -f ${v_file_name} ]] && ERROR "File ${v_file_name} not found !"
vi ${v_file_name}
ERROR "not coded yet"
}
# ------------------------------------------------------------
f_notes_search () {
INPUT
grep -i ${input1} $(find ${NOTES_DIR} -type f -name "SQL.notes.*.txt" -print)
}
# ------------------------------------------------------------
f_notes_collect () {
INPUT
v_file_name=${NOTES_DIR}/SQL.notes.${input1}.txt
[[ -f ${v_file_name} ]] && ERROR "File ${v_file_name} already exists !"
SQLQRY "@sqlnotes ${input1}" >  ${v_file_name}
}
# ------------------------------------------------------------
