# ############################################################
# SMS - Queue Maintenance functions
# ############################################################
# ------------------------------------------------------------
# SMS Queue actions
action_L1="count pump_1 pump_n drain_1 drain_n list_one list_all list_cnt list_sndr list_rcvr "
action_L2="send recv send_random recv_random "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,NONE,List_of_Queued_messages \
cnt,NONE,Count_of_Queued_messages \
send,sndr_id:rcvr_id:msg,Send_Message \
recv,rcvr_id:msg,Receive_Message \
"
# ------------------------------------------------------------
# local variables
v_debug=0
# ------------------------------------------------------------
INCLIB_c
# ------------------------------------------------------------
f_que_count () { 
SMS_q "select count(1) from sms_msg_qt ;"
}
# ------------------------------------------------------------
f_que_pump_1 () { 
SMSPKG_p "msg_pump(1)"
}
# ------------------------------------------------------------
f_que_pump_n () { 
INPUT
SMSPKG_p "msg_pump(${input1})"
}
# ------------------------------------------------------------
f_que_drain_1 () { 
SMSPKG_p "msg_drain(1)"
}
# ------------------------------------------------------------
f_que_drain_n () { 
INPUT
SMSPKG_p "msg_drain(${input1})"
}
# ------------------------------------------------------------
f_que_list_one () { 
INPUT
SMS_q "select id, sndr_id, rcvr_id, dt, status, pkt from msg where id=${input1};"
}
# ------------------------------------------------------------
f_que_list_all () { 
SMS_q "select id, sndr_id, rcvr_id, dt, status, pkt from msg order by id;"
}
# ------------------------------------------------------------
f_que_list_cnt () { 
SMS_q "select rcvr_id, count(1) from msg where status='S' group by rcvr_id order by rcvr_id ;"
}
# ------------------------------------------------------------
f_que_list_sndr () { 
INPUT
SMS_q "select id, sndr_id, rcvr_id, dt, status, pkt from msg where sndr_id='${input1}' order by id;"
}
# ------------------------------------------------------------
f_que_list_rcvr () { 
SMS_q "select rcvr_id, count(1) from msg group by rcvr_id;"
}
# ------------------------------------------------------------
f_que_send_random () { 
# send from N to N
(( x = $RANDOM % 1000 ))
input1=$(sed -n "${x}p" /home/oracle/sms/usr_add.dat)
(( x = $RANDOM % 1000 ))
input2=$(sed -n "${x}p" /home/oracle/sms/usr_add.dat)
echo input1=$input1 input2=$input2
SMSPKG_p "msg_send('${input1}','${input2}')"
echo $input1 >> /home/oracle/sms/ctc_add.dat
}
# ------------------------------------------------------------
f_que_send () { 
INPUT 3
echo input1=$input1 input2=$input2 input3=${input3}
SMSPKG_p "msg_send('${input1}','${input2}','${input3}')"
}
# ------------------------------------------------------------
f_que_recv () { 
INPUT 
echo input1=$input1
input2="test"
#SMSPKG_p "msg_recv('${input1}','${input2}')"
SMSPKG_p "msg_recv('${input1}')"
}
