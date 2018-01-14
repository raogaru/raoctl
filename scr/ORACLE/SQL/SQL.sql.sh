# ############################################################
# SQL QUERY FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# SQL QUERY actions
action_L1="topsql topexe topdisk toptime topcpu topparse topbuff "
action_L2="multi_plan multi_child "
action_L3="text report "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
## USAGE DATA
usage_L=" \
topsql,NONE,Top_SQL_Ordered_by_Executions  \
topexe,NONE,Top_SQL_Ordered_by_Executions  \
topdisk,NONE,Top_SQL_Ordered_by_Disk_Reads  \
toptime,NONE,Top_SQL_Ordered_by_Elapsed_Time  \
topcpu,NONE,Top_SQL_Ordered_by_CPU_Consumption  \
topparse,NONE,Top_SQL_Ordered_by_Parse_Calls  \
topbuff,NONE,Top_SQL_Ordered_by_Buffer_Gets  \
multi_plan,NONE,SQLs_with_multiple_Plan_Hash_Values \
multi_plan,NONE,SQLs_with_multiple_Plan_Hash_Values \
text,sql_id,Show_SQL_Details \
report,sql_id,Report_SQL_Details \
"
# ------------------------------------------------------------
# local variables
typeset -u REPORTS_DIR="REPORTS_DIR"
# ------------------------------------------------------------
SQL_QUERY_f () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "x varchar2(1000);"
SQLLINE "begin"
SQLLINE "x:=dbms_sqlpa.${vLine};"
SQLLINE "dbms_output.put_line('Return value:'||x);"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
SQL_QUERY_clob2file () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "v_clob clob;"
SQLLINE "begin"
SQLLINE "v_clob:=dbms_sqltune.${vLine};"
SQLLINE "dbms_advisor.create_file(buffer=>v_clob,location=>'${REPORTS_DIR}',filename=>'${v_file_name}');"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
SQL_GENERIC_p () {
vLine="$*"
SQLNEWF
SQLLINE "set head on feedback on linesi 120 trimspool on pagesi 100" 
SQLLINE "${vLine}"
SQLEXEC
}
# ============================================================
# TOP SQL FUNCTIONS
# ------------------------------------------------------------
SQL_TOPSQL_f () {
vLine="$*"
SQLNEWF
SQLLINE "set head on feedback on linesi 120 trimspool on pagesi 100" 
SQLLINE "col child#  format 9999"
SQLLINE "select sql_id,child_number child#,plan_hash_value,executions,disk_reads,buffer_gets,fetches,parse_calls,elapsed_time,cpu_time from"
SQLLINE "(select sql_id,child_number,plan_hash_value,executions,disk_reads,buffer_gets,fetches,parse_calls,elapsed_time,cpu_time from v\$sql"
SQLLINE "order by ${1} desc) where rownum<=10 order by ${1} desc;"
SQLEXEC
}
# ------------------------------------------------------------
f_sql_topsql () { 
SQL_TOPSQL_f "executions"
}
# ------------------------------------------------------------
f_sql_topexe () { 
SQL_TOPSQL_f "executions"
}
# ------------------------------------------------------------
f_sql_topdisk () { 
SQL_TOPSQL_f "disk_reads"
}
# ------------------------------------------------------------
f_sql_toptime () { 
SQL_TOPSQL_f "elapsed_time"
}
# ------------------------------------------------------------
f_sql_topcpu () { 
SQL_TOPSQL_f "cpu_time"
}
# ------------------------------------------------------------
f_sql_topparse () { 
SQL_TOPSQL_f "parse_calls"
}
# ------------------------------------------------------------
f_sql_topbuff () { 
SQL_TOPSQL_f "buffer_gets"
}
# ============================================================
# ------------------------------------------------------------
f_sql_multi_plan () { 
SQL_GENERIC_p "select sql_id, plans from (select sql_id, count( distinct plan_hash_value) plans from v\$sql group by sql_id, plan_hash_value having count(distinct plan_hash_value)>1) order by plans desc;"
}
# ------------------------------------------------------------
f_sql_multi_child () { 
SQL_GENERIC_p "select sql_id, childs from (select sql_id, count(distinct child_number) childs from v\$sql group by sql_id  having count(distinct child_number)>1) order by childs desc;"
}
# ------------------------------------------------------------
f_sql_text () { 
INPUT
SQLNEWF
SQLLINE "set head on feedback on linesi 120 trimspool on pagesi 100" 
SQLLINE "col piece noprint"
SQLLINE "col sql_text format a65"
SQLLINE "select piece, sql_text from v\$sqltext where sql_id='${input}' order by piece;"
SQLEXEC
}
# ------------------------------------------------------------
f_sql_report () { 
INPUT
v_file_name="SQL_DETAIL_${ORACLE_SID}_${input}_$(date +%Y%m%d-%H%M%S).html"
SQLNEWF
SQLLINE "declare"
SQLLINE "v_clob clob;"
SQLLINE "begin"
SQLLINE "v_clob:=dbms_sqltune.REPORT_SQL_DETAIL(sql_id=>'${input1}',type=>'HTML',report_level=>'ALL');"
SQLLINE "dbms_advisor.create_file(buffer=>v_clob,location=>'${REPORTS_DIR}',filename=>'${v_file_name}');"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
