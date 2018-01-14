# ############################################################
# FILE TRANSFER FUNCTIONS DBMS_FILE_TRANSFER
# ############################################################
# ------------------------------------------------------------
# FILE TRANSFER actions
action_L1="copy get put "
action_L2="copy2 get2 put2 "
action_L3="test "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
copy,source_dir_obj:source_file:dest_dir_obj:dest_file,Copy_File \
get,source_dir_obj:source_file:source_db:dest_dir_obj:dest_file,Get_File \
put,source_dir_obj:source_file:dest_dir_obj:dest_file:dest_db,Put_File \
"
# ------------------------------------------------------------
# Module specific environment variables
STREAMS_CONF=${CFG_DIR}/streams.cfg
STRLOG=${LOG_DIR}/streams_config.log
STRADM=ADM
v_debug=0
rc_ftp_SOURCE_DIR_OBJ=${rc_ftp_SOURCE_DIR_OBJ:=ARCH_DIR}
rc_ftp_TARGET_DIR_OBJ=${rc_ftp_TARGET_DIR_OBJ:=ARCH_DIR}
# ------------------------------------------------------------
DBMS_FTP (){
vLine="$*"
SQLNEWF
SQLLINE "alter session set current_schema=ADM;"
SQLLINE "exec dbms_file_transfer.${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
f_ftp_copy () {
INPUT 4
#DBMS_FTP "copy_file('${input1}','${input2}','${input3}','${input4}')"
DBMS_FTP "copy_file(source_directory_object=>'${input1}',source_file_name=>'${input2}',destination_directory_object=>'${input3}',destination_file_name=>'${input4}')"
}
# ------------------------------------------------------------
f_ftp_copy2 () {
INPUT 2
DBMS_FTP "copy_file(source_directory_object=>'${rc_ftp_SOURCE_DIR_OBJ=}',source_file_name=>'${input1}',destination_directory_object=>'${rc_ftp_TARGET_DIR_OBJ=}',destination_file_name=>'${input2}')"
}
# ------------------------------------------------------------
f_ftp_get () {
INPUT 5
DBMS_FTP "get_file(source_directory_object=>'${input1}',source_file_name=>'${input2}',source_database=>'${input3}',destination_directory_object=>'${input4}',destination_file_name=>'${input5}')"
}
# ------------------------------------------------------------
f_ftp_get2 () {
INPUT 3
DBMS_FTP "get_file(source_directory_object=>'${rc_ftp_SOURCE_DIR_OBJ=}',source_file_name=>'${input1}',source_database=>'${input2}',destination_directory_object=>'${rc_ftp_TARGET_DIR_OBJ}',destination_file_name=>'${input3}')"
}
# ------------------------------------------------------------
f_ftp_put () {
INPUT 5
DBMS_FTP "put_file(source_directory_object=>'${input1}',source_file_name=>'${input2}',destination_directory_object=>'${input3}',destination_file_name=>'${input4}',destination_database=>'${input5}')"
}
# ------------------------------------------------------------
f_ftp_put2 () {
INPUT 3
DBMS_FTP "put_file(source_directory_object=>'${rc_ftp_SOURCE_DIR_OBJ=}',source_file_name=>'${input1}',destination_directory_object=>'${rc_ftp_TARGET_DIR_OBJ}',destination_file_name=>'${input2}',destination_database=>'${input3}')"
}
