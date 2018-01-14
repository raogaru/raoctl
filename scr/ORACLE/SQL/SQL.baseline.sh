# ############################################################
# BASELINE FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# BASELINE actions
action_L1="create load_from_sqlset drop drop_all list count "
action_L2="alter alter_all " #enable enable_all disable disable_all accept accept_all 
action_L3="stgcre stgdrp stgtru stgcnt pack unpack stgexp stgimp "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
create,sql_id:plan_hash_value,Create_BASELINE  \
load_from_sqlset,sqlset_name,Create_BASELINE_from_SQLSET  \
drop,sql_handle,Drop_BASELINE  \
drop_all,NONE,Drop_all_BASELINEs  \
alter,sql_handle:attribute_name:attribute_value,Alter_BASELINE_attribute  \
alter_all,attribute_name:attribute_value,Alter_all_BASELINEs_attribute  \
list,NONE,List_BASELINEs \
stgcre,NONE,Create_staging_table \
stgdrp,NONE,Drop_staging_table \
stgtru,NONE,Truncate_staging_table \
stgcnt,NONE,Select_staging_table \
pack,sqlset_name,Pack_BASELINE \
unpack,sqlset_name,Unpack_BASELINE \
stgexp,NONE,export_staging_table \
stgimp,export_dump_file_absolute_path,export_staging_table \
"
# ------------------------------------------------------------
# local variables
v_debug=0
STGTAB_OWNER="SYSTEM"
STGTAB_BASELINE="STGTAB_BASELINE"
# ------------------------------------------------------------
BASELINE_p () {
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_spm.${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
BASELINE_f () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "x varchar2(1000);"
SQLLINE "begin"
SQLLINE "x:=dbms_spm.${vLine};"
SQLLINE "dbms_output.put_line('Return value:'||x);"
SQLLINE "end; "
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
BASELINE_l () {
x=/tmp/tmp.$$.sqlbaseline.lst
SQLNEWF
SQLLINE "set pagesi 0 head off feedback off verify off"
SQLLINE "select sql_handle from dba_sql_plan_baselines;"
SQLEXEC > ${x}
}
# ------------------------------------------------------------
f_baseline_drop () { 
INPUT
BASELINE_f "DROP_SQL_PLAN_BASELINE(SQL_HANDLE=>'${input}')"
}

# ------------------------------------------------------------
f_baseline_drop_all () { 
BASELINE_l
cat ${x} | while read input
do
BASELINE_f "DROP_SQL_PLAN_BASELINE(SQL_HANDLE=>'${input}')"
done
}
# ------------------------------------------------------------
f_baseline_alter () { 
INPUT 3
[[ ! ${input2} = @(ENABLED ACCEPTED|FIXED) ]] && 

BASELINE_f "ALTER_SQL_PLAN_BASELINE(SQL_HANDLE=>'${input1}',ATTRIBUTE_NAME=>'${input2}',ATTRIBUTE_VALUE=>'${input3}')"
}
# ------------------------------------------------------------
f_baseline_alter_all () { 
INPUT 2
BASELINE_l
cat ${x} | while read sql_handle
do
BASELINE_f "ALTER_SQL_PLAN_BASELINE(SQL_HANDLE=>'${sql_handle}',ATTRIBUTE_NAME=>'${input1}',ATTRIBUTE_VALUE=>'${input2}')"
done
}
# ------------------------------------------------------------
f_baseline_list () { 
SQLQRY "select sql_handle, plan_name, enabled, accepted, fixed, autopurge purge from dba_sql_plan_baselines;"
}
# ------------------------------------------------------------
f_baseline_count () { 
SQLQRY "select enabled, accepted, fixed, autopurge purge, count(1) baseline_count from dba_sql_plan_baselines group by enabled, accepted, fixed, autopurge order by 1,2,3,4;"
}
# ------------------------------------------------------------
f_baseline_create () {
INPUT 2
BASELINE_f "LOAD_PLANS_FROM_CURSOR_CACHE(SQL_ID=>'${input1}',PLAN_HASH_VALUE=>${input2})"
}
# ------------------------------------------------------------
f_baseline_load_from_sqlset () {
INPUT
BASELINE_f "LOAD_PLANS_FROM_SQLSET(SQLSET_NAME=>'${input}')"
}
# ------------------------------------------------------------
f_baseline_stgcre () {
BASELINE_p "CREATE_STGTAB_BASELINE(TABLE_NAME=>'${STGTAB_BASELINE}',TABLE_OWNER=>'${STGTAB_OWNER}')"
}
# ------------------------------------------------------------
f_baseline_stgdrp () {
SQLQRY "drop table ${STGTAB_OWNER}.${STGTAB_BASELINE} purge;"
}
# ------------------------------------------------------------
f_baseline_stgtru () {
SQLQRY "truncate table ${STGTAB_OWNER}.${STGTAB_BASELINE};"
}
# ------------------------------------------------------------
f_baseline_stgcnt () {
SQLQRY "select count(1) from ${STGTAB_OWNER}.${STGTAB_BASELINE};"
}
# ------------------------------------------------------------
f_baseline_pack () {
BASELINE_f "PACK_STGTAB_BASELINE(TABLE_NAME=>'${STGTAB_BASELINE}',TABLE_OWNER=>'${STGTAB_OWNER}')"
}
# ------------------------------------------------------------
f_baseline_unpack () {
BASELINE_f "UNPACK_STGTAB_BASELINE(TABLE_NAME=>'${STGTAB_BASELINE}',TABLE_OWNER=>'${STGTAB_OWNER}')"
}
# ------------------------------------------------------------
f_baseline_stgexp () {
INPUT
x=/tmp/baseline_stgtab_$(date '+%Y%m%d_%H%M%S')
${ORACLE_HOME}/bin/exp userid='/' file=${x}.dmp log=${x}.log tables=${STGTAB_OWNER}.${STGTAB_BASELINE} statistics=none
}
# ------------------------------------------------------------
f_baseline_stgimp () {
INPUT
x=/tmp/baseline_stgtab_$(date '+%Y%m%d_%H%M%S')
${ORACLE_HOME}/bin/imp userid='/' file=${input} log=${x}_imp.log fromuser=${STGTAB_OWNER} touser=${STGTAB_OWNER} ignore=y
}
# ------------------------------------------------------------
