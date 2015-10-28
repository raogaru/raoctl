# ############################################################
# Partition FUNCTIONS - Oracle Cluster Registry management
# ############################################################
# ------------------------------------------------------------
# Partition Object Functions
action_L1="check add delete show_bkp dump show_dump "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,none,list_part \
"

# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions

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
