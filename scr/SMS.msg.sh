# ############################################################
# SMS - Message Maintenance functions
# ############################################################
# ------------------------------------------------------------
# SMS MSG actions
action_L1="list_one list_all list_cnt list_sndr list_rcvr "
action_L1="send send_11 send_1n send_n1 send_nn "
action_L1="recv  "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
send,sndr_id:rcvr_id:msg,Send_Message \
recv,rcvr_id:msg,Receive_Message \
"
# ------------------------------------------------------------
# local variables
v_debug=0
# ------------------------------------------------------------
INCLIB_c
# ------------------------------------------------------------
f_msg_list_one () { 
INPUT
SMS_q "select id, sndr_id, rcvr_id, dt, status, pkt from msg where id=${input1};"
}
# ------------------------------------------------------------
f_msg_list_all () { 
SMS_q "select id, sndr_id, rcvr_id, dt, status, pkt from msg order by id;"
}
# ------------------------------------------------------------
f_msg_list_cnt () { 
SMS_q "select status, sndr_id, count(1) from msg group by status, sndr_id order by sndr_id ;"
SMS_q "select status, rcvr_id, count(1) from msg group by status, rcvr_id order by rcvr_id ;"
SMS_q "select status, count(1) from msg group by status;"
}
# ------------------------------------------------------------
f_msg_list_sndr () { 
INPUT
SMS_q "select sndr_id, rcvr_id, status, pkt from msg where sndr_id='${input1}' order by id;"
}
# ------------------------------------------------------------
f_msg_list_rcvr () { 
INPUT
SMS_q "select rcvr_id, rcvr_id, status, pkt from msg where rcvr_id='${input1}' order by id;"
}
# ------------------------------------------------------------
# send random msg from 1 to 1
f_msg_send_11 () { 
INPUT 2
input3="msg$RANDOM"
[[ "${input1}" == "${input2}" ]] && ECHO "sender and receiver cannot be same"
SMSPKG_p "msg_send('${input1}','${input2}','${input3}')"
echo from=$input1 to=$input2 msg="${input3}" >>  ${MSG_DAT_FILE}
echo from=$input1 msg="${input3}"   >>  ${SMS_DAT_DIR}/rcvr.${input2}.dat
echo to=$input2 msg="${input3}" >>  ${SMS_DAT_DIR}/sndr.${input1}.dat
}
# ------------------------------------------------------------
# send random msg from 1 to N
f_msg_send_1n () { 
INPUT
input2=$(GetRandUser)
input3="msg$RANDOM"
[[ "${input1}" == "${input2}" ]] && ECHO "sender and receiver cannot be same"
SMSPKG_p "msg_send('${input1}','${input2}','${input3}')"
echo from=$input1 to=$input2 msg="${input3}" >>  ${MSG_DAT_FILE}
echo from=$input1 msg="${input3}"   >>  ${SMS_DAT_DIR}/rcvr.${input2}.dat
echo to=$input2 msg="${input3}" >>  ${SMS_DAT_DIR}/sndr.${input1}.dat
}
# ------------------------------------------------------------
# send random msg from N to 1
f_msg_send_n1 () {
INPUT
input2=$(GetRandUser)
input3="msg$RANDOM"
[[ "${input1}" == "${input2}" ]] && ECHO "sender and receiver cannot be same"
SMSPKG_p "msg_send('${input2}','${input1}','${input3}')"
echo from=$input2 to=$input1 msg="${input3}" >>  ${MSG_DAT_FILE}
echo from=$input2 msg="${input3}"   >>  ${SMS_DAT_DIR}/rcvr.${input2}.dat
echo to=$input1 msg="${input3}" >>  ${SMS_DAT_DIR}/sndr.${input1}.dat
}
# ------------------------------------------------------------
f_msg_send_nn () { 
input1=$(GetRandUser)
input2=$(GetRandUser)
input3="msg$RANDOM"
[[ "${input1}" == "${input2}" ]] && ECHO "sender and receiver cannot be same"
SMSPKG_p "msg_send('${input1}','${input2}','${input3}')"
echo from=$input1 to=$input2 msg="${input3}" >>  ${MSG_DAT_FILE}
echo from=$input1 msg="${input3}"   >>  ${SMS_DAT_DIR}/rcvr.${input2}.dat
echo to=$input2 msg="${input3}" >>  ${SMS_DAT_DIR}/sndr.${input1}.dat
}
# ------------------------------------------------------------
f_msg_send () { 
INPUT 3
[[ "${input1}" == "${input2}" ]] && ECHO "sender and receiver cannot be same"
SMSPKG_p "msg_send('${input1}','${input2}','${input3}')"
echo from=$input1 to=$input2 msg="${input3}" >>  ${MSG_DAT_FILE}
echo from=$input1 msg="${input3}"   >>  ${SMS_DAT_DIR}/rcvr.${input2}.dat
echo to=$input2 msg="${input3}" >>  ${SMS_DAT_DIR}/sndr.${input1}.dat
}
# ------------------------------------------------------------
f_msg_recv () { 
INPUT 
echo input1=$input1
input2="test"
#SMSPKG_p "msg_recv('${input1}','${input2}')"
SMSPKG_p "msg_recv('${input1}')"
}
