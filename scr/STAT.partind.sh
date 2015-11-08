# ############################################################
# STAT partition index - DBMS_STATS Index Statistics FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# STAT partition index actions
action_L1="list list_stattab "
action_L2="gather_2_dict gather_2_stattab gather_2_stattab_as_statid "
action_L3="export export_as_statid import import_statid "
action_L4="delete delete_from_stattab delete_from_stattab_with_statid "
action_L5="get set "
action_L="$action_L1 $action_L2 $action_L3 $action_L4 $action_L5"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_Stats \
list_stattab,none,List_Stats_from_StatTab  \
gather_2_dict,index_owner:index_name:partition_name,Gather_into_Dictionary \
gather_2_stattab,index_owner:index_name:partition_name,Gather_to_StatTab \
gather_2_stattab_as_statid,index_owner:index_name:partition_name:statid,Gather_to_StatTab_with_StatID \
export,index_owner:index_name:partition_name,Export_to_StatTab \
export_as_statid,index_owner:index_name:partition_name:statid,Export_to_StatTab_with_StatID \
import,index_owner:index_name:partition_name,Import_from_StatsTab \
import_statid,index_owner:index_name:partition_name:statid,Import_from_StatsTab_with_StatID \
delete_from_dict,index_owner:index_name:partition_name,Delete_from_Dictionary \
delete_from_stattab,index_owner:index_name:partition_name,Delete_from_StatTab \
delete_from_stattab_with_statid,index_owner:index_name:partition_name:statid,Delete_from_StatTab_with_StatID \
lock,index_owner:index_name:partition_name,Lock_Statistics \
unlock,index_owner:index_name:partition_name,Unlock_Statistics \
"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions
INCLIB_c
# ------------------------------------------------------------
f_partind_list_stattab () {
SQLQRY "select statid, type, count(1) from ${rc_STATTAB_OWNER}.${rc_STATTAB_NAME} group by statid, type order by 1,2;"
}
# ------------------------------------------------------------
f_partind_gather_2_dict () {
INPUT 3
STATS_p "gather_index_stats(ownname=>'${input1}',indname=>'${input2}',partname=>'${input3}')"
}
# ------------------------------------------------------------
f_partind_gather_2_stattab () {
INPUT 3
STATS_p "gather_index_stats(ownname=>'${input1}',indname=>'${input2}',partname=>'${input3}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_partind_gather_2_stattab_as_statid () {
INPUT 4
STATS_p "gather_index_stats(ownname=>'${input1}',indname=>'${input2}',partname=>'${input3}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input4}')"
}
# ------------------------------------------------------------
f_partind_export () {
INPUT 3
STATS_p "export_index_stats(ownname=>'${input1}',indname=>'${input2}',partname=>'${input3}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_partind_export_as_statid () {
INPUT 4
STATS_p "export_index_stats(ownname=>'${input1}',indname=>'${input2}',partname=>'${input3}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input4}')"
}
# ------------------------------------------------------------
f_partind_import () {
INPUT 3
STATS_p "import_index_stats(ownname=>'${input1}',indname=>'${input2}',partname=>'${input3}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',force=>true)"
}
# ------------------------------------------------------------
f_partind_import_statid () {
INPUT 4
STATS_p "import_index_stats(ownname=>'${input1}',indname=>'${input2}',partname=>'${input3}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',force=>true,statid=>'${input4}')"
}
# ------------------------------------------------------------
f_partind_delete_from_dict () {
INPUT 3
STATS_p "delete_index_stats(ownname=>'${input1}',indname=>'${input2}',partname=>'${input3}')"
}
# ------------------------------------------------------------
f_partind_delete_from_stattab () {
INPUT 3
STATS_p "delete_index_stats(ownname=>'${input1}',indname=>'${input2}',partname=>'${input3}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_partind_delete_from_stattab_with_statid () {
INPUT 4
STATS_p "delete_index_stats(ownname=>'${input1}',indname=>'${input2}',partname=>'${input3}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input4}')"
}
# ------------------------------------------------------------
f_partind_get () {
ERROR "not coded yet"
}
# ------------------------------------------------------------
f_partind_set () {
ERROR "not coded yet"
}
# ------------------------------------------------------------
