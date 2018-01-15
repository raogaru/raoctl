-- SQL script to run example process 20 and 30
-- Assumed to run in SCOTT's schema or in a schema that can read SCOTT's tables
-- also assumed example1 is already runned.
-- 2003 12 07 Yeb Havinga

SPOOL example2_run_flow.lst

----------------------------------------------------------------------------
-- Step 1:
-- Start a process 20 by scott
----------------------------------------------------------------------------
DECLARE
    l_prin_id           WF_PROCESS_INSTANCES.ID%TYPE;
    l_pati_id_scott     WF_PARTICIPANTS.ID%TYPE;
    l_acin_id           WF_ACTIVITY_INSTANCES.ID%TYPE;
    
BEGIN
    SELECT prin_seq.NEXTVAL
      INTO l_prin_id
      FROM DUAL;    

    PL_FLOW.CreateProcessInstance(
        prce_id_in=>20,             
        prin_id_in=>l_prin_id
    );

    SELECT id 
      INTO l_pati_id_scott
      FROM wf_participants
     WHERE name='SCOTT';    
    
    PL_FLOW.StartProcess(
        prin_id_in  => l_prin_id,
        pati_id_in  => l_pati_id_scott
    );
END;
/
Prompt Activity instances:
SELECT acti_prce_id, acti_id, prin_id, id, state, date_created, date_started, date_ended FROM WF_ACTIVITY_INSTANCES
/


----------------------------------------------------------------------------
-- Step 2:
-- the accountant miller:
----------------------------------------------------------------------------
DECLARE
    l_prin_id               WF_PROCESS_INSTANCES.ID%TYPE;        -- ID of new created process instance
    l_pati_id_accountant    WF_PARTICIPANTS.ID%TYPE;             -- ID of participant miller
    l_acin_id               WF_ACTIVITY_INSTANCES.ID%TYPE;       -- ID of new created process instance

    l_worklist_cursor   PL_FLOW.generic_curtype;             -- a cursor variable
    l_worklist_record   PL_FLOW.worklist_rowtype%ROWTYPE;    -- PL_FLOW.worklist_rowtype is dummy cursor for %ROWTYPE 

    l_dummy_int        PLS_INTEGER;
  
BEGIN
    SELECT id 
      INTO l_pati_id_accountant
      FROM wf_participants
     WHERE name='MILLER';    

    PL_FLOW.OpenWorkList( 
        pworklist_filter    => 'STATE=''NOTRUNNING'' '||CHR(38)||' ACTIVITIES prce_id=30 and acti_id=10',
        pati_id_in          => l_pati_id_accountant,
        count_flag          => 0,                    -- should rowcount be returned?
        pquery_handle       => l_worklist_cursor,
        pcount              => l_dummy_int
    );
    -- get the workitem
    FETCH l_worklist_cursor INTO l_worklist_record;
    CLOSE l_worklist_cursor;

    -- Now, tell PL/FLOW that MILLER starts with this workitem
    PL_FLOW.ChangeActivityInstanceState(
        acin_id_in  => l_worklist_record.acin_id,
        state_in    => 'RUNNING',
		pati_id_in  => l_pati_id_accountant
    );

    -- Determine whether parent process should LOOP?
    -- change of 9 in 10.
    



    -- Now, complete the same workitem
/**    PL_FLOW.ChangeActivityInstanceState(
        acin_id_in  => l_worklist_record.acin_id,
        state_in    => 'COMPLETED',
		pati_id_in  => l_pati_id_accountant
    );
**/
END;
/
Prompt Activity instances:
SELECT acti_prce_id, acti_id, prin_id, id, state, date_created, date_started, date_ended FROM WF_ACTIVITY_INSTANCES
/



--ROLLBACK
COMMIT
/
SPOOL OFF

QUIT
/
