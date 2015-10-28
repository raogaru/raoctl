# ############################################################
# STAT system - DBMS_STATS Operating System Statistics FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# STAT system actions
action_L1="list list_stattab "
action_L2="gather_2_dict gather_2_stattab gather_2_stattab_as_statid "
action_L3="export export_as_statid import import_statid "
action_L4="delete delete_from_stattab delete_from_stattab_with_statid "
action_L5="restore get_from_dict get_from_stattab get_from_stattab_with_statid set_in_dict set_in_stattab set_in_stattab_with_statid "
action_L="$action_L1 $action_L2 $action_L3 $action_L4 $action_L5"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_Stats \
list_stattab,none,List_Stats_from_StatTab  \
gather_2_dict,none,Gather_into_Dictionary \
gather_2_stattab,none,Gather_to_StatTab \
gather_2_stattab_as_statid,statid,Gather_to_StatTab_with_StatID \
export,none,Export_to_StatTab \
export_as_statid,statid,Export_to_StatTab_with_StatID \
import,none,Import_from_StatsTab \
import_statid,statid,Import_from_StatsTab_with_StatID \
delete_from_dict,none,Delete_from_Dictionary \
delete_from_stattab,none,Delete_from_StatTab \
delete_from_stattab_with_statid,statid,Delete_from_StatTab_with_StatID \
restore,as_of_timestamp,Restore_As_Of_Timestamp \
get_from_dict,pname,Get_Stat_from_Dicttionary \
get_from_stattab,pname,Get_Stat_from_StatTab \
get_from_stattab_with_statid,pname,Get_Stat_from_StatTab_with_StatID \
set_in_dict,pname:pvalue,Set_Stat_in_Dicttionary \
set_in_stattab,pname:pvalue,Set_Stat_in_StatTab \
set_in_stattab_with_statid,pname:pvalue,Set_Stat_in_StatTab_with_StatID \
"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions
INCLIB_c
# ------------------------------------------------------------
f_system_list_stattab () {
SQLQRY "select statid, type, count(1) from ${rc_STATTAB_OWNER}.${rc_STATTAB_NAME} group by statid, type order by 1,2;"
}
# ------------------------------------------------------------
f_system_gather_2_dict () {
STATS_p "gather_system_stats(gathering_mode=>'NOWORKLOAD',interval=>20)"
}
# ------------------------------------------------------------
f_system_gather_2_stattab () {
STATS_p "gather_system_stats(gathering_mode=>'NOWORKLOAD',interval=>20,statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_system_gather_2_stattab_as_statid () {
INPUT
STATS_p "gather_system_stats(gathering_mode=>'NOWORKLOAD',interval=>2,statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input1}')"
}
# ------------------------------------------------------------
f_system_export () {
STATS_p "export_system_stats(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_system_export_as_statid () {
INPUT
STATS_p "export_system_stats(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input1}')"
}
# ------------------------------------------------------------
f_system_import () {
STATS_p "import_system_stats(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',force=>true)"
}
# ------------------------------------------------------------
f_system_import_statid () {
INPUT
STATS_p "import_system_stats(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',force=>true,statid=>'${input1}')"
}
# ------------------------------------------------------------
f_system_delete_from_dict () {
STATS_p "delete_system_stats"
}
# ------------------------------------------------------------
f_system_delete_from_stattab () {
STATS_p "delete_system_stats(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_system_delete_from_stattab_with_statid () {
INPUT
STATS_p "delete_system_stats(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input1}')"
}
# ------------------------------------------------------------
f_system_restore () {
STATS_p "restore_system_stats(as_of_timestamp=>'${input1}')"
}
# ------------------------------------------------------------
f_system_get_from_dict () {
ECHO "not coded yet"
}
# ------------------------------------------------------------
f_system_get_from_stattab () {
ECHO "not coded yet"
}
# ------------------------------------------------------------
f_system_get_from_stattab_with_statid () {
ECHO "not coded yet"
}
# ------------------------------------------------------------
f_system_set_in_dict () {
INPUT
STATS_p "set_system_stats(pname=>'${input1}',pvalue=>'${input2}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input3}')"
}
# ------------------------------------------------------------
f_system_set_in_stattab () {
INPUT 2
STATS_p "set_system_stats(pname=>'${input1}',pvalue=>'${input2}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_system_set_in_stattab_with_statid () {
INPUT 3
STATS_p "set_system_stats(pname=>'${input1}',pvalue=>'${input2}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input3}')"
}
# ------------------------------------------------------------
