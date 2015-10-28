# ############################################################
# SMS - Activity Simulation functions for Oracle Real Application Testing (RAT)
# ############################################################
# ------------------------------------------------------------
# SMS RAT actions
action_L1="list create drop run stop disable enable "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
add,id:name,Add_new_user \
"
# ------------------------------------------------------------
# local variables
v_debug=0
# ------------------------------------------------------------
INCLIB_c
# ------------------------------------------------------------
SMSJOB_CREATE () { 
SMS_q "exec DBMS_SCHEDULER.create_job ( job_name=> upper('JOB_SMS_${1}'), job_type=> 'STORED_PROCEDURE', job_action=> 'SMS.SMSPKG.${1}', schedule_name=> 'SYS.${2}', enabled=> TRUE, comments=> 'SMS Simulation Job');"
}
# ------------------------------------------------------------
SMSJOB_DROP () { 
SMS_q "exec DBMS_SCHEDULER.drop_job (job_name=> upper('JOB_SMS_${1}'), force=>TRUE);"
}
# ------------------------------------------------------------
SMSJOB_RUN () { 
SMS_q "exec DBMS_SCHEDULER.run_job (job_name=> upper('JOB_SMS_${1}'));"
}
# ------------------------------------------------------------
SMSJOB_STOP () { 
SMS_q "exec DBMS_SCHEDULER.stop_job (job_name=> upper('JOB_SMS_${1}'));"
}
# ------------------------------------------------------------
SMSJOB_DISABLE () { 
SMS_q "exec DBMS_SCHEDULER.disable (name=> upper('JOB_SMS_${1}'));"
}
# ------------------------------------------------------------
SMSJOB_ENABLE () { 
SMS_q "exec DBMS_SCHEDULER.enable (name=> upper('JOB_SMS_${1}'));"
}
# ------------------------------------------------------------
f_sim_list () { 
SQLQRY "select job_name,substr(schedule_name,1,30) schedule_name,enabled from DBA_SCHEDULER_JOBS where job_name like 'JOB_SMS%';"
}
# ------------------------------------------------------------
SMSJOB_all () { 
for x in sim_usr_add sim_usr_activate sim_usr_suspend sim_usr_delete sim_ctc_add sim_ctc_accept sim_ctc_suspend sim_ctc_delete sim_ctc_change_keys sim_msg_send 
do
SMSJOB_${1} $x
done
}
# ------------------------------------------------------------
f_sim_create () { 
SMSJOB_CREATE sim_usr_add EVERY5SEC
SMSJOB_CREATE sim_usr_activate EVERY5SEC
SMSJOB_CREATE sim_usr_suspend EVERY10MIN
SMSJOB_CREATE sim_usr_delete  EVERY30MIN
SMSJOB_CREATE sim_ctc_add     EVERY10SEC
SMSJOB_CREATE sim_ctc_accept  EVERY10SEC
SMSJOB_CREATE sim_ctc_suspend EVERY15MIN
SMSJOB_CREATE sim_ctc_delete  EVERY30MIN
SMSJOB_CREATE sim_ctc_change_keys EVERY15MIN
SMSJOB_CREATE sim_msg_send EVERY1SEC
}
# ------------------------------------------------------------
f_sim_drop () { 
SMSJOB_all DROP
}
# ------------------------------------------------------------
f_sim_run () { 
SMSJOB_all RUN
}
# ------------------------------------------------------------
f_sim_stop () { 
SMSJOB_all STOP
}
# ------------------------------------------------------------
f_sim_disable () { 
SMSJOB_all DISABLE
}
# ------------------------------------------------------------
f_sim_enable () { 
SMSJOB_all ENABLE
}
# ------------------------------------------------------------
