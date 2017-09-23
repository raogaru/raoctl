# ############################################################
# GG Manager FUNCTIONS - Oracle GoldenGate GGSCI Command Interface
# ############################################################
# ------------------------------------------------------------
# GGSCI actions
action_L1="info status start stop kill "
action_L2="childs ports trails "
action_L3=" "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
info,none,Information of GoldenGate Manager \
status,none,Status_of_GoldenGate_Manager \
start,none,Start_GoldenGate_Manager \
stop,none,Stop_GoldenGate_Manager \
kill,Extract_or_Replicat_Process_name,Kill_GoldenGate_Manager \
childs,none,Information_on_Child_Processes_started_by_GoldenGate_Manager \
ports,none,Information_on_ports_used_by_GoldenGate_Manager \
trails,none,Information_on_Purge_rules_on_old_extracts_started_by_GoldenGate_Manager \
"
# ------------------------------------------------------------
# local variables
INCLIB_c

# ------------------------------------------------------------
f_mgr_info () {
GGSCI "info manager"
}
# ------------------------------------------------------------
f_mgr_status () {
GGSCI "status manager"
}
# ------------------------------------------------------------
f_mgr_start () {
ECHO "starting mgr on node ${GGHNODE} on port 7${GGHNODE}09"
${OGG_HOME}/mgr port 7${GGHNODE}09 paramfile ${OGG_PRM}/MGR-${GGHNODE}.prm cd ${GGHOME} reportfile ${OGG_RPT}/MGR-${GGHNODE}.rpt &
}
# ------------------------------------------------------------
f_mgr_stop () {
GGSCI "stop manager !"
}
# ------------------------------------------------------------
f_mgr_kill () {
INPUT 
GGSCI "send manager kill ${input1}"
}
# ------------------------------------------------------------
f_mgr_childs () {
GGSCI "send manager ChildStatus"
}
# ------------------------------------------------------------
f_mgr_ports () {
GGSCI "send manager GetPortInfo Detail"
}
# ------------------------------------------------------------
f_mgr_trails () {
GGSCI "send manager GetPurgeOldExtracts"
}
# ------------------------------------------------------------
