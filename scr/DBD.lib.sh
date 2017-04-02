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
f_find_sql_type () {
myStr=$1
v_debug=0

# initialize to null. check for null later
l_SqlType=""

#DEBUG "Parsing sql string is : ${myStr}"
#DEBUG "Parsing sql string in upper-case is : ${myStr}"

stmtA=( CREATE_TABLESPACE ALTER_TABLESPACE DROP_TABLESPACE CREATE_TABLE ALTER_TABLE DROP_TABLE TRUNCATE_TABLE LOCK_TABLE FLASHBACK_TABLE CREATE_INDEXTYPE ALTER_INDEXTYPE DROP_INDEXTYPE CREATE_INDEX CREATE_UNIQUE_INDEX CREATE_BITMAP_INDEX ALTER_INDEX DROP_INDEX SELECT INSERT UPDATE DELETE MERGE COMMENT COMMIT ROLLBACK SAVEPOINT ANALYZE RENAME GRANT REVOKE CREATE_VIEW CREATE_OR_REPLACE_VIEW ALTER_VIEW DROP_VIEW CREATE_SEQUENCE ALTER_SEQUENCE DROP_SEQUENCE CREATE_SYNONYM ALTER_SYNONYM DROP_SYNONYM CREATE_GLOBAL_TEMPORARY_TABLE CREATE_CLUSTER DROP_CLUSTER ALTER_CLUSTER TRUNCATE_CLUSTER CREATE_DIMENSION ALTER_DIMENSION DROP_DIMENSION CREATE_OPERATOR ALTER_OPERATOR DROP_OPERATOR CREATE_DIRECTORY DROP_DIRECTORY CREATE_TYPE CREATE_OR_REPLACE_TYPE ALTER_TYPE DROP_TYPE CREATE_TYPE_BODY DROP_TYPE_BODY CREATE_CONTEXT DROP_CONTEXT CREATE_LIBRARY ALTER_LIBRARY DROP_LIBRARY CREATE_JAVA ALTER_JAVA DROP_JAVA ALTER_SESSION ALTER_SYSTEM CREATE_PROCEDURE CREATE_OR_REPLACE_PROCEDURE ALTER_PROCEDURE DROP_PROCEDURE CREATE_FUNCTION CREATE_OR_REPLACE_FUNCTION ALTER_FUNCTION DROP_FUNCTION CREATE_PACKAGE CREATE_OR_REPLACE_PACKAGE ALTER_PACKAGE DROP_PACKAGE CREATE_PACKAGE_BODY CREATE_OR_REPLACE_PACKAGE_BODY CREATE_TRIGGER CREATE_OR_REPLACE_TRIGGER ALTER_TRIGGER DROP_TRIGGER CREATE_MATERIALIZED_VIEW ALTER_MATERIALIZED_VIEW DROP_MATERIALIZED_VIEW CREATE_MATERIALIZED_VIEW_LOG ALTER_MATERIALIZED_VIEW_LOG DROP_MATERIALIZED_VIEW_LOG CREATE_MATERIALIZED_ZONEMAP ALTER_MATERIALIZED_ZONEMAP DROP_MATERIALIZED_ZONEMAP CREATE_DATABASE_LINK ALTER_DATABASE_LINK DROP_DATABASE_LINK CREATE_PFILE CREATE_SPFILE CREATE_RESTORE_POINT DROP_RESTORE_POINT CREATE_EDITION DROP_EDITION CREATE_FLASHBACK_ARCHIVE ALTER_FLASHBACK_ARCHIVE DROP_FLASHBACK_ARCHIVE CREATE_OUTLINE ALTER_OUTLINE DROP_OUTLINE CREATE_PROFILE ALTER_PROFILE DROP_PROFILE CREATE_ROLE ALTER_ROLE DROP_ROLE SET_ROLE CREATE_USER ALTER_USER DROP_USER CREATE_DATABASE ALTER_DATABASE DROP_DATABASE FLASHBACK_DATABASE CREATE_PLUGGABLE_DATABASE ALTER_PLUGGABLE_DATABASE DROP_PLUGGABLE_DATABASE CREATE_DISKGROUP ALTER_DISKGROUP DROP_DISKGROUP AUDIT NOAUDIT CREATE_AUDIT_POLICY ALTER_AUDIT_POLICY DROP_AUDIT_POLICY CREATE_ROLLBACK_SEGMENT ALTER_ROLLBACK_SEGMENT DROP_ROLLBACK_SEGMENT EXPLAIN_PLAN PURGE SET_CONSTRAINT SET_TRANSACTION CREATE_SCHEMA ADMINISTER_KEY_MANAGEMENT ASSOCIATE_STATISTICS CREATE_CONTROLFILE ALTER_RESOURCE_COST DISASSOCIATE_STATISTICS CALL EXECUTE EXEC REMARK )

# search for each string in myStr
i=0
for s in ${stmtA[@]}
do
	# replace underscore with space in search string
	s=${s//_/ }
	(( i=i+1 ))
	#DEBUG "#$i Is it $s"
	myStr2=${myStr#${s}}
	[[ "${myStr}" != "${myStr2}" ]] && l_SqlType="${s}" && break
done
[[ -z "${l_SqlType}" ]] && ERROR "SQL Type could not be determined ! Is this PLSQL code ?"
DEBUG "END f_find_sql_type l_SqlType=${l_SqlType}"
v_debug=0
}
# ------------------------------------------------------------
f_FindSqlSubType_CREATE_JAVA () {
	l_SqlSubType="UNKNOWN"
}
# ------------------------------------------------------------
f_FindSqlSubType_generic () {
v_debug=0
s1=${l_SqlType}
l_SqlTypeUnderscore=${l_SqlType// /_}
l_SqlSubType=""		
l_SqlSubCfgLineNum=0
rc_SQLRULE_SQLSUBTYPE_CFG_2=${CFG_DIR}/${v_class}.${v_module}.sqlsubtype.${l_SqlTypeUnderscore}.cfg
DEBUG "BEGIN f_FindSqlSubType_generic ${s1}"

#grep SQL-Type clauses only
cat ${rc_SQLRULE_SQLSUBTYPE_CFG} | grep -v "^#" | grep -v "^$" | grep ":${l_SqlType}:" >  ${TMPCFG}.${sNum}

# add sql sub type rules from its config file, if one exists
DEBUG "CFG#${sNum} ${rc_SQLRULE_SQLSUBTYPE_CFG_2}"
[[ -f ${rc_SQLRULE_SQLSUBTYPE_CFG_2} ]] && cat ${rc_SQLRULE_SQLSUBTYPE_CFG_2} | grep -v "^#" | grep -v "^$" >>  ${TMPCFG}.${sNum}

#DEBUG "subsqltype config file is ${TMPCFG}.${sNum}"
#ls -l ${TMPCFG}.${sNum}
#cat ${TMPCFG}.${sNum}

# read sub sql type config line
while read -r l_SubTypeCfg
do
	#DEBUG ${l_SubTypeCfg}
	(( l_SqlSubCfgLineNum=l_SqlSubCfgLineNum+1 ))

	# read sub sql type config line fields
	l_SearchName=$(echo ${l_SubTypeCfg}|cut -f1 -d":")
	DEBUG "Search Name is ${l_SearchName}"

	sSubTypeSearchStringsCount=$(echo ${l_SubTypeCfg}|cut -f2 -d":")
	DEBUG "Search strings count ${sSubTypeSearchStringsCount}"

	sSubTypeSearchSQLType=$(echo ${l_SubTypeCfg}|cut -f3 -d":")
	[[ "${sSubTypeSearchSQLType}" != "${s1}" ]] && WARN "${TMPCFG}.${sNum} file may have invalid entries !" && continue

	DEBUG "Search# ${l_SqlSubCfgLineNum}"
	DEBUG "Search String 1 ${s1}"
	[[ $sSubTypeSearchStringsCount -ge 2 ]] && s2=$(echo ${l_SubTypeCfg}|cut -f4 -d":") && DEBUG "Search String 2 ${s2}"
	[[ $sSubTypeSearchStringsCount -ge 3 ]] && s3=$(echo ${l_SubTypeCfg}|cut -f5 -d":") && DEBUG "Search String 3 ${s3}"
	[[ $sSubTypeSearchStringsCount -ge 4 ]] && s4=$(echo ${l_SubTypeCfg}|cut -f6 -d":") && DEBUG "Search String 4 ${s4}"
	[[ $sSubTypeSearchStringsCount -ge 5 ]] && s5=$(echo ${l_SubTypeCfg}|cut -f7 -d":") && DEBUG "Search String 5 ${s5}"
	[[ $sSubTypeSearchStringsCount -ge 6 ]] && s6=$(echo ${l_SubTypeCfg}|cut -f8 -d":") && DEBUG "Search String 6 ${s6}"
	[[ $sSubTypeSearchStringsCount -ge 7 ]] && s7=$(echo ${l_SubTypeCfg}|cut -f9 -d":") && DEBUG "Search String 7 ${s7}"
	[[ $sSubTypeSearchStringsCount -ge 8 ]] && s8=$(echo ${l_SubTypeCfg}|cut -f10 -d":") && DEBUG "Search String 8 ${s8}"

	# Search for 8 strings
	if [ $sSubTypeSearchStringsCount -eq 8 ]; then
		m=$(fPatternMatch8 "${sStr}" "${s1}" "${s2}" "${s3}" "${s4}" "${s5}" "${s6}" "${s7}" "${s8}")
		[[ "${m}" != "MATCHED" ]] && DEBUG "Search Result 8 NOT MATCHED"
		[[ "${m}" == "MATCHED" ]] && export l_SqlSubType="${s1}...${s2}...${s3}...${s4}...${s5}...${s6}...${s7}...${s8}" && l_SqlSubTypeSearchName=l_SearchName && break
	fi

	# Search for 7 strings
	if [ $sSubTypeSearchStringsCount -eq 7 ]; then
		m=$(fPatternMatch7 "${sStr}" "${s1}" "${s2}" "${s3}" "${s4}" "${s5}" "${s6}" "${s7}")
		[[ "${m}" != "MATCHED" ]] && DEBUG "Search Result 7 NOT MATCHED"
		[[ "${m}" == "MATCHED" ]] && export l_SqlSubType="${s1}...${s2}...${s3}...${s4}...${s5}...${s6}...${s7}" && l_SqlSubTypeSearchName=${l_SearchName} && break
	fi

	# Search for 6 strings
	if [ $sSubTypeSearchStringsCount -eq 6 ]; then
		m=$(fPatternMatch6 "${sStr}" "${s1}" "${s2}" "${s3}" "${s4}" "${s5}" "${s6}")
		[[ "${m}" != "MATCHED" ]] && DEBUG "Search Result 6 NOT MATCHED"
		[[ "${m}" == "MATCHED" ]] && export l_SqlSubType="${s1}...${s2}...${s3}...${s4}...${s5}...${s6}" && l_SqlSubTypeSearchName=${l_SearchName} && break
	fi

	# Search for 5 strings
	if [ $sSubTypeSearchStringsCount -eq 5 ]; then
		m=$(fPatternMatch5 "${sStr}" "${s1}" "${s2}" "${s3}" "${s4}" "${s5}")
		[[ "${m}" != "MATCHED" ]] && DEBUG "Search Result 5 NOT MATCHED"
		[[ "${m}" == "MATCHED" ]] && export l_SqlSubType="${s1}...${s2}...${s3}...${s4}...${s5}" && l_SqlSubTypeSearchName=${l_SearchName} && break
	fi

	# Search for 4 strings
	if [ $sSubTypeSearchStringsCount -eq 4 ]; then
		m=$(fPatternMatch4 "${sStr}" "${s1}" "${s2}" "${s3}" "${s4}")
		[[ "${m}" != "MATCHED" ]] && DEBUG "Search Result 4 NOT MATCHED"
		[[ "${m}" == "MATCHED" ]] && export l_SqlSubType="${s1}...${s2}...${s3}...${s4}" && l_SqlSubTypeSearchName=${l_SearchName} && break
	fi
	
	# Search for 3 strings
	if [ $sSubTypeSearchStringsCount -eq 3 ]; then
		m=$(fPatternMatch3 "${sStr}" "${s1}" "${s2}" "${s3}")
		[[ "${m}" != "MATCHED" ]] && DEBUG "Search Result 3 NOT MATCHED"
		[[ "${m}" == "MATCHED" ]] && export l_SqlSubType="${s1}...${s2}...${s3}" && l_SqlSubTypeSearchName=${l_SearchName} && break
	fi

	# Search for 2 strings
	if [ $sSubTypeSearchStringsCount -eq 2 ]; then
		m=$(fPatternMatch2 "${sStr}" "${s1}" "${s2}")
		[[ "${m}" != "MATCHED" ]] && DEBUG "Search Result 2 NOT MATCHED"
		[[ "${m}" == "MATCHED" ]] && export l_SqlSubType="${s1}...${s2}" && l_SqlSubTypeSearchName=${l_SearchName} && break
	fi
	
	#echo "searching ..."
	
done < ${TMPCFG}.${sNum}

[[ -z "${l_SqlSubType}" ]] && l_SqlSubType="UNKNOWN"
#TODO Introduce l_SqlSubTypeID in subtype config file
DEBUG "Sql Sub Type Line# ${l_SqlSubCfgLineNum} : ${l_SqlSubType}"
DEBUG "ENDING f_FindSqlSubType_generic ${s1}"
v_debug=0
}
# ------------------------------------------------------------
f_find_sql_sub_type () {
v_debug=0
l_SqlSubType=""
# look for user defined FindSqlSubType function. if not exists call generic function
export l_func_name=f_FindSqlSubType_${l_SqlType// /_}
typeset -f ${l_func_name} > /dev/null
if [ $? -eq 0 ]; then
	DEBUG "Calling \"${l_func_name}\" !"
	${l_func_name}
else
	DEBUG "Calling f_FindSqlSubType_generic as \"${l_func_name}\" not defined !"
	f_FindSqlSubType_generic
fi
DEBUG "ENDING f_find_sql_sub_type SQL Sub Type ${l_SqlSubType}"
v_debug=0
}

# ------------------------------------------------------------
# Split input sqlfile into multiple files
f_split_sql_to_files () {
v_debug=0
sFile=$1
sNum=0 #SQL Count
typeset sStr=""
l_FileLineNum=0
l_SqlLineNum=1
sLineCnt=0
l_SqlType=""
l_SqlTypeUnderscore=""
l_SqlSubType=""
lStr=""
cCnt=0

DEBUG Processing $sFile

# NOTE: User TMPFILE3/4 as TMPFILE1/2 already used in DBD.sqlrule.sh

# remove multi-line comments starting with /* and ending with */  
if [ "${rc_SPLITSQL_REMOVE_CSTYLE_COMMENTS}" != "NO" ]; then
	DEBUG "Removing C-Style multi-line comments"
	cat ${sFile} | perl -p0e 's!/\*.*?\*/!!sg' > ${TMPFILE3}
else
	cp ${sFile} ${TMPFILE3}
fi

# remove multi-line comments starting with DOC and ending with #
if [ "${rc_SPLITSQL_REMOVE_DOCUMENT_COMMENTS}" != "NO" ]; then
	DEBUG "Removing DOC-# multi-line comments"
	cat ${TMPFILE3} | perl -p0e 's!DOCUMENT.*?#!!sg' | perl -p0e 's!document.*?#!!sg'> ${TMPFILE4}
else
	cp ${TMPFILE3} ${TMPFILE4}
fi

# remove empty lines
if [ "${rc_SPLITSQL_REMOVE_EMPTY_LINES}" != "NO" ]; then
	DEBUG "Removing empty lines"
	cat ${TMPFILE4} | grep -v "^$" > ${TMPFILE3}
else
	cp ${TMPFILE4}  ${TMPFILE3}
fi

# remove prompt statements
if [ "${rc_SPLITSQL_REMOVE_PROMPT_LINES}" != "NO" ]; then
	DEBUG "Removing PROMPT lines"
	cat ${TMPFILE3} |grep -iv "^[ 	]*prompt" > ${TMPFILE4}
else
	cp ${TMPFILE3}  ${TMPFILE4}
fi

# remove double hiphen comments
if [ "${rc_SPLITSQL_REMOVE_DOUBLE_HIPHEN_LINES}" != "NO" ]; then
	DEBUG "Removing DOUBLE HIPHEN comments"
	cat ${TMPFILE4} |sed -e 's/--.*$//' > ${TMPFILE3}
else
	cp ${TMPFILE4}  ${TMPFILE3}
fi

# remove leading and trailing whitespaces
if [ "${rc_SPLITSQL_REMOVE_MULTIPLE_WHITESPACES}" != "NO" ]; then
	DEBUG "Removing multiple whitespaces"
	# 1.replace tabs 2.leading spaces 3.trailing spaces 4.multiplespaces with one"
	cat ${TMPFILE3} | sed -e 's/[	]/ /g' -e 's/^[ 	]*//g' -e 's/[ 	]*$//g' -e 's/[ ][ ]*/ /g' > ${TMPFILE4}
else
	cp ${TMPFILE3}  ${TMPFILE4}
fi

#final copy in ${TMPFILE3} before processing line by line
cp ${TMPFILE4} ${TMPSCR}
rm -f ${TMPFILE3} ${TMPFILE4}

# processing begins - read full line into lStr
while read -r lStr
do
	(( l_FileLineNum=l_FileLineNum+1 ))
	(( l_SqlLineNum=l_SqlLineNum+1 ))

	# increment char count by length of line
	((cCnt=cCnt+${#lStr}))

	# first char of line
	sChar1=${lStr:0:1}

	# last char of line
	sChar2=${lStr:(-1)}

	#DEBUG "c1=$sChar1"
	#DEBUG "c2=$sChar2"

	# if first char is "/" for First line of SQL then previous sql statement is of PLSQL type 
	[[ "${sChar1}" = "/" && ${l_SqlLineNum} -eq 1 ]] && l_SqlLineNum=0 && continue
	
	# enable this debug line if problem parsing sql file due to bad characters
	DEBUG "FileLine#${l_FileLineNum} SqlLine#${l_SqlLineNum} : Chars=${cCnt} : ${lStr} "

	# replace first char is slash then end SQL
	if [ "${sChar1}" = "/" ]; then
		 sChar1=";"
		sStr="${sStr} ;"
	else
		sStr="${sStr} ${lStr}"
	fi

	# start new SQL if first char is semi-color or slash OR last char is semi-colon
	if [[ "${sChar1}" == ";" || "${sChar1}" == "/" || "${sChar2}" == ";" ]]; then

		# trim leading whitespaces
		sStr="${sStr#"${sStr%%[![:space:]]*}"}"

		ECHO "${cLINE2}"
		(( sNum=sNum+1 ))
		DEBUG "SQL#${sNum} : ${sStr}"
		# create sql file per statement - use this for execution
		ECHO "${sStr}" > ${TMPSQL}.${sNum}
		DEBUG "SQL#${sNum} file is ${TMPSQL}.${sNum}"

		# NOTES: SQL file already created above. Use that for execution in DB. Do not use converted SQL for execution.

		# convert to upper case. 
		sStr=${sStr^^}
		#DEBUG "Parse SQL to find SQL Type SQL Sub Type"
		ECHO "#SQL ${sNum}"
		ECHO "#SQL ${sStr}"

		DEBUG "Find SQL Type for ${sStr}"
		f_find_sql_type "${sStr}"
		ECHO "#SQL Type ${l_SqlType}"
		ECHO "#SQL Object  ${l_SqlObjectName}"

		DEBUG "Find SQL Sub Type for ${l_SqlType}"
		f_find_sql_sub_type 
		ECHO "#SQL Sub Type ${l_SqlSubType}"
		ECHO "#SQL Sub Name ${l_SqlSubTypeSearchName}"

		DEBUG "Show rules for SQL Type (Rules-Category-2) ${l_SqlTypeUnderscore}"
		vGrepPattern="^[0-9]*:[A-Za-z0-9]*:[Y]:.*:${l_SqlTypeUnderscore}:"
		ShowRulesForPattern

		DEBUG "Show rules for Rule-Name (Based on SQL Sub type)"
		vGrepPattern="^[0-9]*:${l_SqlSubTypeSearchName}:[Y]:.*:${l_SqlTypeUnderscore}:"
		ShowRulesForPattern

		DEBUG "Show rules for Rules-Category-3 (SQL Sub Type)"
		#vGrepPattern="^[0-9]*:[A-Za-z0-9]*:[Y]:.*:${l_SqlTypeUnderscore}:${"
		#ShowRulesForPattern

		ECHO "${cLINE2}"
		# start new sql string
		sStr=""
		l_SqlLineNum=0
	fi
done < ${TMPSCR} 

ECHO "${cLINE2}"
ECHO "Summary:"
ECHO "Input Script ${sFile}"
ECHO "Number of lines : ${l_FileLineNum}"
ECHO "Number of chars : ${cCnt}"
ECHO "Number of SQLs : ${sNum}"
}

# ------------------------------------------------------------
f_rule_CreateTableNotAllowed () {
ECHO rule name is $rName 
}
