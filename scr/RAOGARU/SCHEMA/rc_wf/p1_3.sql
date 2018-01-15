set serveroutput on size 10000
set linesi 1000 trims on pagesi 1000
----------------------------------------------------------------------------
-- Step 3:
-- The bonus was disapproved, so SCOTT will have a request denial on HIS worklist.
-- Because SCOTT is assigned the last workitem, he is the only one that may start it.
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
        pworklist_filter    => 'STATE=''NOTRUNNING''',
        pati_id_in          => l_pati_id_scott,      -- this is the ID of jones
        count_flag          => 1,                    -- should rowcount be returned?
        pquery_handle       => l_worklist_cursor,
        pcount              => l_dummy_int
    );

	dbms_output.put_line ('count='||to_char(l_dummy_int));
    -- get the workitem
    -- please note that in this example, assumptions are being made about what this worklist
    -- query will return. In real life, the worklist will be displayed on screen
    FETCH l_worklist_cursor INTO l_worklist_record;
    CLOSE l_worklist_cursor;

    -- Now, tell PL/FLOW that SCOTT starts with this workitem
    PL_FLOW.ChangeActivityInstanceState(
        acin_id_in  => l_worklist_record.acin_id,
        state_in    => 'RUNNING',
		pati_id_in  => l_pati_id_scott
    );

    -- Scott is not happy.
    PL_FLOW.AssignProcessInstanceAttribute(
        prin_id_in  => l_worklist_record.prin_id,
        name_in     => 'HAPPY',
		value_in    => 'N'
    );

    -- Now, complete the same workitem
    PL_FLOW.ChangeActivityInstanceState(
        acin_id_in  => l_worklist_record.acin_id,
        state_in    => 'COMPLETED',
		pati_id_in  => l_pati_id_scott
    );
    
    -- Now there will be a new workitem for scott: file bonus request to president
    PL_FLOW.OpenWorkList( 
        pworklist_filter    => 'STATE=''NOTRUNNING''',
        pati_id_in          => l_pati_id_scott,      -- this is the ID of jones
        count_flag          => 0,                    -- should rowcount be returned?
        pquery_handle       => l_worklist_cursor,
        pcount              => l_dummy_int
    );
    FETCH l_worklist_cursor INTO l_worklist_record;
    CLOSE l_worklist_cursor;

    -- Now, tell PL/FLOW that SCOTT starts with this workitem
PL_FLOW.ChangeActivityInstanceState( acin_id_in  => l_worklist_record.acin_id, state_in    => 'RUNNING', pati_id_in  => l_pati_id_scott);

    -- Here would be code for the screen SCOTT can enter the bonus
    -- request to the manager

    -- Now, complete the same workitem
    PL_FLOW.ChangeActivityInstanceState(
        acin_id_in  => l_worklist_record.acin_id,
        state_in    => 'COMPLETED',
		pati_id_in  => l_pati_id_scott
    );


END;
/

--Prompt Activity instances after SCOTT completed 'read bonus request denial AND file bonus request to president'
--SELECT acti_prce_id, acti_id, prin_id, id, state, date_created, date_started, date_ended FROM WF_ACTIVITY_INSTANCES;

