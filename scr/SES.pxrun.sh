# ############################################################
# <CLASS> <MODULE> FUNCTIONS - <description>
# ############################################################
# ------------------------------------------------------------
# <CLASS> <MODULE> actions
action_L1="sqlplus "
action_L2="yy "
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

# ------------------------------------------------------------
# Module specific common functions
rc_PX_MAX=${rc_PX_MAX:=4}
rc_PX_BID=${rc_PX_BID:=1}
rc_PX_EID=${rc_PX_END:=100}
rc_PX_FUNC=${rc_PX_FUNC:="INVALID"}
# ------------------------------------------------------------
f_pxrun_sqlexec () {
INPUT 
#1=class 2=module 3=action
rc_PX_CUR=${rc_PX_BID}
	while [ ${rc_PX_CUR} -lt ${rc_PX_END} ] ; do
		pid_A=$(jobs -p)
		if [ ${#pid_A[@]} -lt ${rc_PX_MAX} ] ; then
			SQLQRY "select count(1) from rao.t1;" &
		else
			wait
		fi
	done
	wait
}

parallelize arg1 arg2 "5 args to third job" arg4 ...


