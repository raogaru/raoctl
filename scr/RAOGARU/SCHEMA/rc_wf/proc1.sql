-- ----------------------------------------------------------------------

PROMPT Add Process

INSERT INTO wf_processes ( id, name, description) values (1000, 'Simple Test - 1', 'Simple Test flow');

-- ----------------------------------------------------------------------

Prompt Add activities

INSERT INTO wf_activities (prce_id, id,  pati_query, name, description, start_mode, finish_mode, implementation) VALUES ( 
1000, 1001, 10, 'step-1 - submit', 'Simple step 1', 'MANUAL', 'MANUAL', 'NO');

INSERT INTO wf_activities (prce_id, id,  pati_query, name, description, start_mode, finish_mode, implementation) VALUES ( 
1000, 1002, 20, 'step-2 review', 'Simple step 2', 'MANUAL', 'MANUAL', 'NO');

-- ----------------------------------------------------------------------

Prompt Add attributes

INSERT INTO wf_attributes ( prce_id, id, data_type, name, length, description, keep) VALUES ( 
1000, 1001, 'INTEGER', 'EMPNO', 10, 'Link to EMP.EMPNO', 'Y');

INSERT INTO wf_attributes ( prce_id, id, data_type, name, length, description, keep) VALUES ( 
1000, 1005, 'CHARACTER', 'APPROVED', 1, 'MANAGER Approved', 'N');
commit;

-- ----------------------------------------------------------------------

PROMPT Add Transitions
 
INSERT INTO wf_transitions ( ACTI_PRCE_ID_FROM, ACTI_ID_FROM, ACTI_PRCE_ID_TO, ACTI_ID_TO, NAME,
DESCRIPTION, CONDITION, CONDITION_TYPE, REPLICATION_TIMESTAMP ) VALUES ( 
1000, 1001, 1000, 1002, 'Assigned to manager Lead', 'Assigned to Team Lead', NULL, NULL, NULL);

commit;

-- ----------------------------------------------------------------------

