# ############################################################
# DBD SQLRULE FUNCTIONS - Database Deployment SQL Rule Engine
# ############################################################
# ------------------------------------------------------------
# DBD SQLRULE actions
action_L1="list_all list_id list_name list_cat1 list_cat2 list_cat3 list_disabled list_enabled "
action_L2="show_all show_id show_name show_cat1 show_cat2 show_cat3 show_disabled show_enabled "
action_L3="exec_all exec_id exec_name exec_cat1 exec_cat2 exec_cat3 exec_disabled exec_enabled "
action_L4=" "
action_L="$action_L1 $action_L2 $action_L3 $action_L4"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list_all,none,List_all_Rules \
list_id,Rule_ID,List_Rule_by_ID \
list_name,Rule_Name,List_rule_by_Name \
list_cat1,Rule_Category1,List_rule_by_Category1_NotAllowed_or_Custom \
list_cat2,Rule_Category2,List_rule_by_Category2_SQL_Type \
list_cat3,Rule_Category2,List_rule_by_Category3_SQL_SubType \
list_disabled,none,List_Disabled_Rules \
list_enabled,none,List_Enabled_Rules \
show_all,none,Show_all_Rules \
show_id,Rule_ID,Show_Rule_by_ID \
show_name,Rule_Name,Show_rule_by_Name \
show_cat1,Rule_Category1,Show_rule_by_Category1_NotAllowed_or_Custom \
show_cat2,Rule_Category2,Show_rule_by_Category2_SQL_Type \
show_cat3,Rule_Category2,Show_rule_by_Category3_SQL_SubType \
show_disabled,none,Show_Disabled_Rules \
show_enabled,none,Show_Enabled_Rules \
exec_all,none,Execute_all_Rules \
exec_id,Rule_ID,Execute_Rule_by_ID \
exec_name,Rule_Name,Execute_rule_by_Name \
exec_cat1,Rule_Category1,Execute_rule_by_Category1_NotAllowed_or_Custom \
exec_cat2,Rule_Category2,Execute_rule_by_Category2_SQL_Type \
exec_cat3,Rule_Category2,Execute_rule_by_Category3_SQL_SubType \
exec_disabled,none,Execute_Disabled_Rules \
exec_enabled,none,Execute_Enabled_Rules \
"
# ------------------------------------------------------------
# Global variable overwrites
rc_SQLRULE_RULES_CFG=${rc_DBD_SQLRULE_RULES_CFG:=${RC_DIR}/src/${v_class}/${v_module}/sqlrule.cfg}
rc_SQLRULE_SQLTYPE_FOR=${rc_SQLRULE_SQLTYPE_FOR:=all}
rc_SQLRULE_SQLTYPE_CFG_DIR=${rc_SQLRULE_SQLTYPE_CFG_DIR:=${RC_DIR}/src/${v_class}/${v_module}/sqltype}
rc_SQLRULE_SQLTYPE_CFG_FILE=${rc_SQLRULE_SQLTYPE_CFG_DIR}/${rc_SQLRULE_SQLTYPE_FOR}.cfg
rc_SQLRULE_SQLSUBTYPE_CFG_DIR=${rc_SQLRULE_SQLSUBTYPE_CFG_DIR:=${RC_DIR}/src/${v_class}/${v_module}/sqlsubtype}
# ------------------------------------------------------------
# Module specific environment variables
sStr=""				# sql string
vRulesGrepPattern=""

# ------------------------------------------------------------
# Module specific common functions

# ------------------------------------------------------------
CHKFILE ${rc_SQLRULE_RULES_CFG}
CHKFILE ${rc_SQLRULE_SQLTYPE_CFG_FILE}
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
#LIST ACTIONS
# ------------------------------------------------------------
f_sqlrule_list_all () {
vRulesGrepPattern="^[0-9]*:"
ListRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_list_id () {
INPUT
vRulesGrepPattern="^${input1}:"
ListRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_list_name () {
INPUT
vRulesGrepPattern="^[0-9]*:${input1}:"
ListRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_list_cat1 () {
INPUT
vRulesGrepPattern="^[0-9]*:[A-Za-z0-9]*:[YN]:${input1}:"
ListRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_list_cat2 () {
INPUT
vRulesGrepPattern="^[0-9]*:[A-Za-z0-9]*:[YN]:.*:${input1}:"
ListRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_list_cat3 () {
INPUT
vRulesGrepPattern="^[0-9]*:[A-Za-z0-9]*:[YN]:.*:.*:${input1}:"
ListRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_list_disabled () {
vRulesGrepPattern="^[0-9]*:[A-Za-z0-9]*:N:"
ListRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_list_enabled () {
vRulesGrepPattern="^[0-9]*:[A-Za-z0-9]*:Y:"
ListRulesForPattern
}
# ------------------------------------------------------------
#SHOW ACTIONS
# ------------------------------------------------------------
f_sqlrule_show_all () {
vRulesGrepPattern="^[0-9]*:"
ShowRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_show_id () {
INPUT
vRulesGrepPattern="^${input1}:"
ShowRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_show_name () {
INPUT
vRulesGrepPattern="^[0-9]*:${input1}:"
ShowRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_show_cat1 () {
INPUT
vRulesGrepPattern="^[0-9]*:[A-Za-z0-9]*:[YN]:${input1}:"
ShowRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_show_cat2 () {
INPUT
vRulesGrepPattern="^[0-9]*:[A-Za-z0-9]*:[YN]:.*:${input1}:"
ShowRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_show_cat3 () {
INPUT
vRulesGrepPattern="^[0-9]*:[A-Za-z0-9]*:[YN]:.*:.*:${input1}:"
ShowRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_show_disabled () {
vRulesGrepPattern="^[0-9]*:[A-Za-z0-9]*:N:"
ShowRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_show_enabled () {
vRulesGrepPattern="^[0-9]*:[A-Za-z0-9]*:Y:"
ShowRulesForPattern
}
# ------------------------------------------------------------
#EXEC ACTIONS
# ------------------------------------------------------------
f_sqlrule_exec_all () {
vRulesGrepPattern="^[0-9]*:"
ExecRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_exec_id () {
INPUT
vRulesGrepPattern="^${input1}:"
ExecRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_exec_name () {
INPUT
vRulesGrepPattern="^[0-9]*:${input1}:"
ExecRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_exec_cat1 () {
INPUT
vRulesGrepPattern="^[0-9]*:[A-Za-z0-9]*:[YN]:${input1}:"
ExecRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_exec_cat2 () {
INPUT
vRulesGrepPattern="^[0-9]*:[A-Za-z0-9]*:[YN]:.*:${input1}:"
ExecRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_exec_cat3 () {
INPUT
vRulesGrepPattern="^[0-9]*:[A-Za-z0-9]*:[YN]:.*:.*:${input1}:"
ExecRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_exec_disabled () {
vRulesGrepPattern="^[0-9]*:[A-Za-z0-9]*:N:"
ExecRulesForPattern
}
# ------------------------------------------------------------
f_sqlrule_exec_enabled () {
vRulesGrepPattern="^[0-9]*:[A-Za-z0-9]*:Y:"
ExecRulesForPattern
}
# ------------------------------------------------------------
