set linesi 1000 trims on pagesi 1000
----------------------------------------------------------------------------
-- Step 5a:
-- SCOTT reads the result. 
----------------------------------------------------------------------------
DECLARE
    l_prin_id           WF_PROCESS_INSTANCES.ID%TYPE;        -- ID of new created process instance
    l_pati_id_scott     WF_PARTICIPANTS.ID%TYPE;             -- ID of participant 'SCOTT'
    l_acin_id           WF_ACTIVITY_INSTANCES.ID%TYPE;       -- ID of new created process instance

    l_worklist_cursor   PL_FLOW.generic_curtype;             -- a cursor variable
    l_worklist_record   PL_FLOW.worklist_rowtype%ROWTYPE;    -- PL_FLOW.worklist_rowtype is dummy cursor for %ROWTYPE 

    l_dummy_int        PLS_INTEGER;
 
    
BEGIN
    SELECT id 
      INTO l_pati_id_scott
      FROM wf_participants
     WHERE name='SCOTT';    

    PL_FLOW.OpenWorkList( 
        pworklist_filter    => 'STATE=''NOTRUNNING'' '||CHR(38)||' ACTIVITIES prce_id=10 and acti_id=60',
        pati_id_in          => l_pati_id_scott,      -- this is the ID of scott
        count_flag          => 0,                    -- should rowcount be returned?
        pquery_handle       => l_worklist_cursor,
        pcount              => l_dummy_int
    );

    -- get the workitem
    FETCH l_worklist_cursor INTO l_worklist_record;
    CLOSE l_worklist_cursor;

    -- Now, tell PL/FLOW that SCOTT starts with this workitem
    PL_FLOW.ChangeActivityInstanceState(
        acin_id_in  => l_worklist_record.acin_id,
        state_in    => 'RUNNING',
		pati_id_in  => l_pati_id_scott
    );

    -- Here would be code that displays the result on SCOTT's screen.

    -- Now, complete the same workitem
    PL_FLOW.ChangeActivityInstanceState(
        acin_id_in  => l_worklist_record.acin_id,
        state_in    => 'COMPLETED',
		pati_id_in  => l_pati_id_scott
    );
END;
/

Prompt Activity instances after SCOTT completed 'read final result'
SELECT acti_prce_id, acti_id, prin_id, id, state, date_created, date_started, date_ended FROM WF_ACTIVITY_INSTANCES
/

