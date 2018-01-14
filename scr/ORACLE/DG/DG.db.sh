# ############################################################
# DATA GUARD DATABASE FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# DG DB actions
action_L1="create_sby "
action_L2="duplicate1 duplicate "
action_L3="config "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
config,None,Display_Config \
create_sby,None,Create_Standby_Database_from_Primary \
duplicate,primary_db:standby_db:dest_id:,Create_Standby_Database_from_Primary_using_RMAN \
"
# ------------------------------------------------------------
# Local Variables
SYS_PWD=sys123
# ------------------------------------------------------------
f_db_create_sby () {
ERROR "please use DB create_sby instead of DGdb create_sby"
}
# ------------------------------------------------------------
f_db_duplicate1 () {
ECHO "coding not complete. Not tested"
#1=Primary 2=Standby 3=dest_id
INPUT 3
export ORACLE_SID=${input1}
RMANLINE "
CONNECT TARGET /;
CONNECT AUXILIARY sys/${SYS_PWD}@${input2};
DUPLICATE TARGET DATABASE
	FOR STANDBY
	FROM ACTIVE DATABASE
	DORECOVER
	SPFILE
	SET db_unique_name='${input2}'
	SET log_archive_dest_${input3}='SERVICE=${input2} NOAFFIRM ASYNC REGISTER VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=${input2}\'
	SET log_archive_dest_state_${input3}='ENABLE'
	SET fal_client='${input2}'
	SET fal_server='${input1}'
	SET db_file_name_convert='/oracle/data/${input1}','/oracle/data/${input2}'
	SET log_file_name_convert='/oracle/data/${input1}','/oracle/data/${input2}'
	SET standby_file_management='AUTO'
	SET archive_lag_target='900'
;
"
#  NOFILENAMECHECK;
}
# ------------------------------------------------------------
f_db_duplicate () {
ECHO "coding not complete. Not tested"
#1=Primary 2=Standby 3=dest_id
INPUT 3
export ORACLE_SID=${input1}
RMANLINE "
CONNECT TARGET /;
CONNECT AUXILIARY sys/sys123@${input2};
DUPLICATE TARGET DATABASE
	FOR STANDBY
	FROM ACTIVE DATABASE
	DORECOVER
;
"
#  NOFILENAMECHECK;
}
