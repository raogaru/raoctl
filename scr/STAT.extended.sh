# ############################################################
# STAT extended - DBMS_STATS Table Extended Statistics FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# STAT Preferences actions
action_L1="list "
action_L2="create drop "
action_L3="show "
action_L="$action_L1 $action_L2 $action_L3 "
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_Stats \
create,ownname:tabname:extension,create_stats \
drop,ownname:tabname:extension,drop_stats \
show,ownname:tabname:extension,show_stats_name \
"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions
INCLIB_c
# ------------------------------------------------------------
f_extended_list () {
SQLQRY "select statid, type, count(1) from ${rc_STATTAB_OWNER}.${rc_STATTAB_NAME} where type like 'EXTENDED' group by statid, type order by 1,2;"
}
# ------------------------------------------------------------
f_extended_create () {
INPUT 3
STATS_p "create_extended_stats(ownname=>'${input1}',tabname=>'${input2}',extension=>'${input3}')"
}
# ------------------------------------------------------------
f_extended_drop () {
INPUT 3
STATS_p "drop_extended_stats(ownname=>'${input1}',tabname=>'${input2}',extension=>'${input3}')"
}
# ------------------------------------------------------------
f_extended_show () {
INPUT 3
STATS_f "show_extended_stats_name(ownname=>'${input1}',tabname=>'${input2}',extension=>'${input3}')"
}
# ------------------------------------------------------------
