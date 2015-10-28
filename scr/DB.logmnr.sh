# ############################################################
# DB LOG MINOR FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# DB LOGMNR actions
action_L1="list add remove start end mine_1 mine_n "
action_L2="list_txn "
action_L3="x "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list_log,NONE,List_logfiles_added_for_log_mining \
"
# ------------------------------------------------------------
# local variables

# ------------------------------------------------------------
SQL_GETVAL () {
vLine=$*
#constr="sys/sys123@${ORACLE_SID} as sysdba"
constr="/ as sysdba"
#cat $TMPSQL >> $ELOG
${ORACLE_HOME}/bin/sqlplus -s /nolog <<-EOFsql
connect $constr
set feedback off pause off pagesize 0 heading off verify off linesize 500 term on trimspool on
${vLine}
EOFsql
}
# ------------------------------------------------------------
LOGMNR_p () {
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_logmnr.${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
# ------------------------------------------------------------
LOGMNR_f () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "x varchar2(1000);"
SQLLINE "begin"
SQLLINE "x:=dbms_logmnr.${vLine};"
SQLLINE "dbms_output.put_line('Return value:'||x);"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
f_logmnr_list_log () { 
INPUT
LOGMNR_f "add_logfile."
}
# ------------------------------------------------------------
f_logmnr_add () { 
INPUT
x=$(SQL_GETVAL "select trim(name) from v\$archived_log where dest_id=1 and sequence#=${input1} and rownum=1;")
LOGMNR_p "add_logfile('$x')"
}
# ------------------------------------------------------------
f_logmnr_remove () { 
INPUT
x=$(SQL_GETVAL "select trim(name) from v\$archived_log where dest_id=1 and sequence#=${input1} and rownum=1;")
LOGMNR_p "remove_logfile('$x')"
}
# ------------------------------------------------------------
f_logmnr_start () { 
LOGMNR_p "start_logmnr"
}
# ------------------------------------------------------------
f_logmnr_end () { 
LOGMNR_p "end_logmnr"
}
# ------------------------------------------------------------
f_logmnr_mine_1 () { 
INPUT
x=$(SQL_GETVAL "select trim(name) from v\$archived_log where dest_id=1 and sequence#=${input1} and rownum=1;")
SQLNEWF
SQLLINE "select count(1) from v\$logmnr_contents;"
SQLLINE "begin "
SQLLINE "dbms_logmnr.add_logfile('${x}');"
SQLLINE "dbms_logmnr.start_logmnr;"
SQLLINE "end;"
SQLLINE "/"
SQLLINE "select count(1) from v\$logmnr_contents;"
SQLEXEC
}
# ------------------------------------------------------------
