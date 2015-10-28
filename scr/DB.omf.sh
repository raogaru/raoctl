# ############################################################
# ORACLE MANAGED FILES - FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# OMF actions
action_L1="config unconfig add_orl add_orl_mem drop_orl "
action_L2="cre_tbs add_data_file drop_tbs "
action_L3="cre_undo_tbs  "
action_L4="cre_temp_tbs add_temp_file "
action_L="$action_L1 $action_L2 $action_L3 $action_L4"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
config,none,Config_Oracle_Managed_Files_init.ora_parameters \
unconfig,none,UnConfig_Oracle_Managed_Files_init.ora_parameters \
add_orl,orl_size,Create_Online_Redo_Log_Group \
drop_orl,group_number,Drop_Online_Redo_Log_Group \
cre_tbs,tablespace_name:size,Create_Normal_Tablespace \
cre_undo_tbs,tablespace_name:size,Create_UNDO_Tablespace \
cre_temp_tbs,tablespace_name:size,Create_TEMP_Tablespace \
add_orl_mem,group_number,Add_Online_Redo_Log_Group_Member \
"
# ------------------------------------------------------------
#local variables
ORADIR=/oracle
# ------------------------------------------------------------
f_omf_config () {
SQLRUN "alter system set db_create_file_dest='${ORADIR}/data' ;"
SQLRUN "alter system set db_create_online_log_dest_1='${ORADIR}/data' ;"
}
# ------------------------------------------------------------
f_omf_unconfig () {
SQLRUN "alter system set db_create_file_dest='' ;"
SQLRUN "alter system set db_create_online_log_dest_1='' ;"
}
# ------------------------------------------------------------
f_omf_add_orl () {
INPUT
SQLRUN "alter database add logfile size ${input1} ;"
}
# ------------------------------------------------------------
f_omf_add_orl_mem () {
INPUT
SQLRUN "alter database add logfile member group ${input1} ;"
}
# ------------------------------------------------------------
f_omf_drop_orl () {
INPUT
SQLRUN "alter database drop logfile group ${input1} ;"
}
# ------------------------------------------------------------
f_omf_cre_tbs () {
INPUT 2
SQLRUN "create tablespace ${input1} datafile size ${input2} ;"
}
# ------------------------------------------------------------
f_omf_add_data_file () {
INPUT 2
SQLRUN "alter tablespace ${input1} add datafile size ${input2} ;"
}
# ------------------------------------------------------------
f_omf_drop_tbs () {
INPUT
SQLRUN "drop tablespace ${input1} ;"
}
# ------------------------------------------------------------
f_omf_cre_undo_tbs () {
INPUT 2
SQLRUN "create undo tablespace ${input1} datafile size ${input2} ;"
}
# ------------------------------------------------------------
f_omf_cre_temp_tbs () {
INPUT 2
SQLRUN "create temporary tablespace ${input1} tempfile size ${input2} ;"
}
# ------------------------------------------------------------
f_omf_add_temp_file () {
INPUT 2
SQLRUN "alter tablespace ${input1} add tempfile size ${input2} ;"
}
# ------------------------------------------------------------
