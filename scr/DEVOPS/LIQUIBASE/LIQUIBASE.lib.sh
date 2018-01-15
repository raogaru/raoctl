# ------------------------------------------------------------
rc_LIQUIBASE_PROPERTIES_FILE=${rc_LIQUIBASE_DEFAULT_PROPERTIES_FILE:=${CFG_DIR}/liquibase-properties.txt}
rc_LIQUIBASE_DB_CHANGE_LOG_FILE_TYPE=${rc_LIQUIBASE_DB_CHANGE_LOG_FILE_TYPE:=yaml}
rc_LIQUIBASE_DB_CHANGE_LOG_FILE_NAME=${rc_LIQUIBASE_DB_CHANGE_LOG_FILE_NAME:=${CFG_DIR}/liquibase-db-change-log.xml}
rc_LIQUIBASE_LOG_LVEL=${rc_LIQUIBASE_LOG_LVEL:=info}
# ------------------------------------------------------------
# Module specific common functions
LIQUIBASE () {
v_debug=1
DEBUG "LIQUIBASE_HOME=${LIQUIBASE_HOME}"
DEBUG "rc_LIQUIBASE_PROPERTIES_FILE=${rc_LIQUIBASE_PROPERTIES_FILE}"
DEBUG "rc_LIQUIBASE_DB_CHANGE_LOG_FILE_NAME=${rc_LIQUIBASE_DB_CHANGE_LOG_FILE_NAME}"
${LIQUIBASE_HOME}/liquibase --defaultsFile=${rc_LIQUIBASE_PROPERTIES_FILE} --changeLogFile=${rc_LIQUIBASE_DB_CHANGE_LOG_FILE_NAME} --logLevel=${rc_LIQUIBASE_LOG_LVEL} "$*"
v_debug=0
}
# ------------------------------------------------------------
