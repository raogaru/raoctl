# ############################################################
# STAT stattab - DBMS_STATS Statistics Staging Table FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# STAT stattab actions
action_L1="list create drop upgrade "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
create,ownname,Create_Statistics_Staging_Table \
drop,none,Drop_Statistics_Staging_Table \
upgrade,none,Upgrade_Statistics_Staging_Table \
list,none,List_Staging_Table \
"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions
INCLIB_c
# ------------------------------------------------------------
f_stattab_list () {
SQLQRY "select statid, type, count(1) from ${rc_STATTAB_OWNER}.${rc_STATTAB_NAME} group by statid, type order by 1,2;"
}
# ------------------------------------------------------------
f_stattab_create () {
STATS_p "create_stat_table(ownname=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}',tblspace=>'SYSTEM')"
}
# ------------------------------------------------------------
f_stattab_drop () {
STATS_p "drop_stat_table(ownname=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_stattab_upgrade () {
STATS_p "upgrade_stat_table(ownname=>'${rc_STATTAB_OWNER}',stattab=>'${rc_STATTAB_NAME}')"
}
# ------------------------------------------------------------
f_stattab_list () {
SQLQRY "select owner, table_name from dba_tables where table_name='${rc_STATTAB_NAME}';"
}
# ------------------------------------------------------------
