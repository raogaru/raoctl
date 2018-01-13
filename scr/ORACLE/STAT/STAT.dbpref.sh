# ############################################################
# STAT dbpref - DBMS_STATS Database Statistics Preferences FUNCTIONS
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
delete,none,Delete_from_Dictionary \
set,pname:pvalue,set_DB_stat_preferences \
"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions
INCLIB_c
# ------------------------------------------------------------
f_dbpref_list () {
SQLQRY "select statid, type, count(1) from ${rc_STATTAB_OWNER}.${rc_STATTAB_NAME} where type like '%PREF%' group by statid, type order by 1,2;"
}
# ------------------------------------------------------------
f_dbpref_list_stattab () {
SQLQRY "select statid, type, count(1) from ${rc_STATTAB_OWNER}.${rc_STATTAB_NAME} where type like '%PREF%' group by statid, type order by 1,2;"
}
# ------------------------------------------------------------
f_dbpref_export () {
STATS_p "export_database_prefs(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',add_sys=>true)"
}
# ------------------------------------------------------------
f_dbpref_export_as_statid () {
INPUT
STATS_p "export_database_prefs(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input1}',add_sys=>true)"
}
# ------------------------------------------------------------
f_dbpref_import () {
STATS_p "import_database_prefs(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',force=>false)"
}
# ------------------------------------------------------------
f_dbpref_import_statid () {
INPUT
STATS_p "import_database_prefs(statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',force=>false,statid=>'${input1}')"
}
# ------------------------------------------------------------
f_dbpref_delete () {
INPUT
STATS_p "delete_database_prefs(pname=>'${input1}')"
}
# ------------------------------------------------------------
f_dbpref_set () {
INPUT 2
STATS_p "set_database_prefs(pname==>'${input1}',pvalue=>'${input2}')"
}
# ------------------------------------------------------------
