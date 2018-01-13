# ############################################################
# STAT table - DBMS_STATS Index Statistics FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# STAT table actions
action_L1="list list_stattab "
action_L2="gather_2_dict gather_2_stattab gather_2_stattab_as_statid "
action_L3="export export_as_statid import import_statid "
action_L4="delete delete_from_stattab delete_from_stattab_with_statid "
action_L5="restore lock unlock get set "
action_L="$action_L1 $action_L2 $action_L3 $action_L4 $action_L5"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_Stats \
list_stattab,none,List_Stats_from_StatTab  \
gather_2_dict,table_owner:table_name,Gather_into_Dictionary \
gather_2_stattab,table_owner:table_name,Gather_to_StatTab \
gather_2_stattab_as_statid,table_owner:table_name:statid,Gather_to_StatTab_with_StatID \
export,table_owner:table_name,Export_to_StatTab \
export_as_statid,table_owner:table_name:statid,Export_to_StatTab_with_StatID \
import,table_owner:table_name,Import_from_StatsTab \
import_statid,table_owner:table_name:statid,Import_from_StatsTab_with_StatID \
delete_from_dict,table_owner:table_name,Delete_from_Dictionary \
delete_from_stattab,table_owner:table_name,Delete_from_StatTab \
delete_from_stattab_with_statid,table_owner:table_name:statid,Delete_from_StatTab_with_StatID \
restore,table_owner:table_name:as_of_timestamp,Restore_As_Of_Timestamp \
lock,table_owner:table_name,Lock_Statistics \
unlock,table_owner:table_name,Unlock_Statistics \
"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions
INCLIB_c
# ------------------------------------------------------------
f_table_list () {
INPUT 2
SQLQRY "@o_tabstat ${input1} ${input2}"
}
# ------------------------------------------------------------
f_table_list_stattab () {
SQLQRY "select statid, type, count(1) from ${rc_STATTAB_OWNER}.${rc_STATTAB_NAME} group by statid, type order by 1,2;"
}
# ------------------------------------------------------------
f_table_gather_2_dict () {
INPUT 2
STATS_p "gather_table_stats(ownname=>'${input1}',tabname=>'${input2}')"
}
# ------------------------------------------------------------
f_table_gather_2_stattab () {
INPUT 2
STATS_p "gather_table_stats(ownname=>'${input1}',tabname=>'${input2}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_table_gather_2_stattab_as_statid () {
INPUT 3
STATS_p "gather_table_stats(ownname=>'${input1}',tabname=>'${input2}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input3}')"
}
# ------------------------------------------------------------
f_table_export () {
INPUT 2
STATS_p "export_table_stats(ownname=>'${input1}',tabname=>'${input2}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_table_export_as_statid () {
INPUT 3
STATS_p "export_table_stats(ownname=>'${input1}',tabname=>'${input2}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input3}')"
}
# ------------------------------------------------------------
f_table_import () {
INPUT 2
STATS_p "import_table_stats(ownname=>'${input1}',tabname=>'${input2}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',force=>true)"
}
# ------------------------------------------------------------
f_table_import_statid () {
INPUT 3
STATS_p "import_table_stats(ownname=>'${input1}',tabname=>'${input2}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',force=>true,statid=>'${input3}')"
}
# ------------------------------------------------------------
f_table_delete_from_dict () {
INPUT 2
STATS_p "delete_table_stats(ownname=>'${input1}',tabname=>'${input2}')"
}
# ------------------------------------------------------------
f_table_delete_from_stattab () {
INPUT 2
STATS_p "delete_table_stats(ownname=>'${input1}',tabname=>'${input2}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_table_delete_from_stattab_with_statid () {
INPUT 3
STATS_p "delete_table_stats(ownname=>'${input1}',tabname=>'${input2}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input3}')"
}
# ------------------------------------------------------------
f_table_restore () {
INPUT 3
STATS_p "restore_table_stats(ownname=>'${input1}',tabname=>'${input2}',as_of_timestamp=>'${input3}')"
}
# ------------------------------------------------------------
f_table_lock () {
INPUT 2
STATS_p "lock_table_stats(ownname=>'${input1}',tabname=>'${input2}')"
}
# ------------------------------------------------------------
f_table_unlock () {
INPUT 2
STATS_p "unlock_table_stats(ownname=>'${input1}',tabname=>'${input2}')"
}
# ------------------------------------------------------------
f_table_get () {
ERROR "not coded yet"
}
# ------------------------------------------------------------
f_table_set () {
ERROR "not coded yet"
}
# ------------------------------------------------------------
