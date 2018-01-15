set linesi 1000 trims on pagesi 1000
----------------------------------------------------------------------------
-- Step 4:
-- The president makes the final decision.
----------------------------------------------------------------------------
DECLARE
    l_prin_id           WF_PROCESS_INSTANCES.ID%TYPE;        -- ID of new created process instance
    l_pati_id_president WF_PARTICIPANTS.ID%TYPE;             -- ID of participant president
    l_acin_id           WF_ACTIVITY_INSTANCES.ID%TYPE;       -- ID of new created process instance

    l_worklist_cursor   PL_FLOW.generic_curtype;             -- a cursor variable
    l_worklist_record   PL_FLOW.worklist_rowtype%ROWTYPE;    -- PL_FLOW.worklist_rowtype is dummy cursor for %ROWTYPE 

    l_dummy_int        PLS_INTEGER;
 
    
BEGIN
    -- At this point, there is a workitem on the worklist of the managers
    -- The manager is JONES, with pati_id 7566
    SELECT id 
      INTO l_pati_id_president
      FROM wf_participants
     WHERE description='PRESIDENT';    

    PL_FLOW.OpenWorkList( 
        pworklist_filter    => 'STATE=''NOTRUNNING''',
        pati_id_in          => l_pati_id_president,  
        count_flag          => 0,                    -- should rowcount be returned?
        pquery_handle       => l_worklist_cursor,
        pcount              => l_dummy_int
    );
    -- get the first workitem from this list
    -- please note that in this example, assumptions are being made about what this worklist
    -- query will return. In real life, the worklist will be displayed on screen
    FETCH l_worklist_cursor INTO l_worklist_record;
    CLOSE l_worklist_cursor;

    -- Now, tell PL/FLOW that KING starts with this workitem
    PL_FLOW.ChangeActivityInstanceState(
        acin_id_in  => l_worklist_record.acin_id,
        state_in    => 'RUNNING',
		pati_id_in  => l_pati_id_president
    );

    -- King decides to approve the request.
    PL_FLOW.AssignProcessInstanceAttribute(
        prin_id_in  => l_worklist_record.prin_id,
        name_in     => 'APPROVED',
		value_in    => 'Y'
    );

    -- Now, complete the same workitem
    PL_FLOW.ChangeActivityInstanceState(
        acin_id_in  => l_worklist_record.acin_id,
        state_in    => 'COMPLETED',
		pati_id_in  => l_pati_id_president
    );
END;
/

Prompt Activity instances after KING completed 'decide on bonus request'
SELECT acti_prce_id, acti_id, prin_id, id, state, date_created, date_started, date_ended FROM WF_ACTIVITY_INSTANCES
/
Prompt Performers after KING completed 'decide on bonus request'
SELECT id, pati_id, acin_id, date_created, state, accepted FROM WF_PERFORMERS
/

-- Now there are two workitems, one for SCOTT, and one for the ACCOUNTING department.

