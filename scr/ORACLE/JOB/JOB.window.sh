# ############################################################
# DBMS_SCHEDULER WINDOW FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# window actions
action_L1="list create drop open close "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,NONE,List_windows \
create,NONE,Create_Window \
drop,NONE,Drop_Window \
open,NONE,Open_Window \
close,NONE,Close_Window \
"
# ------------------------------------------------------------
# local variables
v_debug=0
# ------------------------------------------------------------
INCLIB_c
# ------------------------------------------------------------
f_window_list () { 
SQLQRY "select window_name dba_scheduler_windows;"
}
# ------------------------------------------------------------
f_window_create () { 
INPUT 3
SCHEDULER_p "create_window(window_name=>'${input1}', program_type=>'${input2}',program_action=>'${input3}',enabled=>true)"
}
# ------------------------------------------------------------
f_window_drop () { 
INPUT
SCHEDULER_p "drop_program(program_name=>'${input1}', force=>FALSE)"
}
# ------------------------------------------------------------
