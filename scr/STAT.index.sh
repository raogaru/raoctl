# ############################################################
# STAT index - DBMS_STATS Index Statistics FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# STAT index actions
action_L1="list list_stattab "
action_L2="gather_2_dict gather_2_stattab gather_2_stattab_as_statid "
action_L3="export export_as_statid import import_statid "
action_L4="delete delete_from_stattab delete_from_stattab_with_statid "
action_L5="restore get set "
action_L="$action_L1 $action_L2 $action_L3 $action_L4 $action_L5"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_Stats \
list_stattab,none,List_Stats_from_StatTab  \
gather_2_dict,index_owner:index_name,Gather_into_Dictionary \
gather_2_stattab,index_owner:index_name,Gather_to_StatTab \
gather_2_stattab_as_statid,index_owner:index_name:statid,Gather_to_StatTab_with_StatID \
export,index_owner:index_name,Export_to_StatTab \
export_as_statid,index_owner:index_name:statid,Export_to_StatTab_with_StatID \
import,index_owner:index_name,Import_from_StatsTab \
import_statid,index_owner:index_name:statid,Import_from_StatsTab_with_StatID \
delete_from_dict,index_owner:index_name,Delete_from_Dictionary \
delete_from_stattab,index_owner:index_name,Delete_from_StatTab \
delete_from_stattab_with_statid,index_owner:index_name:statid,Delete_from_StatTab_with_StatID \
restore,index_owner:index_name:as_of_timestamp,Restore_As_Of_Timestamp \
lock,index_owner:index_name,Lock_Statistics \
unlock,index_owner:index_name,Unlock_Statistics \

"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions
INCLIB_c
# ------------------------------------------------------------
f_index_list_stattab () {
SQLQRY "select statid, type, count(1) from ${rc_STATTAB_OWNER}.${rc_STATTAB_NAME} group by statid, type order by 1,2;"
}
# ------------------------------------------------------------
f_index_gather_2_dict () {
INPUT 2
STATS_p "gather_index_stats(ownname=>'${input1}',indname=>'${input2}')"
}
# ------------------------------------------------------------
f_index_gather_2_stattab () {
INPUT 2
STATS_p "gather_index_stats(ownname=>'${input1}',indname=>'${input2}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_index_gather_2_stattab_as_statid () {
INPUT 3
STATS_p "gather_index_stats(ownname=>'${input1}',indname=>'${input2}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input3}')"
}
# ------------------------------------------------------------
f_index_export () {
INPUT 2
STATS_p "export_index_stats(ownname=>'${input1}',indname=>'${input2}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_index_export_as_statid () {
INPUT 3
STATS_p "export_index_stats(ownname=>'${input1}',indname=>'${input2}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input3}')"
}
# ------------------------------------------------------------
f_index_import () {
INPUT 2
STATS_p "import_index_stats(ownname=>'${input1}',indname=>'${input2}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',force=>true)"
}
# ------------------------------------------------------------
f_index_import_statid () {
INPUT 3
STATS_p "import_index_stats(ownname=>'${input1}',indname=>'${input2}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',force=>true,statid=>'${input3}')"
}
# ------------------------------------------------------------
f_index_delete_from_dict () {
INPUT 2
STATS_p "delete_index_stats(ownname=>'${input1}',indname=>'${input2}')"
}
# ------------------------------------------------------------
f_index_delete_from_stattab () {
INPUT 2
STATS_p "delete_index_stats(ownname=>'${input1}',indname=>'${input2}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_index_delete_from_stattab_with_statid () {
INPUT 3
STATS_p "delete_index_stats(ownname=>'${input1}',indname=>'${input2}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input3}')"
}
# ------------------------------------------------------------
f_index_get () {
ERROR "not coded yet"
}
# ------------------------------------------------------------
f_index_set () {
ERROR "not coded yet"
}
# ------------------------------------------------------------
