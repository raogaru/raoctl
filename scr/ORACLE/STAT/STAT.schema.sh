# ############################################################
# STAT schema - DBMS_STATS Schema Statistics FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# STAT schema actions
action_L1="list list_stattab "
action_L2="gather_2_dict gather_2_stattab gather_2_stattab_as_statid "
action_L3="export export_as_statid import import_statid "
action_L4="delete delete_from_stattab delete_from_stattab_with_statid "
action_L5="restore lock unlock"
action_L="$action_L1 $action_L2 $action_L3 $action_L4 $action_L5"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_Stats \
list_stattab,none,List_Stats_from_StatTab  \
gather_2_dict,schema_name,Gather_into_Dictionary \
gather_2_stattab,schema_name,Gather_to_StatTab \
gather_2_stattab_as_statid,schema_name:statid,Gather_to_StatTab_with_StatID \
export,schema_name,Export_to_StatTab \
export_as_statid,schema_name:statid,Export_to_StatTab_with_StatID \
import,schema_name,Import_from_StatsTab \
import_statid,schema_name:statid,Import_from_StatsTab_with_StatID \
delete_from_dict,schema_name,Delete_from_Dictionary \
delete_from_stattab,schema_name,Delete_from_StatTab \
delete_from_stattab_with_statid,schema_name:statid,Delete_from_StatTab_with_StatID \
restore,schema_name:as_of_timestamp,Restore_As_Of_Timestamp \
lock,schema_name,Lock_Statistics \
unlock,schema_name,Unlock_Statistics \

"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions
INCLIB_c
# ------------------------------------------------------------
f_schema_list_stattab () {
SQLQRY "select statid, type, count(1) from ${rc_STATTAB_OWNER}.${rc_STATTAB_NAME} group by statid, type order by 1,2;"
}
# ------------------------------------------------------------
f_schema_gather_2_dict () {
INPUT
STATS_p "gather_schema_stats(ownname=>'${input1}')"
}
# ------------------------------------------------------------
f_schema_gather_2_stattab () {
INPUT
STATS_p "gather_schema_stats(ownname=>'${input1}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_schema_gather_2_stattab_as_statid () {
INPUT 2
STATS_p "gather_schema_stats(ownname=>'${input1}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input2}')"
}
# ------------------------------------------------------------
f_schema_export () {
INPUT
STATS_p "export_schema_stats(ownname=>'${input1}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_schema_export_as_statid () {
INPUT 2
STATS_p "export_schema_stats(ownname=>'${input1}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input2}')"
}
# ------------------------------------------------------------
f_schema_import () {
INPUT
STATS_p "import_schema_stats(ownname=>'${input1}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',force=>true)"
}
# ------------------------------------------------------------
f_schema_import_statid () {
INPUT 2
STATS_p "import_schema_stats(ownname=>'${input1}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',force=>true,statid=>'${input2}')"
}
# ------------------------------------------------------------
f_schema_delete_from_dict () {
INPUT
STATS_p "delete_schema_stats(ownname=>'${input1}')"
}
# ------------------------------------------------------------
f_schema_delete_from_stattab () {
INPUT
STATS_p "delete_schema_stats(ownname=>'${input1}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_schema_delete_from_stattab_with_statid () {
INPUT 2
STATS_p "delete_schema_stats(ownname=>'${input1}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input2}')"
}
# ------------------------------------------------------------
f_schema_restore () {
INPUT 2
STATS_p "restore_schema_stats(ownname=>'${input1}',as_of_timestamp=>'${input2}')"
}
# ------------------------------------------------------------
f_schema_lock () {
INPUT
STATS_p "lock_schema_stats(ownname=>'${input1}')"
}
# ------------------------------------------------------------
f_schema_unlock () {
INPUT
STATS_p "unlock_schema_stats(ownname=>'${input1}')"
}
# ------------------------------------------------------------
