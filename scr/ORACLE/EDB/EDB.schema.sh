# ############################################################
# EDB SCHEMA FUNCTIONS - Generate EDB Schema
# ############################################################
# ------------------------------------------------------------
# EDB SCHEMA actions
action_L1="create "
action_L2="yy "
action_L3="zz "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
create,none,Create_EDB_Schema_Objects \
drop,none,Drop_EDB_Schema_Objects \
zz,none,zz_description \
"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables
rc_EDB_SCHEMA_TABLE_SCRIPT=${rc_EDB_SCHEMA_SCRIPT_DIR}/edb_cretab.sql	# EDB schema create table script
rc_EDB_DBLINK_SCRIPT=${rc_EDB_SCHEMA_SCRIPT_DIR}/edb_credblink.sql	# EDB schema create dblink script
rc_EDB_TABLE_COMMON_COLUMN_1="edb_ymd varchar2(10) default to_char(sysdate,'yyyymmdd') not null"
rc_EDB_TABLE_COMMON_COLUMN_2="edb_name varchar2(10) not null"
rc_EDB_TABLE_COMMON_COLUMN_DEF="${rc_EDB_TABLE_COMMON_COLUMN_1},${rc_EDB_TABLE_COMMON_COLUMN_2}"
rc_EDB_TABLE_COMMON_COLUMNS="EDB_YMD,EDB_NAME"
rc_EDB_TABLES_LIST="PROFILES USERS TABLESPACES TABLES INDEXES INIT_PAR"
# ------------------------------------------------------------
# Module specific common functions

# ------------------------------------------------------------
INCLIB_c
# ------------------------------------------------------------
TableScript () {
echo "$*" >> ${rc_EDB_SCHEMA_TABLE_SCRIPT}
}
# ------------------------------------------------------------
f_schema_gen_ddl_dblinks () {
rm -f ${rc_EDB_DBLINK_SCRIPT}

DEBUG "Generate create DBLINK DDL for EDB schema"
cat ${v_class_dir}/db.cfg|egrep -v "^#|^$"| while read v_line 
do
v_dbname=$(echo ${v_line}|cut -f1 -d":")
v_hostname=$(echo ${v_line}|cut -f2 -d":")
v_portnum=$(echo ${v_line}|cut -f3 -d":")
v_sidname=$(echo ${v_line}|cut -f4 -d":")
DEBUG "v_dbname=${v_dbname} v_sidname=${v_sidname} v_hostname=${v_hostname} v_portnum=${v_portnum}"

echo "create database link \"${rc_EDB_SCHEMA}\".\"${v_dbname}\" using 'DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=${v_hostname})(PORT=${v_portnum})))(CONNECT_DATA=(SERVICE_NAME=${v_sidname})))' ;" >> ${rc_EDB_DBLINK_SCRIPT}

done
}
# ------------------------------------------------------------
f_schema_gen_ddl_create_table () {
rm -f ${rc_EDB_SCHEMA_TABLE_SCRIPT}
TableScript ""
TableScript "create table ${rc_EDB_SCHEMA}.EDB_YMD (${rc_EDB_TABLE_COMMON_COLUMN_DEF}) tablespace ${rc_EDB_SCHEMA_TABLESPACE};"

DEBUG "Generate create DDL for EDB table creation"

TableScript ""
TableScript "alter session set current schema=${rc_EDB_SCHEMA};"

cat ${v_class_dir}/schema.cfg|egrep -v "^#|^$"| while read v_line 
do
v_tabname=${rc_EDB_TABLE_PREFIX}_$(echo ${v_line}|cut -f1 -d":")
v_tabsource=$(echo ${v_line}|cut -f2 -d":")
v_tabpkcols=$(echo ${v_line}|cut -f3 -d":")
DEBUG "v_tabname=${v_tabname}"
DEBUG "v_tabsource=${v_tabsource}"

TableScript ""
TableScript "-- ----------------------------------------------------------------------"
TableScript "-- ${rc_EDB_TABLE_PREFIX}_${v_tabname}"
TableScript "-- ----------------------------------------------------------------------"
TableScript ""
TableScript "create table ${v_tabname} tablespace ${rc_EDB_SCHEMA_TABLESPACE} as select a.*, b.* from EDB_YMD a, ${v_tabsource} b where rownum<1;"

TableScript ""
TableScript "create unique index ${v_tabname}_PK on ${v_tabname} (${rc_EDB_TABLE_COMMON_COLUMNS},${v_tabpkcols}) tablespace ${rc_EDB_SCHEMA_TABLESPACE} ;"

TableScript ""
TableScript "alter table ${v_tabname} add constraint ${rc_EDB_TABLE_PREFIX}_${v_tabname}_PK primary key (${rc_EDB_TABLE_COMMON_COLUMNS},${v_tabpkcols}) ;"

TableScript ""
TableScript "create or replace force view ${v_tabname}_ROWCNT as "
TableScript "select ${rc_EDB_TABLE_COMMON_COLUMNS}, count(1) as rowcnt from ${v_tabname} a where edb_ymd >= to_char(trunc(sysdate)-7,'YYYY-MM-DD') group by ${rc_EDB_TABLE_COMMON_COLUMNS} ;"

TableScript ""
TableScript "create or replace force view ${v_tabname}_DIFF as" 
TableScript "select a.* from ${v_tabname} a where edb_ymd = (select max(edb_ymd) from EDB_YMD)"
TableScript "minus"
TableScript "select b.* from ${v_tabname} b where edb_ymd = (select max(edb_ymd) from EDB_YMD where edb_ymd<(select max(edb_ymd) from EDB_YMD)) ;"

#(select max(edb_ymd) ymd_0 from ${rc_EDB_SCHEMA}.${rc_EDB_TABLE_PREFIX}_${v_tabname})
#(select max(edb_ymd) ymd_1 from ${rc_EDB_SCHEMA}.${rc_EDB_TABLE_PREFIX}_${v_tabname} where edb_ymd <)

done
TableScript "-- ----------------------------------------------------------------------"
}
# ------------------------------------------------------------
f_schema_create () {

f_schema_gen_ddl_create_table
cat ${rc_EDB_SCHEMA_TABLE_SCRIPT}
# execute in database
#SQLRUN "@${rc_EDB_SCHEMA_TABLE_SCRIPT}"

f_schema_gen_ddl_dblinks
#cat ${rc_EDB_DBLINK_SCRIPT}

}
# ------------------------------------------------------------

# get dba_xxx column names
#SQLNEWF
#SQLLINE "set linesi 10000 pagesi 0 echo off feedback off verify off time off timing off"
#SQLLINE "select listagg(column_name,',') within group (order by column_id) AS all_cols"
#SQLLINE "FROM   dba_tab_columns"
#SQLLINE "WHERE owner='SYS' and table_name='${rc_EDB_SCHEMA_SOURCE_VIEW_PREFIX}_${v_tabname}';"
#v_tabcols=$(SQLEXEC)
