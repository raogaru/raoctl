# ------------------------------------------------------------
rc_STATTAB_OWNER=${rc_STATTAB_OWNER:="SYSTEM"}
rc_STATTAB_NAME=${rc_STATTAB_NAME:="STATTAB"}
# ------------------------------------------------------------
STATS_p () {
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_stats.${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
STATS_f () {
vLine="$*"
SQLNEWF
SQLLINE "set feedback off"
SQLLINE "declare"
SQLLINE "x varchar2(1000);"
SQLLINE "begin"
SQLLINE "x:=dbms_stats.${vLine};"
SQLLINE "dbms_output.put_line(x);"
SQLLINE "end; "
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
