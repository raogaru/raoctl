# ############################################################
# PDB FUNCTIONS - MULTITENANT CONTAINER DATABASE (12c)
# ############################################################
# ------------------------------------------------------------
# DG actions
action_L1="open openro openrw close shutdown startup "
action_L2="list create clone drop unplug_2_xml unplug plug_check plug plug_as "
action_L3="clone_subset "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
open,pdb_name,Open_PDB_in_read_write_mode \
openro,pdb_name,Open_PDB_in_read_only_mode \
close,pdb_name,Close_PDB \
shutdown,pdb_name,Shutdown_PDB \
startup,pdb_name,Startup_PDB \
openro,pdb_name,Open_PDB_read_only \
create,pdb_name,Create_PDB_from_seed \
clone,from_pdb_name:to_pdb_name,Clone_PDB_from_existing_PDB \
drop,pdb_name,Drop_PDB_and_drop_data_files \
unplug_2_xml,pdb_name,Create_XML_file_for_unplug \
unplug,pdb_name,Unplug_PDB_and_keep_data_files \
plug_check,pdb_name,Plug_compatability_check_using_XML_file \
plug,pdb_name,Plug_PDB_using_XML_file_without_copying_files \
plug_as,pdb_name,Plug_PDB_using_XML_file_using_existing_files_in_different_directoryw \
clone_subset,from_pdb_name:to_pdb_name:subset_clause,Clone_PDB_using_subset_of_user_created_tablespaces \
"
# ------------------------------------------------------------
# local variables
PDB_ADM_USR=pdb_adm
PDB_ADM_PWD=pdb_adm
CDB_NAME=${ORACLE_SID}
#CDB_NAME=DB12C
ORADATA=/oracle/data
TNSORA=${CFG_DIR}/tnsnames.ora
DBHOST=$(hostname)
TNSPORT=1521
# ------------------------------------------------------------
AddPDB2TNS () {
PDB_SID=$1
grep "^${PDB_SID}.WORLD=" ${TNSORA} > /dev/null 2>&1
[[ $? -eq 0 ]] && ECHO "${TNSORA} entry already exists" && return 0

ECHO "Adding entry to ${TNSORA}"
echo "${PDB_SID}.WORLD=(DESCRIPTION_LIST=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(COMMUNITY=TCPIP.WORLD)(PROTOCOL=TCP)(HOST=${DBHOST})(PORT=${TNSPORT})))(CONNECT_DATA=(SID=${PDB_SID})(GLOBAL_NAME=${PDB_SID}.WORLD))))" >> ${TNSORA}
}
# ------------------------------------------------------------
RemoveTNS () {
PDB_SID=$1
grep "^${PDB_SID}.WORLD=" ${TNSORA} > /dev/null 2>&1
[[ $? -ne 0 ]] && ECHO "tnsnames.ora entry already removed" && return 0

ECHO "Removing tnsnames.ora entry "
cp -f ${TNSORA} ${TNSORA}.bak
grep -v "^${PDB_SID}.WORLD=" ${TNSORA} > ${TMP}/tnsnames.tmp
cp ${TMP}/tnsnames.tmp ${TNSORA}
}
# ------------------------------------------------------------
f_pdb_open () {
INPUT
SQLRUN "alter pluggable database ${input1} open;"
}
# ------------------------------------------------------------
f_pdb_openro () {
INPUT
SQLRUN "alter pluggable database ${input1} open read only;"
}
# ------------------------------------------------------------
f_pdb_openrw () {
INPUT
SQLRUN "alter pluggable database ${input1} open read write;"
}
# ------------------------------------------------------------
f_pdb_close () {
INPUT
SQLRUN "alter pluggable database ${input1} close;"
}
# ------------------------------------------------------------
f_pdb_shutdown () {
INPUT
SQLNEWF
SQLLINE "whenever sqlerror exit 1;"
SQLLINE "alter session set container = ${input1} ;"
SQLLINE "shutdown immediate ;"
SQLEXEC
}
# ------------------------------------------------------------
f_pdb_list () {
SQLNEWF
SQLLINE "set head on feedback on pagesi 1000 "
SQLLINE "col pdb_id format 99"
SQLLINE "col pdb_name format a10"
SQLLINE "col dbid format 999999999999"
SQLLINE "col open_time format a30"
SQLLINE "select a.pdb_id, a.pdb_name, b.open_mode, b.open_time, a.dbid, a.status"
SQLLINE "from dba_pdbs a, v\$pdbs b where a.dbid=b.dbid order by a.pdb_id;"
SQLEXEC
}
# ------------------------------------------------------------
f_pdb_create () {
INPUT
typeset -u u_pdb_name=${input1}
SQLRUN "create pluggable database ${input1} admin user ${PDB_ADM_USR} identified by ${PDB_ADM_PWD} file_name_convert=('${ORADATA}/${CDB_NAME}/pdbseed/' ,'${ORADATA}/${CDB_NAME}/${u_pdb_name}/');"
AddPDB2TNS ${u_pdb_name}
}
# ------------------------------------------------------------
f_pdb_clone () {
INPUT 2
typeset -u u_pdb_from=${input1}
typeset -u u_pdb_to=${input2}
SQLRUN "create pluggable database ${u_pdb_to} from ${u_pdb_from} file_name_convert=('${ORADATA}/${CDB_NAME}/${u_pdb_from}/' ,'${ORADATA}/${CDB_NAME}/${u_pdb_to}/');"
AddPDB2TNS ${u_pdb_to}
}
# ------------------------------------------------------------
f_pdb_drop () {
INPUT
typeset -u u_pdb_name=${input1}
SQLRUN "drop pluggable database ${u_pdb_name} including datafiles;"
RemoveTNS ${u_pdb_name}
rmdir ${ORADATA}/${CDB_NAME}/${u_pdb_name}
}
# ------------------------------------------------------------
f_pdb_unplug_2_xml () {
INPUT
typeset -u u_pdb_name=${input1}
SQLRUN "alter pluggable database ${input1} unplug into '${ORADATA}/${CDB_NAME}/${u_pdb_name}/${u_pdb_name}.xml';"
}
# ------------------------------------------------------------
f_pdb_unplug () {
INPUT
typeset -u u_pdb_name=${input1}
SQLRUN "drop pluggable database ${input1} keep datafiles ;"
RemoveTNS ${u_pdb_name}
}
# ------------------------------------------------------------
f_pdb_plug_check () {
INPUT
typeset -u u_pdb_name=${input1}
v_pdb_xml=${ORADATA}/${CDB_NAME}/${u_pdb_name}/${u_pdb_name}.xml
SQLNEWF
SQLLINE "SET SERVEROUTPUT ON"
SQLLINE "DECLARE"
SQLLINE "  l_result BOOLEAN;"
SQLLINE "BEGIN"
SQLLINE "  l_result := dbms_pdb.check_plug_compatibility(pdb_descr_file => '${v_pdb_xml}', pdb_name=>'${u_pdb_name}');"
SQLLINE "  IF l_result THEN"
SQLLINE "    DBMS_OUTPUT.PUT_LINE('compatible');"
SQLLINE "  ELSE"
SQLLINE "    DBMS_OUTPUT.PUT_LINE('incompatible');"
SQLLINE "  END IF;"
SQLLINE "END;"
SQLLINE "/"
SQLEXEC
}
# ------------------------------------------------------------
f_pdb_plug () {
INPUT
typeset -u u_pdb_name=${input1}
SQLRUN "create pluggable database ${u_pdb_name} using '${ORADATA}/${CDB_NAME}/${u_pdb_name}/${u_pdb_name}.xml' nocopy tempfile reuse;"
AddPDB2TNS ${u_pdb_name}
}
# ------------------------------------------------------------
f_pdb_plug_as () {
INPUT 2
typeset -u u_pdb_name=${input1}
typeset -u u_pdb_as=${input2}
SQLRUN "create pluggable database ${u_pdb_as} using '${ORADATA}/${CDB_NAME}/${u_pdb_name}/${u_pdb_name}.xml' file_name_convert=('${ORADATA}/${CDB_NAME}/${u_pdb_name}/' ,'${ORADATA}/${CDB_NAME}/${u_pdb_as}/');"
AddPDB2TNS ${u_pdb_as}
}
# ------------------------------------------------------------
f_pdb_clone_subset () {
INPUT 3
typeset -u u_pdb_from=${input1}
typeset -u u_pdb_to=${input2}
#input3 is subset_cluase and it can be one of "ALL", "NONE", "('ts_name1','ts_name2')" or "ALL EXCEPT('ts_name1','ts_name2')"
SQLRUN "create pluggable database ${u_pdb_to} from ${u_pdb_from} file_name_convert=('${ORADATA}/${CDB_NAME}/${u_pdb_from}/' ,'${ORADATA}/${CDB_NAME}/${u_pdb_to}/') user_tablespaces=ALL EXCEPT('ts3');"
SQLRUN "create pluggable database ${u_pdb_as} using '${ORADATA}/${CDB_NAME}/${u_pdb_name}/${u_pdb_name}.xml' file_name_convert=('${ORADATA}/${CDB_NAME}/${u_pdb_name}/' ,'${ORADATA}/${CDB_NAME}/${u_pdb_as}/');"
AddPDB2TNS ${u_pdb_as}
}
# ------------------------------------------------------------
