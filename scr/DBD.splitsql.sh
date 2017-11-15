# ############################################################
# DBD SPLITSQL FUNCTIONS - Database Deployment SQL Rule Engine
# ############################################################
# ------------------------------------------------------------
# DBD SPLITSQL actions
action_L1="process testcase "
action_L="$action_L1 $action_L2 $action_L3 $action_L4"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
process,sql_file_name,Process_SQL_File \
testcase,SQL_Type_in_upper_case_with_under_scores,Process_SQL_File \
"
# ------------------------------------------------------------
# Global variable overwrites
rc_SQLRULE_RULES_CFG=${rc_DBD_SQLRULE_RULES_CFG:=${RC_DIR}/src/${v_class}/${v_module}/sqlrule.cfg}
rc_SQLRULE_SQLTYPE_FOR=${rc_SQLRULE_SQLTYPE_FOR:=all}
rc_SQLRULE_SQLTYPE_CFG_DIR=${rc_SQLRULE_SQLTYPE_CFG_DIR:=${RC_DIR}/src/${v_class}/${v_module}/sqltype}
rc_SQLRULE_SQLTYPE_CFG_FILE=${rc_SQLRULE_SQLTYPE_CFG_DIR}/${rc_SQLRULE_SQLTYPE_FOR}.cfg
rc_SQLRULE_SQLSUBTYPE_CFG_DIR=${rc_SQLRULE_SQLSUBTYPE_CFG_DIR:=${RC_DIR}/src/${v_class}/${v_module}/sqlsubtype}
#
rc_SPLITSQL_FIND_SQLTYPE=${rc_SPLITSQL_FIND_SQLTYPE:=YES}
rc_SPLITSQL_FIND_SQLSUBTYPE=${rc_SPLITSQL_FIND_SQLSUBTYPE:=YES}
rc_SPLITSQL_FIND_SQLOBJECT=${rc_SPLITSQL_FIND_SQLOBJECT:=YES}
rc_SPLITSQL_PROCESS_SQLTYPE_RULES=${rc_SPLITSQL_PROCESS_SQLTYPE_RULES:=YES}
rc_SPLITSQL_PROCESS_SQLSUBTYPE_RULES=${rc_SPLITSQL_PROCESS_SQLSUBTYPE_RULES:=YES}
rc_SPLITSQL_WRITE_DESCRIPTIVE_STORY=${rc_SPLITSQL_WRITE_DESCRIPTIVE_STORY:=NO}
#
rc_SPLITSQL_REMOVE_CSTYLE_COMMENTS=YES
rc_SPLITSQL_REMOVE_DOCUMENT_COMMENTS=YES
rc_SPLITSQL_REMOVE_EMPTY_LINES=YES
rc_SPLITSQL_REMOVE_PROMPT_LINES=YES
rc_SPLITSQL_REMOVE_DOUBLE_HIPHEN_LINES=YES
rc_SPLITSQL_REMOVE_MULTIPLE_WHITESPACES=YES
# ------------------------------------------------------------
# Module specific environment variables
sStr=""				# sql string
l_SqlType=""			# sql statement type
l_SqlSubType=""			# sql statement sub type
vRulesGrepPattern=""

# ------------------------------------------------------------
# Module specific common functions

# ------------------------------------------------------------
CHKFILE ${rc_SQLRULE_RULES_CFG}
CHKFILE ${rc_SQLRULE_SQLTYPE_CFG_FILE}
# ------------------------------------------------------------
ShowRulesForPattern () {
cat ${rc_SQLRULE_RULES_CFG} |grep -v "^$" | grep -v "^#" | grep "${vRulesGrepPattern}" > ${TMPFILE1} 
cat ${TMPFILE1} | awk 'BEGIN {FS=":"} {
printf "\n------------------------------------------------------------";
printf "\nRule #          :%-6d",NR;
printf "\nRule ID         :%-6d", $1;
printf "\nRule Name       :%s", $2;
printf "\nRule Enabled    :%c", $3;
printf "\nRule Category 1 :%s", $4;
printf "\nRule Category 2 :%s", $5;
printf "\nRule Category 3 :%s", $6;
printf "\nRule Description:%s", $7;
printf "\n";
}'
}
# ------------------------------------------------------------
ExecRulesForPattern () {
INCLIB_c
cat ${rc_SQLRULE_RULES_CFG} |grep -v "^$" | grep -v "^#" | grep "${vRulesGrepPattern}" > ${TMPFILE1} 
cat ${TMPFILE1} | cut -f1-4 -d":" |sed -e 's/:/ /g' > ${TMPFILE2}
rSeq=0
cat ${TMPFILE2} | while read rID rName rEnabled rType
do
	ECHO ${cLINE3}
	(( rSeq=rSeq+1 ))
	ECHO "Executing Rule#${rSeq}-${rID}:${rName}:${rType}"
	if [ "${rType}" == "NotAllowed" ]; then 
		WARN "Rule#${rSeq}-${rID}:${rName} is a NotAllowed Rule."
	fi
	if [ "${rType}" == "Custom" ]; then
		export v_rule_function=f_rule_${rName}
		ECHO "Rule#${rSeq}-${rID}:${rName} is a Custom Rule with function ${v_rule_function}"
		typeset -f ${v_rule_function} > /dev/null
		if [ $? -ne 0 ]; then 
			WARN "function ${v_rule_function} not defined.!"
		else
			${v_rule_function}
			[[ $? -ne 0 ]] && WARN "${v_rule_function} return code non-zero. Exiting"
		fi
	fi
	
done
}
# ------------------------------------------------------------
f_sqlrule_process () {
INPUT
INCLIB_c
f_process_sql_file ${input1}
}
# ------------------------------------------------------------
f_sqlrule_testcase () {
INPUT
INCLIB_c
f_process_sql_file ${RC_DIR}/src/DBD/sqlrule/testcase/${input}.sql
}
# ------------------------------------------------------------
