# ############################################################
# AWR BASELINE FUNCTIONS (DBMS_WORKLOAD_REPOSITORY)
# ############################################################
# ------------------------------------------------------------
# AWR actions
action_L1="list_baseline create_baseline rename_baseline drop_baseline "
action_L2="list_baseline_template create_baseline_template drop_baseline_template "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
usage_L=" \
list_baseline,,List_AWR_Baselines \
create_baseline,baseline_name:begin_snap_id:end_snap_id,Create_AWR_Baseline \
rename_baseline,old_baseline_name:new_baseline_name,Rename_AWR_Baseline \
drop_baseline,baseline_name,Drop_AWR_Baseline  \
list_baseline_template,none,List_AWR_Baseline_Templates \
create_baseline_template,template_name:day_of_week:hour_in_day:duration_hours:expiration_days,Create_AWR_Baseline_Template \
drop_baseline_template,template_name,Drop_AWR_Baseline_Template 
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
f_awrbl_list_baseline () { 
SQLNEWF
SQLLINE "set pagesi 1000 head on feedback on verify off linesi 120 trimspool on"
SQLLINE "col baseline_name format a20"
SQLLINE "col start_snap_time format a20"
SQLLINE "col end_snap_time format a20"
SQLLINE "select baseline_id id, baseline_name, baseline_type, start_snap_id bid, end_snap_id eid,"
SQLLINE "to_char(start_snap_time,'YYYY-MM-DD HH24:MI') start_snap_time, "
SQLLINE "to_char(end_snap_time,'YYYY-MM-DD HH24:MI') end_snap_time, moving_window_size window"
SQLLINE "from dba_hist_baseline order  by baseline_id;"
SQLEXEC
}
# ------------------------------------------------------------
f_awrbl_create_baseline () { 
INPUT 3
AWRREP_f "create_baseline(baseline_name=>'${input1}',start_snap_id=>'${input2}',end_snap_id=>'${input3}')"
}
# ------------------------------------------------------------
f_awrbl_rename_baseline () { 
INPUT 2
AWRREP_p "rename_baseline(old_baseline_name=>'${input1}',new_baseline_name=>'${input2}')"
}
# ------------------------------------------------------------
f_awrbl_drop_baseline () { 
INPUT
AWRREP_p "drop_baseline(baseline_name=>'${input1}',cascade=>FALSE)"
}
# ------------------------------------------------------------
f_awrbl_list_baseline_template () { 
SQLQRY "select template_id, template_type, template_name, start_time, end_time, day_of_week, hour_in_day, duration, expiration, repeat_interval, last_generated from DBA_HIST_BASELINE_TEMPLATE;"
}
# ------------------------------------------------------------
f_awrbl_create_baseline_template () { 
INPUT 5
AWRREP_p "create_baseline_template(template_name=>upper('${input1}'),baseline_name_prefix=>upper('${input1}'),day_of_week=>upper('${input2}'), hour_in_day=>${input3}, duration=>${input4}, start_time=>sysdate, end_time=>sysdate+10000, expiration=>${input5})"
}
# ------------------------------------------------------------
f_awrbl_drop_baseline_template () { 
INPUT
AWRREP_p "drop_baseline_template(template_name=>upper('${input1}'))"
}
# ------------------------------------------------------------
