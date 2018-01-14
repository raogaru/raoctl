# ############################################################
# DATA GUARD BROKER FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# DG BROKER actions
action_L1="help ena_dmon dis_dmon "
action_L2="show_cfg verb_cfg cre_cfg rem_cfg ena_cfg dis_cfg edit_cfg_mode edit_cfg_prop "
action_L3="show_db verb_db add_db rem_db ena_db dis_db set_db_state set_db_prop dbup dbdn "
action_L4="start_obs stop_obs "
action_L5="switchover failover convert "
action_L="$action_L1 $action_L2 $action_L3 $action_L4 $action_L5"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
help,none,Show_DG_Borker_Steps \
ena_dmon,none,Enable_DMON_Background_Process \
dis_dmon,none,disable_DMON_Background_Process \
show_cfg,none,Show_Configuration \
verb_cfg,none_Show_Configuration \
cre_cfg,config_name:primary_db,Create_Configuration \
rem_cfg,none,Remove_Configuration \
ena_cfg,none,Enable_Configuration \
dis_cfg,none_Disable_Configuration \
edit_cfg_mode,dg_mode,Edit_Configuration_Mode \
edit_cfg_prop,config_property_name:config_property_value,Edit_Configuration_Parameter_Values \
show_db,db_name,Show_Database_Status_Information \
verb_db,db_name,Show_Database_Status_Detailed_Verbose_Information \
add_db,db_name,Add_Database_to_DG_Broker \
rem_db,db_name,Remove_Database_from_DG_Broker \
ena_db,db_name,Enable_Database_in_DG_Broker \
dis_db,db_name,Disable_Database_in_DG_Broker \
set_db_state,db_name:db_state_value:Change_DB_State_in_DG_Broker \
set_db_prop,db_name:property_name:property_value:Change_a_Database_property_Value_in_DG_Borker \
dbup,none,start_database \
dbdn,none,stop_database \
start_obs,none,Start_DG_Broker_Observer \
stop_obs,none,Stop_DG_Broker_Observer \
switchover,to_database_name,Switchover_given_DB_to_Primary_using_DG_Broker \
failover,to_database_name,Failover_given_DB_to_Primary_using_DG_Broker \
convert,database_name:new_state,Covert_given_DB_to_PHYSICAL_STANDBY_or_SNAPSHOT_STANDBY \
"
# ------------------------------------------------------------
# Local variables
# ------------------------------------------------------------
DGMGRL () {
vLine="$*"
${ORACLE_HOME}/bin/dgmgrl -silent -echo <<-EOFdgm
connect sys/sys123;
${vLine}
EOFdgm
}
# ============================================================
f_broker_help () {
ECHO "
1. Use spfile instead of pfile
	create spfile from pfile;
2. Enable DMON process
	-a ena_dmon
3. Create broker configuration
	-a cre_cfg -i RAODGB:DB50a
4. Show configuration
	-a show_cfg
5. Add standby database 
	-a add_db DB50b
"
}
# ============================================================
# ------------------------------------------------------------
f_broker_ena_dmon () {
SQLRUN "alter system set dg_broker_start=true;"
}
# ------------------------------------------------------------
f_broker_dis_dmon () {
SQLRUN "alter system set dg_broker_start=false;"
}
# ============================================================
# ============================================================
f_broker_show_cfg () {
DGMGRL "SHOW CONFIGURATION;"
}
# ------------------------------------------------------------
f_broker_verb_cfg () {
DGMGRL "SHOW CONFIGURATION VERBOSE;"
}
# ------------------------------------------------------------
f_broker_cre_cfg () {
INPUT 2
DGMGRL "CREATE CONFIGURATION '${input1}' AS PRIMARY DATABASE IS '${input2}' CONNECT IDENTIFIER IS '${input2}';"
}
# ------------------------------------------------------------
f_broker_rem_cfg () {
DGMGRL "REMOVE CONFIGURATION;"
}
# ------------------------------------------------------------
f_broker_ena_cfg () {
DGMGRL "ENABLE CONFIGURATION;"
}
# ------------------------------------------------------------
f_broker_dis_cfg () {
DGMGRL "DISABLE CONFIGURATION;"
}
# ------------------------------------------------------------
f_broker_edit_cfg_mode () {
INPUT
#VALID_LOV u $input1 "MAXPROTECTION|MAXAVAILABILITY|MAXPERFORMANCE"
typeset -u x=${input1}
[[ ! "${x}" = @(MAXPROTECTION|MAXAVAILABILITY|MAXPERFORMANCE) ]] && ERROR "Invalid Protection mode ${input1}"
DGMGRL "EDIT CONFIGURATION SET PROTECTION MODE AS ${input1};"
}
# ------------------------------------------------------------
f_broker_edit_cfg_prop () {
INPUT 2
DGMGRL "EDIT CONFIGURATION SET PROPERTY ${input1}=${input2};"
}
# ============================================================
f_broker_show_db () {
INPUT
DGMGRL "SHOW DATABASE '${input1}' ;"
}
# ------------------------------------------------------------
f_broker_verb_db () {
INPUT
DGMGRL "SHOW DATABASE VERBOSE '${input1}' ;"
}
# ------------------------------------------------------------
f_broker_add_db () {
INPUT
DGMGRL "ADD DATABASE '${input1}' AS CONNECT IDENTIFIER IS '${input1}';"
#[[ ! "${input2}" = @(PHYSICAL|LOGICAL) ]] && ERROR "input2 must be either PHYSICAL or LOGICAL"
#DGMGRL "ADD DATABASE '${input1}' AS CONNECT IDENTIFIER IS '${input1}' MAINTAINED AS '${input2}';"
}
# ------------------------------------------------------------
f_broker_rem_db () {
INPUT
DGMGRL "REMOVE DATABASE '${input1}' PRESERVE DESTINATIONS;"
}
# ------------------------------------------------------------
f_broker_ena_db () {
INPUT
DGMGRL "ENABLE DATABASE '${input1}';"
}
# ------------------------------------------------------------
f_broker_dis_db () {
INPUT
DGMGRL "DISABLE DATABASE '${input1}';"
}
# ------------------------------------------------------------
f_broker_set_db_state () {
INPUT 2
typeset -u input2="${input2}"
[[ ! "${input2}" = @(APPLY-ON|APPLY-OFF|TRANSPORT-ON|TRANSPORT-OFF) ]] && ERROR "input2 must be either APPLY-ON or APPLY-OFF"
DGMGRL "EDIT DATABASE '${input1}' SET STATE= '${input2}' ;"
}
# ------------------------------------------------------------
f_broker_set_db_prop () {
INPUT 3
DGMGRL "EDIT DATABASE '${input1}' SET PROPERTY '${input2}' = '${input3}' ;"
}
# ------------------------------------------------------------
f_broker_dbup () {
DGMGRL "STARTUP;"
}
# ------------------------------------------------------------
f_broker_dbdn () {
DGMGRL "SHUTDOWN IMMEDIATE;"
}
# ============================================================
f_broker_start_obs () {
DGMGRL "START OBSERVER;"
}
# ------------------------------------------------------------
f_broker_stop_obs () {
DGMGRL "STOP OBSERVER;"
}
# ============================================================
f_broker_switchover () {
INPUT
DGMGRL "SWITCHOVER TO '${input1}';"
}
# ------------------------------------------------------------
f_broker_failover () {
INPUT
DGMGRL "FAILOVER TO '${input1}' IMMEDIATE;"
}
# ------------------------------------------------------------
f_broker_convert () {
INPUT 2
typeset -u input2=${input2}
[[ ! "${input2}" = @(SNAPSHOT|PHYSICAL) ]] && ERROR "input2 must be either SNAPSHOT or PHYSICAL"
DGMGRL "CONVERT DATABASE '${input1}' TO '${input2}' STANDBY;"
}
# ------------------------------------------------------------
