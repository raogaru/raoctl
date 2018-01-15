# ############################################################
# DEVOPS LIQUIBASE CONFIG FUNCTIONS - Liquibase Database Deploymen Tool Installation
# ############################################################
# ------------------------------------------------------------
# LIQUIBASE CONFIG actions
action_L1="env install help version which "
action_L2=" "
action_L3=" "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
env,none,Show_Liquibase_Environment \
install,none,Install_Liquibase_from_zip_file \
help,none,Show_Liquibase_HELP \
version,none,Show_Liquibase_VERSION \
which,none,Show_Liquibase_binary_location \
"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables
INCENV liquibase
# ------------------------------------------------------------
# Module specific common functions

# ------------------------------------------------------------
f_config_env () {
env|egrep 'LIQUIBASE'|sort
}
# ------------------------------------------------------------
f_config_install () {
SWFILE=${DOWNLOAD}/liquibase-${LIQUIBASE_VERSION}-bin.tar
ECHO "Install from ${SWFILE}"
CHKFILE ${SWFILE}
cd ${SOFTWARE}
unzip ${SWFILE}
#mv liquibase-${LIQUIBASE_VERSION}-bin liquibase-${LIQUIBASE_VERSION}
cp ${SOFTWARE}/oracle/drivers/ojdbc6.jar ${LIQUIBASE_HOME}/lib/
}
# ------------------------------------------------------------
f_config_help () {
liquibase --help
}
# ------------------------------------------------------------
f_config_version () {
liquibase --version
}
# ------------------------------------------------------------
f_config_which () {
which liquibase
}
# ------------------------------------------------------------
