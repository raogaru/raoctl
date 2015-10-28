# ############################################################
# SMS - Install functions
# ############################################################
# ------------------------------------------------------------
# SMS INSTALL actions
action_L1="step0 step1 step2 step3 "
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
f_install_step0 () { 
SQLNEWF
SQLLINE "@${SMS_HOME}/sms_0.sql"
SQLEXEC
}
# ------------------------------------------------------------
f_install_step1 () { 
SQLNEWF
SQLLINE "@${SMS_HOME}/sms_1.sql"
SQLEXEC_SMS
}
# ------------------------------------------------------------
f_install_step2 () { 
$ORACLE_HOME/bin/wrap 
SQLNEWF
SQLLINE "@${SMS_HOME}/sms_2.sql"
SQLEXEC_SMS
}
# ------------------------------------------------------------
f_install_step3 () { 
SQLNEWF
SQLLINE "@${SMS_HOME}/sms_3.sql"
SQLEXEC_SMS
}
# ------------------------------------------------------------
