# ############################################################
# DBD SQLTYPE FUNCTIONS - Database Deployment SQL-Type SQL-Subtype Parsing Engine
# ############################################################
# ------------------------------------------------------------
# DBD SQLTYPE actions
action_L1="sql_str file_1_sql testcase "
action_L="$action_L1 $action_L2 $action_L3 $action_L4"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
process,sql_file_name,Process_SQL_File \
testcase,SQL_Type_in_upper_case_with_under_scores,Process_SQL_File \
"
# ------------------------------------------------------------
# Global variable overwrites
#rc_RULES_CFG=${rc_DBD_SQLRULE_RULES_CFG:=${RC_DIR}/scr/${v_class}/${v_module}/sqlrule.cfg}
rc_SQLTYPE_FOR=${rc_SQLTYPE_FOR:=all}
rc_SQLTYPE_CFG_DIR=${rc_SQLTYPE_CFG_DIR:=${SCR_DIR}/${v_product}/${v_class}/sqltype}
rc_SQLTYPE_CFG_FILE=${rc_SQLTYPE_CFG_DIR}/${rc_SQLTYPE_FOR}.cfg
rc_SQLSUBTYPE_CFG_DIR=${rc_SQLSUBTYPE_CFG_DIR:=${SCR_DIR}/${v_product}/${v_class}/sqlsubtype}
#
rc_FIND_SQLTYPE=${rc_FIND_SQLTYPE:=YES}
rc_FIND_SQLSUBTYPE=${rc_FIND_SQLSUBTYPE:=YES}
rc_FIND_SQLOBJECT=${rc_FIND_SQLOBJECT:=YES}
#rc_PROCESS_SQLTYPE_RULES=${rc_PROCESS_SQLTYPE_RULES:=YES}
#rc_PROCESS_SQLSUBTYPE_RULES=${rc_PROCESS_SQLSUBTYPE_RULES:=YES}
rc_SQLTYPE_WRITE_DESCRIPTIVE_STORY=${rc_SQLTYPE_WRITE_DESCRIPTIVE_STORY:=YES}
#
# ------------------------------------------------------------
# Module specific environment variables
l_SqlTypeID=0
l_SqlType=""			# sql statement type
l_SqlTypeUnderscore=""
l_SqlSubTypeID=0
l_SqlSubType=""			# sql statement sub type
l_SqlObjectName=""
l_SqlSubTypeSearchName=""
ucSqlStr=""
vRulesGrepPattern=""

# ------------------------------------------------------------
# Module specific common functions

# ------------------------------------------------------------
#CHKFILE ${rc_SQLRULE_RULES_CFG}
#CHKFILE ${rc_SQLRULE_SQLTYPE_CFG_FILE}
# ------------------------------------------------------------
# print MATCHED if arg1 has string arg2
fPatternMatch1 () {
echo ${1}|sed -e "s/^${2}.*/MATCHED/"
}

# ------------------------------------------------------------
# print MATCHED if arg1 has string arg2 and arg3
fPatternMatch2 () {
echo ${1}|sed -e "s/^${2}.*${3}.*/MATCHED/"
}

# ------------------------------------------------------------
# print MATCHED if arg1 string has arg2 ... arg4
fPatternMatch3 () {
echo ${1}|sed -e "s/^${2}.*${3}.*${4}.*/MATCHED/"
}

# ------------------------------------------------------------
# print MATCHED if arg1 string has arg2 ... arg5
fPatternMatch4 () {
echo ${1}|sed -e "s/^${2}.*${3}.*${4}.*${5}.*/MATCHED/"
}

# ------------------------------------------------------------
# print MATCHED if arg1 string has arg2 ... arg6
fPatternMatch5 () {
echo ${1}|sed -e "s/^${2}.*${3}.*${4}.*${5}.*${6}.*/MATCHED/"
}

# ------------------------------------------------------------
# print MATCHED if arg1 string has arg2 ... arg7
fPatternMatch6 () {
echo ${1}|sed -e "s/^${2}.*${3}.*${4}.*${5}.*${6}.*.${7}.*/MATCHED/"
}

# ------------------------------------------------------------
# print MATCHED if arg1 string has arg2 ... arg8
fPatternMatch7 () {
echo ${1}|sed -e "s/^${2}.*${3}.*${4}.*${5}.*${6}.*.${7}.*${8}.*/MATCHED/"
}

# ------------------------------------------------------------
# print MATCHED if arg1 string has arg2 ... arg9
fPatternMatch8 () {
echo ${1}|sed -e "s/^${2}.*${3}.*${4}.*${5}.*${6}.*.${7}.*${8}.*${9}.*/MATCHED/"
}

# ------------------------------------------------------------
# find sql type for given sql 
f_find_sql_type () {
mySqlStr=$1
v_debug=0
DEBUG "BEGIN f_find_sql_type"

DEBUG "Parsing sql string as-is : ${input1}"
ucSqlStr=${input1^^}
DEBUG "Parsing sql string in upper-case : ${ucSqlStr}"

# initialize to null. check for null later
l_SqlTypeID=0
l_SqlType=""
l_SqlTypeUnderscore=""

CHKFILE ${rc_SQLTYPE_CFG_FILE}
DEBUG "Using config file ${rc_SQLTYPE_CFG_FILE}"

cat ${rc_SQLTYPE_CFG_FILE} | grep -v "^#" | grep -v "^$" >  ${TMPCFG}.sqltype

i=0
while read -r l_SqlTypeCfg
do
	# replace underscore with space in search string
	l_SqlTypeCfg=${l_SqlTypeCfg//_/ }
	(( i=i+1 ))
	DEBUG "#----------"
	DEBUG "#$i Is it \"${l_SqlTypeCfg}\""
	tSqlStr=${ucSqlStr#${l_SqlTypeCfg}}
	#DEBUG "tSqlStr is ${tSqlStr}"
	if [ "${ucSqlStr}" != "${tSqlStr}" ]; then
		l_SqlTypeID=${i}
		l_SqlType="${l_SqlTypeCfg}"
		l_SqlTypeUnderscore=${l_SqlType// /_}
		break
	else
		DEBUG "no match \"${l_SqlTypeCfg}\""
	fi
done < ${TMPCFG}.sqltype

[[ -z "${l_SqlType}" ]] && ERROR "SQL Type could not be determined ! Is this PLSQL code ?"
DEBUG "SQL Type identified :-)"
DEBUG "END f_find_sql_type l_SqlType=${l_SqlType}"

# write SQL Type story
if [ "${rc_SQLTYPE_WRITE_DESCRIPTIVE_STORY}" = "YES" ]; then
	ECHO "#SQL Input string: ${mySqlStr}"
	ECHO "#SQL Upper string: ${ucSqlStr}"
	ECHO "#SQL Type ID: ${l_SqlTypeID}"
	ECHO "#SQL Type Name ${l_SqlType}"
fi

v_debug=0
}
# ------------------------------------------------------------
f_find_sql_object () {
v_debug=0
DEBUG "BEGIN f_find_sql_object"
# 2nd item is sql object for type1A 
#type1A=( CREATE_TABLESPACE ALTER_TABLESPACE DROP_TABLESPACE CREATE_TABLE ALTER_TABLE DROP_TABLE TRUNCATE_TABLE LOCK_TABLE FLASHBACK_TABLE CREATE_INDEXTYPE ALTER_INDEXTYPE DROP_INDEXTYPE CREATE_INDEX CREATE_UNIQUE_INDEX CREATE_BITMAP_INDEX ALTER_INDEX DROP_INDEX COMMENT ANALYZE RENAME CREATE_VIEW CREATE_OR_REPLACE_VIEW ALTER_VIEW DROP_VIEW CREATE_SEQUENCE ALTER_SEQUENCE DROP_SEQUENCE CREATE_SYNONYM ALTER_SYNONYM DROP_SYNONYM CREATE_GLOBAL_TEMPORARY_TABLE CREATE_CLUSTER DROP_CLUSTER ALTER_CLUSTER TRUNCATE_CLUSTER CREATE_DIMENSION ALTER_DIMENSION DROP_DIMENSION CREATE_OPERATOR ALTER_OPERATOR DROP_OPERATOR CREATE_DIRECTORY DROP_DIRECTORY CREATE_TYPE CREATE_OR_REPLACE_TYPE ALTER_TYPE DROP_TYPE CREATE_TYPE_BODY DROP_TYPE_BODY CREATE_CONTEXT DROP_CONTEXT CREATE_LIBRARY ALTER_LIBRARY DROP_LIBRARY CREATE_JAVA ALTER_JAVA DROP_JAVA ALTER_SESSION ALTER_SYSTEM CREATE_PROCEDURE CREATE_OR_REPLACE_PROCEDURE ALTER_PROCEDURE DROP_PROCEDURE CREATE_FUNCTION CREATE_OR_REPLACE_FUNCTION ALTER_FUNCTION DROP_FUNCTION CREATE_PACKAGE CREATE_OR_REPLACE_PACKAGE ALTER_PACKAGE DROP_PACKAGE CREATE_PACKAGE_BODY CREATE_OR_REPLACE_PACKAGE_BODY CREATE_TRIGGER CREATE_OR_REPLACE_TRIGGER ALTER_TRIGGER DROP_TRIGGER CREATE_MATERIALIZED_VIEW ALTER_MATERIALIZED_VIEW DROP_MATERIALIZED_VIEW CREATE_MATERIALIZED_VIEW_LOG ALTER_MATERIALIZED_VIEW_LOG DROP_MATERIALIZED_VIEW_LOG CREATE_MATERIALIZED_ZONEMAP ALTER_MATERIALIZED_ZONEMAP DROP_MATERIALIZED_ZONEMAP CREATE_DATABASE_LINK ALTER_DATABASE_LINK DROP_DATABASE_LINK CREATE_PFILE CREATE_SPFILE CREATE_RESTORE_POINT DROP_RESTORE_POINT CREATE_EDITION DROP_EDITION CREATE_FLASHBACK_ARCHIVE ALTER_FLASHBACK_ARCHIVE DROP_FLASHBACK_ARCHIVE CREATE_OUTLINE ALTER_OUTLINE DROP_OUTLINE CREATE_PROFILE ALTER_PROFILE DROP_PROFILE CREATE_ROLE ALTER_ROLE DROP_ROLE SET_ROLE CREATE_USER ALTER_USER DROP_USER CREATE_DATABASE ALTER_DATABASE DROP_DATABASE FLASHBACK_DATABASE CREATE_PLUGGABLE_DATABASE ALTER_PLUGGABLE_DATABASE DROP_PLUGGABLE_DATABASE CREATE_DISKGROUP ALTER_DISKGROUP DROP_DISKGROUP AUDIT NOAUDIT CREATE_AUDIT_POLICY ALTER_AUDIT_POLICY DROP_AUDIT_POLICY CREATE_ROLLBACK_SEGMENT ALTER_ROLLBACK_SEGMENT DROP_ROLLBACK_SEGMENT EXPLAIN_PLAN PURGE SET_CONSTRAINT SET_TRANSACTION CREATE_SCHEMA ADMINISTER_KEY_MANAGEMENT ASSOCIATE_STATISTICS CREATE_CONTROLFILE ALTER_RESOURCE_COST DISASSOCIATE_STATISTICS CALL EXECUTE EXEC REMARK )

# 2nd item is not sql object for Type2A
#type2A=( SELECT INSERT UPDATE DELETE MERGE COMMIT ROLLBACK SAVEPOINT GRANT REVOKE )

l_SqlObjectName=""
tSqlStr=${ucSqlStr#${l_SqlType}}	# remove sql-type previx from sql statement
l_SqlObjectName=${tSqlStr# } 		# remove leading space
l_SqlObjectName=${l_SqlObjectName%% *}  # remove trailing space and rest of SQL
DEBUG "END f_find_sql_object l_SqlObjectName=${l_SqlObjectName}"

# write SQL Type story
if [ "${rc_SQLTYPE_WRITE_DESCRIPTIVE_STORY}" = "YES" ]; then
	DEBUG "#SQL Input string: ${mySqlStr}"
	DEBUG "#SQL Upper string: ${ucSqlStr}"
	DEBUG "#SQL Type ID: ${l_SqlTypeID}"
	DEBUG "#SQL Type Name: ${l_SqlType}"
	ECHO "#SQL Object Name: ${l_SqlObjectName}"
fi

}
# ------------------------------------------------------------
f_FindSqlSubType_generic () {
v_debug=0
sNum=${sNum:=0}
DEBUG "BEGIN f_FindSqlSubType_generic"
DEBUG "Input SQL String: ${ucSqlStr}"
DEBUG "Input SQL Type: ${l_SqlType}"
SqlSubtypeCfgFile=${rc_SQLSUBTYPE_CFG_DIR}/${l_SqlTypeUnderscore}.cfg
DEBUG "SqlSubtypeCfgFile #${sNum} ${SqlSubtypeCfgFile}"
if [ -f ${SqlSubtypeCfgFile} ]; then
	cat ${SqlSubtypeCfgFile} | grep -v "^#" | grep -v "^$" >  ${TMPCFG}.${sNum}
else
	return
fi
DEBUG "Trimmed SqlSubtypeCfgFile is ${TMPCFG}.${sNum}"

s1=${l_SqlType}
l_SqlSubType=""		
l_SqlSubCfgLineNum=0
# read sub sql type config line
while read -r l_SubTypeCfg
do
	DEBUG "#----------"

	(( l_SqlSubCfgLineNum=l_SqlSubCfgLineNum+1 ))
	DEBUG "Search# ${l_SqlSubCfgLineNum}"

	#DEBUG "Search Config Line String ${l_SubTypeCfg}"

	# read sub sql type config line fields
	l_SearchName=$(echo ${l_SubTypeCfg}|cut -f1 -d":")
	DEBUG "Search Name ${l_SearchName}"

	sSubTypeSearchStringsCount=$(echo ${l_SubTypeCfg}|cut -f2 -d":")
	DEBUG "Search strings count ${sSubTypeSearchStringsCount}"

	sSubTypeSearchSQLType=$(echo ${l_SubTypeCfg}|cut -f3 -d":")
	[[ "${sSubTypeSearchSQLType}" != "${s1}" ]] && WARN "${TMPCFG}.${sNum} file may have invalid entries !" && continue

	DEBUG "Search String-1 ${s1}"
	[[ $sSubTypeSearchStringsCount -ge 2 ]] && s2=$(echo ${l_SubTypeCfg}|cut -f4 -d":") && DEBUG "Search String 2 ${s2}"
	[[ $sSubTypeSearchStringsCount -ge 3 ]] && s3=$(echo ${l_SubTypeCfg}|cut -f5 -d":") && DEBUG "Search String 3 ${s3}"
	[[ $sSubTypeSearchStringsCount -ge 4 ]] && s4=$(echo ${l_SubTypeCfg}|cut -f6 -d":") && DEBUG "Search String 4 ${s4}"
	[[ $sSubTypeSearchStringsCount -ge 5 ]] && s5=$(echo ${l_SubTypeCfg}|cut -f7 -d":") && DEBUG "Search String 5 ${s5}"
	[[ $sSubTypeSearchStringsCount -ge 6 ]] && s6=$(echo ${l_SubTypeCfg}|cut -f8 -d":") && DEBUG "Search String 6 ${s6}"
	[[ $sSubTypeSearchStringsCount -ge 7 ]] && s7=$(echo ${l_SubTypeCfg}|cut -f9 -d":") && DEBUG "Search String 7 ${s7}"
	[[ $sSubTypeSearchStringsCount -ge 8 ]] && s8=$(echo ${l_SubTypeCfg}|cut -f10 -d":") && DEBUG "Search String 8 ${s8}"

	# Search for 8 strings
	if [ $sSubTypeSearchStringsCount -eq 8 ]; then
		m=$(fPatternMatch8 "${ucSqlStr}" "${s1}" "${s2}" "${s3}" "${s4}" "${s5}" "${s6}" "${s7}" "${s8}")
		[[ "${m}" != "MATCHED" ]] && DEBUG "Search Result 8 NOT MATCHED"
		[[ "${m}" == "MATCHED" ]] && export l_SqlSubType="${s1}...${s2}...${s3}...${s4}...${s5}...${s6}...${s7}...${s8}" && l_SqlSubTypeSearchName=l_SearchName && break
	fi

	# Search for 7 strings
	if [ $sSubTypeSearchStringsCount -eq 7 ]; then
		m=$(fPatternMatch7 "${ucSqlStr}" "${s1}" "${s2}" "${s3}" "${s4}" "${s5}" "${s6}" "${s7}")
		[[ "${m}" != "MATCHED" ]] && DEBUG "Search Result 7 NOT MATCHED"
		[[ "${m}" == "MATCHED" ]] && export l_SqlSubType="${s1}...${s2}...${s3}...${s4}...${s5}...${s6}...${s7}" && l_SqlSubTypeSearchName=${l_SearchName} && break
	fi

	# Search for 6 strings
	if [ $sSubTypeSearchStringsCount -eq 6 ]; then
		m=$(fPatternMatch6 "${ucSqlStr}" "${s1}" "${s2}" "${s3}" "${s4}" "${s5}" "${s6}")
		[[ "${m}" != "MATCHED" ]] && DEBUG "Search Result 6 NOT MATCHED"
		[[ "${m}" == "MATCHED" ]] && export l_SqlSubType="${s1}...${s2}...${s3}...${s4}...${s5}...${s6}" && l_SqlSubTypeSearchName=${l_SearchName} && break
	fi

	# Search for 5 strings
	if [ $sSubTypeSearchStringsCount -eq 5 ]; then
		m=$(fPatternMatch5 "${ucSqlStr}" "${s1}" "${s2}" "${s3}" "${s4}" "${s5}")
		[[ "${m}" != "MATCHED" ]] && DEBUG "Search Result 5 NOT MATCHED"
		[[ "${m}" == "MATCHED" ]] && export l_SqlSubType="${s1}...${s2}...${s3}...${s4}...${s5}" && l_SqlSubTypeSearchName=${l_SearchName} && break
	fi

	# Search for 4 strings
	if [ $sSubTypeSearchStringsCount -eq 4 ]; then
		m=$(fPatternMatch4 "${ucSqlStr}" "${s1}" "${s2}" "${s3}" "${s4}")
		[[ "${m}" != "MATCHED" ]] && DEBUG "Search Result 4 NOT MATCHED"
		[[ "${m}" == "MATCHED" ]] && export l_SqlSubType="${s1}...${s2}...${s3}...${s4}" && l_SqlSubTypeSearchName=${l_SearchName} && break
	fi
	
	# Search for 3 strings
	if [ $sSubTypeSearchStringsCount -eq 3 ]; then
		m=$(fPatternMatch3 "${ucSqlStr}" "${s1}" "${s2}" "${s3}")
		[[ "${m}" != "MATCHED" ]] && DEBUG "Search Result 3 NOT MATCHED"
		[[ "${m}" == "MATCHED" ]] && export l_SqlSubType="${s1}...${s2}...${s3}" && l_SqlSubTypeSearchName=${l_SearchName} && break
	fi

	# Search for 2 strings
	if [ $sSubTypeSearchStringsCount -eq 2 ]; then
		m=$(fPatternMatch2 "${ucSqlStr}" "${s1}" "${s2}")
		[[ "${m}" != "MATCHED" ]] && DEBUG "Search Result 2 NOT MATCHED"
		[[ "${m}" == "MATCHED" ]] && export l_SqlSubType="${s1}...${s2}" && l_SqlSubTypeSearchName=${l_SearchName} && break
	fi
	
	DEBUG "Search continues ..."
	
done < ${TMPCFG}.${sNum}

(( l_SqlSubTypeID = ${l_SqlTypeID}*100 + 100000 + ${l_SqlSubCfgLineNum} ))
[[ -z "${l_SqlSubType}" ]] && l_SqlSubType="UNKNOWN" && l_SqlSubTypeID=0
DEBUG "Sql Sub Type Line# ${l_SqlSubCfgLineNum} : ${l_SqlSubType}"
DEBUG "ENDING f_FindSqlSubType_generic ${s1}"
v_debug=0
}
# ------------------------------------------------------------
f_find_sql_sub_type () {
v_debug=0
DEBUG "BEGIN f_find_sql_sub_type"
DEBUG "Input SQL String: ${ucSqlStr}"
DEBUG "Input SQL Type: ${l_SqlType}"
DEBUG "Input SQL Type Underscore: ${l_SqlTypeUnderscore}"
l_SqlSubTypeID=0
l_SqlSubType=""			# sql statement sub type
l_SqlSubTypeSearchName=""

# look for user defined FindSqlSubType function. if not exists call generic function
export l_func_name=f_FindSqlSubType_${l_SqlTypeUnderscore}
typeset -f ${l_func_name} > /dev/null
if [ $? -eq 0 ]; then
	DEBUG "Using \"${l_func_name}\" to find sub type"
	${l_func_name} 
else
	DEBUG "Custom \"${l_func_name}\" not defined"
	DEBUG "Using f_FindSqlSubType_generic"
	f_FindSqlSubType_generic 
fi
DEBUG "ENDING f_find_sql_sub_type SQL Sub Type ${l_SqlSubType}"

# write SQL Type story
if [ "${rc_SQLTYPE_WRITE_DESCRIPTIVE_STORY}" = "YES" ]; then
	DEBUG "#----------"
	DEBUG "#SQL Input string: ${mySqlStr}"
	DEBUG "#SQL Upper string: ${ucSqlStr}"
	ECHO "#SQL Sub Type ID ${l_SqlSubTypeID}"
	ECHO "#SQL Sub Type ${l_SqlSubType}"
	ECHO "#SQL Sub Name ${l_SqlSubTypeSearchName}"
fi
v_debug=0
}
# ------------------------------------------------------------
f_sqltype_sql_str () {
INPUT
[[ "${rc_FIND_SQLTYPE}" != "NO" ]] && f_find_sql_type "${input1}"
[[ "${rc_FIND_SQLOBJECT}" != "NO" ]] && f_find_sql_object
[[ "${rc_FIND_SQLSUBTYPE}" = "YES" ]] && f_find_sql_sub_type 

}
# ------------------------------------------------------------
f_sqltype_process () {
INPUT
INCLIB_c
f_process_sql_file ${input1}
}
# ------------------------------------------------------------
f_sqltype_testcase () {
INPUT
INCLIB_c
f_process_sql_file ${RC_DIR}/src/DBD/sqlrule/testcase/${input}.sql
}
# ------------------------------------------------------------
