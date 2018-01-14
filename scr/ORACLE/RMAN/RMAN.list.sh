# ############################################################
# RMAN LIST FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# RMAN LIST actions
action_L1="db ts df cf al incar "
action_L2="cp_db cp_ts cp_df cp_cf cp_al "
action_L3="xxx "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
db,None,List_Backup_of_Database \
ts,None,List_Backup_of_Tablespace \
df,None,List_Backup_of_DataFile \
cf,None,List_Backup_of_ControlFile \
al,None,List_Backup_of_AlertLogs \
incar,None,List_Database_Incarnations \
cp_db,None,List_Backup_Copy_Copy_of_Database \
cp_ts,None,List_Backup_Copy_of_Tablespace \
cp_df,None,List_Backup_Copy_of_DataFile \
"
# ------------------------------------------------------------
# local variables
v_debug=0
#RMAN_STR_LOG="log=${TMPLOG}"
RMAN_STR_LOG=""
# ------------------------------------------------------------
f_list_incar () { 
RMANLINE "LIST INCARNATION;"
}
# ------------------------------------------------------------
f_list_db () { 
RMANLINE "LIST BACKUP OF DATABASE ;"
}
# ------------------------------------------------------------
f_list_ts () { 
INPUT
RMANLINE "LIST BACKUP OF TABLESPACE ${input};"
}
# ------------------------------------------------------------
f_list_df () { 
INPUT
RMANLINE "LIST BACKUP OF DATAFILE ${input};"
}
# ------------------------------------------------------------
f_list_cf () { 
RMANLINE "LIST BACKUP OF CONTROLFILE;"
}
# ------------------------------------------------------------
f_list_al () { 
RMANLINE "LIST ARCHIVELOG ;"
}
# ------------------------------------------------------------
f_list_cp_ts () { 
INPUT
RMANLINE "LIST COPY OF TABLESPACE ${input};"
}
# ------------------------------------------------------------
f_list_df () { 
INPUT
RMANLINE "LIST BACKUP OF DATAFILE ${input};"
}
# ------------------------------------------------------------
f_list_cf () { 
RMANLINE "LIST BACKUP OF CONTROLFILE;"
}
# ------------------------------------------------------------
f_list_al () { 
RMANLINE "LIST ARCHIVELOG ;"
}
