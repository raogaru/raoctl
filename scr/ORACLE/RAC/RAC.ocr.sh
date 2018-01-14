# ############################################################
# RAC OCR FUNCTIONS - Oracle Cluster Registry management
# ############################################################
# ------------------------------------------------------------
# RAC OCR actions
action_L1="check add delete show_bkp dump show_dump "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
check,none,Run_OCR_file_integrity_check_using_ocrcheck \
add,ocr_path,Add_OCR \
delete,ocr_path,Delete_OCR \
show_bkp,none,Show_OCR_backup_files \
dump,none,Dump_OCR_file_contents \
show_dump,none,Show_recent_OCR_dump \
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
