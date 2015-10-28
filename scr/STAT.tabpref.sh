# ############################################################
# STAT tabpref - DBMS_STATS TAble Statistics Preferences FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# STAT Preferences actions
action_L1="list list_stattab "
action_L2="export export_as_statid import import_statid "
action_L3="delete set "
action_L="$action_L1 $action_L2 $action_L3 "
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_Stats \
list_stattab,none,List_Stats_from_StatTab  \
export,ownname:tabname,Export_to_StatTab \
export_as_statid,ownname:tabname:statid,Export_to_StatTab_with_StatID \
import,ownname:tabname,Import_from_StatsTab \
import_statid,ownname:tabname:statid,Import_from_StatsTab_with_StatID \
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
f_tabpref_list () {
SQLQRY "select statid, type, count(1) from ${rc_STATTAB_OWNER}.${rc_STATTAB_NAME} where type like '%PREF%' group by statid, type order by 1,2;"
}
# ------------------------------------------------------------
f_tabpref_list_stattab () {
SQLQRY "select statid, type, count(1) from ${rc_STATTAB_OWNER}.${rc_STATTAB_NAME} where type like '%PREF%' group by statid, type order by 1,2;"
}
# ------------------------------------------------------------
f_tabpref_export () {
INPUT 2
STATS_p "export_table_prefs(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',ownname=>'${input1}',tabname=>'${input2}')"
}
# ------------------------------------------------------------
f_tabpref_export_as_statid () {
INPUT 3
STATS_p "export_table_prefs(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input3}',ownname=>'${input2}',tabname=>'${input3}')"
}
# ------------------------------------------------------------
f_tabpref_import () {
INPUT 2
STATS_p "import_table_prefs(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',ownname=>'${input1}',tabname=>'${input2}')"
}
# ------------------------------------------------------------
f_tabpref_import_statid () {
INPUT 3
STATS_p "import_table_prefs(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',ownname=>'${input1}',tabname=>'${input2}',statid=>'${input3}')"
}
# ------------------------------------------------------------
f_tabpref_delete () {
INPUT 3
STATS_p "delete_table_prefs(ownname=>'${input1}',tabname=>'${input2}',pname=>'${input3}')"
}
# ------------------------------------------------------------
f_tabpref_set () {
INPUT 4
STATS_p "set_table_prefs(ownname=>'${input1}',tabname=>'${input2}',pname==>'${input3}',pvalue=>'${input4}')"
}
# ------------------------------------------------------------
