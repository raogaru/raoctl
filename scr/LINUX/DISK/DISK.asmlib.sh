# ############################################################
# DISK ORACLE ASMLIB FUNCTIONS - partition management
# ############################################################
# ------------------------------------------------------------
# DISK ORACLE ASMLIB actions
#   configure        Configure the Oracle Linux ASMLib driver
#    init             Load and initialize the ASMLib driver
#    exit             Stop the ASMLib driver
#    scandisks        Scan the system for Oracle ASMLib disks
#    listdisks        List known Oracle ASMLib disks
#    querydisk        Determine if a disk belongs to Oracle ASMlib
#    createdisk       Allocate a device for Oracle ASMLib use
#    deletedisk       Return a device to the operating system
#    renamedisk       Change the label of an Oracle ASMlib disk
#    update-driver    Download the latest ASMLib driver
# ------------------------------------------------------------
action_L1="install uninstall config init exit status "
action_L2="scan list query create delete rename "
action_L3="x "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
status,NONE,Display_the_status_of_the_Oracle_ASMLib_driver
"
# ------------------------------------------------------------
# local variables
ORAASM="/usr/sbin/oracleasm"
[[ ! -f ${ORAASM} ]] && ERROR "${ORAASM} file not found. Is Oracle ASMLib installed?"
# ------------------------------------------------------------
f_asmlib_install () {

v_file=oracleasm-support-2.1.5-1.el6.i686.rpm
[[ ! -f $v_file ]] && ERROR "File ${v_file} not found"

v_file=oracleasmlib-2.0.4-1.el6.i686.rpm 
[[ ! -f $v_file ]] && ERROR "File ${v_file} not found"

v_file=oracleasmlib-2.0.4-1.el5.i386.rpm
[[ ! -f $v_file ]] && ERROR "File ${v_file} not found"

/bin/rpm -Uvh oracleasm-support-2.1.5-1.el6.i686.rpm oracleasmlib-2.0.4-1.el6.i686.rpm oracleasmlib-2.0.4-1.el5.i386.rpm
}
# ------------------------------------------------------------
f_asmlib_uninstall () {
ECHO "not coded yet"
}
# ------------------------------------------------------------
f_asmlib_config () {
${ORAASM} "${v_action}"
}
# ------------------------------------------------------------
f_asmlib_init () {
${ORAASM} "${v_action}"
}
# ------------------------------------------------------------
f_asmlib_exit () {
${ORAASM} "${v_action}"
}
# ------------------------------------------------------------
f_asmlib_status () {
${ORAASM} "${v_action}"
}
# ------------------------------------------------------------
f_asmlib_scan () {
${ORAASM} scandisks
}
# ------------------------------------------------------------
f_asmlib_list () {
${ORAASM} listdisks
}
# ------------------------------------------------------------
f_asmlib_query () {
INPUT
${ORAASM} querydisk -v -p ${input1} 
${ORAASM} querydisk -v -d ${input1} 
}
# ------------------------------------------------------------
f_asmlib_create () {
INPUT 2
${ORAASM} createdisk ${input1} /dev/sd${input2}
}
# ------------------------------------------------------------
f_asmlib_delete () {
INPUT
${ORAASM} deletedisk -v ${input1}
}
# ------------------------------------------------------------
f_asmlib_rename () {
INPUT 2
${ORAASM} renamedisk -f -v ${input1} ${input2}
}
# ------------------------------------------------------------
