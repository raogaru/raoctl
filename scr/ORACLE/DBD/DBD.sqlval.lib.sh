# ------------------------------------------------------------
SQLVAL_1_FILE () {
svFileName=$1
v_debug=0
sFile=$1
sNum=0 #SQL Count
l_FileLineNum=0
l_SqlLineNum=1
sLineCnt=0
l_SqlTypeID=""
l_SqlType=""
l_SqlTypeUnderscore=""
l_SqlSubType=""
l_SqlObjectName=""
lStr=""
cCnt=0
DEBUG "${cLINE2}"

DEBUG Processing ${svFileName}

CHKFILE ${svFileName}

svSqlStr=$(cat ${svFileName})

#DEBUG "#SQL ${svSqlStr}"

		ECHO "~~~~~~~~~~~~~"
		if [ "${rc_FIND_SQLTYPE}" != "NO" ]; then
			DEBUG "Find SQL Type for ${svSqlStr}"
			f_find_sql_type "${svSqlStr}"
			DEBUG "#SQL Type ID # ${l_SqlTypeID}"
			DEBUG "#SQL Type Name ${l_SqlType}"

			if [ "${rc_PROCESS_SQLTYPE_RULES}" != "NO" ]; then
				ECHO "Show rules for SQL Type (Rules-Category-2) ${l_SqlTypeUnderscore}"
				vRulesGrepPattern="^[0-9]*:[A-Za-z0-9]*:[Y]:.*:${l_SqlTypeUnderscore}:"
				DEBUG "$vRulesGrepPattern"
				ListRulesForPattern
				#ShowRulesForPattern
				#ExecRulesForPattern
			fi

			if [ "${rc_FIND_SQLOBJECT}" != "NO" ]; then
				DEBUG "Find SQL Object"
				f_find_sql_object
				ECHO "#SQL Obj Name  ${l_SqlObjectName}"
			fi

			if [ "${rc_FIND_SQLSUBTYPE}" != "NO" ]; then
				DEBUG "Find SQL Sub Type for ${l_SqlType}"
				f_find_sql_sub_type 
				DEBUG "#SQL Sub Type ID ${l_SqlSubTypeID}"
				DEBUG "#SQL Sub Type ${l_SqlSubType}"
				DEBUG "#SQL Sub Name ${l_SqlSubTypeSearchName}"

				if [ "${rc_PROCESS_SQLTSUBYPE_RULES}" != "NO" ]; then
					DEBUG "Show rules for Rule-Name (Based on SQL Sub type)"
					vRulesGrepPattern="^[0-9]*:${l_SqlSubTypeSearchName}:[Y]:.*:${l_SqlTypeUnderscore}:"
					DEBUG "$vRulesGrepPattern"
					ListRulesForPattern
					#ShowRulesForPattern
					#ExecRulesForPattern

					#TODO - below not finished
					#DEBUG "Show rules for Rules-Category-3 (SQL Sub Type)"
					#vRulesGrepPattern="^[0-9]*:[A-Za-z0-9]*:[Y]:.*:${l_SqlTypeUnderscore}:
					DEBUG "$vRulesGrepPattern"
					ListRulesForPattern
					#ShowRulesForPattern
					#ExecRulesForPattern
				fi
			fi
		fi

		ECHO "${cLINE2}"
}
# ------------------------------------------------------------
SQLVAL_N_FILES () {
iFileNum=1
v_debug=0
DEBUG "BEGIN SQL Validation file by file"
while ( [ -f ${TMPSQL}.${iFileNum} ] )
do
	DEBUG "Run SQL Validation on file ${TMPSQL}.${iFileNum}"
	SQLVAL_1_FILE ${TMPSQL}.${iFileNum}
	(( iFileNum = iFileNum+1 ))
done
DEBUG "END SQL Validation file by file"
}
# ------------------------------------------------------------
