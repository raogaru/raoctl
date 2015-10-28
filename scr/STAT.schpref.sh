# ############################################################
# STAT schpref - DBMS_STATS Schema Statistics Preferences FUNCTIONS
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
export,none,Export_to_StatTab \
export_as_statid,statid,Export_to_StatTab_with_StatID \
import,none,Import_from_StatsTab \
import_statid,statid,Import_from_StatsTab_with_StatID \
delete,ownname,Delete_from_Dictionary \
set,ownname:pname:pvalue,set_preferences \
"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions
INCLIB_c
# ------------------------------------------------------------
f_schpref_list () {
SQLQRY "select statid, type, count(1) from ${rc_STATTAB_OWNER}.${rc_STATTAB_NAME} where type like '%PREF%' group by statid, type order by 1,2;"
}
# ------------------------------------------------------------
f_schpref_list_stattab () {
SQLQRY "select statid, type, count(1) from ${rc_STATTAB_OWNER}.${rc_STATTAB_NAME} where type like '%PREF%' group by statid, type order by 1,2;"
}
# ------------------------------------------------------------
f_schpref_export () {
INPUT
STATS_p "export_schema_prefs(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',ownname=>'${input1}')"
}
# ------------------------------------------------------------
f_schpref_export_as_statid () {
INPUT 2
STATS_p "export_schema_prefs(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',ownname=>'${input1}',statid=>'${input2}')"
}
# ------------------------------------------------------------
f_schpref_import () {
INPUT
STATS_p "import_schema_prefs(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',ownname=>'${input1}')"
}
# ------------------------------------------------------------
f_schpref_import_statid () {
INPUT 2
STATS_p "import_schema_prefs(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',ownname=>'${input1}',statid=>'${input2}')"
}
# ------------------------------------------------------------
f_schpref_delete () {
INPUT 2
STATS_p "delete_schema_prefs(ownname=>'${input1}',pname=>'${input2}')"
}
# ------------------------------------------------------------
f_schpref_set () {
INPUT 3
STATS_p "set_schema_prefs(ownname=>'{input1}',pname==>'${input2}',pvalue=>'${input3}')"
}
# ------------------------------------------------------------
