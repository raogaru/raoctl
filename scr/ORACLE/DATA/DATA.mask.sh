# ############################################################
# DATA MASK FUNCTIONS - raoctl custom data masking
# ############################################################
# ------------------------------------------------------------
# DATA MASK actions
action_L1="cre_obj drp_obj ins_alg show_alg ins_lst show_lst "
action_L2="val_lst gen_req prep_run run_mask show_log "
action_L3=" "
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
val_tbl,none,Validate_Masking_List_Table \
gen_req,none,Generate_Requirement_Input_File \
prep_run,none,Prepare_Run_file_from_Requirement_File \
run_mask,none,Run_Data_Masking_Routine \
show_log,none,Show_Execution_Log \
"
# ------------------------------------------------------------
# Global variables
#v_debug=1
#rc_SHOW_SQL=YES
#rc_SHOW_LINE=YES
rc_DATAMASK_SQL_DIR=${v_class_dir}/datamask
# ------------------------------------------------------------
# Module specific environment variables
v_schema=${rc_MASK_SCHEMA:="RAO"}
# ------------------------------------------------------------
DATAMASK_SQLEXEC () {
SQLNEWF
SQLLINE "alter session set current_schema=${v_schema};"
SQLLINE "@${rc_DATAMASK_SQL_DIR}/${1}"
SQLEXEC
}
# ------------------------------------------------------------
f_mask_cre_obj () {
DATAMASK_SQLEXEC cre_datamask_obj.sql
}
# ------------------------------------------------------------
f_mask_drp_obj () {
DATAMASK_SQLEXEC drp_datamask_obj.sql
}
# ------------------------------------------------------------
f_mask_ins_alg () {
DATAMASK_SQLEXEC ins_datamask_alg.sql
}
# ------------------------------------------------------------
f_mask_show_alg () {
DATAMASK_SQLEXEC sel_datamask_alg.sql
}
# ------------------------------------------------------------
f_mask_ins_lst () {
#INPUT
#DATAMASK_SQLEXEC ${input1}
DATAMASK_SQLEXEC ins_datamask_lst.sql
}
# ------------------------------------------------------------
f_mask_show_lst () {
DATAMASK_SQLEXEC sel_datamask_lst.sql
}
# ------------------------------------------------------------
f_mask_val_lst () {
SQLNEWF
SQLLINE "set serveroutput on size 100000"
SQLLINE "alter session set current_schema=${v_schema};"
SQLLINE "exec ${v_schema}.mskpkg.val;"
SQLEXEC
}
# ------------------------------------------------------------
f_mask_gen_req () {
ERROR "Not coded yet"
}
# ------------------------------------------------------------
f_mask_testcase () {
INPUT
v_DATAMASK_REQ=${v_class_dir}/datamask/testcase/${input1}
[[ ! -f ${v_DATAMASK_REQ}.sql ]] && ERROR "TESTCASE DDL File ${v_DATAMASK_REQ}.sql not found !"
v_MAIN_DATAMASK_RUN=${TMPDIR}/main_datamask_run.sql
rm -f ${v_MAIN_DATAMASK_RUN}
f_Prepare_SQL_from_REQ 
ECHO "File ${v_MAIN_DATAMASK_RUN}"

}
# ------------------------------------------------------------
f_mask_prep_run () {
INPUT
v_DATAMASK_REQ=${input1}
v_MAIN_DATAMASK_RUN=${TMPDIR}/main_datamask_run.sql
INCLIB_m
rm -f ${v_MAIN_DATAMASK_RUN}
f_Prepare_SQL_from_REQ 
ECHO "File ${v_MAIN_DATAMASK_RUN}"
}
# ------------------------------------------------------------
f_mask_run_mask () {
INPUT
SQLRUN "${input1}"
}
# ------------------------------------------------------------
