# ############################################################
# RAOCTL TOPOLOGY FUNCTIONS - RAOCTL Topology Player
# ############################################################
# ------------------------------------------------------------
# RAOCTL TOPOLOGY actions
action_L1="readcfg "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
readcfg,None,Read_Topology_Configuration \
"
# ------------------------------------------------------------
# local variables

TOPOLOGY_CFG=${CFG_DIR}/topology.cfg
# ------------------------------------------------------------
ReadConfigInfo () {
[[ ! -f ${TOPOLOGY_CFG} ]] && ERROR "${TOPOLOGY_CFG} config file not found !!!" 
t=0
set -A SITEA
cat ${TOPOLOGY_CFG} | grep -v ^# | grep -v "^$" | grep "^TOPOLOGY:" | while read topology_line
do
	ECHO "${cLINE1}\n$topology_line"
	topology_class=$(echo $topology_line |cut -f2 -d":") 
	topology_type=$(echo $topology_line |cut -f3 -d":") 
	topology_sites=$(echo $topology_line |cut -f4 -d":"|cut -f2 -d"=")
	set -A SITEA $(echo $topology_sites | sed -e 's/,/ /g')
	i=0
	set -A SIDA
	set -A DBOA
	for SITE in ${SITEA[*]}
	do
		#DEBUG ========== SITE:${SITE}:
		X=$(grep "^SITE_INFO_${SITE}" ${TOPOLOGY_CFG} |cut -f2 -d"=")
		DBOA[$i]=$(echo $X|cut -f1 -d":")
		SIDA[$i]=$(echo $X|cut -f2 -d":")
		#echo X=${X}
		DEBUG SITE=${SITEA[$i]}:SID=${SIDA[$i]}:DBO=${DBOA[$i]}
		(( i = i+1 ))
	done
	f_topology_${topology_class}_${topology_type}
done
}

# ------------------------------------------------------------
function f_topology_STR_MULTI_MASTER {
DEBUG "function $0 start"
i=0
while  [ $i -lt ${#SITEA[*]} ] # for each site
do
	ECHO "${cLINE2}\nON site ${SITEA[$i]}"
	j=0
	while  [ $j -lt ${#SITEA[*]} ] 
	do
		[[ $i != $j ]] && ECHO "Stream Capture on site ${SITEA[$i]} and Stream Apply site ${SITEA[$j]}"
		(( j = j+1 ))
	done
	(( i = i+1 ))
done
DEBUG "function $0 end"
}
# ------------------------------------------------------------
function f_topology_STR_HUB_SPOKE_2WAY {
DEBUG "function $0 start"
	i=0
	ECHO "${cLINE2}\nON site ${SITEA[$i]} (HUB)"
	j=1
	while  [ $j -lt ${#SITEA[*]} ] 
	do
		ECHO "Streams Capture on site ${SITEA[$i]} and Streams Apply site ${SITEA[$j]}"
		ECHO "Streams Capture on site ${SITEA[$j]} and Streams Apply site ${SITEA[$i]}"
		(( j = j+1 ))
	done
DEBUG "function $0 end"
}
# ------------------------------------------------------------
function f_topology_STR_HUB_SPOKE_1WAY {
DEBUG "function $0 start"
	i=0
	ECHO "${cLINE2}\nON site ${SITEA[$i]} (HUB)"
	j=1
	while  [ $j -lt ${#SITEA[*]} ] 
	do
		ECHO "Streams Capture on site ${SITEA[$i]} and Streams Apply site ${SITEA[$j]}"
		(( j = j+1 ))
	done
DEBUG "function $0 end"
}
# ------------------------------------------------------------
function f_topology_STR_CASCADE {
DEBUG "function $0 start"
	i=0
	ECHO "${cLINE2}\nON site ${SITEA[$i]} (HUB)"
	j=1
	while  [ $j -lt ${#SITEA[*]} ] 
	do
		ECHO "Streams Capture on site ${SITEA[$i]} for Streams Apply site ${SITEA[$j]}"
		(( i = i+1 ))
		(( j = j+1 ))
	done
DEBUG "function $0 end"
}
# ------------------------------------------------------------
function f_topology_STR_DOWN_STREAM {
DEBUG "function $0 start"
	i=0
	ECHO "${cLINE2}\nON site ${SITEA[$i]} (HUB)"
	j=1
	while  [ $j -lt ${#SITEA[*]} ] 
	do
		ECHO "Streams Downstream-Capture on site ${SITEA[$j]} for archive logs from ${SITEA[$i]}. And Streams Apply on site ${SITEA[$j]}"
		(( i = i+1 ))
		(( j = j+1 ))
	done
DEBUG "function $0 end"
}
# ------------------------------------------------------------
function f_topology_DG_PHYSICAL_DATAGUARD {
DEBUG "function $0 start"
	i=0
	ECHO "${cLINE2}\nON site ${SITEA[$i]} (PRIMARY)"
	j=1
	while  [ $j -lt ${#SITEA[*]} ] 
	do
		ECHO "Dataguard from primary ${SITEA[$i]} to physical standby ${SITEA[$j]}"
		(( j = j+1 ))
	done
DEBUG "function $0 end"
}
# ------------------------------------------------------------
function f_topology_DG_LOGICAL_DATAGUARD {
DEBUG "function $0 start"
	i=0
	ECHO "${cLINE2}\nON site ${SITEA[$i]} (PRIMARY)"
	j=1
	while  [ $j -lt ${#SITEA[*]} ] 
	do
		ECHO "Dataguard from primary ${SITEA[$i]} to logical standby ${SITEA[$j]}"
		(( j = j+1 ))
	done
DEBUG "function $0 end"
}
# ------------------------------------------------------------
function f_topology_DG_ACTIVE_DATAGUARD {
DEBUG "function $0 start"
	i=0
	ECHO "${cLINE2}\nON site ${SITEA[$i]} (PRIMARY)"
	j=1
	while  [ $j -lt ${#SITEA[*]} ] 
	do
		ECHO "Dataguard from primary ${SITEA[$i]} to active standby ${SITEA[$j]} with real-time apply"
		(( j = j+1 ))
	done
DEBUG "function $0 end"
}
# ------------------------------------------------------------
function f_topology_DG_CASCADED_PHYSICAL_DATAGUARD {
DEBUG "function $0 start"
	i=0
	ECHO "${cLINE2}\nON site ${SITEA[$i]} (PRIMARY)"
	j=1
	while  [ $j -lt ${#SITEA[*]} ] 
	do
		ECHO "Dataguard from site ${SITEA[$i]} to physical standby ${SITEA[$j]}"
		(( i = i+1 ))
		(( j = j+1 ))
	done
DEBUG "function $0 end"
}
# ------------------------------------------------------------
function f_topology_CDB_CDB_SETUP {
DEBUG "function $0 start"
	i=0
	ECHO "${cLINE2}\nON site ${SITEA[$i]} (CDB)"
	j=1
	while  [ $j -lt ${#SITEA[*]} ] 
	do
		ECHO "On container database ${SITEA[$i]} create pluggable database ${SITEA[$j]}"
		(( j = j+1 ))
	done
DEBUG "function $0 end"
}
# ------------------------------------------------------------
f_config_common () {
ReadConfigInfo
#ALERTLOG "Oracle Streams Configuration"
#SetupStreams ${1}
ECHO Done
}
# ------------------------------------------------------------
f_config_phase1 () {
f_config_common phase1
}
# ------------------------------------------------------------
f_topology_readcfg () {
ReadConfigInfo
}
