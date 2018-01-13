# ############################################################
# STAT pending - DBMS_STATS Table Pending Statistics FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# STAT Preferences actions
action_L1="list list_stattab "
action_L2="export export_as_statid "
action_L3="delete "
action_L="$action_L1 $action_L2 $action_L3 "
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_Stats \
list_stattab,none,List_Stats_from_StatTab  \
export,ownname:tabname,Export_to_StatTab \
export_as_statid,ownname:tabname:statid,Export_to_StatTab_with_StatID \
delete,ownname:tabname:pname,Delete_from_Dictionary \
set,ownname:tabname:pname:pvalue,set_preferences \
"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions
INCLIB_c
# ------------------------------------------------------------
f_pending_list () {
SQLQRY "select statid, type, count(1) from ${rc_STATTAB_OWNER}.${rc_STATTAB_NAME} where type like 'PENDING' group by statid, type order by 1,2;"
}
# ------------------------------------------------------------
f_pending_list_stattab () {
SQLQRY "select statid, type, count(1) from ${rc_STATTAB_OWNER}.${rc_STATTAB_NAME} where type like 'PENDING' group by statid, type order by 1,2;"
}
# ------------------------------------------------------------
f_pending_export () {
INPUT 2
STATS_p "export_pending_stats(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',ownname=>'${input1}',tabname=>'${input2}')"
}
# ------------------------------------------------------------
f_pending_export_as_statid () {
INPUT 3
STATS_p "export_pending_stats(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',ownname=>'${input2}',tabname=>'${input3}',statid=>'${input3}')"
}
# ------------------------------------------------------------
f_pending_publish () {
INPUT 2
STATS_p "publish_pending_stats(ownname=>'${input1}',tabname=>'${input2}',force=>true)"
}
# ------------------------------------------------------------
f_pending_delete () {
INPUT 3
STATS_p "delete_pending_stats(ownname=>'${input1}',tabname=>'${input2}')"
}
# ------------------------------------------------------------
