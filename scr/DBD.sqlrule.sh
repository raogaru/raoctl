# ############################################################
# DBD SQLRULE FUNCTIONS - Database Deployment SQL Rule Engine
# ############################################################
# ------------------------------------------------------------
# DBD SQLRULE actions
action_L1="list_all list_id list_name list_cat1 list_cat2 list_cat3 "
action_L2="show_all show_id show_name show_cat1 show_cat2 show_cat3 show_disabled show_enabled "
action_L3="exec_all exec_id exec_name exec_cat1 exec_cat2 exec_cat3 exec_disabled exec_enabled "
action_L4="splitsql test"
action_L="$action_L1 $action_L2 $action_L3 $action_L4"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list_all,none,List_all_Rules \
list_id,Rule_ID,List_Rule_by_ID \
zz,none,zz_description \
"
# ------------------------------------------------------------
# Global variable overwrites
rc_SQLRULE_RULES_CFG=${rc_DBD_SQLRULE_RULES_CFG:=${CFG_DIR}/sqlrule.cfg}
rc_SQLRULE_SQLSUBTYPE_CFG=${CFG_DIR}/sqlsubtype.cfg
rc_SPLITSQL_REMOVE_CSTYLE_COMMENTS=YES
rc_SPLITSQL_REMOVE_DOCUMENT_COMMENTS=YES
rc_SPLITSQL_REMOVE_EMPTY_LINES=YES
rc_SPLITSQL_REMOVE_PROMPT_LINES=YES
rc_SPLITSQL_REMOVE_DOUBLE_HIPHEN_LINES=YES
rc_SPLITSQL_REMOVE_MULTIPLE_WHITESPACES=YES
# ------------------------------------------------------------
# Module specific environment variables
sStr=""				# sql string
sType=""			# sql statement type
sSubType=""			# sql statement sub type

# ------------------------------------------------------------
# Module specific common functions

# ------------------------------------------------------------
CHKFILE ${rc_SQLRULE_RULES_CFG}
CHKFILE ${rc_SQLRULE_SQLSUBTYPE_CFG}
# ------------------------------------------------------------
ShowRulesForPattern () {
cat ${rc_SQLRULE_RULES_CFG} |grep -v "^$" | grep -v "^#" | grep "${vGrepPattern}" > ${TMPFILE1} 
cat ${TMPFILE1} | awk 'BEGIN {FS=":"} {
printf "\n------------------------------------------------------------";
printf "\n#%d",NR;
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
cat ${rc_SQLRULE_RULES_CFG} |grep -v "^$" | grep -v "^#" | grep "${vGrepPattern}" > ${TMPFILE1} 
cat ${TMPFILE1} | cut -f1,2 -d":" |sed -e 's/:/ /g' > ${TMPFILE2}
rSeq=0
cat ${TMPFILE2} | while read rID rName
do
	ECHO ${cLINE3}
	(( rSeq=rSeq+1 ))
	ECHO "Executing Rule#${rSeq}-${rID}:${rName}"
	export v_rule_function=f_rule_${rName}
	typeset -f ${v_rule_function} > /dev/null
	[[ $? -ne 0 ]] && WARN "function ${v_rule_function} not defined.!"
	${v_rule_function}
	
done
}
# ------------------------------------------------------------
#RAO LIST
# ------------------------------------------------------------
f_sqlrule_list_all () {
cat  ${rc_SQLRULE_RULES_CFG} |grep -v "^$" | grep -v "^#" 
}
# ------------------------------------------------------------
f_sqlrule_list_id () {
INPUT
cat ${rc_SQLRULE_RULES_CFG} |grep -v "^$" | grep -v "^#" | grep "^${input1}:" | head -1 
}
# ------------------------------------------------------------
f_sqlrule_list_name () {
INPUT
cat ${rc_SQLRULE_RULES_CFG} |grep -v "^$" | grep -v "^#" | grep -i ":${input1}:" | head -1 
}
# ------------------------------------------------------------
#RAO SHOW
# ------------------------------------------------------------
f_sqlrule_show_all () {
vGrepPattern=":"
ShowRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_show_id () {
INPUT
vGrepPattern="^${input1}:"
ShowRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_show_name () {
INPUT
vGrepPattern="^[0-9]*:${input1}:"
ShowRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_show_cat1 () {
INPUT
vGrepPattern="^[0-9]*:[A-Za-z0-9]*:[YN]:${input1}:"
ShowRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_show_cat2 () {
INPUT
vGrepPattern="^[0-9]*:[A-Za-z0-9]*:[YN]:.*:${input1}:"
ShowRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_show_cat3 () {
INPUT
vGrepPattern="^[0-9]*:[A-Za-z0-9]*:[YN]:.*:.*:${input1}:"
ShowRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_show_disabled () {
vGrepPattern="^[0-9]*:[A-Za-z0-9]*:N:"
ShowRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_show_enabled () {
vGrepPattern="^[0-9]*:[A-Za-z0-9]*:Y:"
ShowRulesForPattern
}
# ------------------------------------------------------------
#RAO EXEC
# ------------------------------------------------------------
f_sqlrule_exec_all () {
vGrepPattern=":"
ExecRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_exec_id () {
INPUT
vGrepPattern="^${input1}:"
ExecRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_exec_name () {
INPUT
vGrepPattern="^[0-9]*:${input1}:"
ExecRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_exec_cat1 () {
INPUT
vGrepPattern="^[0-9]*:[A-Za-z0-9]*:[YN]:${input1}:"
ExecRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_exec_cat2 () {
INPUT
vGrepPattern="^[0-9]*:[A-Za-z0-9]*:[YN]:.*:${input1}:"
ExecRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_exec_cat3 () {
INPUT
vGrepPattern="^[0-9]*:[A-Za-z0-9]*:[YN]:.*:.*:${input1}:"
ExecRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_exec_disabled () {
vGrepPattern="^[0-9]*:[A-Za-z0-9]*:N:"
ExecRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_exec_enabled () {
vGrepPattern="^[0-9]*:[A-Za-z0-9]*:Y:"
ExecRulesForPattern
}
# ------------------------------------------------------------
#RAO CALL
# ------------------------------------------------------------
f_sqlrule_splitsql () {
INPUT
INCLIB_c
f_split_sql_to_files ${input1}
}
# ------------------------------------------------------------
