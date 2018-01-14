# ############################################################
# DBD SQLRULE FUNCTIONS - Database Deployment SQL Rule Engine
# ############################################################
# ------------------------------------------------------------
# DBD SQLRULE actions
action_L1="list_all list_id list_name list_cat1 list_cat2 list_cat3 list_disabled list_enabled "
action_L2="show_all show_id show_name show_cat1 show_cat2 show_cat3 show_disabled show_enabled "
action_L3="exec_all exec_id exec_name exec_cat1 exec_cat2 exec_cat3 exec_disabled exec_enabled "
action_L4="list_not_allowed list_sqltype list_sqlsubtype "
action_L5="show_not_allowed show_sqltype show_sqlsubtype "
action_L6="exec_not_allowed exec_sqltype exec_sqlsubtype "
action_L="$action_L1 $action_L2 $action_L3 $action_L4 $action_L5 $action_L6 "
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
INCLIB_m 
# ------------------------------------------------------------
CHKFILE ${rc_SQLRULE_RULES_CFG}
CHKFILE ${rc_SQLRULE_SQLTYPE_CFG_FILE}
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
#ACTIONS cat1=NotAllowed|PreBuild cat2=SqlType cat3=SqlSubType
# ------------------------------------------------------------
f_sqlrule_list_sqltype () {
INPUT 
f_sqlrule_list_cat2 
}
# ------------------------------------------------------------
f_sqlrule_list_sqlsubtype () {
INPUT 
f_sqlrule_list_cat3 
}
# ------------------------------------------------------------
f_sqlrule_show_sqltype () {
INPUT
f_sqlrule_show_cat2
}
# ------------------------------------------------------------
f_sqlrule_show_sqlsubtype () {
INPUT
f_sqlrule_show_cat3 
}
# ------------------------------------------------------------
f_sqlrule_exec_sqltype () {
INPUT
f_sqlrule_exec_cat2
}
# ------------------------------------------------------------
f_sqlrule_exec_sqlsubtype () {
INPUT
f_sqlrule_exec_cat3 
}
# ------------------------------------------------------------
