# ############################################################
# SQL REPORT FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# SQL Performance Report actions
action_L1="sqlset tunetask baseline awr ash all "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
xx,xx,xx \
"
# ------------------------------------------------------------
# local variables

# ------------------------------------------------------------
# Module specific environment variables
STREAMS_CONF=${CFG_DIR}/streams.cfg
STRLOG=${LOG_DIR}/streams_setup.log
STRADM=ADM
v_debug=0
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
info_sqlset() {
ADD_H2_LINK "SQL Tuning Sets"
ADD_H2_HEADER "SQLSET INFO"
ADD_H3_DETAIL "\
LIST:x_sqlset_list.sql,\
SQLs:x_sqlset_listsql.sql,\
REFERENCES:x_sqlset_listref.sql"
}
# ========
info_tunetask () {
ADD_H2_LINK "SQL Tuning Tasks"
ADD_H2_HEADER "TUNETASK INFO"
ADD_H3_DETAIL "\
LIST:x_tunetask_list.sql,\
EXECUTIONS:x_tunetask_listexec.sql"
}
# ========
info_baseline () {
ADD_H2_LINK "SQL Baselines"
ADD_H2_HEADER "BASELINE INFO"
ADD_H3_DETAIL "\
LIST:x_baseline_list.sql,\
COUNT:x_baseline_count.sql"
}
# ------------------------------------------------------------
# ========
info_profile () {
ADD_H2_LINK "SQL Profiles"
ADD_H2_HEADER "SQL PROFILE INFO"
ADD_H3_DETAIL "\
LIST:x_profile_list.sql"
}
# ------------------------------------------------------------
f_report_sqlset () {
INCLIB_c RPT
# ========
info_db
info_sqlset
# ========
ECHO "Preparing SQL to generate HTML report"
f_html_report "SQL_Tuning_Sets_Report" "SQL Tuning Sets Report" "SQL Tuning Sets Report" 
SQLEXEC
}
# ------------------------------------------------------------
f_report_tunetask () {
INCLIB_c RPT
# ========
info_db
info_tunetask
# ========
ECHO "Preparing SQL to generate HTML report"
f_html_report "SQL_Tuning_Tasks_Report" "SQL Tuning Tasks Report" "SQL Tuning Tasks Report"
SQLEXEC
}
# ------------------------------------------------------------
f_report_baseline () {
INCLIB_c RPT
# ========
info_db
info_baseline
# ========
ECHO "Preparing SQL to generate HTML report"
f_html_report "SQL_Baseline_Report" "SQL Baseline Report" "SQL Baseline Report"
SQLEXEC
}
# ------------------------------------------------------------
f_report_all () {
INCLIB_c RPT
# ========
info_db
info_sqlset
info_tunetask
info_baseline
info_profile
# ========
ECHO "Preparing SQL to generate HTML report"
f_html_report "SQL_Performance_Tools_Report" "SQL Performance Tools Report" "SQL Performance Tools_Report" 
SQLEXEC
}
# ------------------------------------------------------------
