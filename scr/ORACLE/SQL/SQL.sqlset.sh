# ############################################################
# SQLSET FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# SQLSET actions
action_L1="create create_for_1day_awr drop delsql delall list listsql refadd refdel reflist "
action_L2="load_from_cache load_from_sqlset load_from_awr_snap load_from_awr_baseline "
action_L3="stgcre stgdrp stgtru stgcnt pack unpack stgexp stgimp remap "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
usage_L=" \
create,sqlset_name,Create_SQLSET  \
create_for_1day_awr,num_days,Create_SQLSETs_for_1day_all_AWR_Snaps  \
drop,sqlset_name,Drop_SQLSET  \
delsql,sqlset_name:sql_id,Delete_SQL_from_SQLSET \
delall,sqlset_name,Delete_all_SQL_from_SQLSET \
list,NONE,List_SQLSETs \
listsql,sqlset_name,List_SQLs_in_SQLSET \
refadd,sqlset_name,Add_reference_to_SQLSET \
refdel,sqlset_name:reference_id,Delete_referenced_from_SQLSET \
reflist,NONE,List_references \
load_from_cache,sqlset_name,parsing_schema_name,Load_SQLs_from_cache \
load_from_sqlset,to_sqlset_name:from_sqlset_name,Load_SQLs_from_another_SQLSET \
load_from_awr_snap,sqlset_name:begin_snap_id:end_snap_id,Load_SQLs_from_AWR \
load_from_awr_baseline,sqlset_name:awr_baseline_name,Load_SQLs_from_AWR_baseline \
stgcre,NONE,Create_staging_table \
stgdrp,NONE,Drop_staging_table \
stgtru,NONE,Truncate_staging_table \
stgcnt,NONE,Select_staging_table \
pack,sqlset_name,Pack_SQLSET \
unpack,sqlset_name,Unpack_SQLSET \
stgexp,NONE,export_staging_table \
stgimp,export_dump_file_absolute_path,export_staging_table \
remap,sqlset_name:fromuser:touser,Remap_SQLSET_items_attributes \
"
# ------------------------------------------------------------
# local variables
PARSING_SCHEMA=${rc_PARSING_SCHEMA:=SYS}
STGTAB_OWNER="SYSTEM"
STGTAB_SQLSET="STGTAB_SQLSET"
# ------------------------------------------------------------
SQLSET_p () {
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_sqltune.${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
SQLSET_f () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "x varchar2(1000);"
SQLLINE "begin"
SQLLINE "x:=dbms_sqltune.${vLine};"
SQLLINE "dbms_output.put_line('Return value:'||x);"
SQLLINE "end; "
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
SQLSET_load () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "c1 dbms_sqltune.sqlset_cursor;"
SQLLINE "begin"
SQLLINE "open c1 FOR select value(p) from table(DBMS_SQLTUNE.${vLine}) p;"
SQLLINE "dbms_sqltune.load_sqlset(sqlset_name=>'${sqlset_name}',populate_cursor=>c1);"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}

# ------------------------------------------------------------
f_sqlset_create () { 
INPUT
SQLSET_p "create_sqlset(sqlset_name=>'${input}')"
}
# ------------------------------------------------------------
f_sqlset_create_for_1day_awr () { 
INPUT
SQL2LST "select snap_id from dba_hist_snapshot where trunc(begin_interval_time)=trunc(sysdate)-${input1} order by snap_id ;"
i=0
id1=0
id2=0
cat ${SQL2LST_LST} |while read id2
do
if [ $i -gt 0 ]; then
sqlset_name="SQLSET_AWR_${id1}_${id2}"
ECHO "Creating SQLSET ${sqlset_name} for begin_snap_id=$id1 end_snap_id=$id2"
SQLSET_p "create_sqlset(sqlset_name=>'${sqlset_name}')"
SQLSET_load "select_workload_repository(begin_snap=>${id1},end_snap=>${id2})"
fi
id1=$id2
(( i=i+1 ))
done
}
# ------------------------------------------------------------
f_sqlset_drop () { 
INPUT
SQLSET_p "drop_sqlset(sqlset_name=>'${input}')"
}
# ------------------------------------------------------------
f_sqlset_delsql () { 
INPUT 2
SQLSET_p "DELETE_SQLSET(SQLSET_NAME=>'${input1}',BASIC_FILTER=>'sql_id=''${input2}''')"
}
# ------------------------------------------------------------
f_sqlset_delall () { 
INPUT
SQLSET_p "DELETE_SQLSET(SQLSET_NAME=>'${input}')"
}

# ------------------------------------------------------------
f_sqlset_list () { 
SQLQRY "select name, to_char(created,'YYYY-MM-DD HH24:MI') created, statement_count sql_cnt from dba_sqlset order by 2;"
}

# ------------------------------------------------------------
f_sqlset_listsql () { 
INPUT
ECHO sqlset_name=${input}
SQLNEWF
SQLLINE "set head on pagesi 1000 linesi 100 trimspool on"
SQLLINE "col sql_text format a50"
SQLLINE "select sql_id, plan_hash_value, sql_text"
SQLLINE "from dba_sqlset_statements where sqlset_name='${input}' order by sql_id;"
SQLEXEC
}

# ------------------------------------------------------------
f_sqlset_refadd () { 
INPUT
SQLSET_f "ADD_SQLSET_REFERENCE(SQLSET_NAME=>'${input}')"
}

# ------------------------------------------------------------
f_sqlset_refdel () { 
INPUT 2
SQLSET_p "REMOVE_SQLSET_REFERENCE(SQLSET_NAME=>'${input1}',REFERENCE_ID=>${input2})"
}

# ------------------------------------------------------------
f_sqlset_reflist () { 
SQLQRY "select sqlset_id, sqlset_owner,sqlset_name, id ref_id, owner ref_owner, created from dba_sqlset_references;"
}

# ------------------------------------------------------------
f_sqlset_load_from_cache () {
INPUT 
sqlset_name=${input}
SQLSET_load "SELECT_CURSOR_CACHE(BASIC_FILTER=>'parsing_schema_name = ''${PARSING_SCHEMA}'' ')"
}
# ------------------------------------------------------------
f_sqlset_load_from_sqlset () {
INPUT 2
sqlset_name=${input1}
SQLSET_load "SELECT_SQLSET(SQLSET_NAME=>'${input2}')"
}
# ------------------------------------------------------------
f_sqlset_load_from_awr_snap () {
INPUT 3
sqlset_name=${input1}
SQLSET_load "select_workload_repository(begin_snap=>${input2},end_snap=>${input3})"
}
# ------------------------------------------------------------
f_sqlset_load_from_awr_baseline () {
INPUT 2
sqlset_name=${input1}
SQLSET_load "select_workload_repository(baseline_name=>'${input2}')"
}
# ------------------------------------------------------------
f_sqlset_stgcre () {
SQLSET_p "create_stgtab_sqlset(table_name=>'${STGTAB_SQLSET}',schema_name=>'${STGTAB_OWNER}')"
}
# ------------------------------------------------------------
f_sqlset_stgdrp () {
SQLQRY "drop table ${STGTAB_OWNER}.${STGTAB_SQLSET} purge;"
}
# ------------------------------------------------------------
f_sqlset_stgtru () {
SQLQRY "truncate table ${STGTAB_OWNER}.${STGTAB_SQLSET};"
}
# ------------------------------------------------------------
f_sqlset_stgcnt () {
SQLQRY "select count(1) from ${STGTAB_OWNER}.${STGTAB_SQLSET};"
}
# ------------------------------------------------------------
f_sqlset_pack () {
INPUT
SQLSET_p "pack_stgtab_sqlset(sqlset_name=>'${input}',staging_table_name=>'${STGTAB_SQLSET}',staging_schema_owner=>'${STGTAB_OWNER}')"
}
# ------------------------------------------------------------
f_sqlset_unpack () {
INPUT
SQLSET_p "unpack_stgtab_sqlset(sqlset_name=>'${input}',replace=>TRUE,staging_table_name=>'${STGTAB_SQLSET}',staging_schema_owner=>'${STGTAB_OWNER}')"
}
# ------------------------------------------------------------
f_sqlset_stgexp () {
x=/tmp/sqlset_stgtab_$(date '+%Y%m%d_%H%M%S')
${ORACLE_HOME}/bin/exp userid='/' file=${x}.dmp log=${x}.log tables=${STGTAB_OWNER}.${STGTAB_SQLSET} statistics=none
}
# ------------------------------------------------------------
f_sqlset_stgimp () {
INPUT
x=/tmp/sqlset_stgtab_$(date '+%Y%m%d_%H%M%S')
${ORACLE_HOME}/bin/imp userid='/' file=${input} log=${x}_imp.log fromuser=${STGTAB_OWNER} touser=${STGTAB_OWNER} ignore=y
}
# ------------------------------------------------------------
f_sqlset_remap () {
ERROR "not coded yet"
}
# ------------------------------------------------------------
