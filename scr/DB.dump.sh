# ############################################################
# DB DUMP FUNCTIONS - alter database dump
# ############################################################
# ------------------------------------------------------------
# DB DUMP actions
action_L1="ctl_cc ctl_trc " #controlfile
action_L2="redo_full redo_header redo_by_scn redo_by_time redo_by_dba redo_by_rba "# redo OR standby redo OR archive 
action_L3="df_headers df_full df_range "	# datafile 
action_L4="fb_header fb_full "	#flashback logfile 
action_L5="system_state process_state process_stats lib_cache buf_cache "
action_L6="shared_pool large_pool sga pga heap ipc "
action_L="$action_L1 $action_L2 $action_L3 $action_L4 $action_L5 $action_L6"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
ctl_cc,NONE,Create_Controlfile_command  \
ctl_trc,NONE,Dump_controlfile_info \
redo_full,redo_file_name,Dump_redolog_blocks \
redo_header,redo_file_name,Dump_redolog_header \
redo_by_scn,redo_file_name:scn_min:scn_max,Dump_redolog_by_SCN_min_and_max_range \
redo_by_time,redo_file_name:time_min:time_max,Dump_redolog_by_REDODUMP_TIME_min_and_max_range \
redo_by_dba,redo_file_name:from_DBA_fileno:from_DBA_blockno:to_DBA_fileno:to_DBA:blockno,Dump_redolog_by_DataBlockAddress_range \
redo_by_rba,redo_file_name:from_RBA_seqno:from_RBA_blockno:to_RBA_seqno:to_RBA:blockno,Dump_redolog_by_RedoBlockAddress_range \
df_header,fileno,Dump_headers_of_all_datafiles \
df_range,fileno,Dump_datafile_by_BLOCK_range  \
df_full,fileno,Dump_datafile_full \
fb_header,fb_logfile_no,Dump_Flashback_Logfile_header \
fb_full,fb_logfile_no,Dump_Flashback_Logfile \
system_state,NONE,Dump_System_State \
process_state,os_pid,Dump_Process_State_for_given_os_pid \
lib_cache,NONE,Dump_Library_Cache \
buf_cache,RBA,Dump_Buffer_Cache \
"
# ------------------------------------------------------------
# Module specific environment variables
DBDUMP_p () {
vLine="$*"
SQLNEWF
SQLLINE "alter session set tracefile_identifier='RAOCTL_${v_module}_${v_action}';"
SQLLINE "alter session set max_dump_file_size=unlimited;"
SQLLINE "oradebug setmypid"
SQLLINE "oradebug tracefile_name"
SQLLINE "${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
DBDUMP_p2 () {
vLine="$*"
SQLNEWF
SQLLINE "alter session set tracefile_identifier='RAOCTL_${v_module}_${v_action}';"
SQLLINE "alter session set max_dump_file_size=unlimited;"
SQLLINE "oradebug setospid ${input1}"
SQLLINE "oradebug tracefile_name"
SQLLINE "${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
REDODUMP_p () {
vLine="$*"
v_orl_file_name="${input1}"
DBDUMP_p "alter system dump logfile '${v_orl_file_name}' ${vLine}"
}
# ------------------------------------------------------------
f_dump_ctl_cc () { 
DBDUMP_p "alter database backup controlfile to trace"
}
# ------------------------------------------------------------
f_dump_ctl_trc () { 
DBDUMP_p "alter session set events 'immediate trace name CONTROLF level 12'"
}
# ------------------------------------------------------------
f_dump_redo_full () { 
INPUT
REDODUMP_p ""
}
# ------------------------------------------------------------
f_dump_redo_header () { 
DBDUMP_p "alter session set events 'immediate trace name REDOHDR level 10'"
}
# ------------------------------------------------------------
f_dump_redo_by_scn () { 
INPUT 3
REDODUMP_p "SCN MIN ${input2} SCN MAX ${input3}"
}
# ------------------------------------------------------------
f_dump_redo_by_time () { 
INPUT 3
REDODUMP_p "TIME MIN ${input2} TIME MAX ${input3}"
}
# ------------------------------------------------------------
f_dump_redo_by_dba () { 
INPUT 5
#input2=fileno input3=blockno input4=fileno input5=blockno
REDODUMP_p "DBA MIN ${input2} ${input3} DBA MAX ${input4} ${input5}"
}
# ------------------------------------------------------------
f_dump_redo_by_rba () { 
INPUT 5
#input2=seqno input3=blockno input4=seqno input5=blockno
REDODUMP_p "RBA MIN ${input2} ${input3} RBA MAX ${input4} ${input5}"
}
# ------------------------------------------------------------
f_dump_df_headers () { 
DBDUMP_p "alter session set events 'immediate trace name file_hdrs level 10'"
}
# ------------------------------------------------------------
f_dump_df_range () { 
INPUT 3
DBDUMP_p "alter system dump datafile ${input1} block min ${input2} block max ${input3}"
}
# ------------------------------------------------------------
f_dump_df_full () { 
INPUT
DBDUMP_p "alter system dump datafile ${input1}"
}
# ------------------------------------------------------------
f_dump_fb_header () { 
INPUT
DBDUMP_p "alter system dump flashback logfile ${input1} logical"
}
# ------------------------------------------------------------
f_dump_fb_full () { 
INPUT
DBDUMP_p "alter system dump flashback logfile ${input1}"
}
# ------------------------------------------------------------
f_dump_system_state () { 
DBDUMP_p "alter session set events 'immediate trace name SYSTEMSTATE level 10'"
}
# ------------------------------------------------------------
f_dump_process_state () { 
INPUT
ECHO "Process state dump for OS PID ${input1}"
DBDUMP_p2 "alter session set events 'immediate trace name PROCESSSTATE level 10'"
}
# ------------------------------------------------------------
f_dump_process_stats () { 
INPUT
ECHO "Process Statistics dump for OS PID ${input1}"
DBDUMP_p2 "oradebug procstat"
}
# ------------------------------------------------------------
f_dump_lib_cache () { 
DBDUMP_p "alter session set events 'immediate trace name LIBRARY_CACHE level 10'"
}
# ------------------------------------------------------------
f_dump_buf_cache () { 
INPUT
DBDUMP_p "alter session set events 'immediate trace name BUFFER level ${input1}'"
}
# ------------------------------------------------------------
f_dump_ipc () { 
DBDUMP_p "oradebug ipc"
}
# ------------------------------------------------------------
f_dump_ipc () { 
DBDUMP_p "oradebug ipc"
}
# ------------------------------------------------------------
