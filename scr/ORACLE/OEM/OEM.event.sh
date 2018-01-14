# ############################################################
# OEM EVENT FUNCTIONS - Oracle Enterprise Manager Event Management
# ############################################################
# ------------------------------------------------------------
# OEM EVENT actions
action_L1="add_comment "
action_L2="publish "
action_L3=""
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
"
# ------------------------------------------------------------
# Global variable overwrites
EMCLI_HOME=${HOME}/emcli
EMCLI=${EMCLI_HOME}/emcli

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions

# ------------------------------------------------------------
f_event_add_comment () {
INPUT 2
${EMCLI} add_comment_to_event -event_id="${input1}" -comment="${input2}"
}
# ------------------------------------------------------------
f_event_enable_or_disable_event_correlation_rule () {
ECHO "Not coded yet"
}
# ------------------------------------------------------------
f_event_publish () {
INPUT 4
[[ ! "${input3}" = @(CLEAR MINOR_WARNING WARNING CRITICAL FATAL) ]] && ERROR "Invalid Event Severity Level"
${EMCLI} publish_event -target_type="${input1}" -target_name="${input2}" -severity="${input3}" -name="${input4}" -message="${input4}"
}

