# ------------------------------------------------------------
# Global variable overwrites
rc_SQLRULE_RULES_CFG=${rc_SQLRULE_RULES_CFG:=${SCR_DIR}/${v_product}/${v_class}/sqlrule.cfg}
rc_SQLRULE_SQLTYPE_FOR=${rc_SQLRULE_SQLTYPE_FOR:=all}
rc_SQLRULE_SQLTYPE_CFG_DIR=${rc_SQLRULE_SQLTYPE_CFG_DIR:=${SCR_DIR}/${v_product}/${v_class}/sqltype}
rc_SQLRULE_SQLTYPE_CFG_FILE=${rc_SQLRULE_SQLTYPE_CFG_DIR}/${rc_SQLRULE_SQLTYPE_FOR}.cfg
rc_SQLRULE_SQLSUBTYPE_CFG_DIR=${rc_SQLRULE_SQLSUBTYPE_CFG_DIR:=${RC_DIR}/scr/${v_class}/${v_module}/sqlsubtype}
rc_SQLRULE_NOTALLOWED_ACTION=${rc_SQLRULE_NOTALLOWED_ACTION:=WARN}
# ------------------------------------------------------------
# Module specific environment variables
vRulesGrepPattern=""
# ------------------------------------------------------------
# Module specific common functions
f_NotAllowedRule () {
DEBUG "BEGIN f_NotAllowedRule"
[[ "${rc_SQLRULE_NOTALLOWED_ACTION}" == "ERROR" ]] && ERROR "Exiting !!!"
WARN "You have been warned !!!"
DEBUG "END f_NotAllowedRule"
}
# ------------------------------------------------------------
ListRulesForPattern () {
cat ${rc_SQLRULE_RULES_CFG} |grep -v "^$" | grep -v "^#" | grep "${vRulesGrepPattern}"
}
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
cat ${rc_SQLRULE_RULES_CFG} |grep -v "^$" | grep -v "^#" | grep "${vRulesGrepPattern}" > ${TMPFILE1} 
cat ${TMPFILE1} | cut -f1-4 -d":" |sed -e 's/:/ /g' > ${TMPFILE2}
rSeq=0
cat ${TMPFILE2} | while read rID rName rEnabled rType
do
	ECHO ${cLINE3}
	(( rSeq=rSeq+1 ))
	if [ "${rEnabled}" == "Y" ]; then 
	ECHO "Executing Rule#${rSeq}-${rID}:${rName}:${rType}"
	if [ "${rType}" == "NotAllowed" ]; then 
		WARN "Rule#${rSeq}-${rID}:${rName} is a NotAllowed Rule."
		f_NotAllowedRule
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
	else
		ECHO "Rule#${rSeq}-${rID}:${rName} is disabled"
	fi
	
done
}
# ------------------------------------------------------------
