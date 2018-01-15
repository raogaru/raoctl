set linesi 1000 trims on pagesi 1000
----------------------------------------------------------------------------
-- Step 2: techlead review
----------------------------------------------------------------------------
DECLARE
    l_prin_id           WF_PROCESS_INSTANCES.ID%TYPE;        -- ID of new created process instance
    l_pati_id_manager   WF_PARTICIPANTS.ID%TYPE;             -- ID of participant 'JONES'
    l_acin_id           WF_ACTIVITY_INSTANCES.ID%TYPE;       -- ID of new created process instance

    l_worklist_cursor   PL_FLOW.generic_curtype;             -- a cursor variable
    l_worklist_record   PL_FLOW.worklist_rowtype%ROWTYPE;    -- PL_FLOW.worklist_rowtype is dummy cursor for %ROWTYPE 

    l_dummy_int        PLS_INTEGER;
 
    
BEGIN
    -- The manager is JONES, with pati_id 7566
    SELECT id INTO l_pati_id_manager FROM wf_participants WHERE name='JONES';    

    PL_FLOW.OpenWorkList( 
        pworklist_filter    => 'a.atri_id=112 AND a.value=TO_CHAR(7788)',
        pati_id_in          => l_pati_id_manager,
        count_flag          => 0,
        pquery_handle       => l_worklist_cursor,
        pcount              => l_dummy_int
    );
    -- get the workitem for this manager
    -- please note that in this example, assumptions are being made about what this worklist
    -- query will return. In real life, the worklist will be displayed on screen
    FETCH l_worklist_cursor INTO l_worklist_record;
    CLOSE l_worklist_cursor;

    -- Now, tell PL/FLOW that JONES starts with this workitem
    PL_FLOW.ChangeActivityInstanceState(
        acin_id_in  => l_worklist_record.acin_id,
        state_in    => 'RUNNING',
		pati_id_in  => l_pati_id_manager   -- pati id of JONES
    );

    -- Jones decides to deny the request.
    PL_FLOW.AssignProcessInstanceAttribute(
        prin_id_in  => l_worklist_record.prin_id,
        name_in     => 'APPROVED',
		value_in    => 'N'
    );

    -- Now, complete the same workitem
    PL_FLOW.ChangeActivityInstanceState(
        acin_id_in  => l_worklist_record.acin_id,
        state_in    => 'COMPLETED',
		pati_id_in  => l_pati_id_manager   -- pati id of JONES
    );
END;
/
Prompt Activity instances after JONES completed 'decide on bonus request'
SELECT acti_prce_id, acti_id, prin_id, id, state, date_created, date_started, date_ended FROM WF_ACTIVITY_INSTANCES
/
Prompt Performers after JONES completed 'file bonus request': 7788 is SCOTT.
SELECT id, pati_id, acin_id, date_created, state, accepted FROM WF_PERFORMERS
/

