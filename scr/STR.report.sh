# ############################################################
# STREAMS REPORT FUNCTIONS - Oracle Streams
# ############################################################
# ------------------------------------------------------------
# STREAMS SETUP actions
action_L1="captures propagations applys rules stats  "
action_L2="all hc diag  "
action_L3="ppp "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
hc,None,Report_HealthCheck \
all,None,Report_all \
diag,None,Report_Diagnostic Info \
"
# ------------------------------------------------------------
INCLIB_c
# ------------------------------------------------------------
# REPLICATION SITES CONFIGURATION INFO in MultiMaster.cfg
#STREAM_SITES=US,EU,AP
#SITE_INFO_US=DBO:DB50:DB50
#SITE_INFO_EU=DBO:DB51:DB51
#SITE_INFO_AP=DBO:DB52:DB52
# ------------------------------------------------------------
TestConnection () {
DEBUG TestConnection to ${ON_SID}
SQLNEWF
SQLLINE "select user from dual;"
STREXEC as sysdba ${ON_SID} 
}
# ------------------------------------------------------------
ReadConfigInfo () {
[[ ! -f ${STREAMS_CONF} ]] && ERROR "${STREAMS_CONF} config file not found !!!"
site_A=$(grep "^STREAM_SITES=" ${STREAMS_CONF} | cut -f2 -d"=" | sed -e 's/,/ /g')
SITEA=(${site_A})		#bash shell
#set -A SITEA ${site_A}		#ksh shell
#set -A SIDA
#set -A DBOA
i=0
for SITE in ${SITEA[*]}
do
	#DEBUG ========== SITE:${SITE}:
	X=$(grep "^SITE_INFO_${SITE}" ${STREAMS_CONF} |cut -f2 -d"=")
	DBOA[$i]=$(echo $X|cut -f1 -d":")
	SIDA[$i]=$(echo $X|cut -f2 -d":")
	#echo X=${X}
	DEBUG SITE=${SITEA[$i]}:SID=${SIDA[$i]}:DBO=${DBOA[$i]}
	(( i = i+1 ))
done
}
# ------------------------------------------------------------
ReportStreams () {
ACTION=${1}
i=0
while  [ $i -lt ${#SITEA[*]} ] # for each site
do
	ON_SITE=${SITEA[$i]}
	ON_SID=${SIDA[$i]}
	ON_DBO=${DBOA[$i]}
	ON_TNS=${TNSA[$i]}
	#RAO1
	ECHO ${cLINE1}
	ECHO "ON site ${SITEA[$i]}"
	ECHO ${cLINE1}
	TestConnection

	j=0
	while  [ $j -lt ${#SITEA[*]} ] 
	do
		TO_SITE=${SITEA[$j]}
		TO_SID=${SIDA[$j]}
		TO_DBO=${DBOA[$j]}
		TO_TNS=${TNSA[$j]}
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~
		DIRECTION_NAME=${ON_SITE}_TO_${TO_SITE}

		APPLY_QUEUE_TABLE_NAME=${APPLY_QUEUE_NAME}T
		
		PROPAGATION_NAME=P_${ON_SITE}_TO_${TO_SITE}
		STREXEC as sysdba ${ON_SID} 
		
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~
		(( j = j+1 ))
	done
	(( i = i+1 ))
done
}
# ------------------------------------------------------------
info_db () {
# ========
ADD_H2_LINK "Database"
ADD_H2_HEADER "DATABASE INFO"
ADD_H3_DETAIL "\
DATABASE:dbinfo,\
INSTANCE:instinfo,\
CONTROL_FILES:cfiles,\
DATA_FILES:dfiles,\
REDO_LOG_FILES:lfiles" 
}
# ========
info_captures() {
ADD_H2_LINK "Captures"
ADD_H2_HEADER "CAPTURES INFO"
ADD_H3_DETAIL "\
LIST:s_capture_rulesets.sql,\
Applied_SCN:s_capture_applied_scn.sql,\
PARAMETERS:s_capture_parameters.sql,\
ATTRIBUTES:s_capture_attributes.sql,\
COMBINED_CAPTURES:s_capture_combined_capture.sql,\
DOWNSTREAM_CAPTURES:s_capture_downstream.sql,\
LAST_ARCHLOG_AVAILABLE:s_capture_last_arch_redolog.sql,\
REGISTERED_REDO:s_capture_registered_redolog.sql,\
REQUIRED_REDO:s_capture_required_redolog.sql,\
REDO_SCAN_LATENCY:s_capture_redo_scan_latency.sql,\
RULE_EVALUATIONS:s_capture_rule_evaluations.sql,\
SESSIONS:s_capture_sessions.sql,\
SESSION_STATISTICS:s_capture_sessstat.sql,\
MESSAGE_TIMING:s_capture_msg_timing.sql,\
ELAPSED_TIMES:s_capture_elapsed_time.sql,\
ENQUEUE_LATENCY:s_capture_enqueue_latency.sql"
}
# ========
info_synchronous_captures () {
ADD_H2_LINK "Synchronous Captures"
ADD_H2_HEADER "SYNCHRONOUS CAPTURES INFO"
ADD_H3_DETAIL "\
SYNCHRONOUS_CAPTURE_TABLES:s_syncap_tables.sql,\
SYNCHRONOUS_CAPTURE_QUEUES_RULESETS:s_syncap_queues_rulesets.sql"
}
# ========
info_propagations () {
ADD_H2_LINK "Propagations"
ADD_H2_HEADER "PROPAGATIONS INFO"
ADD_H3_DETAIL "\
LIST:s_prop_dblinks.sql,\
QUEUES:s_prop_queues.sql,\
RULES:s_prop_ruleset.sql,\
SCHEDULES:s_prop_schedules.sql,\
SENDERS:s_prop_senders.sql,\
RECEIVERS:s_prop_receivers.sql,\
SESSIONS:s_prop_sessions.sql,\
STATISTICS:s_prop_msg_stats.sql"
}
# ========
info_applys () {
ADD_H2_LINK "Applys" 
ADD_H2_HEADER "APPLYS INFO"
ADD_H3_DETAIL "\
LIST:s_apply_list.sql,\
PARAMETERS:s_apply_parameters.sql,\
RULESETS:s_apply_queue_ruleset.sql,\
RULES:s_apply_rules.sql,\
NOEXECUTION_RULES:s_apply_noexec_rules.sql,\
READER_SERVERS:s_apply_reader_servers.sql,\
SESSIONS:s_apply_sessions.sql,\
COMBINED_CAPTURE_APPLYS:s_apply_combined_capture.sql,\
COORDINATORS:s_apply_coordinators.sql,\
TRANSACTIONS:s_apply_coord_txn.sql,\
ERRORS:s_apply_errors.sql,\
KEY_COLUMNS:s_apply_key_columns.sql"
}
# ========
info_apply_handlers () {
ADD_H2_LINK "Apply Handlers" 
ADD_H2_HEADER "APPLY HANDLERS INFO"
ADD_H3_DETAIL "\
DDL_HANDLERS:s_apply_ddl_handlers.sql,\
ALL_DML_HANDLERS:s_apply_all_dml_handlers.sql,\
PROCEDURE_DML_HANDLERS:s_apply_proc_dml_handlers.sql,\
STATEMENT_DML_HANDLERS:s_apply_stmt_dml_handlers.sql,\
STATEMENT_DML_HANDLERS_SEQUENCE:s_apply_stmt_dml_handler_seq.sql,\
MESSAGE_HANDLERS:s_apply_msg_handlers.sql,\
PRECOMMIT_HANDLINGS:s_apply_precommit_handlers.sql,\
ERROR_HANDLERS:s_apply_error_handlers.sql"
}
# ========
info_apply_perf () {
ADD_H2_LINK "Apply Performance" 
ADD_H2_HEADER "APPLY PERFORMANCE INFO"
ADD_H3_DETAIL "\
PARALLELISM:s_apply_parallelism.sql,\
MESSAGE_SPILL_RATE:s_apply_msg_spills_rate.sql,\
MESSAGE_SPILL_TRANSACTIONS:s_apply_msg_spills_txn.sql,\
VALUE_DEPDENDENCIES:s_apply_value_dependencies.sql,\
OBJECT_DEPENDENCIES:s_apply_object_dependencies.sql,\
LATENCY_as_per_COORDINATORS:s_apply_latency_asper_coord.sql,\
LATENCY_as_per_READER:s_apply_latency_asper_reader.sql,\
LATENCY_as_per_PROGRESS:s_apply_latency_asper_progress.sql"
}
# ========
info_queues () {
ADD_H2_LINK "Queues" 
ADD_H2_HEADER "QUEUES INFO"
ADD_H3_DETAIL "\
ANYDATA_QUEUES:s_queue_anydata_queues.sql,\
MESSAGE_CLIENTS:s_queue_msg_clients.sql,\
MESSAGE_NOTIFICATIONS:s_queue_msg_notifications.sql,\
PERSISTENT_MESSAGES:s_queue_persistent_msgs.sql,\
VIEW_MESSAGES:s_queue_view_msgs.sql"
}
# ========
info_rules () {
ADD_H2_LINK "Rules" 
ADD_H2_HEADER "RULES INFO"
ADD_H3_DETAIL "\
LIST:s_rules_list.sql,\
POSITIVE_RULES:s_rules_positive.sql,\
NEGATIVE_RULES:s_rules_negative.sql,\
AGGREGATE_STATISTICS:s_ruleset_stats.sql,\
LIST_CONDITIONS:s_rule_conditions.sql,\
CURRENT_CONDITIONS:s_rules_current_condition.sql,\
MODIFIED_CONDITIONS:s_rules_modified_condition.sql"
}
# ========
info_rule_eval_ctx () {
ADD_H2_LINK "Rule Evaluation Context" 
ADD_H2_HEADER "RULE EVALUATION CONTEXT INFO"
ADD_H3_DETAIL "\
RULESET_EVALUATIONS:s_ruleset_evaluations.sql,\
RULESET_EVALUATION_CONTEXT:s_ruleset_eval_context.sql,\
RULESET_EVALUATION_RESOURCES:s_ruleset_eval_resources.sql,\
RULE_EVALUATION_CONTEXT:s_rules_eval_context.sql,\
RULE_EVALUATION_CONTEXT_TABLES:s_rules_eval_context_tables.sql,\
RULE_EVALUATION_CONTEXT_VARIABLES:s_rules_eval_context_variables.sql"
}
# ======== 
info_buff_queues () {
ADD_H2_LINK "Buffered Queues" 
ADD_H2_HEADER "BUFFERED QUEUES INFO" 
ADD_H3_DETAIL "\
CAPTURES:s_bufq_captures.sql,\
APPLYS:s_bufq_dequeue_applys.sql,\
MESSAGE_COUNTS:s_bufq_msg_count.sql,\
ENQUEUE_PROPAGATIONS:s_bufq_enqueue_propagations.sql,\
DEQUEUE_PROPAGATIONS:s_bufq_dequeue_propagations.sql,\
PROPAGATION_MSG_COUNTS:s_bufq_prop_msg_count.sql,\
ENQUEUE_PROPAGATION_SENDER_PERFORMANCE:s_bufq_prop_send_perf_stat.sql,\
DEQUEUE_PROPAGATION_RECEIVER_PERFORMANCE:s_bufq_prop_recv_perf_stat.sql"
}
# ========
info_supp_log () {
ADD_H2_LINK "Supplemental Logging"
ADD_H2_HEADER "SUPPLEMENTAL LOGGING INFO"
ADD_H3_DETAIL "\
DATABASE_LEVEL:s_suplog_database.sql,\
SCHEMA_LEVEL:s_suplog_schemas.sql,\
TABLES_LEVEL:s_suplog_tables.sql,\
GROUPS:s_suplog_groups.sql,\
SPECIFICATIONS:s_suplog_specifications.sql"
}
# ========
info_split_merges () {
ADD_H2_LINK "Split Merges" 
ADD_H2_HEADER "SPLIT and MERGE INFO"
ADD_H3_DETAIL "\
JOBS:s_split_merge_jobs.sql,\
OPERATIONS_HISTORY:s_split_merge_operations.sql,\
THRESHOLDS:s_split_merge_action_thresholds.sql,\
CLONED_CAPTURE_LAG:s_split_merge_cloned_lag.sql,\
MAPPING_of_ORIGINAL_and_CLONES:s_split_merge_mappings.sql"
}
# ========
info_topology () {
ADD_H2_LINK "Topology"
ADD_H2_HEADER "TOPOLOGY INFO"
ADD_H3_DETAIL "\
TOPOLOGY_Performance_Runs:s_topology_perf_run.sql,\
TOPOLOGY_DATABASES:s_topology_database.sql,\
TOPOLOGY_COMPONENTS:s_topology_component.sql,\
TOPOLOGY_COMPONENTS:s_topology_component_link.sql,\
TOPOLOGY_COMPONENTS_STATISTICS:s_topology_component_stat.sql,\
TOPOLOGY_COMPONENTS_SESSION_STATS:s_topology_component_session_stat.sql,\
TOPOLOGY_COMPONENTS_BOTTLENECK:s_topology_path_bottleneck.sql,\
How_to_use_UTL_SPADV:s_topology_utl_spadv.sql"
}
# ========
info_transformations () {
ADD_H2_LINK "Transformtions" 
ADD_H2_HEADER "RULE BASED TRANSFORMATIONS"
ADD_H3_DETAIL "\
LIST:s_xform_info.sql,\
ADD_COLUMN:s_xform_add_column.sql,\
RENAME_TABLE:s_xform_rename_table.sql,\
DECLATIVES:s_xform_declarative.sql,\
CUSTOM_RULES:s_xform_custorm_rule.sql"
}
# ========
info_performance () {
#ADD_H2_LINK "Performance" 
#ADD_H2_HEADER "PERFORMANCE STATISTICS"
#ADD_H3_DETAIL "TEST:test" 
ECHO nothing here
}
# ========
info_diagnosis () {
#ADD_H2_LINK "Diagnosis"
#ADD_H2_HEADER "DIAGNOSIS"
#ADD_H3_DETAIL "TEST:test" 
ECHO nothing here
}
# ========
info_non_compatible () {
ADD_H2_LINK "Non-Compatible"
ADD_H2_HEADER "NON COMPATIBLE CONFIGURATION OBJECTS INFO"
ADD_H3_DETAIL "\
CAPTURE:s_other_noncompatible_objects_capture.sql,\
SYNCHRONOUS_CAPTURE:s_other_noncompatible_objects_syncapture.sql,\
APPLY:s_other_noncompatible_objects_apply.sql"
}
# ========
info_other () {
ADD_H2_LINK "Other Stream Info"
ADD_H2_HEADER "OTHER STREAM INFO"
ADD_H3_DETAIL "\
LOCAL_STREAM_ADMINISTRATORS:s_other_stream_admins_local.sql,\
STREAM_ADMINISTRATORS_ALLOW_REMOTE:s_other_stream_admins_remote.sql,\
STREAM_ALERTS_OUTSTANDING:s_other_stream_alerts_outstanding.sql,\
STREAM_ALERTS_HISTORY:s_other_stream_alerts_history.sql,\
STREAM_POOL_SIZE_ADVISOR:s_other_stream_pool.sql"
}
# ------------------------------------------------------------
f_report_captures () {
INCLIB_c RPT
# ========
info_db 
info_captures
# ========
ECHO "Preparing SQL to generate HTML report"
f_html_report "Streams_Captures_Healthcheck_Report" "Streams Captures Healthcheck Report" "Streams Captures Healthcheck Report"
STREXEC as sysdba US
#SQLEXEC
}
# ------------------------------------------------------------
f_report_applys () {
INCLIB_c RPT
# ========
info_db 
info_applys
# ========
ECHO "Preparing SQL to generate HTML report"
f_html_report "Streams_Applys_Healthcheck_Report" "Streams Applys Healthcheck Report" "Streams Applys Healthcheck Report"
STREXEC as sysdba US
#SQLEXEC
}
# ------------------------------------------------------------
f_report_all () {
INCLIB_c RPT
# ========
info_db 
info_captures
info_synchronous_captures 
info_propagations 
info_applys 
info_apply_handlers 
info_apply_perf 
info_queues 
info_rules 
info_rule_eval_ctx 
info_buff_queues 
info_supp_log 
info_split_merges 
info_topology 
info_transformations 
info_performance 
info_diagnosis 
info_non_compatible 
info_other 
# ========
ReadConfigInfo
for SITE in ${SITEA[*]}
do
	ECHO "Preparing SQL to generate HTML report"
	f_html_report "Streams_Healthcheck_Report_for_${SITE}" "${SITE} Streams Healthcheck Report" "${SITE} Streams Healthcheck Report" 
	STREXEC as sysdba ${SITE}
	(( i = i+1 ))
done
#SQLEXEC
}
# ------------------------------------------------------------
