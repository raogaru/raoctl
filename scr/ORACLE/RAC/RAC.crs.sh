# ############################################################
# RAC CRS FUNCTIONS - Oracle Cluster Registry Services (crsctl)
# ############################################################
# ------------------------------------------------------------
# RAC crsctl actions
action_L1="status start stop "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
status,none,crs_status_in_table_format \
stop,none,stop_crs \
start,none,start_crs \
"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions


# ------------------------------------------------------------
CRSCTL_p () {
${ORACLE_HOME}/bin/crsctl ${v_module} crs
}
# ------------------------------------------------------------
f_ocr_check () {
ocrcheck  
}
# ------------------------------------------------------------
f_ocr_add () {
INPUT
ocrconfig -add ${input1}
}
# ------------------------------------------------------------
f_ocr_delete () {
INPUT
ocrconfig -delete ${input1}
}
# ------------------------------------------------------------
f_ocr_show_bkp () {
ocrconfig -showbackup 
}
# ------------------------------------------------------------
f_ocr_dump () {
INPUT
cd $TMP
ocrdump -backupfile ${input1}
more OCRDUMPFILE
}
# ------------------------------------------------------------
f_ocr_dump () {
cd $TMP
more OCRDUMPFILE
}
# ------------------------------------------------------------
