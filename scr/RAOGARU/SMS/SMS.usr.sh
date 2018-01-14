# ############################################################
# SMS - User Maintenance functions
# ############################################################
# ------------------------------------------------------------
# SMS USR actions
action_L1="show show_all count add activate suspend delete upd_name upd_status "
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
f_usr_show () { 
INPUT
SMS_q "select id, name, status, hash, dt from usr  where id='${input1}';"
}
# ------------------------------------------------------------
f_usr_show_all () { 
SMS_q "select id, name, status, hash, dt from usr  order by id;"
}
# ------------------------------------------------------------
f_usr_count () { 
SMS_q "select status, count(1) usr_status_count from usr group by status;"
}
# ------------------------------------------------------------
f_usr_add () { 
input1=$(echo 01$RANDON$RANDON$RANDOM$RANDOM$RANDOM$RANDOM|cut -c1-12)
input2="$(echo First$RANDOM Last$RANDOM)"
SMSPKG_p "usr_add('${input1}','${input2}')"
echo $input1 >> ${USR_DAT_FILE}
}
# ------------------------------------------------------------
f_usr_activate () { 
INPUT
SMSPKG_p "usr_activate('${input1}')"
}
# ------------------------------------------------------------
f_usr_suspend () { 
INPUT
SMSPKG_p "usr_suspend('${input1}')"
}
# ------------------------------------------------------------
f_usr_delete () { 
INPUT
SMSPKG_p "usr_delete('${input1}')"
}
# ------------------------------------------------------------
f_usr_upd_name () { 
INPUT 2
SMSPKG_p "usr_upd_name('${input1}','${input2}')"
}
# ------------------------------------------------------------
f_usr_upd_status () { 
INPUT 2
SMSPKG_p "usr_upd_status('${input1}','${input2}')"
}
# ------------------------------------------------------------
