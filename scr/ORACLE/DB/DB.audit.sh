# ############################################################
# AUDIT FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# DB AUDIT actions
action_L1="report_options report_trail report_audited "
action_L2="report_all "
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
# Connect to SQLPLUS and execute script
REPEXEC () {  #1-user 2=password 3=SID 4=sqlfile
if [[ $1 = "as" && $2 = "sysdba" ]] ; then
	constr="/ as sysdba"
else
	constr="${1}/${2}@${3}"
fi
if [[ -z $4 ]]; then
	SQLFILE=${TMPSQL}
else
	SQLFILE=$4
fi
#echo Executing SQL $SQLFILE as $constr
cat $SQLFILE >> $STRLOG
export ORACLE_SID=$3
${ORACLE_HOME}/bin/sqlplus -s /nolog <<-EOFsql
connect $constr
--show user	
set echo off feedback off pagesi 0 termout on linesi 1000 trimspool on
set serveroutput on size 10000
spool ${TMPLOG} append
@${SQLFILE}
spool off
EOFsql
}
# ------------------------------------------------------------
info_db () {
# ========
ADD_H2_LINK "Database"
ADD_H2_HEADER "DATABASE INFO"
ADD_H3_DETAIL "\
DATABASE:dbinfo,\
INSTANCE:instinfo"
}
# ========
info_audit_options() {
ADD_H2_LINK "Options"
ADD_H2_HEADER "AUDIT OPTIONS INFO"
ADD_H3_DETAIL "\
OBJECT_AUDIT_OPTIONS:a_obj_audit_opts.sql,\
PRIVILEGE_AUDIT_OPTIONS:a_priv_audit_opts.sql,\
STATEMENT_AUDIT_OPTIONS:a_stmt_audit_opts.sql"
}
# ========
info_audit_audited() {
ADD_H2_LINK "Audited Info"
ADD_H2_HEADER "AUDITED INFO"
ADD_H3_DETAIL "\
AUDITED_OBJECTS:a_audit_object.sql,\
AUDITED_SESSIONS:a_audit_session.sql,\
AUDITED_STATEMENTS:a_audit_statement.sql"
}
# ========
info_audit_trail() {
ADD_H2_LINK "Trail"
ADD_H2_HEADER "AUDIT TRAIL INFO"
ADD_H3_DETAIL "\
AUDIT_TRAIL:a_audit_trail.sql"
}
# ------------------------------------------------------------
f_audit_report_options () {
INCLIB_c RPT
# ========
info_db
info_audit_options
# ========
ECHO "Preparing SQL to generate HTML report"
f_html_report "DB_AUDIT_Options_Report" "DB AUDIT Options Report" "DB AUDIT Options Report"
SQLEXEC
}
# ------------------------------------------------------------
f_audit_report_trail () {
INCLIB_c RPT
# ========
info_db
info_audit_trail
# ========
ECHO "Preparing SQL to generate HTML report"
f_html_report "DB_AUDIT_Trail_Report" "DB AUDIT Trail Report" "DB AUDIT Trail Report"
SQLEXEC
}
# ------------------------------------------------------------
f_audit_report_audited () {
INCLIB_c RPT
# ========
info_db
info_audit_audited
# ========
ECHO "Preparing SQL to generate HTML report"
f_html_report "DB_AUDIT_Audited_Report" "DB AUDIT Audited Report" "DB AUDIT Audited Report"
SQLEXEC
}
# ------------------------------------------------------------
