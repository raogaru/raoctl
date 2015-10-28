# ############################################################
# STAT diff - DBMS_STATS Statistics Differences Report FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# STAT table actions
action_L1="stattab_statid_2_statid stattab_statid_2_dict "
action_L2="history_time1_2_time2 history_time1_2_dict "
action_L3="pending_2_hist pending_2_dict "
action_L="$action_L1 $action_L2 $action_L3 $action_L4 $action_L5"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
stattab_statid_2_statid,table_owner:table_name:statid1:statid2,diff_table_stats_in_stattab_statid_2_statid \
stattab_statid_2_dict,table_owner:table_name:statid1,diff_table_stats_in_stattab_statid_2_dict \
history_time1_2_time2,table_owner:table_name:time1:time2,diff_table_stats_in_history_time1_2_time2 \
history_time1_2_dict,table_owner:table_name:time1,diff_table_stats_in_history_time1_2_dict \
pending_2_hist,table_owner:table_name:time1,diff_table_stats_in_pending_2_hist \
pending_2_dict,table_owner:table_name,diff_table_stats_in_pending_2_dict \
"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables
rc_STAT_DIFF_PCT_THRESHOLD=${rc_STAT_DIFF_PCT_THRESHOLD:="10"}
t_set="set pagesi 0 linesize 2000 trims on feedback off long 500000 longchunksize 500000"
# ------------------------------------------------------------
# Module specific common functions
INCLIB_c
# ------------------------------------------------------------
DIFF_p () {
vLine="$*"
SQLNEWF
SQLLINE "${t_set}"
SQLLINE "select report, 'Max Diff % = '||maxdiffpct from table(dbms_stats.diff_table_stats_in_${t_diff_type}(ownname=>'${input1}',tabname=>'${input2}',pctthreshold=>${rc_STAT_DIFF_PCT_THRESHOLD=},${vLine}));"
SQLEXEC
}
# ------------------------------------------------------------
f_diff_stattab_statid_2_statid () {
INPUT 4
t_diff_type="stattab"
DIFF_p "statid1=>'${input3}',statid2=>'${input4}',stattab1own=>'${rc_STATTAB_OWNER}',stattab1=>'${rc_STATTAB_NAME}',stattab2own=>'${rc_STATTAB_OWNER}',stattab2=>'${rc_STATTAB_NAME}'"
}
# ------------------------------------------------------------
f_diff_stattab_statid_2_dict () {
INPUT 3
t_diff_type="stattab"
DIFF_p "statid1=>'${input3}',statid2=>null,stattab1own=>'${rc_STATTAB_OWNER}',stattab1=>'${rc_STATTAB_NAME}',stattab2own=>null,stattab2=>null"
}
# ------------------------------------------------------------
f_diff_history_time1_2_time2 () {
INPUT 4
t_diff_type="history"
DIFF_p "time1=>to_timestamp('${input3}','yyyy-mm-dd-hh24-mi-ss'),time2=>to_timestamp('${input4}','yyyy-mm-dd-hh24-mi-ss')"
}
# ------------------------------------------------------------
f_diff_history_time1_2_dict () {
INPUT 3
t_diff_type="history"
DIFF_p "time1=>to_timestamp('${input3}','yyyy-mm-dd-hh24-mi-ss'),time2=>null"
}
# ------------------------------------------------------------
f_diff_pending_2_hist () {
INPUT 3
t_diff_type="pending"
DIFF_p "time_stamp=>to_timestamp('${input3}','yyyy-mm-dd-hh24-mi-ss')"
}
# ------------------------------------------------------------
f_diff_pending_2_dict () {
INPUT 2
t_diff_type="pending"
DIFF_p "time_stamp=>null"
}
# ------------------------------------------------------------
