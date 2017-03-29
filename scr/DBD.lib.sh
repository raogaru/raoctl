# ------------------------------------------------------------
# print MATCHED if arg1 has string arg2
MATCH1 () {
echo ${1}|sed -e's/^${2}.*/MATCHED/'
}

# ------------------------------------------------------------
# print MATCHED if arg1 has string arg2 and arg3
MATCH2 () {
echo ${1}|sed -e's/^${2}.*${3}.*/MATCHED/'
}

# ------------------------------------------------------------
# print MATCHED if arg1 string has arg2 and arg3 and arg3
MATCH3 () {
echo ${1}|sed -e's/^${2}.*${3}.*${4}.*/MATCHED/'
}

# ------------------------------------------------------------
f_find_sql_type () {
myStr=$1
v_debug=1
#DEBUG "Parsing sql string is : ${myStr}"

# convert to upper case
myStr=${myStr^^}

#DEBUG "Parsing sql string in upper-case is : ${myStr}"
ECHO "${myStr}"

stmtA=( CREATE_TABLE ALTER_TABLE CREATE_INDEX ALTER_INDEX SELECT INSERT UPDATE DELETE COMMENT COMMIT ADMINISTER_KEY_MANAGEMENT ALTER_AUDIT_POLICY ALTER_CLUSTER ALTER_DATABASE ALTER_DATABASE_LINK ALTER_DIMENSION ALTER_DISKGROUP ALTER_FLASHBACK_ARCHIVE ALTER_FUNCTION ALTER_INDEXTYPE ALTER_JAVA ALTER_LIBRARY ALTER_MATERIALIZED_VIEW ALTER_MATERIALIZED_VIEW_LOG ALTER_MATERIALIZED_ZONEMAP ALTER_OPERATOR ALTER_OUTLINE ALTER_PACKAGE ALTER_PLUGGABLE_DATABASE ALTER_PROCEDURE ALTER_PROFILE ALTER_RESOURCE_COST ALTER_ROLE ALTER_ROLLBACK_SEGMENT ALTER_SEQUENCE ALTER_SESSION ALTER_SYNONYM ALTER_SYSTEM ALTER_TABLESPACE ALTER_TRIGGER ALTER_TYPE ALTER_USER ALTER_VIEW ANALYZE ASSOCIATE_STATISTICS AUDIT CALL CREATE_AUDIT_POLICY CREATE_CLUSTER CREATE_CONTEXT CREATE_CONTROLFILE CREATE_DATABASE CREATE_DATABASE_LINK CREATE_DIMENSION CREATE_DIRECTORY CREATE_DISKGROUP CREATE_EDITION CREATE_FLASHBACK_ARCHIVE CREATE_FUNCTION CREATE_INDEXTYPE CREATE_JAVA CREATE_LIBRARY CREATE_MATERIALIZED_VIEW CREATE_MATERIALIZED_VIEW_LOG CREATE_MATERIALIZED_ZONEMAP CREATE_OPERATOR CREATE_OUTLINE CREATE_PACKAGE CREATE_PACKAGE_BODY CREATE_PFILE CREATE_PLUGGABLE_DATABASE CREATE_PROCEDURE CREATE_PROFILE CREATE_RESTORE_POINT CREATE_ROLE CREATE_ROLLBACK_SEGMENT CREATE_SCHEMA CREATE_SEQUENCE CREATE_SPFILE CREATE_SYNONYM CREATE_TABLESPACE CREATE_TRIGGER CREATE_TYPE CREATE_TYPE_BODY CREATE_USER CREATE_VIEW DISASSOCIATE_STATISTICS DROP_AUDIT_POLICY DROP_CLUSTER DROP_CONTEXT DROP_DATABASE DROP_DATABASE_LINK DROP_DIMENSION DROP_DIRECTORY DROP_DISKGROUP DROP_EDITION DROP_FLASHBACK_ARCHIVE DROP_FUNCTION DROP_INDEX DROP_INDEXTYPE DROP_JAVA DROP_LIBRARY DROP_MATERIALIZED_VIEW DROP_MATERIALIZED_VIEW_LOG DROP_MATERIALIZED_ZONEMAP DROP_OPERATOR DROP_OUTLINE DROP_PACKAGE DROP_PLUGGABLE_DATABASE DROP_PROCEDURE DROP_PROFILE DROP_RESTORE_POINT DROP_ROLE DROP_ROLLBACK_SEGMENT DROP_SEQUENCE DROP_SYNONYM DROP_TABLE DROP_TABLESPACE DROP_TRIGGER DROP_TYPE DROP_TYPE_BODY DROP_USER DROP_VIEW EXPLAIN_PLAN FLASHBACK_DATABASE FLASHBACK_TABLE GRANT LOCK_TABLE MERGE NOAUDIT PURGE RENAME REVOKE ROLLBACK SAVEPOINT SET_CONSTRAINT SET_CONSTRAINTS SET_ROLE SET_TRANSACTION TRUNCATE_CLUSTER TRUNCATE_TABLE )

# search for each string in myStr
i=0
sType=""
for s in ${stmtA[@]}
do
	# replace underscore with space in search string
	s=${s//_/ }
	(( i=i+1 ))
	#DEBUG "#$i Looking for $s"
	#echo -n "."
	myStr2=${myStr#${s}}
	#DEBUG "myStr now is ${myStr}"
	[[ "${myStr}" != "${myStr2}" ]] && sType=${s} && break
done
[[ -z "${sType}" ]] && ERROR "SQL Type could not be determined !"
DEBUG "SQL Type is ${sType}"
v_debug=0
}
# ------------------------------------------------------------
# Split input sqlfile into multiple files
f_split_sql_to_files () {
v_debug=0
sFile=$1
sNum=0 #SQL Count
typeset sStr=""
lNum=0
sLineCnt=0
lStr=""
cCnt=0

DEBUG Processing $sFile

# remove multi-line comments starting with /* and ending with */  
if [ "${rc_SPLITSQL_REMOVE_CSTYLE_COMMENTS}" != "NO" ]; then
	DEBUG "Removing C-Style multi-line comments"
	cat ${sFile} | perl -p0e 's!/\*.*?\*/!!sg' > ${TMPFILE1}
else
	cp ${sFile} ${TMPFILE1}
fi

# remove multi-line comments starting with DOC and ending with #
if [ "${rc_SPLITSQL_REMOVE_DOCUMENT_COMMENTS}" != "NO" ]; then
	DEBUG "Removing DOC-# multi-line comments"
	cat ${TMPFILE1} | perl -p0e 's!DOCUMENT.*?#!!sg' > ${TMPFILE2}
else
	cp ${TMPFILE1} ${TMPFILE2}
fi

# remove empty lines
if [ "${rc_SPLITSQL_REMOVE_EMPTY_LINES}" != "NO" ]; then
	DEBUG "Removing empty lines"
	cat ${TMPFILE2} | grep -v "^$" > ${TMPFILE3}
else
	cp ${TMPFILE2}  ${TMPFILE3}
fi

# remove prompt statements
if [ "${rc_SPLITSQL_REMOVE_PROMPT_LINES}" != "NO" ]; then
	DEBUG "Removing PROMPT lines"
	cat ${TMPFILE3} |grep -iv "^[ 	]*prompt" > ${TMPFILE4}
else
	cp ${TMPFILE3}  ${TMPFILE4}
fi

cat ${TMPFILE4} | while read -r lStr
do
	(( lNum=lNum+1 ))

	# trim double hiphen comments
	lStr="${lStr%%--*}"

	DEBUG "trim leading whitespaces"
	lStr="${lStr#"${lStr%%[![:blank:]]*}"}"
	#lStr=${lStr%% }

	DEBUG "trim trailing whitespaces"
	lStr="${lStr%"${lStr##*[![:blank:]]}"}" 
	#lStr=${lStr## }

	DEBUG "replace tab with space"
	#lStr=${lStr//	/ }

	DEBUG "replace multiple whitespaces with one space"
	lStr=$(echo ${lStr})

	# increment char count by length of line
	((cCnt=cCnt+${#lStr}))

	#DEBUG "Line#${lNum} : Chars=${cCnt} SQL# ${sNum} : ${lStr} "

	# first char of line
	sChar1=${lStr:0:1}

	# last char of line
	sChar2=${lStr:(-1)}

	#DEBUG "c1=$sChar1"
	#DEBUG "c2=$sChar2"

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

		# trim multi line comments
		#sStr=$(echo ${sStr} | perl -p0e 's!/\*.*?\*/!!sg' )

		ECHO "${cLINE2}"
		(( sNum=sNum+1 ))
		DEBUG "SQL#${sNum} : ${sStr}"
		ECHO "${sStr}" > ${TMPSQL}.${sNum}
		DEBUG "SQL#${sNum} file is ${TMPSQL}.${sNum}"

		DEBUG "Find SQL Type for ${sStr}"
		f_find_sql_type "${sStr}"

		ECHO "Find SQL Sub Type for ${sType}"
		# find sub category rules
		sStr=${sStr^^}
		#MATCH1 "${sStr}" "${sType}"
		#f_find_sql_sub_type

		DEBUG "exec rule of type ${sType}"
		#x="$(echo ${sType}|sed -e 's/ /_/g')"
		#vGrepPattern="^[0-9]*:[A-Za-z0-9]*:[YN]:.*:${x}:"
		#ShowRulesForPattern

		# start new sql string
		sStr=""
	fi
done
ECHO "${cLINE2}"
ECHO "Summary:"
ECHO "Input Script ${sFile}"
ECHO "Number of lines : ${lNum}"
ECHO "Number of chars : ${cCnt}"
ECHO "Number of SQLs : ${sNum}"
}

# ------------------------------------------------------------
f_rule_CreateTableNotAllowed () {
ECHO rule name is $rName 
}
