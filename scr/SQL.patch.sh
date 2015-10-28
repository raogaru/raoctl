# ############################################################
# SQL PATCH FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# PATCH actions
action_L1="list accept drop alter "
action_L1="crestg drpstg expstg impst gpack unpack  "
action_L1="stgcre stgdrp stgtru stgcnt pack unpack stgexp stgimp "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,None,List_SQL_Patches \
accept,None,Accept_SQL_Patch \
drop,None,Drop_SQL_Patch \
alter,patch_name:attrib_name:attrib_value,Accept_SQL_Patch \
stgcre,NONE,Create_staging_table \
stgdrp,NONE,Drop_staging_table \
stgtru,NONE,Truncate_staging_table \
stgcnt,NONE,Select_staging_table \
pack,sqlset_name,Pack_SQLPATCH \
unpack,sqlset_name,Unpack_SQLPATCH \
stgexp,NONE,export_staging_table \
stgimp,export_dump_file_absolute_path,Export_staging_table \
"
# ------------------------------------------------------------
#Local Variables & Overwrite global variables
typeset -u REPORTS_DIR="REPORTS_DIR"
rc_SHOW_SQL=YES
STGTAB_OWNER="SYSTEM"
STGTAB_SQLPATCH="STGTAB_SQLPATCH"
# ------------------------------------------------------------
SQLPATCH_p () {
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_sqldiag.${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
SQLPATCH_f () {
vLine="$*"
SQLNEWF
SQLLINE "declare"
SQLLINE "x varchar2(1000);"
SQLLINE "begin"
SQLLINE "x:=dbms_sqldiag.${vLine};"
SQLLINE "dbms_output.put_line('Return value:'||x);"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
SQLPATCH_l () {
x=/tmp/tmp.$$.sqlpatch.lst
SQLNEWF
SQLLINE "set pagesi 0 head off feedback off verify off"
SQLLINE "select name from dba_sql_patches;"
SQLEXEC > ${x}
}
# ------------------------------------------------------------
f_patch_list () { 
SQLQRY "select name, category, signature, created, status, task_id, task_exec_name from dba_sql_patches order by task_id;"
}
# ------------------------------------------------------------
f_patch_drop () { 
INPUT
SQLPATCH_p "DROP_SQL_PATCH(NAME=>'${input}')"
}
# ------------------------------------------------------------
f_patch_drop_all () { 
SQLPATCH_l
cat ${x} | while read input
do
SQLPATCH_p "DROP_SQL_PATCH(NAME=>'${input}')"
done
}
# ------------------------------------------------------------
f_patch_accept () { 
INPUT
SQLPATCH_p "ACCEPT_SQL_PATCH(TASK_NAME=>'${input}')"
}
# ------------------------------------------------------------
f_patch_stgcre () {
SQLPATCH_p "CREATE_STGTAB_SQLPATCH(TABLE_NAME=>'${STGTAB_SQLPATCH}',schema_name=>'${STGTAB_OWNER}')"
}
# ------------------------------------------------------------
f_patch_stgdrp () {
SQLQRY "drop table ${STGTAB_OWNER}.${STGTAB_SQLPATCH} purge;"
}
# ------------------------------------------------------------
f_patch_stgtru () {
SQLQRY "truncate table ${STGTAB_OWNER}.${STGTAB_SQLPATCH};"
}
# ------------------------------------------------------------
f_patch_stgcnt () {
SQLQRY "select count(1) from ${STGTAB_OWNER}.${STGTAB_SQLPATCH};"
}
# ------------------------------------------------------------
f_patch_pack () {
SQLPATCH_p "pack_stgtab_sqlpatch(staging_table_name=>'${STGTAB_SQLPATCH}',staging_schema_owner=>'${STGTAB_OWNER}')"
}
# ------------------------------------------------------------
f_patch_unpack () {
SQLPATCH_p "unpack_stgtab_sqlpatch(staging_table_name=>'${STGTAB_SQLPATCH}',staging_schema_owner=>'${STGTAB_OWNER}',replace=>true)"
}
# ------------------------------------------------------------
f_patch_stgexp () {
x=/tmp/sqlpatch_stgtab_$(date '+%Y%m%d_%H%M%S')
${ORACLE_HOME}/bin/exp userid='/' file=${x}.dmp log=${x}.log tables=${STGTAB_OWNER}.${STGTAB_SQLPATCH} statistics=none
ECHO "Export file name = $x"
}
# ------------------------------------------------------------
f_patch_stgimp () {
INPUT
x=/tmp/patch_stgtab_$(date '+%Y%m%d_%H%M%S')
${ORACLE_HOME}/bin/imp userid='/' file=${input} log=${x}_imp.log fromuser=${STGTAB_OWNER} touser=${STGTAB_OWNER} ignore=y
}
# ------------------------------------------------------------
