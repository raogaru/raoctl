PROMPT step-1 create draft
delete from wf_debug_log;
commit;
set linesi 1000 trims on pagesi 1000
DECLARE
    l_prin_id           WF_PROCESS_INSTANCES.ID%TYPE;        -- ID of new created process instance
    l_pati_id_employee   WF_PARTICIPANTS.ID%TYPE;             -- ID of participant 'SCOTT'
    l_acin_id           WF_ACTIVITY_INSTANCES.ID%TYPE;       -- ID of new created activity instance
    
BEGIN
    SELECT prin_seq.NEXTVAL INTO l_prin_id FROM DUAL;    
    PL_FLOW.CreateProcessInstance( prce_id_in=>100,prin_id_in=>l_prin_id);
    SELECT id INTO l_pati_id_employee FROM wf_participants WHERE name='SCOTT';    
    PL_FLOW.AssignProcessInstanceAttribute( prin_id_in=>l_prin_id, name_in=>'EMPNO', value_in=>l_pati_id_employee);
    PL_FLOW.StartProcess( prin_id_in  => l_prin_id, pati_id_in  => l_pati_id_employee);
    SELECT id INTO l_acin_id FROM wf_activity_instances WHERE prin_id = l_prin_id AND acti_id = 10;
    PL_FLOW.ChangeActivityInstanceState( acin_id_in=> l_acin_id, state_in=> 'RUNNING', pati_id_in=>l_pati_id_employee);
    PL_FLOW.ChangeActivityInstanceState( acin_id_in=> l_acin_id, state_in=> 'COMPLETED', pati_id_in  => l_pati_id_employee);
END;
/
