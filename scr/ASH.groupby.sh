# ############################################################
# ASH GROUP BY FUNCTIONS (V$ACTIVE_SESSION_HISTORY)
# ############################################################
# ------------------------------------------------------------
# ASH GROUP BY actions
action_L1="program module action machine event wait user opname state sqlid phv sid "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
module,none,Group_by_Module \
action,none,Group_by_Action \
"
# ------------------------------------------------------------
# local variables

# ------------------------------------------------------------
ASHGRP_by () {
SQLQRY "select ${1}, count(1) from v\$active_session_history group by ${1} order by 2;"
}
# ------------------------------------------------------------
f_groupby_program () { 
ASHGRP_by ${v_action}
}
# ------------------------------------------------------------
f_groupby_module () { 
ASHGRP_by ${v_action}
}
# ------------------------------------------------------------
f_groupby_action () { 
ASHGRP_by ${v_action}
}
# ------------------------------------------------------------
f_groupby_machine () { 
ASHGRP_by ${v_action}
}
# ------------------------------------------------------------
f_groupby_event () { 
ASHGRP_by ${v_action}
}
# ------------------------------------------------------------
f_groupby_wait () { 
ASHGRP_by wait_class
}
# ------------------------------------------------------------
f_groupby_user () { 
ASHGRP_by user_id
}
# ------------------------------------------------------------
f_groupby_opname () { 
ASHGRP_by sql_opname
}
# ------------------------------------------------------------
f_groupby_state () { 
ASHGRP_by session_state
}
# ------------------------------------------------------------
f_groupby_sqlid () { 
ASHGRP_by sql_id
}
# ------------------------------------------------------------
f_groupby_phv () { 
ASHGRP_by sql_plan_hash_value
}
# ------------------------------------------------------------
f_groupby_sid () { 
ASHGRP_by session_id
}
# ------------------------------------------------------------
