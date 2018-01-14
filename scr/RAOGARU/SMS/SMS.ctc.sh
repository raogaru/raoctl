# ############################################################
# SMS - Contact Maintenance functions
# ############################################################
# ------------------------------------------------------------
# SMS CTC actions
action_L1="add_random add add_2way accept accept_2way accept_all suspend delete upd_status change_keys "
action_L2="count list_sndr list_rcvr "
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
f_ctc_count () { 
SMS_q "select status, count(1) ctc_status_count from ctc group by status;"
}
# ------------------------------------------------------------
f_ctc_list_sndr () { 
INPUT
SMS_q "select sndr_id, rcvr_id, sndr_key, rcvr_key, status  from ctc where sndr_id='${input1}';"
}
# ------------------------------------------------------------
f_ctc_list_rcvr () { 
INPUT
SMS_q "select sndr_id, rcvr_id , sndr_key, rcvr_key, status from ctc where rcvr_id='${input1}';"
}
# ------------------------------------------------------------
f_ctc_add_random () { 
input1=$(GetRandUser)
input2=$(GetRandUser)
[[ -z "${input1}" ]] && ERROR "invalid input1 value" 
[[ -z "${input2}" ]] && ERROR "invalid input2 value" 
echo sndr=$input1 rcvr=$input2 >> ${CTC_DAT_FILE}
if [ $input1 != $input2 ]; then
SMSPKG_p "ctc_add('${input1}','${input2}')"
fi
}
# ------------------------------------------------------------
f_ctc_add () { 
INPUT 2
echo input1=$input1 input2=$input2
SMSPKG_p "ctc_add('${input1}','${input2}')"
}
# ------------------------------------------------------------
f_ctc_add_2way () { 
INPUT 2
echo input1=$input1 input2=$input2
SMSPKG_p "ctc_add('${input1}','${input2}')"
SMSPKG_p "ctc_add('${input2}','${input1}')"
}
# ------------------------------------------------------------
f_ctc_accept () { 
INPUT 2
SMSPKG_p "ctc_accept('${input1}','${input2}')"
}
# ------------------------------------------------------------
f_ctc_accept_2way () { 
INPUT 2
SMSPKG_p "ctc_accept('${input1}','${input2}')"
SMSPKG_p "ctc_accept('${input2}','${input1}')"
}
# ------------------------------------------------------------
f_ctc_accept_all () { 
INPUT 1
SMSPKG_p "ctc_accept_all('${input1}')"
}
# ------------------------------------------------------------
f_ctc_suspend () { 
INPUT 2
SMSPKG_p "ctc_suspend('${input1}','${input2}')"
}
# ------------------------------------------------------------
f_ctc_delete () { 
INPUT 2
SMSPKG_p "ctc_delete('${input1}','${input2}')"
}
# ------------------------------------------------------------
f_ctc_upd_status () { 
INPUT 3
SMSPKG_p "ctc_upd_status('${input1}','${input2}','${input3}')"
}
# ------------------------------------------------------------
# ------------------------------------------------------------
f_ctc_change_keys () { 
INPUT 2
SMSPKG_p "ctc_change_keys('${input1}','${input2}')"
}
