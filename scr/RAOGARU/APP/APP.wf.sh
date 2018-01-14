# ############################################################
# RAO APP WF FUNCTIONS - Raogaru RC Workflow Management Application
# ############################################################
# ------------------------------------------------------------
# RAO APP WF actions
action_L1="install uninstall "
action_L2="run "
action_L3="zz "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
xx,none,xx_description \
yy,none,yy_description \
zz,none,zz_description \
"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables
rc_WF_PROC_NAME=p1
rc_WF_SQLDIR=${RC_DIR}/schema/rc_wf
constr="rc_wf/rc_wf"

# ------------------------------------------------------------
# Module specific common functions

# ------------------------------------------------------------
f_wf_install () {
INPUT
ECHO "not coded yet"
}
# ------------------------------------------------------------
f_wf_uninstall () {
INPUT
ECHO "not coded yet"
}
# ------------------------------------------------------------
f_wf_run () {
INPUT 2
SQLRUN "@${rc_WF_SQLDIR}/p${input1}_${input2}.sql"
}
# ------------------------------------------------------------

