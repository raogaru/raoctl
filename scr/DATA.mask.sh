# ############################################################
# DATA MASK FUNCTIONS - raoctl custom data masking
# ############################################################
# ------------------------------------------------------------
# DATA MASK actions
action_L1="cre_tbl drp_tbl load_tbl sel_tbl  "
action_L2="add_col rem_col val_tbl run_mask "
action_L3="x "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
cre_tbl,none,Create_Masking_List_Table \
drp_tbl,none,Drop_Masking_List_Table \
load_tbl,insert_sql_file,Load_Masking_List_Table \
sel_tbl,none,Select_Masking_List_Table \
val_tbl,none,Validate_Masking_List_Table \
run_mask,none,Run_Data_Masking_Routine \
"
# ------------------------------------------------------------
# Global variables
rc_SHOW_SQL=YES
rc_SHOW_LINE=YES
# ------------------------------------------------------------
# Module specific environment variables
v_debug=0
v_schema=${rc_MASK_SCHEMA:="RAO"}
v_msktbl=${rc_MASK_LIST_TABLE:="DATA_MASK_LIST"}
[[ "${v_msktbl}" = MSKTBL" || "${v_msktbl}" = msktbl" ]] && ERROR "Cannot use msktbl as table_name. Synonym will be created with this name"
# ------------------------------------------------------------
f_mask_cre_tbl () {
SQLNEWF
SQLLINE "alter session set current_schema=${v_schema};"
SQLLINE "create table ${v_msktbl} ( seq number, own varchar2(30), tab varchar2(30), col varchar2(30), typ varchar2(10), len number(4), msk varchar2(30), val varchar2(30)) ;"
SQLLINE "create index ${v_msktbl}_pk on ${v_msktbl} (own,tab,col);"
SQLLINE "alter table ${v_msktbl} add constraint ${v_msktbl}_pk primary key (own,tab,col);"
SQLLINE "create synonym msktbl for ${v_schema}.${v_msktbl};"
SQLLINE "create sequence mskseq;"
SQLLINE "@mskpkg.pks"
SQLLINE "@mskpkg.pkb"
SQLEXEC
}
# ------------------------------------------------------------
f_mask_drp_tbl () {
SQLNEWF
SQLLINE "alter session set current_schema=${v_schema};"
SQLLINE "drop table ${v_msktbl} purge;"
SQLLINE "drop synonym msktbl;"
SQLLINE "drop sequence mskseq;"
SQLLINE "drop package mskpkg;"
SQLEXEC
}
# ------------------------------------------------------------
f_mask_load_tbl () {
#INPUT
SQLNEWF
SQLLINE "alter session set current_schema=${v_schema};"
SQLLINE "@msktbl_insert.sql"
#SQLRUN "@${input1}"
SQLEXEC
}
# ------------------------------------------------------------
f_mask_sel_tbl () {
SQLNEWF
SQLLINE "alter session set current_schema=${v_schema};"
SQLLINE "set linesi 120 trims on pages 1000 head on"
SQLLINE "col own format a5"
SQLLINE "col tab format a5"
SQLLINE "col col format a20"
SQLLINE "col msk format a20"
SQLLINE "select seq,own,tab,col,typ,len,msk,val from msktbl;"
SQLEXEC
}
# ------------------------------------------------------------
f_mask_add_col () {
INPUT 7
SQLNEWF
SQLLINE "alter session set current_schema=${v_schema};"
SQLLINE "set serveroutput on size 10000"
SQLLINE "insert into msktbl (seq, own, tab, col, typ, len, msk, val) values "
SQLLINE "(mskseq.nextval,'${input1}','${input2}','${input3}','${input4}',${input5},'${input6}',${input7});"
SQLLINE "commit;"
SQLEXEC
}
# ------------------------------------------------------------
f_mask_rem_col () {
INPUT 3
SQLNEWF
SQLLINE "alter session set current_schema=${v_schema};"
SQLLINE "set serveroutput on size 10000"
SQLLINE "delete from msktbl where own='${input1}' and tab='${input2}' and col='${input3}';"
SQLLINE "commit;"
SQLEXEC
}
# ------------------------------------------------------------
f_mask_val_tbl () {
SQLNEWF
SQLLINE "set serveroutput on size 10000"
SQLLINE "alter session set current_schema=${v_schema};"
SQLLINE "exec ${v_schema}.mskpkg.mask(i_validate=>true,i_run=>false);"
SQLEXEC
}
# ------------------------------------------------------------
f_mask_run_mask () {
SQLNEWF
SQLLINE "set serveroutput on size 10000"
SQLLINE "alter session set current_schema=${v_schema};"
SQLLINE "exec ${v_schema}.mskpkg.mask(i_validate=>true,i_run=>true);"
SQLEXEC
}
# ------------------------------------------------------------
