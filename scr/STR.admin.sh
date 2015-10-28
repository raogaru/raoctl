# ############################################################
# STREAMS ADMIN FUNCTIONS - Oracle Streams Administration
# ############################################################
# ------------------------------------------------------------
# STREAMS ADMIN actions
action_L1="instantiate "
action_L2="archives needed_archives purge_archives "
action_L3="queues "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
needed_archives,,List_purgeable_archive_logs \
purge,,Purge_Archives \
"
# ------------------------------------------------------------
# Module specific environment variables
STREAMS_CONF=${CFG_DIR}/streams.cfg
STRLOG=${LOG_DIR}/streams_config.log
STRADM=ADM
v_debug=0
# ------------------------------------------------------------
f_admin_needed_archives () {
SQLQRY "SELECT r.CONSUMER_NAME, max(r.sequence#) purge_until_seq FROM DBA_REGISTERED_ARCHIVED_LOG r, DBA_CAPTURE c WHERE r.CONSUMER_NAME = c.CAPTURE_NAME and r.next_scn < c.required_checkpoint_scn group by r.consumer_name;"
}

# ------------------------------------------------------------
f_admin_purge_archives () {
purge_until_seq=$(SQLRET "select min(purge_until_seq) from (SELECT r.CONSUMER_NAME, max(r.sequence#) purge_until_seq FROM DBA_REGISTERED_ARCHIVED_LOG r, DBA_CAPTURE c WHERE r.CONSUMER_NAME = c.CAPTURE_NAME and r.next_scn < c.required_checkpoint_scn group by r.consumer_name);")
ECHO "Remove archive log until Sequence = $purge_until_seq"
SQL2LST "select name from (select distinct sequence#,name from DBA_REGISTERED_ARCHIVED_LOG where sequence#<=${purge_until_seq} order by sequence#);"
cat ${SQL2LST_LST} | while read archlog_name
do
EXECME "rm -f $archlog_name"
done
}
# ------------------------------------------------------------
f_admin_rule () {
ECHO "not coded yet"
}
