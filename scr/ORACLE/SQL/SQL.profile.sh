# ############################################################
# SQL PROFILE FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# SQL PROFILE actions
action_L1="list show accept alter drop import count "
action_L2="stgcre stgdrp stgtru stgcnt pack unpack stgexp stgimp "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,NONE,List \
show,profile_name,List \
accept,task_name,Accept  \
alter,name:attribute_name:attribute_value,Alter  \
drop,sql_profile_name,Drop  \
import,NONE,Import  \
count,NONE,Count \
stgcre,NONE,Create_staging_table \
stgdrp,NONE,Drop_staging_table \
stgtru,NONE,Truncate_staging_table \
stgcnt,NONE,Select_staging_table \
pack,sqlset_name,Pack_SQL_Profiles_into_Staging_Table \
unpack,sqlset_name,Unpack_SQL_Profiles_from_Staging_Table \
stgexp,NONE,export_staging_table \
stgimp,export_dump_file_absolute_path,export_staging_table \
"
# ------------------------------------------------------------
# local variables
STGTAB_OWNER=${rc_STGTAB_OWNER:="SYSTEM"}
STGTAB_SQLPROF=${rc_STGTAB_SQLPROF:="STGTAB_SQLPROF"}
# ------------------------------------------------------------
SQLPROF_p () {
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_sqltune.${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
SQLPROF_f () {
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
f_profile_list () { 
SQLQRY "select name, category, created, type, status, task_exec_name from dba_sql_profiles order by created;"
}
# ------------------------------------------------------------
f_profile_show () { 
INPUT
SQLQRY "select attr5 rationale from sys.wri$_adv_rationale a, dba_sql_profiles b wherea a.exec_name=b.task_exec_name and b.name=${input1};"
}
# ------------------------------------------------------------
f_profile_accept () { 
INPUT
SQLPROF_f "accept_sql_profile(task_name=>'${input1}',force_match=>true)"
}
# ------------------------------------------------------------
f_profile_alter () { 
INPUT 3
[[ ! ${input2} = @(ENABLED ACCEPTED|FIXED) ]] && 

SQLPROF_p "alter_sql_sqlprof(name=>'${input1}',attribute_name=>'${input2}',value=>'${input3}')"
}
# ------------------------------------------------------------
f_profile_drop () { 
INPUT
SQLPROF_p "drop_sql_sqlprof(name=>'${input1}')"
}
# ------------------------------------------------------------
f_profile_import () { 
ERROR "not coded yet"
}
# ------------------------------------------------------------
f_profile_count () { 
SQLQRY "select category, type, status, count(1) from dba_sql_profiles group by category, type, status order by 1,2,3;"
}
# ------------------------------------------------------------
f_profile_create () {
INPUT 2
SQLPROF_f "LOAD_PLANS_FROM_CURSOR_CACHE(SQL_ID=>'${input1}',PLAN_HASH_VALUE=>${input2})"
}
# ------------------------------------------------------------
f_profile_load_from_sqlset () {
INPUT
SQLPROF_f "LOAD_PLANS_FROM_SQLSET(SQLSET_NAME=>'${input}')"
}
# ------------------------------------------------------------
f_profile_stgcre () {
SQLPROF_p "CREATE_STGTAB_SQLPROF(TABLE_NAME=>'${STGTAB_SQLPROF}',TABLE_OWNER=>'${STGTAB_OWNER}')"
}
# ------------------------------------------------------------
f_profile_stgdrp () {
SQLQRY "drop table ${STGTAB_OWNER}.${STGTAB_SQLPROF} purge;"
}
# ------------------------------------------------------------
f_profile_stgtru () {
SQLQRY "truncate table ${STGTAB_OWNER}.${STGTAB_SQLPROF};"
}
# ------------------------------------------------------------
f_profile_stgcnt () {
SQLQRY "select count(1) from ${STGTAB_OWNER}.${STGTAB_SQLPROF};"
}
# ------------------------------------------------------------
f_profile_pack () {
SQLPROF_f "PACK_STGTAB_SQLPROF(TABLE_NAME=>'${STGTAB_SQLPROF}',TABLE_OWNER=>'${STGTAB_OWNER}')"
}
# ------------------------------------------------------------
f_profile_unpack () {
SQLPROF_f "UNPACK_STGTAB_SQLPROF(TABLE_NAME=>'${STGTAB_SQLPROF}',TABLE_OWNER=>'${STGTAB_OWNER}')"
}
# ------------------------------------------------------------
f_profile_stgexp () {
INPUT
x=/tmp/baseline_stgtab_$(date '+%Y%m%d_%H%M%S')
${ORACLE_HOME}/bin/exp userid='/' file=${x}.dmp log=${x}.log tables=${STGTAB_OWNER}.${STGTAB_SQLPROF} statistics=none
}
# ------------------------------------------------------------
f_profile_stgimp () {
INPUT
x=/tmp/baseline_stgtab_$(date '+%Y%m%d_%H%M%S')
${ORACLE_HOME}/bin/imp userid='/' file=${input} log=${x}_imp.log fromuser=${STGTAB_OWNER} touser=${STGTAB_OWNER} ignore=y
}
# ------------------------------------------------------------
