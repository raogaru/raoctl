# ############################################################
# DATA MASK FUNCTIONS - raoctl custom data masking
# ############################################################
# ------------------------------------------------------------
# DATA MASK actions
action_L1="cre_obj drp_obj ins_alg show_alg ins_lst show_lst "
action_L2="val_lst gen_req gen_scr run_mask show_log "
action_L3="testcase "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
cre_obj,none,Create_Data_Masking_Objects \
drp_obj,none,Drop_Data_Masking_Objects \
ins_alg,none,Insert_Available_Algorithms \
show_alg,none,Show_Available_Algorithms \
ins_lst,none,Load_Data_Masking_Attribute_List \
show_lst,none,Show_Data_Masking_Attribute_List \
val_lst,none,Validate_Masking_List_Table \
gen_req,none,Generate_Requirement_Input_File \
gen_scr,none,Generate_Masking_SQL_Script_from_Requirement_File \
run_mask,none,Run_Data_Masking_Routine \
show_log,none,Show_Execution_Log \
testcase,none,Execute_a_Test_Case_Masking \
"
# ------------------------------------------------------------
# Global variables
v_debug=0
rc_DATAMASK_SQL_DIR=${v_class_dir}/datamask
rc_SHOW_DATAMASK_SCR=${rc_SHOW_DATAMASK_SCR:=YES}
# ------------------------------------------------------------
# Module specific environment variables
rc_DATAMASK_SCHEMA=${rc_DATAMASK_SCHEMA:="RAO"}
# ------------------------------------------------------------
DATAMASK_SQLEXEC () {
SQLNEWF
SQLLINE "alter session set current_schema=${rc_DATAMASK_SCHEMA};"
SQLLINE "@${rc_DATAMASK_SQL_DIR}/${1}"
SQLEXEC
}
# ------------------------------------------------------------
f_mask_cre_obj () {
DATAMASK_SQLEXEC cre_obj.sql
}
# ------------------------------------------------------------
f_mask_drp_obj () {
DATAMASK_SQLEXEC drp_obj.sql
}
# ------------------------------------------------------------
f_mask_ins_alg () {
DATAMASK_SQLEXEC ins_alg.sql
}
# ------------------------------------------------------------
f_mask_show_alg () {
DATAMASK_SQLEXEC sel_alg.sql
}
# ------------------------------------------------------------
f_mask_ins_lst () {
#INPUT
#DATAMASK_SQLEXEC ${input1}
DATAMASK_SQLEXEC ins_lst.sql
}
# ------------------------------------------------------------
f_mask_show_lst () {
DATAMASK_SQLEXEC sel_lst.sql
}
# ------------------------------------------------------------
f_mask_val_lst () {
SQLNEWF
SQLLINE "alter session set current_schema=${rc_DATAMASK_SCHEMA};"
SQLLINE "set serveroutput on size 100000"
SQLLINE "alter session set current_schema=${rc_DATAMASK_SCHEMA};"
SQLLINE "exec ${rc_DATAMASK_SCHEMA}.mskpkg.val;"
SQLEXEC
}
# ------------------------------------------------------------
f_mask_gen_req () {
SQLNEWF
SQLLINE "alter session set current_schema=${rc_DATAMASK_SCHEMA};"
ERROR "Not coded yet"
}
# ------------------------------------------------------------
f_mask_gen_scr () {
INPUT
v_DATAMASK_REQ=${v_DATAMASK_REQ:=${input1}}
ECHO "REQ ${v_DATAMASK_REQ}.req"
CHKFILE ${v_DATAMASK_REQ}.req

INCLIB_m

DEBUG "Prepare and Execute DataMask SQL ..."
SQLNEWF
SQLLINE "alter session set current_schema=${rc_DATAMASK_SCHEMA};"
f_Prepare_SQL_from_REQ

ECHO "Masking SQL ${TMPSQL}"
[[ "${rc_SHOW_DATAMASK_SCR}" = "YES" ]] && cat ${TMPSQL}
}
# ------------------------------------------------------------
f_mask_run_mask () {
INPUT
f_mask_gen_scr
SQLEXEC
}
# ------------------------------------------------------------
f_mask_testcase () {
INPUT
v_DATAMASK_REQ=${v_class_dir}/datamask/testcase/${input1}
ECHO "Testcase DDL ${v_DATAMASK_REQ}.sql"
CHKFILE ${v_DATAMASK_REQ}.sql

SQLNEWF
SQLLINE "set feedback off echo off verify off"
SQLLINE "alter session set current_schema=${rc_DATAMASK_SCHEMA};"
SQLLINE "@${v_DATAMASK_REQ}.sql"
#SQLLINE "@${v_class_dir}/datamask/ins_testcase_lst.sql ${rc_DATAMASK_SCHEMA} ${input1}"
SQLEXEC

input1=${v_DATAMASK_REQ}
f_mask_run_mask
}
# ------------------------------------------------------------
