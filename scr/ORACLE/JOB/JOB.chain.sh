# ############################################################
# DBMS_SCHEDULER CHAIN FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# chain actions
action_L1="list create drop alter "
action_L2="create_test_program_for_chain_step list_steps define_step drop_step "
action_L3="list_rules define_rule drop_rule  "
action_L4="enable disable analyze run "
action_L="$action_L1 $action_L2 $action_L3 $action_L4 "
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,NONE,List_Chains \
create,chain_name,Create_Chain \
drop,chain_name,Drop_Chain \
list_step,NONE,List_Chain_Steps \
add_step,chain_name:step,Add_Chain_Step \
remove_step,chain_name:step,Remove_Chain_Step \
"
# ------------------------------------------------------------
# local variables
v_debug=0
# ------------------------------------------------------------
INCLIB_c
# ------------------------------------------------------------
f_chain_list () { 
SQLQRY "select owner||'.'||chain_name
||'  RuleSet:'||rule_set_owner||'.'||rule_set_name ,
enabled
from dba_scheduler_chains;"
}
# ------------------------------------------------------------
f_chain_create () { 
INPUT
SCHEDULER_p "create_chain(chain_name=>'${input1}')"
}
# ------------------------------------------------------------
f_chain_drop () { 
INPUT
SCHEDULER_p "drop_chain(chain_name=>'${input1}', force=>FALSE)"
}
# ------------------------------------------------------------
f_chain_alter () { 
INPUT 4
SCHEDULER_p "alter_chain(chain_name=>'${input1}', step_name=>'${input2}', attribute=>'${input3}', value=>${input4})"
}
# ------------------------------------------------------------
# CHAIN STEPS
# ------------------------------------------------------------
f_chain_list_steps () { 
SQLNEWF
SQLLINE "set head on pagesi 1000 linesi 200 trims on"
SQLLINE "col chain_name format a30"
SQLLINE "col step_name format a30"
SQLLINE "col program_name format a30"
SQLLINE "select owner||'.'||chain_name chain_name, step_name, program_owner||'.'||program_name program_name from dba_scheduler_chain_steps order by chain_name,step_name;"
SQLEXEC
}
# ------------------------------------------------------------
f_chain_define_step () { 
INPUT 3
SCHEDULER_p "define_chain_step(chain_name=>'${input1}', step_name=>'${input2}',program_name=>'${input3}')"
}
# ------------------------------------------------------------
f_chain_drop_step () { 
INPUT 2
SCHEDULER_p "drop_chain_step(chain_name=>'${input1}', step_name=>'${input2}',force=>true)"
}
# ------------------------------------------------------------
# CHAIN RULES
# ------------------------------------------------------------
f_chain_list_rules () { 
SQLNEWF
SQLLINE "set head on pagesi 1000 linesi 200 trims on"
SQLLINE "col chain_name format a30"
SQLLINE "col rule_name format a30"
SQLLINE "col condition format a50"
SQLLINE "col action format a50"
SQLLINE "
select owner||'.'||chain_name chain_name,
rule_owner||'.'||rule_name rule_name,
condition, action
from dba_scheduler_chain_rules;"
SQLEXEC
}
# ------------------------------------------------------------
f_chain_define_rule () { 
INPUT 3
SCHEDULER_p "define_chain_rule(chain_name=>'${input1}', condition=>'${input2}', action=>'${input3}')"
}
# ------------------------------------------------------------
f_chain_drop_rule () { 
INPUT 2
SCHEDULER_p "drop_chain_rule(chain_name=>'${input1}', rule_name=>'${input2}',force=>true)"
}
# ------------------------------------------------------------
# CHAIN EXEC
# ------------------------------------------------------------
f_chain_enable () { 
INPUT
SCHEDULER_p "enable(name=>'${input1}')"
}
# ------------------------------------------------------------
f_chain_disable () { 
INPUT
SCHEDULER_p "disable(name=>'${input1}',force=>true)"
}
# ------------------------------------------------------------
f_chain_analyze () { 
INPUT 2
ECHO "not coded yet"
#SCHEDULER_p "analyze_chain(chain_name=>'${input1}', step_name=>'${input2}',force=>true)"
}
# ------------------------------------------------------------
f_chain_run () { 
INPUT 2
rc_SHOW_SQL=YES
SCHEDULER_p "run_chain(chain_name=>'${input1}', start_steps=>'${input2}')"
}
# ------------------------------------------------------------
f_chain_create_test_program_for_chain_step () { 
INPUT
rc_SHOW_SQL=YES
SQLNEWF
SQLLINE "create or replace procedure RAO.p_${input1} is"
SQLLINE "begin"
SQLLINE "null;"
SQLLINE "-- insert into t1 values('${input1}', sysdate);"
SQLLINE "commit;"
SQLLINE "end;"
SQLLINE "/"
SQLEXEC
SCHEDULER_p "create_program(program_name=>'${input1}', program_type=>'STORED_PROCEDURE',program_action=>'RAO.P_${input1}',enabled=>true)"
}
# ------------------------------------------------------------
