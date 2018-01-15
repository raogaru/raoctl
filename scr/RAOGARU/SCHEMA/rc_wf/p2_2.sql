set serveroutput on size 10000
set linesi 1000 trims on pagesi 1000
delete from wf_debug_log;
commit;
----------------------------------------------------------------------------
-- Step 2: get self draft request and then submit
----------------------------------------------------------------------------
DECLARE
    l_prin_id           WF_PROCESS_INSTANCES.ID%TYPE;        -- ID of new created process instance
    l_pati_id_scott   WF_PARTICIPANTS.ID%TYPE;             -- ID of participant 'JONES'
    l_acin_id           WF_ACTIVITY_INSTANCES.ID%TYPE;       -- ID of new created process instance

    l_worklist_cursor   PL_FLOW.generic_curtype;             -- a cursor variable
    l_worklist_record   PL_FLOW.worklist_rowtype%ROWTYPE;    -- PL_FLOW.worklist_rowtype is dummy cursor for %ROWTYPE 

    l_dummy_int        PLS_INTEGER;
BEGIN
dbms_output.put_line('DEBUG: get scott id');
SELECT id INTO l_pati_id_scott FROM wf_participants WHERE name='SCOTT';    

dbms_output.put_line('DEBUG:get work');
PL_FLOW.OpenWorkList(pworklist_filter=>'a.atri_id=112 AND a.value=TO_CHAR(7788)',pati_id_in=>l_pati_id_scott,count_flag=>1,pquery_handle=>l_worklist_cursor,pcount=>l_dummy_int);

dbms_output.put_line('DEBUG:p_count='||to_char(l_dummy_int));

dbms_output.put_line('DEBUG:fetch work item ');
FETCH l_worklist_cursor INTO l_worklist_record;
CLOSE l_worklist_cursor;

dbms_output.put_line('DEBUG:change status to running acin='||l_worklist_record.acin_id||' pati='||l_pati_id_scott);
PL_FLOW.ChangeActivityInstanceState( acin_id_in=>l_worklist_record.acin_id,state_in=>'RUNNING',pati_id_in=>l_pati_id_scott);

dbms_output.put_line('DEBUG:submit ');
PL_FLOW.AssignProcessInstanceAttribute(prin_id_in=>l_worklist_record.prin_id,name_in=>'SUBMITTED',value_in=>'N');

dbms_output.put_line('DEBUG:complete ');
PL_FLOW.ChangeActivityInstanceState(acin_id_in=>l_worklist_record.acin_id,state_in=>'COMPLETED',pati_id_in=>l_pati_id_scott);

END;
/
