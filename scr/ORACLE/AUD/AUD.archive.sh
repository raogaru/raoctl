# ############################################################
# AUD ARCHIVE FUNCTIONS - Archive sys.aud$ table
# ############################################################
# ------------------------------------------------------------
# AUD ARCHIVE actions
action_L1="cre_tbl ren_part drp_part stats_part  "
action_L2="arch_yesterday arch_day_x arch_day_n1_to_n2 arch_yyyymmdd arch_yyyymmdd1_to_yyyymmdd2 "
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
RC_SYSAUD_SCHEMA="SYSAUD"
RC_SYSAUD_TABLE="SYSAUD"

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions

# ------------------------------------------------------------
f_module_action () {
INPUT
ECHO "not coded yet"
}
# ------------------------------------------------------------

