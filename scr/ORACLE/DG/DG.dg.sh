# ############################################################
# DATA GUARD FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# DG actions
action_L1="adg_status adg_switchover adg_failover "	# active data guard 
action_L2="pdg_status pdg_switchover pdg_failover "	# physical data guard
action_L3="ldg_status ldg_switchover ldg_failover "	# logical data guard 
action_L4="cycle cycle_switchovers cycle_failovers "	# continuous mode 
action_L5="convert_physical_to_snapshot convert_snapshot_to_physical p2s s2p  report "	# snapshot standby 
action_L="$action_L1 $action_L2 $action_L3 $action_L4 $action_L5"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
config,None,Display_Config \
adg_status,None,ActiveDataGuard_status \
adg_switchover,from_site:to_site,ActiveDataGuard_Swithcover \
adg_failover,from_site:to_site,ActiveDataGuard_Failover \
pdg_status,None,PhysicalDataGuard_status \
pdg_switchover,Site,PhysicalDataGuard_Swithcover \
pdg_failover,Site,PhysicalDataGuard_Failover \
ldg_status,None,LogicalDataGuard_status \
ldg_switchover,Site,LogicalDataGuard_Swithcover \
ldg_failover,Site,LogicalDataGuard_Failover \
dg_status,None,DataGuard_status \
dg_switchover,Site,DataGuard_Swithcover \
dg_failover,Site,DataGuard_Failover  \
convert_physical_to_snapshot,Site,Convert_Physcial_Standby_2_Snapshot_Standby  \
convert_snapshot_to_physical,Site,Convert_Snapshot_Standby_2_Physical_Standby  \
"
# ------------------------------------------------------------
# local variables
INCLIB_c
# ------------------------------------------------------------
f_wait_for_nogap () {
while [ 1 ]
do
DEBUG "\nCheck gap_status on primary ${input1} where destination='${input2}'"
x=$(SQL_GETVAL ${input1} "select gap_status from v\$archive_dest_status where destination='${input2}';")
[[ "$x" = "NO GAP" ]] && ECHO "Gap Resolved" && return 0
ECHO "$(date '+%Y-%m-%d %H:%M:%S') gap_status from ${input1} to ${input2} = $x. will check again ..."
sleep 10
done
}
# ------------------------------------------------------------
f_dg_adg_status () {
site1=${1}
site2=${2}
ECHO "$cLINE3"
ECHO "\n\nRead Dataguard config information"
f_DG_ReadConfig
}
# ------------------------------------------------------------
f_dg_switchover () {
site1=${1}
site2=${2}
ECHO "$cLINE3"
ECHO "\n\nRead Dataguard config information"
f_DG_ReadConfig
ECHO "\nSwitchover requested from ${site1} to ${site2}"
#----
DEBUG "\nCheck database_role of ${site1}"
x=$(SQL_GETVAL ${site1} "select database_role from v\$database;")
if [ "$x" = "PRIMARY" ] ; then
	ECHO "${site1} database_role = $x"
else
	ERROR "${site1} database_role = $x. Cannot proceed"
fi
#----
DEBUG "\nCheck database_role of ${site2}"
x=$(SQL_GETVAL ${site2} "select database_role from v\$database;")
if [ "$x" = "PHYSICAL STANDBY" ] ; then
	ECHO "${site1} database_role = $x"
else
	ERROR "${site1} database_role = $x. Cannot proceed"
fi
#----
DEBUG "\nCheck switchover_status on primary ${site1} "
x=$(SQL_GETVAL ${site1} "select switchover_status from v\$database;")
if [ "$x" = "TO STANDBY" ] ; then
	ECHO "${site1} switchover_status = $x"
else
	ERROR "${site1} switchover_status = $x. Cannot proceed!"
fi
#----
DEBUG "\nCheck gap_status on primary ${site1} where destination='${site2}'"
x=$(SQL_GETVAL ${site1} "select gap_status from v\$archive_dest_status where destination='${site2}';")
if [ "$x" = "NO GAP" ] ; then
	ECHO "gap_status from ${site1} to ${site2} = $x"
else
	ERROR "gap_status from ${site1} to ${site2} = $x. Cannot proceed"
fi
#----
ECHO "\nSwitching primary ${site1} to standby"
SQL_RUNSTR ${site1} "alter database commit to switchover to standby with session shutdown;"
#----
ECHO "\nShutdown primary ${site1}"
SQL_RUNSTR ${site1} "shutdown abort"
#----
ECHO "\nStartup mount ${site1}"
SQL_RUNSTR ${site1} "startup mount"
#----
DEBUG "\nCheck database_role of ${site1}"
x=$(SQL_GETVAL ${site1} "select database_role from v\$database;")
if [ "$x" = "PHYSICAL STANDBY" ] ; then
	ECHO "${site1} database_role = $x"
else
	ERROR "${site1} database_role = $x. Cannot proceed"
fi
#----
DEBUG "\nCheck switchover_status of ${site2}"
x=$(SQL_GETVAL ${site2} "select switchover_status from v\$database;")
if [[ "$x" = @(TO PRIMARY|SESSIONS ACTIVE) ]] ; then
	ECHO "${site2} switchover_status = $x"
else
	ERROR "${site2} switchover_status = $x. Cannot proceed"
fi
#----
ECHO "\nSwitching standby ${site2} to primary"
SQL_RUNSTR ${site2} "alter database commit to switchover to primary with session shutdown;"
#----
DEBUG "\nCheck database_role of ${site2}"
x=$(SQL_GETVAL ${site2} "select database_role from v\$database;")
if [ "$x" = "PRIMARY" ] ; then
	ECHO "${site2} database_role = $x"
else
	ERROR "${site2} database_role = $x. Cannot proceed"
fi
#----
ECHO "\nNew primary ${site2} open"
SQL_RUNSTR ${site2} "alter database open;"
#----
DEBUG "\nCheck open_mode of ${site2}"
x=$(SQL_GETVAL ${site2} "select open_mode from v\$database;")
if [ "$x" = "READ WRITE" ] ; then
	ECHO "${site2} open_mode = $x"
else
	ERROR "${site2} open_mode = $x. Cannot proceed"
fi
#----
ECHO "\nNew standby ${site1} open read only"
SQL_RUNSTR ${site1} "alter database open read only;"
#----
DEBUG "\nCheck open_mode of ${site1}"
x=$(SQL_GETVAL ${site1} "select open_mode from v\$database;")
if [ "$x" = "READ ONLY" ] ; then
	ECHO "${site1} open_mode = $x"
else
	ERROR "${site1} open_mode = $x. Cannot proceed"
fi
#----
ECHO "\nStart MRP on new standby ${site1}"
SQL_RUNSTR ${site1} "alter database recover managed standby database disconnect from session;"
#----
DEBUG "\nCheck open_mode of ${site1}"
x=$(SQL_GETVAL ${site1} "select open_mode from v\$database;")
if [ "$x" = "READ ONLY WITH APPLY" ] ; then
	ECHO "${site1} open_mode = $x"
else
	ERROR "${site1} open_mode = $x. Cannot proceed"
fi
#----
ECHO "\nNew primary ${site2} switch logs"
SQL_RUNSTR ${site2} "alter system switch logfile;"
SQL_RUNSTR ${site2} "alter system switch logfile;"
SQL_RUNSTR ${site2} "alter system switch logfile;"
SQL_RUNSTR ${site2} "alter system switch logfile;"
SQL_RUNSTR ${site2} "alter system switch logfile;"
#----
ECHO "\nRead Dataguard config information"
f_DG_ReadConfig
#----
x=$(SQL_GETVAL ${site2} "select sequence# from v\$log where status='CURRENT';")
ECHO "Primary ${site2} log seq  = $x"
y=$(SQL_GETVAL ${site1} "select sequence# from v\$managed_standby where process='MRP0';")
ECHO "Standby ${site1} log seq  = $y"
#[[ $x -eq $y  ]] && return 0
#[[ (($x-$y)) -le 1 ]] && return 0
return 1
}
# ------------------------------------------------------------
f_dg_failover () {
site1=${1}
site2=${2}
ECHO "$cLINE3"
ECHO "\n\nRead Dataguard config information"
f_DG_ReadConfig
ECHO "\nFailover requested from ${site1} to ${site2}"
#----
DEBUG "\nCheck database_role of ${site1}"
x=$(SQL_GETVAL ${site1} "select database_role from v\$database;")
if [ "$x" = "PRIMARY" ] ; then
	ECHO "${site1} database_role = $x"
	ERROR "${site1} is available and hence cannot proceed with failover"
fi
#----
DEBUG "\nCheck database_role of ${site2}"
x=$(SQL_GETVAL ${site2} "select database_role from v\$database;")
if [ "$x" = "PHYSICAL STANDBY" ] ; then
	ECHO "${site2} database_role = $x"
else
	ERROR "${site2} database_role = $x. Cannot proceed"
fi
#----
DEBUG "\nCheck switchover_status of ${site2}"
x=$(SQL_GETVAL ${site2} "select switchover_status from v\$database;")
if [[ "$x" = @(TO PRIMARY|SESSIONS ACTIVE) ]] ; then
	ECHO "${site2} switchover_status = $x"
else
	ERROR "${site2} switchover_status = $x. Cannot proceed"
fi
#----
ECHO "\nFinish recovery of standby ${site2}"
SQL_RUNSTR ${site2} "alter database recover managed standby database finish;"
#----
ECHO "\nActivate standby ${site2} to primary"
SQL_RUNSTR ${site2} "alter database activate standby database;"
#----
ECHO "\nShutdown standby ${site2}"
SQL_RUNSTR ${site2} "shutdown immediate;"
#----
ECHO "\nStartup new primary ${site2}"
SQL_RUNSTR ${site2} "startup;"
#----
DEBUG "\nCheck database_role of ${site2}"
x=$(SQL_GETVAL ${site2} "select database_role from v\$database;")
if [ "$x" = "PRIMARY" ] ; then
	ECHO "${site2} database_role = $x"
else
	ERROR "${site2} database_role = $x. Cannot proceed"
fi
#----
DEBUG "\nCheck open_mode of ${site2}"
x=$(SQL_GETVAL ${site2} "select open_mode from v\$database;")
if [ "$x" = "READ WRITE" ] ; then
	ECHO "${site2} open_mode = $x"
else
	ERROR "${site2} open_mode = $x. Cannot proceed"
fi
#----
ECHO "\nNew primary ${site2} switch log"
SQL_RUNSTR ${site2} "alter system set log_archive_dest_state_2 = defer ;"
SQL_RUNSTR ${site2} "alter system set log_archive_dest_state_2 = enable ;"
#----
ECHO "\nNew primary ${site2} switch log"
SQL_RUNSTR ${site2} "alter system switch logfile;"
#----
}
# ------------------------------------------------------------
f_dg_convert_physical_to_snapshot () {
INPUT
export ORACLE_SID=${input1}
ECHO "\nRequested to Convert Physical Standby site ${ORACLE_SID} to Snapshot Standby"
#----
DEBUG "\nCheck database_role of ${ORACLE_SID}"
x=$(SQL_GETVAL ${ORACLE_SID} "select database_role from v\$database;")
if [ "$x" = "PHYSICAL STANDBY" ] ; then
	ECHO "${ORACLE_SID} database_role = $x"
else
	ERROR "${ORACLE_SID} database_role = $x. Cannot proceed"
fi
#----
DEBUG "\nCheck flashback status of ${ORACLE_SID}"
x=$(SQL_GETVAL ${ORACLE_SID} "select flashback_on from v\$database;")
if [ "$x" = "YES" ] ; then
	ECHO "${ORACLE_SID} flashback_on = $x"
else
	ERROR "${ORACLE_SID} flashback_on = $x. Cannot proceed"
fi
#----
ECHO "\nCancel MRP"
SQLRUN "alter database recover managed standby database cancel;"
#----
ECHO "\nShutdown Immediate"
SQLRUN "shutdown immediate;"
#----
ECHO "\nStartup Mount"
SQLRUN "startup mount;"
#----
ECHO "\nConvert to Snapshot Standby"
SQLRUN "alter database convert to snapshot standby;"
#----
ECHO "\nShutdown Abort"
SQLRUN "shutdown abort;"
#----
ECHO "\nStartup"
SQLRUN "startup"
#----
DEBUG "\nCheck database_role of ${ORACLE_SID}"
x=$(SQL_GETVAL ${ORACLE_SID} "select database_role from v\$database;")
ECHO "${ORACLE_SID} database_role = $x"
[[ "$x" = "SNAPSHOT STANDBY" ]] && return 0
return 1
}
# ------------------------------------------------------------
f_dg_convert_snapshot_to_physical () {
INPUT
export ORACLE_SID=${input1}
ECHO "\nRequested to Convert Physical Standby site ${ORACLE_SID} to Snapshot Standby"
#----
DEBUG "\nCheck database_role of ${ORACLE_SID}"
x=$(SQL_GETVAL ${ORACLE_SID} "select database_role from v\$database;")
if [ "$x" = "SNAPSHOT STANDBY" ] ; then
	ECHO "${ORACLE_SID} database_role = $x"
else
	ERROR "${ORACLE_SID} database_role = $x. Cannot proceed"
fi
#----
DEBUG "\nCheck flashback status of ${ORACLE_SID}"
x=$(SQL_GETVAL ${ORACLE_SID} "select flashback_on from v\$database;")
if [ "$x" = "YES" ] ; then
	ECHO "${ORACLE_SID} flashback_on = $x"
else
	ERROR "${ORACLE_SID} flashback_on = $x. Cannot proceed"
fi
#----
ECHO "\nShutdown Immediate"
SQLRUN "shutdown immediate;"
#----
ECHO "\nStartup Mount"
SQLRUN "startup mount;"
#----
ECHO "\nConvert to Physical Standby"
SQLRUN "alter database convert to physical standby;"
#----
ECHO "\nShutdown Abort"
SQLRUN "shutdown abort"
#----
ECHO "\nStartup"
SQLRUN "startup;"
#----
DEBUG "\nCheck database_role of ${ORACLE_SID}"
x=$(SQL_GETVAL ${ORACLE_SID} "select database_role from v\$database;")
ECHO "${ORACLE_SID} database_role = $x"
[[ "$x" = "PHYSICAL STANDBY" ]] && return 0
return 1
}
# ------------------------------------------------------------
f_dg_adg_failover () { 
INPUT 2
DG_TYPE="ADG"
f_dg_failover ${input1} ${input2}
}
# ------------------------------------------------------------
f_dg_adg_switchover () {
INPUT 2
v_debug=1
DG_TYPE="ADG"
f_dg_switchover ${input1} ${input2}
}
# ------------------------------------------------------------
f_dg_cycle () {
INPUT 3
v_debug=1
DG_TYPE="ADG"
typeset -i c_count=${input3}
c_index=1
while [ $c_index -le $c_count ]
do
	ECHO $cLINE1
	ECHO "ITERATION# ${c_index} : Switchover from ${input1} to ${input2}"
	f_wait_for_nogap
	f_dg_switchover ${input1} ${input2}
	#############################
	##### [[ $? -ne 0 ]] && ERROR "Terminating cyclic switchovers!!!"
	#############################
	x=${input1} ; input1=${input2} ; input2=${x}
	(( c_index = c_index+1 ))
done

}
# ------------------------------------------------------------
info_db () {
ADD_H2_LINK "Database"
ADD_H2_HEADER "DATABASE INFO"
ADD_H3_DETAIL "\
DATABASE:dbinfo,\
INSTANCE:instinfo"
}
# ========
info_dg_info () {
ADD_H2_LINK "Dataguard Info "
ADD_H2_HEADER "DATA GUARD INFO"
ADD_H3_DETAIL "\
ROLE:dg_dbrole.sql,\
DESTINATION_STATUS:dg_sby_dest_status.sql,\
APPLY_STATUS:dg_sby_redo_apply_status.sql,\
STANDBY_EVENTS:dg_sby_events.sql,\
INIT_PARAMETERS:dg_init_params.sql"
}
# ------------------------------------------------------------
f_dg_report () {
INCLIB_c RPT
# ========
info_db 
info_dg_info
# ========
ECHO "Preparing SQL to generate HTML report"
f_html_report "Dataguard_Healthcheck_Report_for_${ORACLE_SID}" "DataGuard Healthcheck Report" "Dataguard Healthcheck Report"
SQLEXEC
}
# ------------------------------------------------------------
f_dg_p2s () {
f_dg_convert_physical_to_snapshot
}
# ------------------------------------------------------------
f_dg_s2p () {
f_dg_convert_snapshot_to_physical
}
