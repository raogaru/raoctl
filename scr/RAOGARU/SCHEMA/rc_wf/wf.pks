CREATE OR REPLACE PACKAGE pl_flow IS
defsmtphost         CONSTANT    VARCHAR(100)    DEFAULT '&1';   -- default smtp host
defdomain           CONSTANT    VARCHAR(100)    DEFAULT '&2';   -- default domain for identification to smtp host
def_sender_email    CONSTANT    VARCHAR(100)    DEFAULT '&3';   -- default sender email address
mail_errors_to      CONSTANT    VARCHAR(100)    DEFAULT '&4';   -- email address to mail workflow runtime errors to

-- For parameter passing of the cursor result of WMOpenWorkflow
TYPE generic_curtype IS REF CURSOR;

-- To contain OUT parameters of tools
TYPE varchar_table_type IS TABLE OF wf_attribute_instances.value%TYPE;
out_parm_tab varchar_table_type     := varchar_table_type();   -- to contain outparms of called procedures. Needs to be in PKS

-- Used by the find_ancestor_activities recursive function.
TYPE acti_type IS RECORD (
    prce_id     wf_activities.prce_id%TYPE
,   acti_id     wf_activities.id%TYPE
);
TYPE acti_table_type IS TABLE OF acti_type INDEX BY BINARY_INTEGER;

/*--------------------------------------------------------------------------
 * This cursor is ONLY for use in PL/SQL program's that call WMOpenWorklist.
 * The output of WMOpenWorklist is a reference cursor with the same %ROWTYPE.
 *--------------------------------------------------------------------------*/
CURSOR worklist_rowtype IS
     SELECT i.prin_id
          , i.id      AS acin_id
          , i.acti_id
          , i.acti_prce_id
          , i.state                    
          , TO_CHAR( i.date_created, 'DD-MM-RR HH24:MI' ) AS date_created
          , i.date_started
          , i.date_due
          , i.worklist_display             --this should be used for display, not the activity name. I you need the activity name, you need to make a display query that puts that name in here.
          , b.name   AS perf_by_name
          , b.id     AS perf_by_id
          , f.pefo_id
          , f.accepted
          , p.pati_id AS responsible_id
          , pati_resp.name AS responsible_name
       FROM wf_process_instances   p
          , wf_activity_instances  i
          , wf_performers          f
          , wf_participants        b  -- performing participant
          , (SELECT acin_id, pati_id 
               FROM wf_performers 
              WHERE state     = 'ASSIGNED'
                AND   (accepted IS NULL OR accepted != 'N')  --check for null moet, want die valt niet onder != N
            ) f_assigned              -- assigned_participant/perfomer (assume 0..1 assigned performer with accepted <> N
          , wf_participants pati_resp -- responsible person participant
          ;

PROCEDURE set_logging ( logging_in    IN  BOOLEAN) ;

PROCEDURE set_archive ( archive_in    IN  BOOLEAN) ;

-- if another procedure rolls back information, log lines will be rollbacked too!
PROCEDURE log( what_in wf_debug_log.what%TYPE) ;

-- Returns True when there exists a participant with ID pati_id_in and type type_in, else return False
FUNCTION participant_is_type( pati_id_in IN wf_participants.id%TYPE, type_in IN wf_participants.participant_type%TYPE) RETURN BOOLEAN;
   
-- Returns: True    , when there exists a participant with ID pati_id_in and type 'HUMAN'
FUNCTION participant_is_human( pati_id_in IN  wf_participants.id%TYPE) RETURN BOOLEAN;

/*
 * WMConnect
 * Not necessary.
 *	WMTErrRetType WMConnect (
 *	in WMTPConnectInfo pconnect_info,
 *	out WMTPSessionHandle psession_handle)
 * WMDisconnect
 */

/*
||==========================================================================
|| PROCEDURE: WMOpenWorkList - Specifies and opens the query to produce the worklist
||                             that matches the criterion of the filter.
|| DESCRIPTION
|| This command provides the capability of returning a list of work items assigned to a
|| specified workflow participant or a workgroup. The requester may be making the request
|| on behalf of himself or may be a manager wanting to know what work has been assigned to
|| a particular person or a workgroup.
|| A query handle will be returned for the list of work items that match the specified value
|| for the attribute. The command will also return, optionally, the total count of work items
|| available. If the count is requested and the implementation does not support it, the command
|| will return a pcount value of -1. If pworklist_filter is NULL, then the function, with the
|| corresponding fetch calls will return the list of ALL accessible work items.
||
|| WMTErrRetType WMOpenWorkList (
||  in WMTPSessionHandle psession_handle,
||  in WMTPFilter        pworklist_filter,
||  in WMTBoolean        count_flag,
||  out WMTPQueryHandle  pquery_handle,
||  out WMTPInt32        pcount)
||
||  Argument Name      Description
||  psession_handle    Pointer to a structure containing information about the context for this action.
||  pworklist_filter   Pointer to a structure containing the filter information for this request.
||  count_flag         Boolean flag that indicates if the total count of work items should be returned.
||  pquery_handle      Pointer to a structure containing a unique query information returned by this function.
||  pcount             Total number of work items that fulfill the filter condition.
||
||  ERROR RETURN VALUE
||  WM_SUCCESS
||  WM_INVALID_SESSION_HANDLE
||  WM_INVALID_FILTER
||
||==========================================================================
|| Implementation details:
|| - Session is implicit (oracle session).
|| - WMTPQueryHandle is a reference cursor
||==========================================================================
*/
PROCEDURE OpenWorkList(
-- WFMC interface 2, section 8.2.4:
-- Filter is a structure that containts: filter_type, length, attribute_name, comparison, filter_string.
-- this is much the same as attribute value comparison. (see condition cursor)
-- in this implementation, the filter parameter string (VARCHAR) should be passed as a piece of SQL.
-- (keep it simple)
-- The syntax is: CONSTRAINT [CHR(38) CONSTRAINT]
-- where 
-- CONSTRAINT = STATE_CONSTRAINT | ACTIVITY_CONSTRAINT
-- STATE_CONSTRAINT = STATE=''<state>''
-- ACTIVITY_CONSTRAINT = ACTIVITIES ACTIVITY_CONSTRAINT_PART [and ACTIVITY_CONSTRAINT_PART]
-- ACTIVITY_CONSTRAINT_PART = prce_id=<nr> | acti_id=<nr>
-- e.g. 'STATE=''NOTRUNNING'' '||CHR(38)||' ACTIVITIES prce_id=10 and acti_id=70'
    pworklist_filter IN  VARCHAR2,
    pati_id_in       IN  wf_participants.id%TYPE,   -- not standard... used instead of pworklist_filter
    count_flag       IN  INTEGER,
    pquery_handle    OUT generic_curtype,       -- reference cursor
    pcount           OUT INTEGER,
    sort_by          IN  VARCHAR2 DEFAULT 'date_created',
    sort_order       IN  VARCHAR2 DEFAULT 'ASC'
);


/*
||==========================================================================
|| WMCreateProcessInstance - Create an instance of a previously defined process.
||
|| DESCRIPTION
||
|| An operational instance of the named process definition will be created by a WFM Engine as the result of
|| this command. A call to WMStartProcess would then start the process.
|| To assign attributes to the process instance, you will make multiple calls to
|| WMAssignProcessInstanceAttribute.
|| The process instance ID returned by this call is valid and reliable until WMStartProcess is called, at which
|| time it may be reassigned to a new value.
||
|| WMTErrRetType WMCreateProcessInstance (
|| 		in WMTPSessionHandle psession_handle,
|| 		in WMTPProcDefID pproc_def_id,
|| 		in WMTPText pproc_inst_name,
|| 		out WMTPProcInstID pproc_inst_id)
||
|| Exceptions:	invalid_process_definition
||==========================================================================
*/
PROCEDURE CreateProcessInstance (
	prce_id_in IN wf_processes.id%TYPE,
	prin_id_in IN wf_process_instances.id%TYPE
);

/*
||==========================================================================
|| WMStartProcess - Start the named process.
||
|| DESCRIPTION
||
|| The WMStartProcess command directs the WFM Engine to begin executing a process, for which an
|| instance has been created. When a process is started through this command, the first activity(s) of the
|| process will be started. The process instance ID returned by this call will be valid for the life of the process
|| instance.
||
|| WMTErrRetType WMStartProcess (
|| 		in WMTPSessionHandle psession_handle,
|| 		in WMTPProcInstID pproc_inst_id,
|| 		out WMTPProcInstID pnew_proc_inst_id)
||
|| Exceptions:	invalid_process_instance
||		invalid participant
||==========================================================================
*/
PROCEDURE StartProcess
	( prin_id_in IN wf_process_instances.id%TYPE,
	pati_id_in IN wf_participants.id%TYPE );		-- responsible (human) participant;

/*
||==========================================================================
|| WMTerminateProcessInstance - Terminate a process instance.
||
|| DESCRIPTION
||
|| This command provides the capability of gracefully terminating a process without aborting the process
|| instance. Return from this call does not imply that the process instance has terminated, for example, the
|| process instance could be stopped when currently running activities are complete. The exact behavior of
|| currently running activities is system dependent.
||
|| WMTErrRetType WMTerminateProcessInstance (
|| in WMTPSessionHandle psession_handle,
|| in WMTPProcInstID pproc_inst_id)
||
|| Implementation: raise 'terminated' flag so at the next complete workitem,
|| the process instance will be marked as finished (date_ended).
||
|| Exceptions:	invalid_process_instance
||==========================================================================
*/
-- PROCEDURE TerminateProcessInstance
--	( prin_id_in IN wf_process_instances.id%TYPE );

/*
||==========================================================================
|| WMChangeProcessInstanceState - Changes the state of the named process instance.
||
|| DESCRIPTION
||
|| This command is defined to allow a process instance to be changed temporarily to a specific state such as
|| suspended.
|| Execution of this command will cause the single process instance that is named to be transitioned to a new
|| state. In this case, the meaning of all states is dependent upon the particular WFM Engine implementation.
|| This command will set the state attribute of the process instance to a state such as suspended or running.
||
|| States are: notstarted, running, suspended, completed, terminated, aborted
||
|| WMTErrRetType WMChangeProcessInstanceState (
|| 		in WMTPSessionHandle psession_handle,
|| 		in WMTPProcInstID pproc_inst_id,
|| 		in WMTPProcInstState pproc_inst_state)
||
|| Exceptions:	invalid_process_instance
||		invalid_state
||		state_transition_not_allowed
||==========================================================================
*/
PROCEDURE ChangeProcessInstanceState
	( prin_id_in IN wf_process_instances.id%TYPE,
	  state_in IN wf_process_instances.state%TYPE );

/*
||==========================================================================
|| WMAssignProcessInstanceAttribute - Assign the proper attribute to process instance(s)
||
|| DESCRIPTION
||
|| This command tells the WFM Engine to assign an attribute, change an attribute or to change the value of an
|| attribute of a process instance.
||
|| This command changes the value of an attribute of a process instance. Attributes of process instances are
|| of the kind called Process Control and Process Relevant Data. These attributes are specified as
|| quadruplets of name, type, length and value.
||
|| WMTErrRetType WMAssignProcessInstanceAttribute (
|| 		in WMTPSessionHandle psession_handle,
|| 		in WMTPProcInstID pproc_inst_id,
|| 		in WMTPAttrName pattribute_name,
|| 		in WMTInt32 attribute_type,
|| 		in WMTInt32 attribute_length,
|| 		in WMTPText pattribute_value)
||
|| exceptions:	invalid_process_instance
|| 		invalid_attribute
||		attribute_assignment_failed
||
|| Implementation: why the default value in the process definition, when
|| creation is done during assignment?
||==========================================================================
*/
PROCEDURE AssignProcessInstanceAttribute
	( prin_id_in IN wf_process_instances.id%TYPE,
	name_in IN wf_attributes.name%TYPE,
	value_in IN wf_attribute_instances.value%TYPE );


/*
||==========================================================================
|| WMAssignActivityInstanceAttribute - Assign an attribute to an activity instance.
||
|| DESCRIPTION
||
|| This command tells the WFM Engine to assign an attribute, to change an attribute or to change the value of
|| an attribute of the activity instance within a named process definition.
|| This command changes the value of the attributes of a activity instance. These attributes of activity
|| instances are of the kind called Process Control and Process Relevant Data. These attributes are specified
|| as quadruplets of name, type, length and value.
|| WMTErrRetType WMAssignActivityInstanceAttribute (
|| 		in WMTPSessionHandle psession_handle,
|| 		in WMTPProcDefID pproc_def_id,
|| 		in WMTPActivityInstID pactivity_inst_id,
|| 		in WMTPAttrName pattribute_name,
|| 		in WMTInt32 attribute_type,
|| 		in WMTInt32 attribute_length,
|| 		in WMTPText pattribute_value)
||
|| exceptions:	invalid_process_instance
||		invalid_activity_instance
|| 		invalid_attribute
||		attribute_assignment_failed
||
|| Implementation: why the default value in the process definition, when
|| creation is done during assignment?
|| Answer: maybe create attributes with a default value on process / activity creation?
||==========================================================================
*/
PROCEDURE AssignActi_InstanceAttribute
	( acin_id_in IN wf_activity_instances.id%TYPE,
	name_in IN wf_activity_attributes.name%TYPE,
	value_in IN wf_acti_attribute_instances.value%TYPE );


/*
||==========================================================================
|| WMChangeActivityInstanceState - Changes the state of the named activity instance.
||
|| DESCRIPTION
||
|| This command directs a WFM Engine to change the state of a single activity instance within a process
|| instance. This allows the state of one activity instance to be changed, without impacting others in the
|| process instance.
|| For example, this command will be used to change the state of an activity instance to suspended. This
|| command can be used afterwards to change the state of the activity instance back to running. The
|| implementation documentation will provide the names and semantics of the supported activity states for a
|| particular implementation.
||
|| States are: notstarted, running, suspended, completed, terminated, aborted
||
|| WMTErrRetType WMChangeActivityInstanceState (
|| 		in WMTPSessionHandle psession_handle,
|| 		in WMTPProcInstID pproc_inst_id,
|| 		in WMTPActivityInstID pactivity_inst_id,
|| 		in WMTPActivityInstState pactivity_inst_state)Changes the state of the named process instance.
||
|| Exceptions:	invalid_process_instance -- not in this implementation.
||		invalid_activity_instance
||		invalid_state
||		state_transition_not_allowed
||==========================================================================
*/
PROCEDURE ChangeActivityInstanceState
	(
--	  prin_id_in IN wf_activity_instances.prin_id%TYPE, -- process instance is not primary key in this implementation.
	  acin_id_in IN wf_activity_instances.id%TYPE,
	  state_in IN wf_activity_instances.state%TYPE,
	  pati_id_in IN wf_participants.id%TYPE );

/*
||==========================================================================
|| AddProcessInstanceRemarks - Adds a remark to an process instance.
||
|| DESCRIPTION
||
|| This command is not wfmc standard. It adds a remark to the process instance.
||
|| Exceptions:	invalid_process_instance
||==========================================================================
*/
PROCEDURE AddProcessInstanceRemarks
	( prin_id_in IN wf_process_instances.id%TYPE,
	  remarks_in IN wf_process_instances.remarks%TYPE );

/*
||==========================================================================
|| AddActivityInstanceRemarks - Adds a remark to an activity instance.
||
|| DESCRIPTION
||
|| This command is not wfmc standard. It adds a remark to the activity instance.
||
|| Exceptions:	invalid_activity_instance
||==========================================================================
*/
PROCEDURE AddActivityInstanceRemarks
	( acin_id_in IN wf_activity_instances.id%TYPE,
	  remarks_in IN wf_activity_instances.remarks%TYPE );

/*
||==========================================================================
|| delegate_activity_instance - Delegate an activity instance to a new participant.
||
|| DESCRIPTION
||
|| This command delegates performing an activity to another participant.
|| Delegation is currently not supported by the WFMC.
|| The target participant has the option not to accept the delegation. In that case
|| the previous participant will still be responsible.
||
|| Exceptions:
||		invalid_activity_instance
||		invalid participant
||==========================================================================
*/
PROCEDURE delegate_activity_instance
	(
	  acin_id_in IN wf_activity_instances.id%TYPE,
	  pati_id_to_in IN wf_participants.id%TYPE,             -- the target participant
	  remarks_in IN wf_performers.remarks%TYPE                 -- remark to the target
);

/*
||==========================================================================
|| save_session_state -
||
|| DESCRIPTION
||==========================================================================
*/
PROCEDURE save_session_state(
      acin_id_in       IN   wf_activity_instances.id%TYPE,
      session_state_out OUT  wf_activity_instances.session_state%TYPE
);


/*
||==========================================================================
|| Internal procedure (but published because it could have been a dbms_job):
|| Retained in specs for pending jobs.
||
|| Should only be called by the workflow engine.
||==========================================================================
*/
PROCEDURE instantiate_activity_instance
(   prin_id_in           IN wf_process_instances.id%TYPE    -- on which process instance
,   prce_id_in           IN wf_processes.id%TYPE            -- activity primary key process part
,   acti_id_in           IN wf_activities.id%TYPE           -- activity primary key activity part
,   perf_pati_id_in      IN wf_participants.id%TYPE         -- (human) participant that will become current perfomer, null otherwise
,   apli_id_in           IN wf_applications.id%TYPE         -- application id
,   plsql_proc_name_in   IN wf_applications.plsql_proc_name%TYPE       -- if not null, call plsql_proc_name
,   deli_id_in           IN wf_deadlines.id%TYPE            -- id of the optional deadline that is applicable to this activity instance
,   days_due_in          IN wf_activities.limit%TYPE        -- number of days after which the workitem is due. Type is 'DURATION UNIT' domain in ORA designer.
,   prce_id_subflow_in   IN wf_processes.id%TYPE            -- if not null, the subprocess id.
,   subflow_execution_in IN wf_activities.subflow_execution%TYPE-- synchronous or asynchronous
,   implementation_in    IN wf_activities.implementation%TYPE   -- subflow / tool / no?
,   start_mode_in        IN wf_activities.start_mode%TYPE       -- manual or automatic?
,   finish_mode_in       IN wf_activities.finish_mode%TYPE      -- manual or automatic?
,   assi_pati_id_in      IN wf_participants.id%TYPE                    DEFAULT NULL -- participant that will become assigned to the activity_instance
,   date_created_in      IN wf_activity_instances.date_created%TYPE    DEFAULT SYSDATE --if manual activity, then you can set this to a future date, and the workitem will appear on the worklist only after that date.
,   acin_id_in           IN wf_activity_instances.id%TYPE              DEFAULT NULL
,   pati_id_in           IN wf_activity_instances.pati_id%TYPE         DEFAULT 0 --for backwards compatibility with submitted jobs
,   pati_id_exclude_in   IN wf_activity_instances.pati_id_exclude%TYPE DEFAULT NULL
);

/*
||==========================================================================
|| check_deadlines
||
|| Depending on the DEADLINE.EXECUTION type (synchronous or asynchronous) 
|| the activity instance is terminated or not. On arrival of a deadline, an
|| exception (not PL/SQL exception) is raised, which can be the condition for
|| a transition (with transition type 'exception'.
||==========================================================================
*/
PROCEDURE check_deadlines;

/*
||==========================================================================
|| grant_role - Grant a participant a role
||
|| DESCRIPTION
||              pati_id_in  the HUMAN, SYSTEM, OU or ROLE that is granted the..
||              role_name_in        the name of the ROLE that is granted.
||
|| Exceptions:
||==========================================================================
*/
PROCEDURE grant_role(
      pati_id_in    IN  wf_participants.id%TYPE,
      role_name_in  IN  wf_participants.name%TYPE
);

/*
||==========================================================================
|| revoke_role - Revoke a previously granted role (overloaded)
||
|| DESCRIPTION
||              pati_id_in  the HUMAN, SYSTEM, OU or ROLE who is revoked the..
||              role_name_in        the name of the ROLE that is granted.
||
|| Exceptions:
||==========================================================================
*/
PROCEDURE revoke_role(
      pati_id_in    IN  wf_participants.id%TYPE,
      role_name_in  IN  wf_participants.name%TYPE
);

/*
||==========================================================================
|| revoke_role - Revoke a previously granted role (overloaded)
||
|| DESCRIPTION
||              pati_id_in          the HUMAN, SYSTEM, OU or ROLE who is revoked the..
||              role_pati_id_in     the participant id of the ROLE that is to be revoked.
||
|| Exceptions:
||==========================================================================
*/
PROCEDURE revoke_role(
      pati_id_in        IN  wf_participants.id%TYPE,
      role_pati_id_in   IN  wf_participants.id%TYPE
);


/*
||==========================================================================
|| add_proxy - Add a proxy participant to a participant (overloaded)
||
|| DESCRIPTION
||              human_pati_id_in      the HUMAN participant that will be proxied
||              proxy_pati_id_in      the HUMAN or ROLE participant that is the proxy
||
|| Exceptions:
||==========================================================================
*/
PROCEDURE add_proxy(
      human_pati_id_in  IN  wf_participants.id%TYPE,
      proxy_pati_id_in  IN  wf_participants.id%TYPE
);

/*
||==========================================================================
|| add_proxy - Add a proxy participant to a participant  (overloaded)
||
||       Pre: proxy_role_name_in    the name of the ROLE participant that is the proxy
||            human_pati_id_in      the HUMAN participant that will be proxied
||
||      Post: add_proxy( id, human_pati_id_in ) is called where id
||            is the participant id of the ROLE with name proxy_role_name_in
||      
|| Exceptions:
||            NO_DATA_FOUND when there is no role with name proxy_role_name_in
||            Application error when type of human_pati_id_in <> 'HUMAN'
||==========================================================================
*/
PROCEDURE add_proxy(
      proxy_role_name_in    IN  wf_participants.name%TYPE,
      human_pati_id_in      IN  wf_participants.id%TYPE
);

/*
||==========================================================================
|| remove_proxy - Remove a proxy from a participant (overloaded)
||
||         Pre: proxy_pati_id_in      the proxy to be removed from the HUMAN.
||              human_pati_id_in      the HUMAN participant with a proxy
||
||        Post: The pair <proxy_pati_id_in,human_pati_id_in> is not in the
||              the relation 'PROXY OF'.
||
|| DESCRIPTION
||
|| Exceptions:
||==========================================================================
*/
PROCEDURE remove_proxy(
      proxy_pati_id_in  IN  wf_participants.id%TYPE,
      human_pati_id_in  IN  wf_participants.id%TYPE
);

/*
||==========================================================================
|| remove_proxy - Remove a proxy from a participant (overloaded)
||
||        Pre: human_pati_id_in is the id of a HUMAN participant (with a proxy)
||             proxy_role_name_in is the name of a proxy role to be removed
||       Post: remove_proxy( id, human_pati_id_in ) is called where id
||             is the participant id of the ROLE with name proxy_role_name_in
||
|| DESCRIPTION
||
|| Exceptions:
||==========================================================================
*/
PROCEDURE remove_proxy(
      proxy_role_name_in  IN  wf_participants.name%TYPE,
      human_pati_id_in  IN  wf_participants.id%TYPE
);
/*
||==========================================================================
|| Send a mail (useful for automatic activites)
||
|| send_mail
||
|| DESCRIPTION
||
|| The code is copied from the example from the UTL_SMTP documentation.
||
|| Usage: e.g. send_mail( smtp_server_in        => 'smtp.foo.com',
||                        domain_in             => 'foo.com',
||                        sender_name_in        => 'Mr S. Ender',
||                        sender_email_in       => 'sender@foo.com',
||                        recipient_name_in     => 'Mr R. Ecipient',
||                        recipient_in          => 'recipient@foo.com',
||                        subject_in            => 'This is the subject',
||                        body_in               => 'This is the message body'
||                      );
||==========================================================================
*/
PROCEDURE send_mail(
    smtp_server_in      IN  VARCHAR2    DEFAULT defsmtphost,    -- max   64
    domain_in           IN  VARCHAR2    DEFAULT defdomain,      -- max   64
    sender_name_in      IN  VARCHAR2,                           -- max   64
    sender_email_in     IN  VARCHAR2,                           -- max   64
    recipient_name_in   IN  VARCHAR2,                           -- max   64
    recipient_email_in  IN  VARCHAR2,                           -- max   64
    subject_in          IN  VARCHAR2,                           -- max  256 ?
    body_in             IN  VARCHAR2                            -- max 1000 ?
);

/*
||==========================================================================
|| FUNCTION: has_roles
|| 
||      Pre: pati_id_in is the ID of a participant
||
||  Returns: a list of role id's granted to this participant.
||==========================================================================
*/
FUNCTION has_roles( 
    pati_id_in           IN  wf_participants.id%TYPE
,   call_history_in     IN  VARCHAR2    DEFAULT ''                -- to detect loops in PROXY OF, string of '(pati_id)(pati_id) etc'
)
RETURN int_table_type;
/*
||==========================================================================
|| FUNCTION: is_proxy_of
|| 
||      Pre: proxy_pati_id_in is the ID of a participant
||           human_pati_id_in is the ID of a human
||
||  Returns: 1, if the proxy is a proxy of te human
||           0, otherwise
||==========================================================================
*/
FUNCTION is_proxy_of( 
    proxy_pati_id_in    IN wf_participants.id%TYPE
,   human_pati_id_in    IN wf_participants.id%TYPE
,   call_history_in     IN  VARCHAR2    DEFAULT ''                -- to detect loops in PROXY OF, string of '(pati_id)(pati_id) etc'
)
RETURN INTEGER;

/*
||==========================================================================
||assign_workitem - Assigns a participant (any type) to a workitem.
||
|| DESCRIPTION when a specific participant is assigned to a workitem, the
||             workitem will not appear on the worklist of other participants
||             (unless they have that role / ou assigned to them.)
||             There can be three active assignments: a ROLE assignment, an OU 
||             assignment and a HUMAN assignment.
||             For each assignment: If the workitem was already assigned, 
||             the current assignment is
||             rejected and the new assignment is linked to the current one,
||             so that when the new assignment is rejected, the current 
||             assignment can be restored. Also the order of assignments is 
||             preserved in this way.
||             User has to make sure that the different types of assignment are 
||             compatible, i.e. that e.g. the assigned human also has the 
||             assigned role (otherwise the workitem does not appear on any
||             worklist
||
|| Exceptions:
||==========================================================================
*/
PROCEDURE assign_workitem
(   pati_id_in     IN  wf_participants.id%TYPE
,   acin_id_in     IN  wf_activity_instances.id%TYPE
,   remarks_in     IN  wf_performers.remarks%TYPE
);

/*
||==========================================================================
||reject_workitem - Rejects assignment / delegation of participant to workitem
||
|| DESCRIPTION when a specific participant is assigned to a workitem and he
||             rejects it, the workitem will appear again on the worklist of
||             other participants, as if it was not assigned or delegated
|| PRE: the performer record exists for the activity instance, with
||      undefined accepted state
|| POST: that record has accepted='N' and delegated performer or previous 
||       assigned participant becomes current perfomer.
|| Exceptions:
||==========================================================================
*/
PROCEDURE reject_workitem
(   acin_id_in     IN  wf_activity_instances.id%TYPE
,   pati_id_in     IN  wf_participants.id%TYPE
,   remarks_in     IN  wf_performers.remarks%TYPE
);

END pl_flow;
/

show errors
