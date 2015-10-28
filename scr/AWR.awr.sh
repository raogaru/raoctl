# ############################################################
# AWR FUNCTIONS (DBMS_WORKLOAD_REPOSITORY)
# ############################################################
# ------------------------------------------------------------
# AWR actions
action_L1="snap list snap_count set_report_thresholds set_snap_settings show_snap_settings drop_snap_range "
action_L2="info report sql_report diff_report diff_sql_report data_extract "
action_L3="add_colored_sql remove_colored_sql sqlid_trend wait_trend stat_trend "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
usage_L=" \
snap,,Create_AWR_SNAPSHOT  \
list,num_days_offset,List_AWR_SNAPSHOTs  \
snap_count,NONE,Count_of_AWR_SNAPSHOTs  \
set_report_thresholds,parameter:value,Set_AWR_Report_Thresholds \
set_snap_settings,parameter:value,Set_AWR_Snapshot_Settings \
show_snap_settings,parameter:value,Show_AWR_Snapshot_Settings \
drop_snap_range,begin_snap:end_snap,Drop_Snapshot_Range \
info,NONE,AWR_Information_Report \
report,being_snap_id:end_snap_id,AWR_Report \
sql_report,being_snap_id:end_snap_id:sql_id,AWR_SQL_Report \
diff_report,being_snap_id:end_snap_id:begin_snap_id2,end_anp_id2,AWR_DIFF_Report \
diff_sql_report,being_snap_id:end_snap_id:begin_snap_id2,end_anp_id2:sql_id,AWR_DIFF_SQL_Report \
add_colored_sql,sql_id,Always_add_sql_to_AWR_Report \
remove_colored_sql,sql_id,Remove_colored_SQL_attribute_on_sqlid \
sqlid_trend,sql_id:duration_days:interval_hours,sqlid_performance_trend  \
wait_trend,wait_event_name:duration_days:interval_hours,wait_event_performance_trend  \
stat_trend,sysstat_name:duration_days:interval_hours,sysstat_event_performance_trend  
"

# ------------------------------------------------------------
AWRREP_p () {
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_workload_repository.${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
AWRREP_f () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "x varchar2(1000);"
SQLLINE "begin"
SQLLINE "x:=dbms_workload_repository.${vLine};"
SQLLINE "dbms_output.put_line('Return value:'||x);"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
AWRREP_common () {
vLine="$*"
SQLLINE "set echo off head off feedback off termout off"
SQLLINE "col dbid new_value v_dbid"
SQLLINE "col instance_number new_value v_inst_num"
SQLLINE "col db_name new_value v_db_name"
SQLLINE "col instance_name new_value v_inst_name"
SQLLINE "select d.dbid, d.name db_name, i.instance_number, i.instance_name from v\$database d, v\$instance i;"
SQLLINE "define dbid         = &v_dbid;"
SQLLINE "define dbid2         = &v_dbid;"
SQLLINE "define db_name      = '&v_db_name';"
SQLLINE "define db_name2      = '&v_db_name';"
SQLLINE "define inst_num     = &v_inst_num;"
SQLLINE "define inst_num2     = &v_inst_num;"
SQLLINE "define inst_name    = '&v_inst_name';"
SQLLINE "define inst_name2    = '&v_inst_name';"
SQLLINE "define report_type  = 'html';"
SQLLINE "define num_days     = 0;"
SQLLINE "@@?/rdbms/admin/${vLine}"
SQLEXEC
}
# ------------------------------------------------------------
f_awr_snap () { 
AWRREP_f "create_snapshot"
}
# ------------------------------------------------------------
f_awr_list () {
input1=${input:=0}
SQLNEWF
SQLLINE "set pagesi 1000 head on feedback on verify off linesi 100 trimspool on"
SQLLINE "col begin_interval_time format a20"
SQLLINE "col end_interval_time format a20"
SQLLINE "col db_startup_time format a25"
SQLLINE "col lvl format 99"
SQLLINE "col ins format 99"
SQLLINE "select snap_id, to_char(begin_interval_time,'YYYY-MM-DD HH24:MI') begin_interval_time, "
SQLLINE "to_char(end_interval_time,'YYYY-MM-DD HH24:MI') end_interval_time, "
#SQLLINE "startup_time db_startup_time,"
SQLLINE "snap_level lvl, instance_number ins"
SQLLINE "from dba_hist_snapshot"
SQLLINE "where trunc(begin_interval_time)=trunc(sysdate)-${input1} order by snap_id ;"
SQLEXEC
}
# ------------------------------------------------------------
f_awr_snap_count () {
SQLNEWF
SQLLINE "set pagesi 1000 head on feedback on verify off linesi 120 trimspool on"
SQLLINE "col cnt format 999"
SQLLINE "col min_begin_time format a25"
SQLLINE "col max_end_time format a25"
SQLLINE "select trunc(begin_interval_time) day, count(1) cnt, min(snap_id) min_snap_id, max(snap_id) max_snap_id,min(begin_interval_time) min_begin_time, max(end_interval_time) max_end_time"
SQLLINE "from dba_hist_snapshot"
SQLLINE "group by trunc(begin_interval_time) order by 1 ;"
SQLEXEC
}
# ------------------------------------------------------------
f_awr_set_report_thresholds () { 
INPUT 2
AWRREP_p "AWR_SET_REPORT_THRESHOLDS(${input1}=>${input2})"
}
# ------------------------------------------------------------
f_awr_set_snap_settings () { 
INPUT 2
AWRREP_p "MODIFY_SNAPSHOT_SETTINGS(${input1}=>${input2})"
}
# ------------------------------------------------------------
f_awr_show_snap_settings () { 
SQLQRY "select topnsql,retention, snap_interval from WRM\$_WR_CONTROL;"
}
# ------------------------------------------------------------
f_awr_drop_snap_range () { 
INPUT 2
AWRREP_p "DROP_SNAPSHOT_RANGE(low_snap_id=>${input1},high_snap_id=>${input2})"
}
# ------------------------------------------------------------
f_awr_info () { 
SQLNEWF
SQLLINE "define report_name  = '${RPT_DIR}/AWR_INFO_${ORACLE_SID}.txt';"
AWRREP_common "awrinfo"
}
# ------------------------------------------------------------
f_awr_report () { 
INPUT 2
SQLNEWF
SQLLINE "define begin_snap   = ${input1};"
SQLLINE "define end_snap     = ${input2};"
SQLLINE "define report_name  = '${RPT_DIR}/AWR_REPORT_${ORACLE_SID}_${input1}_${input2}_$(date +%Y%m%d-%H%M%S).html';"
AWRREP_common "awrrpti"
}
# ------------------------------------------------------------
f_awr_sql_report () { 
INPUT 3
SQLNEWF
SQLLINE "define begin_snap   = ${input1};"
SQLLINE "define end_snap     = ${input2};"
SQLLINE "define sql_id       = '${input3}';"
SQLLINE "define report_name  = '${RPT_DIR}/AWR_SQL_REPORT_${ORACLE_SID}_${input1}_${input2}_$(date +%Y%m%d-%H%M%S).html';"
AWRREP_common "awrsqrpi"
}
# ------------------------------------------------------------
f_awr_diff_report () { 
INPUT 4
SQLNEWF
SQLLINE "define begin_snap   = ${input1};"
SQLLINE "define end_snap     = ${input2};"
SQLLINE "define begin_snap2   = ${input3};"
SQLLINE "define end_snap2     = ${input4};"
SQLLINE "define num_days2   = 0;"
SQLLINE "define report_name  = '${RPT_DIR}/AWR_DIFF_REPORT_${ORACLE_SID}_${input1}_${input2}_$(date +%Y%m%d-%H%M%S).html';"
AWRREP_common "awrddrpi"
}
# ------------------------------------------------------------
f_awr_diff_sql_report () { 
INPUT 5
SQLNEWF
SQLLINE "define begin_snap   = ${input1};"
SQLLINE "define end_snap     = ${input2};"
SQLLINE "define begin_snap2   = ${input3};"
SQLLINE "define end_snap2     = ${input4};"
SQLLINE "define num_days2   = 0;"
SQLLINE "define sql_id       = '${input5}';"
SQLLINE "define report_name  = '${RPT_DIR}/AWR_SQL_DIFF_REPORT_${ORACLE_SID}_${input1}_${input2}_$(date +%Y%m%d-%H%M%S).html';"
AWRREP_common "awrsqrpi"
}
# ------------------------------------------------------------
f_awr_data_extract () { 
INPUT 3
SQLNEWF
SQLLINE "col dbid new_value v_dbid"
SQLLINE "col db_name new_value v_db_name"
SQLLINE "select dbid, name db_name from v\$database;"
SQLLINE "define dbid         = &v_dbid;"
SQLLINE "define num_days   = 0;"
SQLLINE "define db_name      = '&v_db_name';"
SQLLINE "define begin_snap   = ${input1};"
SQLLINE "define end_snap     = ${input2};"
SQLLINE "define directory_name  = '${input3}';"
#SQLLINE "define file_name = 'AWR_DATA_${ORACLE_SID}_${input1}_${input2}_$(date +%Y%m%d%H%M%S)';"
SQLLINE "define file_name = 'AWR_DATA_${ORACLE_SID}_${input1}_${input2}';"
AWRREP_common "awrextr"
}
# ------------------------------------------------------------
f_awr_add_colored_sql () { 
INPUT
AWRREP_p "ADD_COLORED_SQL(sql_id=>'${input}')"
}
# ------------------------------------------------------------
f_awr_remove_colored_sql () { 
INPUT
AWRREP_p "REMOVE_COLORED_SQL(sql_id=>'${input}')"
}
# ------------------------------------------------------------
f_awr_sqlid_trend () { 
INPUT 3
x=$(echo ${input}|sed -e 's/:/ /g')
SQLQRY "@awr_sqlid_trend.sql ${x}"
}
# ------------------------------------------------------------
f_awr_wait_trend () { 
INPUT 3
x=$(echo ${input}|sed -e 's/:/ /g')
SQLQRY "@awr_wait_trend.sql ${x}"
}
# ------------------------------------------------------------
f_awr_stat_trend () { 
INPUT 3
x=$(echo ${input}|sed -e 's/:/ /g')
SQLQRY "@awr_stat_trend.sql ${x}"
}
# ------------------------------------------------------------
