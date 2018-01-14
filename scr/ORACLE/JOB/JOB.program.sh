# ############################################################
# DBMS_SCHEDULER PROGRAM FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# program actions
action_L1="list create drop create_few "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,NONE,List_programs \
"
# ------------------------------------------------------------
# local variables
v_debug=0
# ------------------------------------------------------------
INCLIB_c
# ------------------------------------------------------------
f_program_list () { 
SQLQRY "select program_name,program_type, enabled,program_action from dba_scheduler_programs;"
}
# ------------------------------------------------------------
f_program_create () { 
INPUT 3
SCHEDULER_p "create_program(program_name=>'${input1}', program_type=>'${input2}',program_action=>'${input3}',enabled=>true)"
}
# ------------------------------------------------------------
f_program_drop () { 
INPUT
SCHEDULER_p "drop_program(program_name=>'${input1}', force=>FALSE)"
}
# ------------------------------------------------------------
