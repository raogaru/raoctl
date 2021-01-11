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
rc_EDB_TABLE_COMMON_COLUMN_1="edb_ymd varchar2(10) default to_char(sysdate,'yyyymmdd') not null"
rc_EDB_TABLE_COMMON_COLUMN_2="edb_name varchar2(10) not null"
rc_EDB_TABLE_COMMON_COLUMN_3=""
rc_EDB_TABLE_COMMON_COLUMNS="${rc_EDB_TABLE_COMMON_COLUMN_1},${rc_EDB_TABLE_COMMON_COLUMN_2}"
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

# ------------------------------------------------------------
f_schema_create () {
rm -f ${rc_EDB_SCHEMA_TABLE_SCRIPT}

TableScript ""
TableScript "create table ${rc_EDB_SCHEMA}.EDB_TEMP ("
TableScript "${rc_EDB_TABLE_COMMON_COLUMNS}"
TableScript ") tablespace ${rc_EDB_SCHEMA_TABLESPACE};"

for v_tabname in ${rc_EDB_TABLES_LIST}
do
DEBUG v_tabname=${v_tabname}
DEBUG v_tabsource=$(cat ${v_class_dir}/schema.cfg | grep "^${v_tabname}:" |cut -f2 -d":")
TableScript ""
TableScript "create table ${rc_EDB_SCHEMA}.${rc_EDB_TABLE_PREFIX}_${v_tabname}"
TableScript "tablespace ${rc_EDB_SCHEMA_TABLESPACE}"
TableScript "as select a.*, b.*"
TableScript "from ${rc_EDB_SCHEMA}.EDB_TEMP a, ${v_tabsource} b"
TableScript "where rownum<1;"
done

# execute in database
SQLRUN "@${rc_EDB_SCHEMA_TABLE_SCRIPT}"

}
# ------------------------------------------------------------

# get dba_xxx column names
#SQLNEWF
#SQLLINE "set linesi 10000 pagesi 0 echo off feedback off verify off time off timing off"
#SQLLINE "select listagg(column_name,',') within group (order by column_id) AS all_cols"
#SQLLINE "FROM   dba_tab_columns"
#SQLLINE "WHERE owner='SYS' and table_name='${rc_EDB_SCHEMA_SOURCE_VIEW_PREFIX}_${v_tabname}';"
#v_tabcols=$(SQLEXEC)
