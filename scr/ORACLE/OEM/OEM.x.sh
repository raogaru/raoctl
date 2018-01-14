# ############################################################
# OEM XXX FUNCTIONS - Oracle Enterprise Manager Configuration
# ############################################################
# ------------------------------------------------------------
# OEM XXX actions
action_L1="create delete owner active inactive "
action_L2=""
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
f_xxx_yyy () {
INPUT 3
${EMCLI} create_tenant -name="${input1}" -description="${input2}" -owner_name="${input3}"
}
