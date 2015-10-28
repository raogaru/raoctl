# ############################################################
# STAT column - DBMS_STATS Column Statistics FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# STAT table actions
action_L1="list list_stattab "
action_L2="export export_as_statid import import_statid "
action_L3="delete delete_from_stattab delete_from_stattab_with_statid "
action_L4="get set "
action_L="$action_L1 $action_L2 $action_L3 $action_L4 "
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_Stats \
list_stattab,none,List_Stats_from_StatTab  \
export,table_owner:table_name:column_name,Export_to_StatTab \
export_as_statid,table_owner:table_name:column_name:statid,Export_to_StatTab_with_StatID \
import,table_owner:table_name:column_name,Import_from_StatsTab \
import_statid,table_owner:table_name:column_name:statid,Import_from_StatsTab_with_StatID \
delete_from_dict,table_owner:table_name:column_name,Delete_from_Dictionary \
delete_from_stattab,table_owner:table_name:column_name,Delete_from_StatTab \
delete_from_stattab_with_statid,table_owner:table_name:column_name:statid,Delete_from_StatTab_with_StatID \
get,table_owner:table_name:column_name,Get_Column_Stats \
set,table_owner:table_name:column_name,Set_Column_Stats \
"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions
INCLIB_c
# ------------------------------------------------------------
f_column_list () {
INPUT 2
SQLQRY "@o_tabcolstat ${input1} ${input2}"
}
# ------------------------------------------------------------
f_column_list_stattab () {
SQLQRY ""
}
# ------------------------------------------------------------
f_column_gather_2_stattab_as_statid () {
INPUT 3
STATS_p "gather_column_stats(ownname=>'${input1}',tabname=>'${input2}',colname=>'${input3}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input3}')"
}
# ------------------------------------------------------------
f_column_export () {
INPUT 3
STATS_p "export_column_stats(ownname=>'${input1}',tabname=>'${input2}',colname=>'${input3}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_column_export_as_statid () {
INPUT 4
STATS_p "export_column_stats(ownname=>'${input1}',tabname=>'${input2}',colname=>'${input3}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input4}')"
}
# ------------------------------------------------------------
f_column_import () {
INPUT 3
STATS_p "import_column_stats(ownname=>'${input1}',tabname=>'${input2}',colname=>'${input3}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',force=>true)"
}
# ------------------------------------------------------------
f_column_import_statid () {
INPUT 4
STATS_p "import_column_stats(ownname=>'${input1}',tabname=>'${input2}',colname=>'${input3}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',force=>true,statid=>'${input4}')"
}
# ------------------------------------------------------------
f_column_delete_from_dict () {
INPUT 3
STATS_p "delete_column_stats(ownname=>'${input1}',tabname=>'${input2}',colname=>'${input3}')"
}
# ------------------------------------------------------------
f_column_delete_from_stattab () {
INPUT 3
STATS_p "delete_column_stats(ownname=>'${input1}',tabname=>'${input2}',colname=>'${input3}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_column_delete_from_stattab_with_statid () {
INPUT 4
STATS_p "delete_column_stats(ownname=>'${input1}',tabname=>'${input2}',colname=>'${input3}',statown=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',statid=>'${input4}')"
}
# ------------------------------------------------------------
f_column_get () {
ERROR "not coded yet"
}
# ------------------------------------------------------------
f_column_set () {
ERROR "not coded yet"
}
# ------------------------------------------------------------
