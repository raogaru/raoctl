# ############################################################
# DBMS_SCHEDULER SCHEDULES FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# schedule actions
action_L1="list create drop create_few "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,NONE,List_windows
"
# ------------------------------------------------------------
# local variables
v_debug=0
# ------------------------------------------------------------
INCLIB_c
# ------------------------------------------------------------
f_schedule_list () { 
SQLQRY "select schedule_name, substr(repeat_interval,1,60) from DBA_SCHEDULER_SCHEDULES;"
}
# ------------------------------------------------------------
f_schedule_create () { 
INPUT 2
SCHEDULER_p "create_schedule(schedule_name=>'${input1}', repeat_interval=>'${input2}')"
}
# ------------------------------------------------------------
f_schedule_drop () { 
INPUT
SCHEDULER_p "drop_schedule(schedule_name=>'${input1}')"
}
# ------------------------------------------------------------
f_schedule_create_few () { 
SCHEDULER_p "create_schedule(schedule_name=>'EVERY1SEC', repeat_interval=>'FREQ=SECONDLY;INTERVAL=1')"
SCHEDULER_p "create_schedule(schedule_name=>'EVERY5SEC', repeat_interval=>'FREQ=SECONDLY;INTERVAL=5')"
SCHEDULER_p "create_schedule(schedule_name=>'EVERY10SEC', repeat_interval=>'FREQ=SECONDLY;INTERVAL=10')"
SCHEDULER_p "create_schedule(schedule_name=>'EVERY15SEC', repeat_interval=>'FREQ=SECONDLY;INTERVAL=15')"
SCHEDULER_p "create_schedule(schedule_name=>'EVERY30SEC', repeat_interval=>'FREQ=SECONDLY;INTERVAL=30')"

SCHEDULER_p "create_schedule(schedule_name=>'EVERY1MIN', repeat_interval=>'FREQ=MINUTELY;INTERVAL=1')"
SCHEDULER_p "create_schedule(schedule_name=>'EVERY5MIN', repeat_interval=>'FREQ=MINUTELY;INTERVAL=5')"
SCHEDULER_p "create_schedule(schedule_name=>'EVERY10MIN', repeat_interval=>'FREQ=MINUTELY;INTERVAL=10')"
SCHEDULER_p "create_schedule(schedule_name=>'EVERY15MIN', repeat_interval=>'FREQ=MINUTELY;INTERVAL=15')"
SCHEDULER_p "create_schedule(schedule_name=>'EVERY30MIN', repeat_interval=>'FREQ=MINUTELY;INTERVAL=30')"

SCHEDULER_p "create_schedule(schedule_name=>'EVERY1HOUR', repeat_interval=>'FREQ=HOURLY;INTERVAL=1')"
SCHEDULER_p "create_schedule(schedule_name=>'EVERY4HOUR', repeat_interval=>'FREQ=HOURLY;INTERVAL=4')"
SCHEDULER_p "create_schedule(schedule_name=>'EVERY12HOUR', repeat_interval=>'FREQ=HOURLY;INTERVAL=12')"
}
# ------------------------------------------------------------
