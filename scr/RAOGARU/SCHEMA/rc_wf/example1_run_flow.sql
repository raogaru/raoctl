-- SQL script to run the example process definition
-- Assumed to run in SCOTT's schema or in a schema that can read SCOTT's tables
-- 2003 11 27 Yeb Havinga

SPOOL example1_run_flow.lst

----------------------------------------------------------------------------
-- Step 1:
-- Scott creates a process instance and files a bonus request.
----------------------------------------------------------------------------
DECLARE
    l_prin_id           WF_PROCESS_INSTANCES.ID%TYPE;        -- ID of new created process instance
    l_pati_id_manager   WF_PARTICIPANTS.ID%TYPE;             -- ID of participant 'SCOTT'
    l_acin_id           WF_ACTIVITY_INSTANCES.ID%TYPE;       -- ID of new created activity instance
    
BEGIN
    -- create the process.
    -- 1 get a new sequence number
    SELECT prin_seq.NEXTVAL
      INTO l_prin_id
      FROM DUAL;    
    -- 2 create the process
    PL_FLOW.CreateProcessInstance(
        prce_id_in=>10,             -- 10 is process id of file bonus request process
        prin_id_in=>l_prin_id
    );

    -- Scott is the emp wanting a bonus
    SELECT id 
      INTO l_pati_id_manager
      FROM wf_participants
     WHERE name='SCOTT';    

    -- The attribute is named 'EMPNO'
    -- scotts EMPNO is 7788
    -- note that because the attribute instances values are not constrained
    -- in anyway to actually contain an existing EMPNO in the SCOTT.EMP table.
    PL_FLOW.AssignProcessInstanceAttribute(
        prin_id_in  =>l_prin_id,
        name_in     =>'EMPNO',
		value_in    =>l_pati_id_manager
    );

    -- Start the process instance
    -- The process is started by the participant 'SCOTT'
    
    PL_FLOW.StartProcess(
        prin_id_in  => l_prin_id,        -- the previously created process instance
        pati_id_in  => l_pati_id_manager
    );

    -- At this point, there is a workitem in this process
    -- that represents the 'File request to manager' workitem
    -- Every EMP may process it, but SCOTT is the one to start it.
    -- First, find the ID of this newly created activity instance
    SELECT id
      INTO l_acin_id
      FROM wf_activity_instances
     WHERE prin_id = l_prin_id       -- only from this process instance
       AND acti_id = 10;             -- and only activity 10. (file bonus request)
       
    -- Now, tell PL/FLOW that SCOTT starts with this workitem
    PL_FLOW.ChangeActivityInstanceState(
        acin_id_in  => l_acin_id,
        state_in    => 'RUNNING',
		pati_id_in  => l_pati_id_manager   -- pati id of SCOTT
    );

    -- Now, complete the same workitem
    PL_FLOW.ChangeActivityInstanceState(
        acin_id_in  => l_acin_id,
        state_in    => 'COMPLETED',
		pati_id_in  => l_pati_id_manager   -- pati id of SCOTT
    );
END;
/
Prompt Activity instances after SCOTT completed 'file bonus request'
SELECT acti_prce_id, acti_id, prin_id, id, state, date_created, date_started, date_ended FROM WF_ACTIVITY_INSTANCES
/

----------------------------------------------------------------------------
-- Step 2:
-- The manager 'JONES' 
-- Now fetch the worklist of the manager jones.
----------------------------------------------------------------------------
DECLARE
    l_prin_id           WF_PROCESS_INSTANCES.ID%TYPE;        -- ID of new created process instance
    l_pati_id_manager   WF_PARTICIPANTS.ID%TYPE;             -- ID of participant 'JONES'
    l_acin_id           WF_ACTIVITY_INSTANCES.ID%TYPE;       -- ID of new created process instance

    l_worklist_cursor   PL_FLOW.generic_curtype;             -- a cursor variable
    l_worklist_record   PL_FLOW.worklist_rowtype%ROWTYPE;    -- PL_FLOW.worklist_rowtype is dummy cursor for %ROWTYPE 

    l_dummy_int        PLS_INTEGER;
 
    
BEGIN
    -- At this point, there is a workitem on the worklist of the managers
    -- The manager is JONES, with pati_id 7566
    SELECT id 
      INTO l_pati_id_manager
      FROM wf_participants
     WHERE name='JONES';    

    PL_FLOW.OpenWorkList( 
--        pworklist_filter    => 'STATE=''NOTRUNNING''',
        pworklist_filter    => 'a.atri_id=10 AND a.value=TO_CHAR(7788)',  -- ID of Scott.
        pati_id_in          => l_pati_id_manager,    -- this is the ID of jones
        count_flag          => 0,                    -- should rowcount be returned?
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
        count_flag          => 0,                    -- should rowcount be returned?
        pquery_handle       => l_worklist_cursor,
        pcount              => l_dummy_int
    );
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
    PL_FLOW.ChangeActivityInstanceState(
        acin_id_in  => l_worklist_record.acin_id,
        state_in    => 'RUNNING',
		pati_id_in  => l_pati_id_scott
    );

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

Prompt Activity instances after SCOTT completed 'read bonus request denial AND file bonus request to president'
SELECT acti_prce_id, acti_id, prin_id, id, state, date_created, date_started, date_ended FROM WF_ACTIVITY_INSTANCES
/

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
----------------------------------------------------------------------------
-- Step 5b:
-- The accountant MILLER (id 7934) handles the paycheck
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
        pworklist_filter    => 'STATE=''NOTRUNNING'' '||CHR(38)||' ACTIVITIES prce_id=10 and acti_id=70',
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

    -- Here would be code like changing amount on next paycheck.

    -- Now, complete the same workitem
    PL_FLOW.ChangeActivityInstanceState(
        acin_id_in  => l_worklist_record.acin_id,
        state_in    => 'COMPLETED',
		pati_id_in  => l_pati_id_accountant
    );
END;
/
Prompt The process is now completed.

COMMIT
/
SPOOL OFF

--ROLLBACK
--/
QUIT
/
