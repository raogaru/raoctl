# ############################################################
# SMS library functions
# ############################################################
# ------------------------------------------------------------
SMS_HOME=/home/oracle/sms
SMS_DAT_DIR=/home/oracle/dat
USR_DAT_FILE=${SMS_DAT_DIR}/usr.dat
CTC_DAT_FILE=${SMS_DAT_DIR}/ctc.dat
MSG_DAT_FILE=${SMS_DAT_DIR}/msg.dat
USR_MAX_CNT=20
# ------------------------------------------------------------
GetRandUser() {
(( x = $RANDOM % ${USR_MAX_CNT} + 1))
y=$(sed -n "${x}p" ${USR_DAT_FILE})
echo ${y%% }
}
# ------------------------------------------------------------
SQLEXEC_SMS () {
constr="sms/SMS"
ECHO ${cLINE3}
${ORACLE_HOME}/bin/sqlplus -s /nolog <<-EOFsql
connect $constr
set echo off feedback on pause off pagesize 0 heading off verify off linesize 500 term on trimspool on serveroutput on size 10000
@${TMPSQL}
EOFsql
}
# ------------------------------------------------------------
SMS_q () {
SQLNEWF
SQLLINE "set echo off feedback on pause off pagesize 1000 heading on "
SQLLINE "set verify off linesize 500 term on trimspool on"
SQLLINE "$*"
SQLEXEC_SMS
}
# ------------------------------------------------------------
SMSPKG_p () {
vLine="$*"
SQLNEWF
SQLLINE "exec sms.smspkg.${vLine};"
SQLEXEC_SMS
}
# ------------------------------------------------------------
SMSPKG_f () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "x varchar2(1000);"
SQLLINE "begin"
SQLLINE "x:=sms.smspkg.${vLine};"
SQLLINE "dbms_output.put_line('Return value:'||x);"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC_SMS
}
# ------------------------------------------------------------
