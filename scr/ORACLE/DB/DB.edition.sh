# ############################################################
# EDITIONS FUNCTIONS - EDITION BASED SCHEMAS
# ############################################################
# ------------------------------------------------------------
# DB EDITION actions
action_L1="list create drop set  "
action_L2="user_enable user_disable user_grant user_revoke deploy "
action_L3="x "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
all,None,Report_all \
"
# ------------------------------------------------------------
# Module specific environment variables
v_debug=0
# ------------------------------------------------------------
f_edition_list () {
SQLNEWF
SQLLINE "set pagesi 1000 head on feedback on lines 120 trimspool on"
SQLLINE "col edition_name format a30"
SQLLINE "col parent_edition_name format a30"
SQLLINE "col current_edition format a30"
SQLLINE "SELECT e.edition_name, e.parent_edition_name, e.usable, p.property_value current_edition FROM dba_editions e, database_properties p WHERE e.edition_name= p.property_value (+) order by e.edition_name;"
SQLEXEC
}
# ------------------------------------------------------------
f_edition_create () {
INPUT 
SQLRUN "create edition ${input1} ;"
}
# ------------------------------------------------------------
f_edition_drop () {
INPUT 
SQLRUN "drop edition ${input1} ;"
}
# ------------------------------------------------------------
f_edition_set () {
INPUT
SQLQRY "alter database default edition=${input1};"
}
# ------------------------------------------------------------
f_edition_user_enable () {
INPUT
SQLRUN "alter user ${input} enable editions;"
}
# ------------------------------------------------------------
f_edition_user_disable () {
INPUT
SQLRUN "alter user ${input} disable editions;"
}
# ------------------------------------------------------------
f_edition_user_grant () {
INPUT 2
SQLRUN "grant use on edition ${input1} to ${input2};"
}
# ------------------------------------------------------------
f_edition_user_revoke() {
ECHO "x"
}
# ------------------------------------------------------------
f_edition_deploy () {
INPUT 3
# 1=username 2=edition_name 3=sql_script
SQLNEWF
SQLLINE "alter session set current_schema=${input1};"
SQLLINE "alter session set edition=${input2};"
SQLLINE "select sys_context('USERENV', 'SESSION_EDITION_NAME') as edition from dual;"
SQLLINE "@${input3}"
SQLEXEC
}
# ------------------------------------------------------------
