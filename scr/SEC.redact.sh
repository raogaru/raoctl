# ############################################################
# DBMS_READACT FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# REDACT actions
action_L1="list_pol list_col list_def_val  "
action_L2="create drop enable disable addcol drpcol set_pol_desc set_col_desc "
action_L3="mask_full mask_none mask_random mask_part mask_regexp "
action_L4="set_expr "
action_L="$action_L1 $action_L2 $action_L3 $action_L4"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list_pol,none,List_Policies \
list_col,none,List_Policy_Columns \
list_def_val,none,List_Default_full_readact_values \
create,object_name,Create_Policy \
drop,object_name,Drop_Policy \
enable,object_name,Enable_Policy \
disable,object_name,Disable_Policy \
addcol,object_name:column_name,Add_Column_to_Policy \
drpcol,object_name:column_name,Delete_Column_from_Policy \
mask_full,object_name:column_name,Set_redaction_type_full \
mask_none,object_name:column_name,Set_redaction_type_none \
mask_part,object_name:column_name:func_type,Set_redaction_type_partial \
set_pol_desc,object_name:policy_desc,Set_redaction_policy_description \
set_col_desc,object_name:column_name:column_desc,Set_redaction_column_description \
set_expr,Set_redaction_policy_conditional_expression \
"
# ------------------------------------------------------------
# Modify Global variables
v_debug=0
# ------------------------------------------------------------
# Set Local variables
raoctl_SET_CONTAINER=${raoctl_SET_CONTAINER:=pdb1}
SQLPLUS_LINE_1="alter session set container=${raoctl_SET_CONTAINER};"
# ------------------------------------------------------------
REDACT_p () {
vLine="$*"
SQLNEWF
SQLLINE "exec dbms_redact.${vLine};"
SQLEXEC
}
# ------------------------------------------------------------
R_SCHEMA=${raoctl_REDACT_SCHEMA:=DBSNMP} 
# ------------------------------------------------------------
REDACT_POLICY () {
REDACT_p "${1}(object_schema=>upper('${R_SCHEMA}'),object_name=>upper('${2}'), policy_name=>upper('${R_SCHEMA}_${2}'))"
}
# ============================================================
f_redact_list_pol () {
SQLNEWF
SQLLINE "set head on pagesi 1000 linesi 150 trimspool on recsepchar '-'"
SQLLINE "col object_owner format a10"
SQLLINE "col object_name format a30"
SQLLINE "col policy_name format a50"
SQLLINE "col expression format a30"
SQLLINE "select enable, object_owner, object_name, policy_name, expression --,policy_description"
SQLLINE "from redaction_policies order by 2,3;"
SQLEXEC
}
# ------------------------------------------------------------
f_redact_list_col () {
SQLNEWF
SQLLINE "set head on pagesi 1000 linesi 200 trimspool on recsepchar '-'"
SQLLINE "col object_owner format a10"
SQLLINE "col object_name format a30"
SQLLINE "col column_name format a30"
SQLLINE "col policy_name format a40"
SQLLINE "col function_type format a18"
SQLLINE "col function_parameters format a30"
SQLLINE "select object_owner, object_name, column_name, function_type, function_parameters --,column_description"
SQLLINE "from redaction_columns order by 1,2,3;"
SQLEXEC
}
# ------------------------------------------------------------
f_redact_list_def_val  () {
SQLNEWF
SQLLINE "set head off feedback off pagesi 0 linesi 200 trimspool on recsepchar '-'"
SQLLINE "col c1 format a40"
SQLLINE "col c2 format a40"
SQLLINE "prompt DATA_TYPE_NAME  FULL_REDACTION_DEFAULT_VALUE"
SQLLINE "prompt"
SQLLINE "select 'NUMBER_VALUE' c1,NUMBER_VALUE c2 from REDACTION_VALUES_FOR_TYPE_FULL;"
SQLLINE "select 'BINARY_FLOAT_VALUE' c1,BINARY_FLOAT_VALUE c2 from REDACTION_VALUES_FOR_TYPE_FULL;"
SQLLINE "select 'BINARY_DOUBLE_VALUE' c1,BINARY_DOUBLE_VALUE c2 from REDACTION_VALUES_FOR_TYPE_FULL;"
SQLLINE "select 'CHAR_VALUE' c1,CHAR_VALUE c2 from REDACTION_VALUES_FOR_TYPE_FULL;"
SQLLINE "select 'VARCHAR_VALUE' c1,VARCHAR_VALUE c2 from REDACTION_VALUES_FOR_TYPE_FULL;"
SQLLINE "select 'NCHAR_VALUE' c1,NCHAR_VALUE c2 from REDACTION_VALUES_FOR_TYPE_FULL;"
SQLLINE "select 'DATE_VALUE' c1,DATE_VALUE c2 from REDACTION_VALUES_FOR_TYPE_FULL;"
SQLLINE "select 'TIMESTAMP_VALUE' c1,TIMESTAMP_VALUE c2 from REDACTION_VALUES_FOR_TYPE_FULL;"
SQLLINE "select 'TIMESTAMP_WITH_TIME_ZONE_VALUE' c1,TIMESTAMP_WITH_TIME_ZONE_VALUE c2 from REDACTION_VALUES_FOR_TYPE_FULL;"
SQLLINE "select 'BLOB_VALUE' c1,BLOB_VALUE c2 from REDACTION_VALUES_FOR_TYPE_FULL;"
SQLLINE "select 'CLOB_VALUE' c1,CLOB_VALUE c2 from REDACTION_VALUES_FOR_TYPE_FULL;"
SQLLINE "select 'NCLOB_VALUE' c1,NCLOB_VALUE c2 from REDACTION_VALUES_FOR_TYPE_FULL;"
SQLEXEC
}
# ------------------------------------------------------------
f_redact_create () {
INPUT
REDACT_p "add_policy(object_schema=>upper('${R_SCHEMA}'),object_name=>upper('${input1}'), policy_name=>upper('${R_SCHEMA}_${input1}'),expression=>'1=1')"
}
# ------------------------------------------------------------
f_redact_drop () {
INPUT
REDACT_POLICY "drop_policy" "${input1}" 
}
# ------------------------------------------------------------
f_redact_enable () {
INPUT
REDACT_POLICY "enable_policy" "${input1}" 
}
# ------------------------------------------------------------
f_redact_disable () {
INPUT
REDACT_POLICY "disable_policy" "${input1}" 
}
# ------------------------------------------------------------
f_redact_addcol () {
INPUT 2
REDACT_p "alter_policy(object_schema=>upper('${R_SCHEMA}'),object_name=>upper('${input1}'),column_name=>upper('${input2}'), policy_name=>upper('${R_SCHEMA}_${input1}'),action=>dbms_redact.add_column)"
}
# ------------------------------------------------------------
f_redact_drpcol () {
INPUT 2
REDACT_p "alter_policy(object_schema=>upper('${R_SCHEMA}'),object_name=>upper('${input1}'),column_name=>upper('${input2}'), policy_name=>upper('${R_SCHEMA}_${input1}'),action=>dbms_redact.drop_column)"
}
# ------------------------------------------------------------
f_redact_set_pol_desc () {
INPUT 2
REDACT_p "alter_policy(object_schema=>upper('${R_SCHEMA}'),object_name=>upper('${input1}'), policy_name=>upper('${R_SCHEMA}_${input1}'),action=>dbms_redact.set_policy_description,policy_description=>'${input2}')"
}
# ------------------------------------------------------------
f_redact_set_col_desc () {
INPUT 3
REDACT_p "alter_policy(object_schema=>upper('${R_SCHEMA}'),object_name=>upper('${input1}'),column_name=>upper('${input2}'), policy_name=>upper('${R_SCHEMA}_${input1}'),action=>dbms_redact.set_column_description,column_description=>'${input3}')"
}
# ------------------------------------------------------------
f_redact_mask_full () {
INPUT 2
REDACT_p "alter_policy(object_schema=>upper('${R_SCHEMA}'),object_name=>upper('${input1}'),column_name=>upper('${input2}'), policy_name=>upper('${R_SCHEMA}_${input1}'),action=>dbms_redact.modify_column,function_type=>dbms_redact.full)"
}
# ------------------------------------------------------------
f_redact_mask_none () {
INPUT 2
REDACT_p "alter_policy(object_schema=>upper('${R_SCHEMA}'),object_name=>upper('${input1}'),column_name=>upper('${input2}'), policy_name=>upper('${R_SCHEMA}_${input1}'),action=>dbms_redact.modify_column,function_type=>dbms_redact.none)"
}
# ------------------------------------------------------------
f_redact_mask_random () {
INPUT 2
REDACT_p "alter_policy(object_schema=>upper('${R_SCHEMA}'),object_name=>upper('${input1}'),column_name=>upper('${input2}'), policy_name=>upper('${R_SCHEMA}_${input1}'),action=>dbms_redact.modify_column,function_type=>dbms_redact.random)"
}
# ------------------------------------------------------------
f_redact_mask_part () {
INPUT 3
typeset -u INPUT3=$input3
#x="US_SSN_F5 US_SSN_L4 US_SSN_ENTIRE NUM_US_SSN_F5 NUM_US_SSN_L4 NUM_US_SSN_ENTIRE ZIP_CODE NUM_ZIP_CODE CCN16_F12 CCN16_F12 DATE_EPOCH"
#[[ ! ${INPUT3} = @($x) ]] && ERROR "Invalid partial function_parameter $INPUT3. Valid values are $x"
REDACT_p "alter_policy(object_schema=>upper('${R_SCHEMA}'),object_name=>upper('${input1}'),column_name=>upper('${input2}'), policy_name=>upper('${R_SCHEMA}_${input1}'),action=>dbms_redact.modify_column,function_type=>dbms_redact.partial, function_parameters=>dbms_redact.REDACT_${input3})"
}
# ------------------------------------------------------------
f_redact_mask_regexp () {
INPUT 4
typeset -u INPUT3=$input3
typeset -u x="ANY_DIGIT CC_L6_T4 US_PHONE EMAIL_ADDRESS IP_ADDRESS"
#[[ ! ${INPUT3} = @($x) ]] && ERROR "Invalid partial function_parameter $INPUT3. Valid values are $x"
REDACT_p "alter_policy(object_schema=>upper('${R_SCHEMA}'),object_name=>upper('${input1}'),column_name=>upper('${input2}'), policy_name=>upper('${R_SCHEMA}_${input1}'),action=>dbms_redact.modify_column,function_type=>dbms_redact.regexp, regexp_pattern=>dbms_redact.RE_PATTERN_${input3},regexp_replace_string=>dbms_redact.RE_REDACT_${input4})"
}
# ------------------------------------------------------------
f_redact_set_expr () {
INPUT 2
REDACT_p "alter_policy(object_schema=>upper('${R_SCHEMA}'),object_name=>upper('${input1}'), policy_name=>upper('${R_SCHEMA}_${input1}'),action=>dbms_redact.modify_expression,expression=>'${input2}')"
}
# ------------------------------------------------------------
