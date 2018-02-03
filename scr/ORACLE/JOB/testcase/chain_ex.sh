#######################################################################
#
# Chain example
#
#
#      |--C1 : S1 --> S2 ----|\ 
#      |                     | \
# C0 --|--C2 : S1 --> S2 ----|--Complete
#      |                     | /
#      |--C3 : S1 --> S2 ----|/
#
#######################################################################
#
alias jobCHAIN="raoctl -p oracle -c job -m chain -a "
#
jobCHAIN create -i RAO.C0
jobCHAIN create -i RAO.C1
jobCHAIN create -i RAO.C2
jobCHAIN create -i RAO.C3
# 
# attch 3 chanins to c0
jobCHAIN define_step -i RAO.C0:C0S1:RAO.C1
jobCHAIN define_step -i RAO.C0:C0S2:RAO.C2
jobCHAIN define_step -i RAO.C0:C0S3:RAO.C3
#
jobCHAIN create_test_program_for_chain_step -i C1S1P1
jobCHAIN create_test_program_for_chain_step -i C1S1P2
jobCHAIN create_test_program_for_chain_step -i C1S2P1
jobCHAIN create_test_program_for_chain_step -i C1S2P2
jobCHAIN create_test_program_for_chain_step -i C1S3P1
jobCHAIN create_test_program_for_chain_step -i C1S3P2
#
# add steps to c1
jobCHAIN define_step -i RAO.C1:C1S1:C1S1P1
jobCHAIN define_step -i RAO.C1:C1S2:C1S2P2
#
# add steps to c2
jobCHAIN define_step -i RAO.C2:C2S1:C2S1P1
jobCHAIN define_step -i RAO.C2:C2S2:C2S2P2
#
# add steps to c3
jobCHAIN define_step -i RAO.C3:C3S1:C3S1P1
jobCHAIN define_step -i RAO.C3:C3S2:C3S2P2
#
# add rule to start chains unconditionally
jobCHAIN define_rule -i RAO.C0:TRUE:"START RAO.C1"
jobCHAIN define_rule -i RAO.C0:TRUE:"START RAO.C2"
jobCHAIN define_rule -i RAO.C0:TRUE:"START RAO.C3"

#
jobCHAIN enable -i RAO.C1
jobCHAIN enable -i RAO.C2
jobCHAIN enable -i RAO.C3
jobCHAIN enable -i RAO.C0
#

select * from DBA_SCHEDULER_CHAINS;

select * from DBA_SCHEDULER_CHAIN_STEPS;

select * from DBA_SCHEDULER_CHAIN_RULES;

select * from DBA_SCHEDULER_RUNNING_CHAINS;


