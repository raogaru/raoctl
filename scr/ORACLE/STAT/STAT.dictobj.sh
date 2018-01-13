# ############################################################
# STAT dictobj - DBMS_STATS Dictionary Object Statistics FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# STAT dictobj actions
action_L1="list list_stattab "
action_L2="gather_2_dict gather_2_stattab gather_2_stattab_as_statid "
action_L3="export export_as_statid import import_statid "
action_L4="delete delete_from_stattab delete_from_stattab_with_statid "
action_L5="restore "
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
"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions
INCLIB_c
# ------------------------------------------------------------
f_dictobj_list () {
SQLQRY "select s.* from dba_tab_statistics s where owner='SYS';"
}
# ------------------------------------------------------------
f_dictobj_list_stattab () {
SQLQRY "select statid, type, count(1) from ${rc_STATTAB_OWNER}.${rc_STATTAB_NAME} group by statid, type order by 1,2;"
}
# ------------------------------------------------------------
f_dictobj_gather_2_dict () {
STATS_p "gather_dictionary_stats"
}
# ------------------------------------------------------------
f_dictobj_gather_2_stattab () {
STATS_p "gather_dictionary_stats(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_dictobj_gather_2_stattab_as_statid () {
INPUT
STATS_p "gather_dictionary_stats(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input1}')"
}
# ------------------------------------------------------------
f_dictobj_export () {
STATS_p "export_dictionary_stats(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_dictobj_export_as_statid () {
INPUT
STATS_p "export_dictionary_stats(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input1}')"
}
# ------------------------------------------------------------
f_dictobj_import () {
STATS_p "import_dictionary_stats(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',force=>true)"
}
# ------------------------------------------------------------
f_dictobj_import_statid () {
INPUT
STATS_p "import_dictionary_stats(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',force=>true,statid=>'${input1}')"
}
# ------------------------------------------------------------
f_dictobj_delete_from_dict () {
STATS_p "delete_dictionary_stats"
}
# ------------------------------------------------------------
f_dictobj_delete_from_stattab () {
STATS_p "delete_dictionary_stats(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_dictobj_delete_from_stattab_with_statid () {
INPUT
STATS_p "delete_dictionary_stats(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input1}')"
}
# ------------------------------------------------------------
f_dictobj_restore () {
STATS_p "restore_dictionary_stats(as_of_timestamp=>'${input1}')"
}
# ------------------------------------------------------------
