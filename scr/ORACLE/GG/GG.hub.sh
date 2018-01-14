# ############################################################
# GG Hub FUNCTIONS - Oracle GoldenGate Hub
# ############################################################
# ------------------------------------------------------------
# GGSCI actions
action_L1="list status"
action_L2="whoami "
action_L3="vote monitor "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,List_nodes_GoldenGate_Hub \
"
# ------------------------------------------------------------
# local variables
INCLIB_c
# ------------------------------------------------------------
CHKFILE ${OGG_HUB_CFG_FILE}
# ------------------------------------------------------------
f_hub_list () {
[[ -z ${GGHNAME} ]] && ECHO "This is not hub"

ECHO "List of nodes for Hub: ${GGHNAME}"
ECHO ""
cat ${OGG_HUB_CFG_FILE} | grep "^${GGHNAME}:" | awk -F ":" '{printf "#-----------\nHostname   : %-30s\nIP Address : %-15s\nNode Number: %-3d\nEnabled    : %c\n" , $2, $5, $3, $4}'
}
# ------------------------------------------------------------
f_hub_status () {
[[ -z ${GGHNAME} ]] && ECHO "This is not hub"
ECHO "List of nodes for Hub: ${GGHNAME}"
ECHO ""
cat ${OGG_HUB_CFG_FILE} | grep "^${GGHNAME}:" | sed -e 's/:/ /g' |while read h_hub h_name h_num h_enabled h_ip 
do
ECHO "#"
ECHO "Hostname   : ${h_name}"
ECHO "IP Address : ${h_ip}"
ECHO "Node Number: ${h_num}"
ECHO "Enabled    : ${h_enabled}"
ECHO "Last active: $(stat ${OGG_PCS}/${h_num}|grep "^Modify"|cut -f2- -d":")"
done
}
# ------------------------------------------------------------
f_hub_monitor () {
[[ -z ${GGHNAME} ]] && ECHO "This is not hub"
ECHO "Hub Name: ${GGHNAME}"
ECHO ""
while  [ 1 ]
do
cat ${OGG_HUB_CFG_FILE} | grep "^${GGHNAME}:" | sed -e 's/:/ /g' |while read h_hub h_name h_num h_enabled h_ip 
do
[[ ${h_enabled} == "Y" ]] && ECHO "`date` #${h_num} ${h_name} (${h_ip}) last active @ "
#[[ ${h_enabled} == "Y" ]] && ECHO "`date` #${h_num} ${h_name} (${h_ip}) last active @ $(stat ${OGG_PCS}/${h_num}|grep "^Modify"|cut -f2- -d":")"
done
ECHO ""
sleep 3
done

}
# ------------------------------------------------------------
