# ############################################################
# STAT admin - DBMS_STATS Global Statistics Preferences and Administrative FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# STAT Preferences actions
action_L1="list_pref set_pref get_pref reset_pref show_pref "
action_L2="show_retention alter_retention show_availability "
action_L3="purge resume"
action_L="$action_L1 $action_L2 $action_L3 "
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list_pref,none,List_Stats \
set_pref,pname:pvalue,Set_Global_Preference_Parameter_Value \
get_pref,pname,Get_Global_Preference_Parameter_Value \
reset_pref,none,Reset_Global_Preference_Parameter_Values \
show_pref,none,Show_Global_Preference_Parameter_Values \
show_retention,none,Show_History_Retention_in_Days \
set_retention,days,Set_History_Retention_in_Days \
show_availability,none,Show_Stats_History_Availability \
purge,none,Purge_Stats_History_beyond_retention \
resume,none,Resume_Gather_Stats \
"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables
param_L=" CASCADE DEGREE ESTIMATE_PERCENT METHOD_OPT NO_INVALIDATE GRANULARITY PUBLISH INCREMENTAL STALE_PERCENT AUTOSTATS_TARGET "
# ------------------------------------------------------------
# Module specific common functions
INCLIB_c
# ------------------------------------------------------------
f_admin_list_pref () {
ECHO ${param_L}
}
# ------------------------------------------------------------
f_admin_set_pref () {
INPUT 2
STATS_p "set_global_prefs(pname=>'${input1}',pvalue=>'${input2}')"
}
# ------------------------------------------------------------
f_admin_get_pref () {
INPUT
STATS_f "get_prefs(pname=>'${input1}')"
}
# ------------------------------------------------------------
f_admin_reset_pref () {
STATS_p "reset_global_pref_defaults"
}
# ------------------------------------------------------------
f_admin_show_pref () {
for t_param in ${param_L}
do
ECHO ${t_param} $( STATS_f "get_prefs(pname=>'${t_param}')")
done
}
# ------------------------------------------------------------
f_admin_show_retention () {
ECHO Statistics History Retention in Days : $(STATS_f "get_stats_history_retention")
}
# ------------------------------------------------------------
f_admin_alter_retention () {
INPUT
STATS_p "alter_stats_history_retention(retention=>${input1})"
}
# ------------------------------------------------------------
f_admin_show_availability () {
ECHO Statistics History Availablity TimeStamp : $(STATS_f "get_stats_history_availability")
}
# ------------------------------------------------------------
f_admin_purge () {
STATS_p "purge_stats(before_timestamp=>to_timestamp('${input1}','yyyy-mm-dd-hh24-mi-ss'))"
}
# ------------------------------------------------------------
f_admin_resume () {
STATS_p "resume_gather_stats"
}
# ------------------------------------------------------------
