# ------------------------------------------------------------
SCHEDULER_p () {
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_scheduler.${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
SCHEDULER_f () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "x varchar2(1000);"
SQLLINE "begin"
SQLLINE "x:=dbms_scheduler.${vLine};"
SQLLINE "dbms_output.put_line('Return value:'||x);"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
