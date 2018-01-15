CREATE OR REPLACE PACKAGE BODY pl_flow
IS
/*
||==========================================================================
|| PACKAGE BODY: PL_FLOW

|| Naming conventions:
|| IN parameters    '<name>_in'
|| OUT parameters   '<name>_out'
|| Cursors      '<name>_cursor'
|| Records      '<name>_record'
|| All other variables (always internal to procedure) without in, out, record or cursors.
|| Internal procs: all lowercase, separated by _
|| External procs: like WFMC standard, or like internal procs when not in WFMC standard
|| All pl_flow tables: start with wf_
|| Table shorthand notations (foreign keys etc): First two letters of each syllable.
||==========================================================================
*/

-- DECLARE autocommit BOOLEAN true;

-- On change of an workitem to 'COMPLETED', and no other workitems in the process instance:
-- If there are transitions, but no condition is met, complete the process?
-- If true: yes, of false, give a warning when this occurs. (it might be an application error)

logging         BOOLEAN DEFAULT true;  -- set to true with set_logging to log info in WF_DEBUG_LOG
archive         BOOLEAN DEFAULT false; -- set to true enables move_to_archive
previous_log_call_time  NUMBER(15,6);  -- to store the previous select TO_NUMBER(TO_CHAR(systimestamp,'SSSSSFF'))/1000000 from dual in

no_conditions_complete_process  BOOLEAN                 DEFAULT TRUE;

max_worklist_size               PLS_INTEGER             DEFAULT 10000;    -- used by WMOpenWorklist

pl_flow_participant             wf_participants.id%TYPE := 1;           -- installed by plflowsystemdata.sql.

l_sql           VARCHAR2(30000);                                    -- string to contain any sql statement

/*
||==========================================================================
|| PRODEDURE: set_logging
||
||       Pre: logging_in = true or false
||
||      Post: if logging_in is true, pl_flow.log calls in the current session
||                                   write lines to WF_DEBUG_LOG
||                            false, the above does not happen
||
||==========================================================================
*/
PROCEDURE set_logging (logging_in IN BOOLEAN) IS
BEGIN
    pl_flow.logging := logging_in;
END set_logging;

/*
||==========================================================================
|| PRODEDURE: set_archive
||
||       Pre: archive_in = true or false
||
||      Post: if archive_in is true, move_to_archive moves finished process
||                                   instances to the archive.
||                            false, the above does not happen
||
|| The only reason to disable moving to archive, is to be able to debug completed
|| process instances.
||
||==========================================================================
*/
PROCEDURE set_archive ( archive_in    IN  BOOLEAN) IS
BEGIN
    pl_flow.archive := archive_in;
END set_archive;


/*
||==========================================================================
|| PRODEDURE: log
||
||       Pre: what_in is a string containing line to be logged
||            logging is a boolean package variable
||
||      Post: WF_DEBUG_LOG = WF_DEBUG_LOG +
||               <delo_seq.NEXTVAL, SYSDATE, what_in>
||                                              , if logging is true
||            nothing                           , otherwise
||
|| DESCRIPTION
||
|| For logging of debug information.
|| Please note: if another procedure rolls back information, log lines
|| will be rollbacked too!
||==========================================================================
*/
PROCEDURE log
(   what_in wf_debug_log.what%TYPE
)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_owner     VARCHAR2(30);
    l_name      VARCHAR2(30);
    l_lineno    PLS_INTEGER;
    l_type      VARCHAR2(30);

    l_debug     VARCHAR2(5000)   DEFAULT '';        -- dbms_utility.format_call_stack;
    l_what      VARCHAR2(4000);
    l_milli     CHAR(3);
    l_time      NUMBER(15,6);

    
    l_sizeb     PLS_INTEGER;
BEGIN
    IF logging THEN
         -- Figure out call stack when debugging
        who_called_me( l_owner, l_name, l_lineno, l_type );
        BEGIN
            SELECT TEXT
              INTO l_debug
              FROM  (select * from user_source
                    where name=l_name and type=l_type and line < l_lineno
                    and ( text like 'PROCEDURE%' OR text like 'FUNCTION%' )
                    order by line desc
                    )
              WHERE ROWNUM=1;
        EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            l_debug := '(?) ';
        END;
        SELECT TO_CHAR(systimestamp,'FF3') INTO l_milli FROM dual;
        SELECT TO_NUMBER(TO_CHAR(systimestamp,'SSSSSFF'))/1000000 INTO l_time FROM dual;
        
        l_debug := 'ms='||l_milli || ' ' || l_name || '#' || l_lineno || ' ' || l_debug || ':' || substrb(what_in, 1, 3800) 
                   || ' (elapsed: ' || TO_CHAR(l_time - NVL(pl_flow.previous_log_call_time,0)) || ')';

        /* Max size varchar2 in pl/sql: 32767 bytes; in oracle9: 4000 bytes */
        l_what := substrb(l_debug, 1, 4000);
        
        INSERT INTO wf_debug_log( id, when, what) VALUES ( delo_seq.NEXTVAL, SYSDATE, l_what);
        pl_flow.previous_log_call_time := l_time;
        COMMIT;

    END IF;
END log;

/*
||==========================================================================
|| FUNCTION: proxy_of
||
||      Pre: proxy_pati_id_in is the ID of a participant
||           human_pati_id_in is the ID of a human
||
||  Returns: 1, if the proxy is a proxy of te human
||           0, otherwise
||==========================================================================
*/
FUNCTION is_proxy_of
(   proxy_pati_id_in    IN wf_participants.id%TYPE
,   human_pati_id_in    IN wf_participants.id%TYPE
,   call_history_in     IN VARCHAR2    DEFAULT ''            -- to detect loops in PROXY OF, string of '(pati_id)(pati_id) etc'
)
RETURN INTEGER
IS
    /*--------------------------------------------------------------------------
     * Return all the participants this participant is a direct proxy of.
     *--------------------------------------------------------------------------*/
    CURSOR proxy_cursor(
        proxy_pati_id_in IN wf_participants.id%TYPE,
        human_pati_id_in IN wf_participants.id%TYPE
    )
    IS
      SELECT pati_id_arg2                      AS pati_id,
             DECODE( pati_id_arg2, human_pati_id_in, 1, 0) AS match     -- return matching PROXY OF first
        FROM wf_participant_relations r
       WHERE r.relation_type='PROXY OF'
         AND r.pati_id_arg1 = proxy_pati_id_in
	  ORDER BY match DESC;                                              -- return matching PROXY OF first

    proxy_record   proxy_cursor%ROWTYPE;

    l_return_code   INTEGER DEFAULT 0;

    new_call_history    VARCHAR2(10000);

BEGIN
    /*--------------------------------------------------------------------------
     * Update call history.
     *--------------------------------------------------------------------------*/
    new_call_history    := call_history_in || '('||proxy_pati_id_in||')';
    /*--------------------------------------------------------------------------
     * Read all the participants this participant is a direct proxy of
     *--------------------------------------------------------------------------*/
    FOR proxy_record IN proxy_cursor(  proxy_pati_id_in => proxy_pati_id_in
                                     , human_pati_id_in => human_pati_id_in )
    LOOP
        /*--------------------------------------------------------------------------
         * Loop through all the participants I am a direct proxy of as long as there is no match
         *--------------------------------------------------------------------------*/
        /*--------------------------------------------------------------------------
         * If there is a match, exit this loop and return 1
         *--------------------------------------------------------------------------*/
        IF proxy_record.match = 1
        THEN
            l_return_code := 1;         -- there is a match! :-) Now exit this function as fast as possible..
            EXIT;
        ELSE
            /*--------------------------------------------------------------------------
             * If this proxy isn't a loop then..
             *--------------------------------------------------------------------------*/
            IF NVL(INSTR( call_history_in, '('||proxy_record.pati_id||')' ),0) = 0
            THEN
                /*--------------------------------------------------------------------------
                 * I am a proxy for a participant if I am proxy for a proxy of a participant
                 *--------------------------------------------------------------------------*/
                l_return_code := is_proxy_of( proxy_record.pati_id, human_pati_id_in, new_call_history );
            END IF;
        END IF;
    END LOOP;
    /*--------------------------------------------------------------------------
     * Return my result..
     *--------------------------------------------------------------------------*/
    RETURN l_return_code;

END is_proxy_of;

/*
||==========================================================================
|| FUNCTION: has_roles
||
||      Pre: pati_id_in is the ID of a participant
||
||  Returns: a list of role id's granted to this participant.
||
|| DESCRIPTION
|| Every kind of participant (SYSTEM, HUMAN, TEAM and ROLE) can be
|| granted a role. A grant is a relation between participants and is stored
|| in the table WF_PARTICIPANT_RELATIONS.
|| The relation 'GRANT' is transitive (roles granted to roles)
|| and also transitive in it's first argument via the relations 'PROXY OF' and
|| 'MEMBER OF'.
||
|| Without the concept of PROXY OF, the list of roles can be fetched with
|| a hierarchical query (making GRANT transitive) that is fed the participant
|| id pati_id_in + the id's of the team the pati_id_in is member of.
|| Because the transitivity of PROXY OF and GRANT can be mixed, only one at
|| a time can be implemented with a hierarchical query. Moreover, PROXY OF
|| can contain cycles, and in Oracle < 10 there is no NOCYCLE.
|| So, has_role is called recursively with recursion on the proxy relationship.
||
|| See Also: grant_role and revoke_role
||
|| int_table_type is nested table and not index-by-table, so it is usable
|| from SQL (see table 19.2 comparing oracle collection types in the PL/SQL book).
||
|| If you want to debug this function using the LOG procedure and WF_DEBUG_LOG
|| table, uncomment the log lines. The only way to call this function with logging
|| is in a PL/SQL block; it cannot be called by SQL anymore. In effect this means
|| that the worklist will give errors when a proxy relation ship exists.
||   declare    output int_table_type;
||   begin      output := pl_flow.has_roles( 7499 ); end;
||==========================================================================
*/
FUNCTION has_roles
(   pati_id_in           IN  wf_participants.id%TYPE
,   call_history_in      IN  VARCHAR2       DEFAULT ''  -- to detect loops in PROXY OF, string of '(pati_id)(pati_id) etc'
)
RETURN int_table_type
IS
    /*------------------------------------------------------------------------
     * Return the transitive closure of
     * { x | grant(pati_id_in,x) or (grant(org,x) and memberof(x,org)) }
     * = all the roles granted directly or indirectly to this participant
     *   or to an organisation it is member of.
     *------------------------------------------------------------------------*/
    CURSOR grant_cursor(
        pati_id_in IN wf_participants.id%TYPE
    )
    IS
        SELECT DISTINCT pati_id_arg2 AS pati_id     -- arg 2 is pati_id of role
        FROM  wf_participant_relations r
        WHERE r.relation_type='GRANT'
        CONNECT BY PRIOR r.pati_id_arg2  = r.pati_id_arg1
                     AND r.relation_type ='GRANT'   -- grant is transitive
        START WITH r.pati_id_arg1 IN                -- grantee in
        (
         SELECT pati_id_in FROM DUAL                -- human with direct grant
        UNION
         SELECT orgr.pati_id_arg2                   -- the ou's the human is member of
         FROM wf_participant_relations orgr
         WHERE orgr.relation_type = 'MEMBER OF'
         AND   orgr.pati_id_arg1  = pati_id_in      -- human member pati id.
        );

    grant_record   grant_cursor%ROWTYPE;

    /*------------------------------------------------------------------------
     * Return the participants this participant is a direct proxy of.
     *------------------------------------------------------------------------*/
    CURSOR proxy_cursor(
        pati_id_in IN wf_participants.id%TYPE
    )
    IS
              SELECT pati_id_arg2 AS pati_id
                FROM wf_participant_relations r
               WHERE r.relation_type='PROXY OF'
                 AND r.pati_id_arg1 = pati_id_in;

    proxy_record   proxy_cursor%ROWTYPE;

    my_roles               int_table_type   DEFAULT int_table_type();   -- needs initialization
    my_proxys_roles        int_table_type;

    l_found PLS_INTEGER;
    p_index PLS_INTEGER     DEFAULT 1;

    new_call_history    VARCHAR2(10000);

BEGIN
    /*------------------------------------------------------------------------
     * Update call history.
     *------------------------------------------------------------------------*/
    new_call_history    := call_history_in || '('||pati_id_in||')';
    /*------------------------------------------------------------------------
     * Get my roles (p_index is default 1)
     *------------------------------------------------------------------------*/
    FOR grant_record IN grant_cursor(  pati_id_in=>pati_id_in )
    LOOP
        my_roles.EXTEND;
        my_roles(p_index) := grant_record.pati_id;
        p_index := p_index+1;
    END LOOP;
    /*------------------------------------------------------------------------
     * Get the roles granted to the participants I'm proxy of.
     *------------------------------------------------------------------------*/
    FOR proxy_record IN proxy_cursor(  pati_id_in=>pati_id_in )
    LOOP
-----   log( '- proxy ('||proxy_record.pati_id||') found.' );
        /*--------------------------------------------------------------------
         * If this proxy isn't a loop then..
         *--------------------------------------------------------------------*/
        IF NVL(INSTR( call_history_in, '('||proxy_record.pati_id||')' ),0) = 0
        THEN
------      log( '-- it was not in call_history_in' );
            /*----------------------------------------------------------------
             * find my proxy's roles
             *----------------------------------------------------------------*/
-------     log( '-- its parents called' );
            my_proxys_roles := has_roles(
                proxy_record.pati_id,
                new_call_history
            );
            /*----------------------------------------------------------------
             * Add it's roles to my roles
             *---------------------------------------------------------------*/
            FOR i IN 1 .. NVL(my_proxys_roles.LAST, 0)
            LOOP
                /*------------------------------------------------------------
                 * Is the proxy's role already listed in my roles?
                 *------------------------------------------------------------*/
                  SELECT count(*) INTO l_found
                  FROM TABLE(my_roles)
                  WHERE COLUMN_VALUE = my_proxys_roles(i)
                  ;
                /*------------------------------------------------------------
                 * If not, then add it to my roles
                 *------------------------------------------------------------*/
                IF l_found = 0 THEN
-----------         log( '--- added proxy '||proxy_record.pati_id||'''s role('||i||') to my_roles('||p_index||')' );
                    my_roles.EXTEND;
                    my_roles(p_index) := my_proxys_roles(i);
                    p_index := p_index+1;
-----------         ELSE   log( '--- proxy '||proxy_record.pati_id||'''s role('||i||') already in my_roles('||p_index||')' );
                END IF;
            END LOOP;
        END IF;
    END LOOP;

    RETURN my_roles;

END has_roles;

/*
||==========================================================================
|| FUNCTION: participant_is_type
||
|| Pre:     pati_id_in  is a number
||          type_in     is a character string
||
|| Returns: True    , when there exists a participant with ID pati_id_in
||                    and type type_in
||          False   , otherwise
||==========================================================================
*/
FUNCTION participant_is_type
(   pati_id_in  wf_participants.id%TYPE,
    type_in     wf_participants.participant_type%TYPE
)
RETURN BOOLEAN
IS
    l_dummy PLS_INTEGER;
BEGIN
    /*------------------------------------------------------------------------
     * Get matching record. Gives NO_DATA_FOUND when type mismatch or
     * ID not found.
     *------------------------------------------------------------------------*/
    SELECT 1
      INTO l_dummy
      FROM wf_participants
     WHERE participant_type = type_in
       AND id               = pati_id_in;
    /*------------------------------------------------------------------------
     * No errors means that the type matches
     *------------------------------------------------------------------------*/
    RETURN TRUE;
    /*------------------------------------------------------------------------
     * No data found error means that the type doesn't match
     *------------------------------------------------------------------------*/
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN FALSE;
END participant_is_type;

/*
||==========================================================================
|| FUNCTION: participant_is_human
||
|| Pre:     pati_id_in  is a number
||
|| Returns: True    , when there exists a participant with ID pati_id_in
||                    and type 'HUMAN'
||          False   , otherwise
||==========================================================================
*/
FUNCTION participant_is_human
(   pati_id_in  wf_participants.id%TYPE
)
RETURN BOOLEAN
IS
BEGIN
    RETURN participant_is_type( pati_id_in, 'HUMAN' );
END participant_is_human;

/*
||==========================================================================
|| PROCEDURE: WMOpenWorkList - Specifies and opens the query to produce the
||                worklist that matches the criterion of the filter.
|| DESCRIPTION
|| This command provides the capability of returning a list of work items
|| assigned to a specified workflow participant or a workgroup. The requester
|| may be making the request on behalf of himself or may be a manager wanting
|| to know what work has been assigned to a particular person or a workgroup.
|| A query handle will be returned for the list of work items that match the
|| specified value for the attribute. The command will also return, optionally,
|| the total count of work items available. If the count is requested and the
|| implementation does not support it, the command will return a pcount value
|| of -1. If pworklist_filter is NULL, then the function, with the
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
PROCEDURE OpenWorkList
-- WFMC interface 2, section 8.2.4:
-- Filter is a structure that containts: filter_type, length, attribute_name, comparison, filter_string.
-- this is much the same as attribute value comparison. (see condition cursor)
-- in this implementation, the filter parameter string (VARCHAR) should be
-- passed as a piece of SQL. (keep it simple)
-- The syntax is: CONSTRAINT [CHR(38) CONSTRAINT] | ANDATTRIBUTEFILTER
-- where
-- CONSTRAINT = STATE_CONSTRAINT | ACTIVITY_CONSTRAINT
-- STATE_CONSTRAINT = STATE=''<state>''
-- ACTIVITY_CONSTRAINT = ACTIVITIES ACTIVITY_CONSTRAINT_PART [and ACTIVITY_CONSTRAINT_PART]
-- ACTIVITY_CONSTRAINT_PART = prce_id=<nr> | acti_id=<nr>
-- e.g. 'STATE=''NOTRUNNING'' '||CHR(38)||' ACTIVITIES prce_id=10 and acti_id=70'
-- ANDATTRIBUTEFILTER = <query fitting after 'WHERE', containing reference to table a (wf_attribute_instances)>
-- e.g. 'a.atri_id = 10 AND a.value=''somevalue'' '
(   pworklist_filter IN  VARCHAR2,
    pati_id_in       IN  wf_participants.id%TYPE,   -- not standard... used instead of pworklist_filter
    count_flag       IN  INTEGER,
    pquery_handle    OUT generic_curtype,       -- reference cursor
    pcount           OUT INTEGER,
    sort_by          IN  VARCHAR2 DEFAULT 'date_created',
    sort_order       IN  VARCHAR2 DEFAULT 'ASC'
)
IS
    l_pos_s         PLS_INTEGER;
    l_pos_e         PLS_INTEGER;
    l_patient_id    PLS_INTEGER;
    l_acti_found    BOOLEAN         DEFAULT FALSE;

    l_filter_pos_1  PLS_INTEGER;
    l_filter_pos_2  PLS_INTEGER;
    l_state_expr    VARCHAR2(4000);   -- to contain filter for returning kinds of states
    l_acti_filter   VARCHAR2(4000);   -- to contain filter for activities

    l_select_expr   VARCHAR2(2000);   -- to contain common SELECT part of query
    l_from_expr     VARCHAR2(2000);   -- to contain common FROM part of query
    l_where_expr    VARCHAR2(2000);   -- to contain common WHERE part of query

    l_from_a1       VARCHAR2(2000);   -- to contain FROM part of first other sub-query joining another attribute instance
    l_where_a1      VARCHAR2(2000);   -- to contain WHERE part of first other sub-query joining another attribute instance

    l_from_a2       VARCHAR2(2000);   -- to contain FROM part of second other sub-query joining another attribute instance
    l_where_a2      VARCHAR2(2000);   -- to contain WHERE part of second other sub-query joining another attribute instance


    role_id_table int_table_type; --to contain list of pati_id's which the participant is granted (including himself)
BEGIN
    pcount := -1;       -- count_flag stuff not implemented.

    /*------------------------------------------------------------------------
     * Get roles of participant and add participant itself to the set.
     *------------------------------------------------------------------------*/
    SELECT pl_flow.has_roles(pati_id_in,'') INTO role_id_table FROM DUAL;
    role_id_table.EXTEND;
    role_id_table(role_id_table.LAST) := pati_id_in;

    /*------------------------------------------------------------------------
     * Define the common parts of the query
     *------------------------------------------------------------------------*/
    l_select_expr := ' i.prin_id
, i.id AS acin_id
, i.acti_id
, i.acti_prce_id
, i.state
, i.date_created
, i.date_started
, i.date_due
, i.worklist_display
, b.name AS perf_by_name
, b.id AS perf_by_id
, f.pefo_id
, f.accepted
, p.pati_id AS responsible_id
, pati_resp.name AS responsible_name
';

	log('l_select_expr='||l_select_expr);

    l_from_expr := 
' wf_process_instances   p , wf_activity_instances  i
, wf_performers          f  --current performer
, (SELECT pefo.acin_id, pefo.pati_id FROM wf_performers pefo, wf_participants pati WHERE pefo.state     = ''ASSIGNED'' AND  pefo.pati_id = pati.id AND pati.participant_type = ''ROLE'' AND   (pefo.accepted IS NULL OR pefo.accepted != ''N'')) f_assigned_role
, (SELECT pefo.acin_id, pefo.pati_id FROM wf_performers pefo, wf_participants pati WHERE pefo.state     = ''ASSIGNED'' AND  pefo.pati_id = pati.id AND pati.participant_type = ''HUMAN'' AND   (pefo.accepted IS NULL OR pefo.accepted != ''N'')) f_assigned_human
, (SELECT pefo.acin_id, pefo.pati_id FROM wf_performers pefo, wf_participants pati WHERE pefo.state     = ''ASSIGNED'' AND  pefo.pati_id = pati.id AND pati.participant_type = ''TEAM'' AND   (pefo.accepted IS NULL OR pefo.accepted != ''N'') ) f_assigned_ou              
, wf_participants        b  -- performing participant
, wf_participants pati_resp -- responsible person participant
, wf_activities          acti
';

log('l_from_expr='||l_from_expr);


    l_where_expr  := 
        '     p.id             = i.prin_id      -- link prin_id to activity_instance
          AND i.negation_ind   = ''N''          -- only valid instances, not faked ones
          AND (i.pati_id IS NULL OR i.pati_id IN (SELECT * FROM TABLE(CAST( :role_id_table AS int_table_type )))) --only activities that participant may be able to perform
          -- link possible current performer
          AND i.id             = f.acin_id (+)
          AND f.pati_id        = b.id (+)       -- link performer to participant record
          AND f.state (+)      = ''CURRENT''
          AND (f.accepted IS NULL OR f.accepted <> ''N'')
          --link possible assigned performer (role, ou or human)
          AND i.id             = f_assigned_role.acin_id (+) 
          AND i.id             = f_assigned_human.acin_id (+)
          AND i.id             = f_assigned_ou.acin_id (+)
          --if someone is assigned, it has to be equal to the participant, or the participant has to have a role that equals the assigned.
          AND (f_assigned_role.pati_id IS NULL OR f_assigned_role.pati_id IN (SELECT * FROM TABLE(CAST( :role_id_table AS int_table_type ))))
          AND (f_assigned_ou.pati_id IS NULL OR f_assigned_ou.pati_id IN (SELECT * FROM TABLE(CAST( :role_id_table AS int_table_type ))))
          AND (f_assigned_human.pati_id IS NULL OR f_assigned_human.pati_id IN (SELECT * FROM TABLE(CAST( :role_id_table AS int_table_type ))))
          -- link responsible participant to processinstance
          AND pati_resp.id (+) = p.pati_id
          -- join activity instance with activity
          AND acti.id          = i.acti_id
          AND acti.prce_id     = i.acti_prce_id
          AND acti.implementation    = ''NO''      --only select manual activities
          -- dont select future activities
          AND TRUNC(i.date_created) <= SYSDATE
          ';

log('l_where_expr='||l_where_expr);

    /*------------------------------------------------------------------------
     * Is there a filter?
     *------------------------------------------------------------------------*/
    IF LENGTH(pworklist_filter)>0 THEN
	log('ppworklist_filter='||pworklist_filter);
    /*------------------------------------------------------------------------
     * Does the filter include attributes?
     * Then execute a query with wf_attributes linked.
     *------------------------------------------------------------------------*/
        IF INSTR(pworklist_filter, ' a.')>0 THEN
            /*----------------------------------------------------------------
             * Variant with wf_attributes.
             *  - maybe with first/second sub-query selecting another attribute
             *----------------------------------------------------------------*/
            IF INSTR(pworklist_filter, ' a1.')>0 THEN
                l_from_a1  := ', wf_attribute_instances a1';
                l_where_a1 := 'AND i.prin_id = a1.prin_id';
				log('pworklist_filter contains a1 hence using wf_attribute_instances a1. '||'l_where_a1='||l_where_a1);
            ELSE
                l_from_a1  := '';
                l_where_a1 := '';
            END IF;
            IF INSTR(pworklist_filter, ' a2.')>0 THEN
                l_from_a2  := ', wf_attribute_instances a2';
                l_where_a2 := 'AND i.prin_id = a2.prin_id';
				log('pworklist_filter contains a2 hence using wf_attribute_instances a2. '||'l_where_a2='||l_where_a2);
            ELSE
                l_from_a2  := '';
                l_where_a2 := '';
            END IF;

l_sql := 'SELECT * FROM (SELECT ' || l_select_expr 
|| ' FROM ' || l_from_expr || ' ,wf_attribute_instances a ' || l_from_a1 || l_from_a2 
|| ' WHERE  ' || l_where_expr || ' AND i.prin_id = a.prin_id ' || l_where_a1 || l_where_a2
|| ' AND i.state IN (''NOTRUNNING'', ''RUNNING'',''SUSPENDED'') AND ' 
|| pworklist_filter 
|| ' ORDER BY ' || sort_by || ' ' || sort_order || ') WHERE ROWNUM <= ' || max_worklist_size;

log('l_sql='||l_sql);

            OPEN pquery_handle FOR l_sql USING role_id_table, role_id_table, role_id_table, role_id_table;
        /*--------------------------------------------------------------------
         * Variant with filter and without wf_attributes
         *--------------------------------------------------------------------*/
        ELSE
            /*----------------------------------------------------------------
             * Determine state filter
             * Input like 'STATE=''NOTRUNNING'''
             * l_state_expr is e.g.
             *     = 'NOTRUNNING'
             * or IN ( 'RUNNING', 'SUSPENDED' )
             *----------------------------------------------------------------*/
            l_state_expr := ' IN (''NOTRUNNING'', ''RUNNING'',''SUSPENDED'') ';         -- default value: get all not completed / terminated states.
            l_filter_pos_1 := INSTR( UPPER( pworklist_filter ), 'STATE' );              -- find 'state' constraints
            IF l_filter_pos_1 > 0                                                       -- when found
            THEN
                l_filter_pos_2 := INSTR( UPPER( pworklist_filter), '&', l_filter_pos_1 );     -- determine the end (by finding &) of the state constraint
                IF l_filter_pos_2 = 0 THEN l_filter_pos_2 := LENGTH( pworklist_filter )+1; END IF;      -- if no AND, then end pos = length + 1
                l_state_expr := SUBSTR( pworklist_filter,
                                        l_filter_pos_1 + LENGTH( 'STATE' ),         -- start position
                                        l_filter_pos_2 - ( l_filter_pos_1 + LENGTH( 'STATE' ) ) -- length
                                      ) || ' ';
            END IF;
           /*-----------------------------------------------------------------
             * Construct activity list
             * input like 'ACTIVITIES prce_id=10 and acti_id=20 or prce_id=10 and acti_id=30'
             * and ( i.acti_prce_id=10 and i.acti_id=20 or i.acti_prce_id=10 and i.acti_id=40 )
             *---------------------------------------------------------------*/
            l_acti_filter := '';                                                            -- default value
            l_filter_pos_1 := INSTR( UPPER( pworklist_filter ), 'ACTIVITIES' );             -- find 'state' constraints
            IF l_filter_pos_1 > 0                                                           -- when found
            THEN
                l_filter_pos_2 := INSTR( UPPER( pworklist_filter), '&', l_filter_pos_1 ); -- determine the end (by finding &) of the state constraint
                IF l_filter_pos_2 = 0 THEN l_filter_pos_2 := LENGTH( pworklist_filter )+1; END IF;      -- if no AND, then end pos = length + 1
                l_acti_filter := REPLACE
                (   ' AND ( ' || 
                    SUBSTR( UPPER(pworklist_filter)     -- note the UPPER
                          , l_filter_pos_1 + LENGTH( 'ACTIVITIES' )                      -- start position
                          , l_filter_pos_2 - ( l_filter_pos_1 + LENGTH( 'ACTIVITIES' ) ) -- length
                          ) || ') '
                ,   'PRCE_ID'
                ,   'i.acti_prce_id'
                );
                l_acti_filter := REPLACE( l_acti_filter, 'ACTI_ID', 'i.acti_id' );

            END IF;
            l_sql := 'SELECT *
                      FROM (SELECT ' || l_select_expr || '
                            FROM   ' || l_from_expr || '
                            WHERE  ' || l_where_expr || '
                            AND    i.state '
                                || l_state_expr
                                || l_acti_filter
                                || '
                            ORDER BY ' || sort_by || ' ' || sort_order || '
                           )
                      WHERE ROWNUM <= ' || max_worklist_size;
            log('bla1'||substr(l_sql,0,3500));
            log('bla2'||substr(l_sql,3500));
            OPEN pquery_handle FOR l_sql 
            USING role_id_table, role_id_table, role_id_table, role_id_table;
        END IF;
    ELSE
        /*--------------------------------------------------------------------
         * Openworklist without filter
         *--------------------------------------------------------------------*/
		log('Openworklist without filter..');
        l_sql := 'SELECT *
             FROM (SELECT ' || l_select_expr || '
                   FROM   ' || l_from_expr || '
                   WHERE  ' || l_where_expr || '
                   AND    i.state IN (''NOTRUNNING'', ''RUNNING'', ''SUSPENDED'')
                   ORDER BY ' || sort_by || ' ' || sort_order || '
                  )
             WHERE ROWNUM <= ' || max_worklist_size;
        log('l_sql='||l_sql);
        OPEN pquery_handle FOR l_sql 
        USING role_id_table, role_id_table, role_id_table, role_id_table;
    END IF;
    log('end of procedure');

END OpenWorkList;

/*
||==========================================================================
|| Internal procedure: CREATE ACTIVITY INSTANCE.
||
|| Called by StartProcess and ChangeActivityInstanceState( complete ).
|| The acin_id_in is used in case an activity instance has been created in the
|| past, when not all preconditions had been fulfilled, uptil now.
|| This acin will then be overwritten / initialized. In all other cases,
|| leave acin_id NULL.
||
|| DESCRIPTION
||
|| Creates an activity instance. If the activity is an plsql_proc_name
|| then call that procedure.
||
|| Exceptions:  invalid activity    (no data found)
||
|| IF the activity.pati_id(_query) results in a human participant, it will 
|| become the current performer (for it is the only participant that is allowed 
|| to perform the activity instance)
||==========================================================================
*/
PROCEDURE create_activity_instance
(   prin_id_in IN wf_process_instances.id%TYPE
,   prce_id_in IN wf_processes.id%TYPE
,   acti_id_in IN wf_activities.id%TYPE
,   acin_id_in IN wf_activity_instances.id%TYPE DEFAULT NULL
)
IS
    /*------------------------------------------------------------------------
     * Cursor to get the activity model.
     *------------------------------------------------------------------------*/
    CURSOR activity_cursor(
        prce_id_in IN wf_processes.id%TYPE
    ,   acti_id_in IN wf_activities.id%TYPE )
    IS
        SELECT a.prce_id
        ,      a.id AS acti_id
        ,      a.apli_id
        ,      a.create_delay_expr
        ,      a.start_mode
        ,      a.finish_mode
        ,      a.implementation
        ,      a.prce_id_has_subflow
        ,      a.subflow_execution
        ,      p.plsql_proc_name
        ,      a.worklist_display_query
        ,      a.assign_to
        ,      a.pati_query
        ,      a.pati_exclude_query
        FROM   wf_activities a
        ,      wf_applications p
        WHERE  a.apli_id = p.id (+)
        AND    a.prce_id = prce_id_in
        AND    a.id      = acti_id_in
    ;
    activity_record activity_cursor%ROWTYPE;

    /*------------------------------------------------------------------------
     * Cursor to get the deadlines conditions
     *------------------------------------------------------------------------*/
    CURSOR deadline_cursor(
        prce_id_in IN wf_processes.id%TYPE,
        acti_id_in IN wf_activities.id%TYPE )
    IS
        SELECT d.id
        ,      d.execution
        ,      d.condition
        ,      d.exception_name
        FROM   wf_deadlines d
        WHERE acti_prce_id = prce_id_in
        AND   acti_id      = acti_id_in;

    deadline_record deadline_cursor%ROWTYPE;

    l_due_days          NUMBER(15,5);
    l_due_days_lowest   NUMBER(15,5);
    l_deli_id           wf_deadlines.id%TYPE;        -- to contain the first deadline

    l_pati_id_performer wf_participants.id%TYPE;     -- assigned person id, (if any)
    l_pati_id_assigned  wf_participants.id%TYPE;     -- assigned participant id, (if any)
    l_pati_id           wf_participants.id%TYPE;     -- allowed human participant id, (if any)
    l_pati_id_exclude   wf_participants.id%TYPE;     -- unallowed human participant id, (if any)

    l_job_out BINARY_INTEGER; -- submitted job number

    l_create_delay_expr      NUMBER(15,5) DEFAULT 0; -- number of days to wait before creation of the workitem
BEGIN
    /*------------------------------------------------------------------------
     * Get the activity model
     *------------------------------------------------------------------------*/
    OPEN activity_cursor( prce_id_in, acti_id_in );
    FETCH activity_cursor INTO activity_record;
    /*------------------------------------------------------------------------
     * execute participant queries.
     *------------------------------------------------------------------------*/
     IF activity_record.pati_query IS NOT NULL THEN
         BEGIN
            --Maybe no query, but pati_id
            l_pati_id := TO_NUMBER(activity_record.pati_query);
         EXCEPTION --could only be number format exception, meaning it is a real query
             WHEN OTHERS THEN
             BEGIN
                 log( 'About to execute SQL statement ''' || activity_record.pati_query
                     || ''' using ' || TO_CHAR(prin_id_in) );
                 EXECUTE IMMEDIATE activity_record.pati_query INTO l_pati_id USING prin_id_in;
                log( 'Result is : participant ' || l_pati_id ||
                     ' is allowed to perform activity ' || acti_id_in );
             EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    log( 'The ''pati'' query for activity ' || prce_id_in ||
                        ' ' || acti_id_in || ' didn''t return a result. (query = '''
                        || activity_record.pati_query || ''' using prin_id = ' ||
                        prin_id_in || ')' );
                    l_pati_id := NULL;
                WHEN OTHERS THEN
                    RAISE;
             END;
         END;
     END IF;
     IF activity_record.pati_exclude_query IS NOT NULL THEN
         BEGIN
         log( 'About to execute SQL statement ''' || activity_record.pati_exclude_query
                     || ''' using ' || TO_CHAR(prin_id_in) );
             EXECUTE IMMEDIATE activity_record.pati_exclude_query INTO l_pati_id_exclude USING prin_id_in;
                log( 'Result is : participant ' || l_pati_id_exclude ||
                     ' is not allowed to perform activity ' || acti_id_in );
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                log('The ''pati_exclude'' query for activity ' || prce_id_in ||
                    ' ' || acti_id_in || ' didn''t return a result. (query = '''
                    || activity_record.pati_exclude_query || ''' using prin_id = ' ||
                    prin_id_in || ')' );
                l_pati_id_exclude := NULL;
            WHEN OTHERS THEN
                RAISE;
         END;
     END IF;
    /*------------------------------------------------------------------------
     * If activity.pati_id is a human then use this specific participant as
     * performer of the to be created activity instance.
     *------------------------------------------------------------------------*/
     l_pati_id_performer := NULL;
     IF participant_is_human( l_pati_id )
     THEN
        l_pati_id_performer := l_pati_id;
     END IF;
    /*------------------------------------------------------------------------
     * If 'assign_to' is not null, it contains a query to get a participant id
     * that should perform the activity.
     * Takes precedence over activities.pati_id.
     * Example query:
     * SELECT pati_id FROM wf_process_instances WHERE id = :prin_id_in
     *------------------------------------------------------------------------*/
    IF activity_record.assign_to IS NOT NULL
    THEN
        log( 'About to execute SQL statement ''' || activity_record.assign_to
             || ''' using ' || TO_CHAR(prin_id_in) );
        BEGIN
            EXECUTE IMMEDIATE activity_record.assign_to
            INTO l_pati_id_assigned
            USING prin_id_in;
            log( 'Result is : participant ' || l_pati_id_assigned ||
                 ' is to be assigned to activity ' || acti_id_in );
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                log( 'The ''assign_to'' query for activity ' || prce_id_in ||
                    ' ' || acti_id_in || ' didn''t return a result. (query = '''
                    || activity_record.assign_to || ''' using prin_id = ' ||
                    prin_id_in || ')' );
                l_pati_id_assigned := NULL;
            WHEN OTHERS THEN
                RAISE;
        END;
    END IF;
    /*------------------------------------------------------------------------
     * check if excluded participant does not equal allowed/assigned and is human
     *------------------------------------------------------------------------*/
    IF l_pati_id_exclude IS NOT NULL THEN
        IF NOT participant_is_human(l_pati_id_exclude)  THEN
            RAISE_APPLICATION_ERROR( -20123,
                    'The excluded participant for activity ' || prce_id_in ||
                    ' ' || acti_id_in || ' is not a HUMAN participant' );
        END IF;
        IF l_pati_id_exclude = l_pati_id_assigned THEN
            RAISE_APPLICATION_ERROR( -20124,
                    'The excluded participant for activity ' || prce_id_in ||
                    ' ' || acti_id_in || 'equals the assigned particpant' );
        END IF;
        IF l_pati_id_exclude = l_pati_id THEN
            RAISE_APPLICATION_ERROR( -20125,
                    'The excluded participant for activity ' || prce_id_in ||
                    ' ' || acti_id_in || ' equals the allowed participant' );
        END IF;
    END IF;
    /*------------------------------------------------------------------------
     * Small check for subflow execution.
     *------------------------------------------------------------------------*/
    IF activity_record.implementation = 'SUBFLOW' THEN
        IF activity_record.prce_id_has_subflow IS NULL THEN
            RAISE_APPLICATION_ERROR( -20121, 'Activity ' || prce_id_in || ' '
                || acti_id_in || ' has implementation ''SUBFLOW'' ' ||
                'but no sub process id is specified.' );
        END IF;
    END IF;
    /*------------------------------------------------------------------------
     * Get all the deadline conditions
     *------------------------------------------------------------------------*/
    FOR deadline_record IN deadline_cursor( prce_id_in, acti_id_in )
    LOOP
    /*------------------------------------------------------------------------
     * Evaluate all deadline condition expressions
     * Get the condition from the process instances table, so the condition can
     * contain references to things that can be fetched from information in
     * the workflow relevant data.
     * Deadline can evaluate to NULL (no deadline).
     *------------------------------------------------------------------------*/
        l_sql := 'SELECT ' || deadline_record.condition || '
                  FROM WF_PROCESS_INSTANCES
                  WHERE id=:prin_id_in
                 ';
        log( 'About to execute SQL statement ''' || l_sql || ''' using '
             || TO_CHAR(prin_id_in) );
        EXECUTE IMMEDIATE l_sql INTO l_due_days USING prin_id_in;
        IF l_due_days_lowest IS NULL
        OR l_due_days_lowest > l_due_days
        THEN
            l_due_days_lowest := l_due_days;
            l_deli_id         := deadline_record.id;
        END IF;
    END LOOP;
    /*--------------------------------------------------------------------------
     * Evaluate the create delay expr expression
     *--------------------------------------------------------------------------*/
    IF activity_record.create_delay_expr IS NOT NULL
    THEN
        IF activity_record.implementation = 'NO' AND
           activity_record.start_mode     = 'MANUAL'
        THEN
            l_sql := 'SELECT ' || activity_record.create_delay_expr
                  || ' FROM WF_PROCESS_INSTANCES '
                  || 'WHERE id=:prin_id_in ';
            log( 'About to execute SQL statement ''' || l_sql || ''' using '
                 || TO_CHAR(prin_id_in) );
            EXECUTE IMMEDIATE l_sql INTO l_create_delay_expr USING prin_id_in;
            --due to the extra SELECT, no NO_DATA_FOUND-exceptions are raised when the query does not find anything
            -- (unless the prin_id_in does not exist, which is a real error that should be raised.
            IF l_create_delay_expr IS NULL THEN l_create_delay_expr := 0; END IF;
            log( 'Result is delay of : ' || l_create_delay_expr ||
                 ' for activity ' || acti_id_in );
        ELSE
            RAISE_APPLICATION_ERROR( -20122, 'Activity ' || prce_id_in || ' ' || acti_id_in || ' has delay_expression "' || activity_record.create_delay_expr || '", but is not a ''MANUAL'' activity with ''NO'' implementation, it is ' || activity_record.start_mode || ',' || activity_record.implementation ||')' );
            --NB: If you need automatic activities to start in the future,
            --    then you have to change the source, e.g. give delayed activities
            --    a special state and adapt check_deadlines to check for those
            --    activities that have reached their start_date and start them then.
            --The construction with Oracle Jobs has been removed,
            --because jobs cannot be replicated and stored.
        END IF;
    END IF;
    pl_flow.instantiate_activity_instance (
        prin_id_in           => prin_id_in
    ,   prce_id_in           => prce_id_in
    ,   acti_id_in           => acti_id_in
    ,   perf_pati_id_in      => l_pati_id_performer
    ,   apli_id_in           => activity_record.apli_id
    ,   plsql_proc_name_in   => activity_record.plsql_proc_name
    ,   deli_id_in           => l_deli_id
    ,   days_due_in          => l_due_days_lowest
    ,   prce_id_subflow_in   => activity_record.prce_id_has_subflow
    ,   subflow_execution_in => activity_record.subflow_execution
    ,   implementation_in    => activity_record.implementation
    ,   start_mode_in        => activity_record.start_mode
    ,   finish_mode_in       => activity_record.finish_mode
    ,   assi_pati_id_in      => l_pati_id_assigned
    ,   date_created_in      => SYSDATE + TO_NUMBER(l_create_delay_expr)
    ,   acin_id_in           => acin_id_in
    ,   pati_id_in           => l_pati_id
    ,   pati_id_exclude_in   => l_pati_id_exclude
    );
    CLOSE activity_cursor;
/*--------------------------------------------------------------------------
 * When the activity model doesn't exist.
 *--------------------------------------------------------------------------*/
--EXCEPTION           -- no_data_found -> activity model not found
--    WHEN OTHERS THEN
--        ROLLBACK;
--        RAISE;
END create_activity_instance;

/*
||==========================================================================
|| PROCEDURE: instantiate_activity_instance
||
|| DESCRIPTION
||
|| This is an internal procedure that is called by CreateActivityInstance.
||
|| It was made public in the package specification, because this procedure
|| could be submitted. (When there was a create_delay_expr) This is not the case
|| anymore.
||
|| The acin_id_in is used in case an activity instance has been created in the
|| past, when not all preconditions had been fulfilled, uptil now.
|| This acin will then be overwritten / initialized. In all other cases,
|| leave acin_id NULL.
||
|| Actions performed are:
|| - execute the workitem_display_query if there is one
|| - create the workitem record
|| - if implementation is SUBFLOW; create the subprocess instance
|| - if implementation is TOOL; call the tool (stored procedure)
|| - if start_mode is AUTOMATIC, start the activity instance
|| - if finish_mode is AUTOMATIC, complete the activity instance
||
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
,   pati_id_in           IN wf_activity_instances.pati_id%TYPE         DEFAULT 0 --for backwards compatibility with submitted jobs a default value is added.
,   pati_id_exclude_in   IN wf_activity_instances.pati_id_exclude%TYPE DEFAULT NULL
)
IS
    l_acin_id               wf_activity_instances.id%TYPE;      -- the returning new activity instance id
    l_worklist_line         VARCHAR(4000)   DEFAULT NULL;       -- the line to be displayed in the worklist
    parameter_list          VARCHAR(4000)   DEFAULT '';         -- to contain the parameter list
    parameter_list_for_log  VARCHAR(4000)   DEFAULT '';         -- to contain the parameter list
    l_comma_in_parm_list    BOOLEAN         DEFAULT FALSE;      -- used at construction of a parameter list
    l_notation              CHAR(1)         DEFAULT NULL;       -- to check for mixed positional and named notation for parameter passing
    l_job_out               BINARY_INTEGER;                     -- submitted job number for called pl/sql procedures
    l_due_date              DATE            DEFAULT NULL;       -- date after which the workitem is due

    l_prin_id                   wf_process_instances.id%TYPE;   --the id of the subflow prin
    l_worklist_display_query    wf_activities.worklist_display_query%TYPE;
    
    l_loopnr                    PLS_INTEGER;
    
    l_pati_id                   wf_activity_instances.pati_id%TYPE;
    
    l_pati_id_subflow           wf_activity_instances.pati_id%TYPE; --used to get the responsible participant for this process instance (and use it for subflow process instance)
    l_remarks                   wf_process_instances.remarks%TYPE; --remarks of parent prin for copy to subflow

    /*--------------------------------------------------------------------------
     * Get the list of parameters and values for constructing subflow IN-parameter list.
     *--------------------------------------------------------------------------*/
    CURSOR subf_fopa_cursor
    (   prce_id_subflow_in IN wf_processes.id%TYPE
    ,   prin_id_in         IN wf_process_instances.id%TYPE 
    ,   acti_id_in         IN wf_activities.id%TYPE
    ,   prce_id_in         IN wf_processes.id%TYPE
    )
    IS
        SELECT * FROM (
            /* Union actual parameters of which the value is given by an attribute instance */
            SELECT fp.data_type
            ,      fp.fopa_mode
            ,      fp.fopa_index
            ,      i.value
            ,      NULL as expression
            ,      a.name
            FROM wf_formal_parameters     fp
            ,    wf_actual_parameters     ap
            ,    wf_attribute_instances   i
            ,    wf_attributes            a
            WHERE fp.ID            = ap.fopa_id
            AND   ap.acti_id       = acti_id_in
            AND   ap.acti_prce_id  = prce_id_in
            AND   fp.fopa_mode     LIKE 'IN%'
            AND   fp.atri_id       = a.id          -- join fp with subprocess attribute
            AND   ap.atri_id       = i.atri_id     -- join actual parameter with attribute instance
            AND   i.prin_id        = prin_id_in    -- value in this process instance
            AND   fp.prce_id       = prce_id_subflow_in    -- formal parameters for this subprocess
            UNION
            /* With actual parameters of which the value is given by an expression */
            SELECT fp.data_type
            ,      fp.fopa_mode
            ,      fp.fopa_index
            ,      NULL AS value
            ,      ap.expression
            ,      a.name
            FROM wf_formal_parameters     fp
            ,    wf_actual_parameters     ap
            ,    wf_attributes            a
            WHERE fp.ID            = ap.fopa_id
            AND   ap.acti_id       = acti_id_in
            AND   ap.acti_prce_id  = prce_id_in
--            AND   fp.fopa_mode     = 'IN' --can only be IN if expression.
            AND   fp.atri_id       = a.id          -- join fp with subprocess attribute
            AND   ap.expression    IS NOT NULL
            AND   ap.atri_id       IS NULL         -- only expressions when there is no attribute
            AND   fp.prce_id       = prce_id_subflow_in
        )
        ;
    subf_fopa_record subf_fopa_cursor%ROWTYPE;

    /*--------------------------------------------------------------------------
     * Get the list of parameters and values for constructing tool parameter list.
     *--------------------------------------------------------------------------*/
    CURSOR tool_fopa_cursor (
        apli_id_in IN wf_applications.id%TYPE,
        prin_id_in IN wf_process_instances.id%TYPE,
        acti_id_in IN wf_activities.id%TYPE,
        prce_id_in IN wf_processes.id%TYPE )
    IS
        SELECT ROWNUM, name, fopa_index, value, expression FROM (
            /* IN and INOUT parameters with actual parameter with attribute instance */
            SELECT fp.data_type, fp.fopa_mode, fp.name, fp.fopa_index, fp.id AS fopa_id
            ,      i.value, NULL as expression
            FROM   wf_formal_parameters     fp
            ,      wf_actual_parameters     ap
            ,      wf_attribute_instances   i
            WHERE fp.ID           = ap.fopa_id
            AND   ap.acti_id      = acti_id_in        -- actual parms of this activity
            AND   ap.acti_prce_id = prce_id_in
            AND   fp.apli_id      = apli_id_in        -- formal parameters for this application
            AND   fp.fopa_mode    LIKE 'IN%'          --IN and INOUT
            AND   ap.atri_id      = i.atri_id
            AND   i.prin_id       = prin_id_in        -- value in this process instance.
           UNION
            /* IN parameters with actual parameter with expression */
            SELECT fp.data_type, fp.fopa_mode, fp.name, fp.fopa_index, fp.id AS fopa_id 
            ,      NULL AS value, ap.expression
            FROM  wf_formal_parameters fp
            ,     wf_actual_parameters ap
            WHERE fp.ID            = ap.fopa_id
            AND   ap.acti_id       = acti_id_in        -- actual parms of this activity
            AND   ap.acti_prce_id  = prce_id_in
            AND   fp.apli_id       = apli_id_in        -- formal parameters for this application
            AND   ap.expression    IS NOT NULL
            AND   ap.atri_id       IS NULL         -- only expressions when there is no attribute
           UNION
            /* OUT parameters. */
            SELECT fp.data_type, fp.fopa_mode, fp.name, fp.fopa_index, fp.id AS fopa_id
            ,      NULL AS value, NULL as expression
            FROM  wf_formal_parameters     fp
            ,     wf_actual_parameters     ap
            WHERE fp.ID            = ap.fopa_id
            AND   ap.acti_id       = acti_id_in        -- actual parms of this activity
            AND   ap.acti_prce_id  = prce_id_in
            AND   fp.apli_id       = apli_id_in        -- formal parameters for this application
            AND   fp.fopa_mode     = 'OUT'
        )
        ORDER BY fopa_index ASC -- for positional parameter passing, otherwise it can be null
        ,        fopa_id ASC     --if fopa_index = null, to maintain same order for assignattrib.
        ;
        
    CURSOR acin_cursor (acin_id_in IN wf_activity_instances.id%TYPE)
    IS
        SELECT * FROM wf_activity_instances
        WHERE id = acin_id_in
        FOR UPDATE;
    acin_record acin_cursor%ROWTYPE;
    /*--------------------------------------------------------------------------
     * 'Copy' OUT parameter resuls from outparm_tab to PL/Flow attribute instances
     *--------------------------------------------------------------------------*/
    PROCEDURE assignattrib
    IS
        n PLS_INTEGER;
    BEGIN
        n := 1;
        FOR cAtri IN (      /* cursor to get attribut names for out parameters */
            SELECT atri.name, fopa.fopa_mode, fopa.id AS fopa_id
            FROM wf_formal_parameters fopa
            ,    wf_actual_parameters acpa
            ,    wf_attributes        atri
            WHERE acpa.acti_prce_id = prce_id_in
            AND   acpa.acti_id      = acti_id_in
            AND   acpa.fopa_id      = fopa.id
            AND   fopa.apli_id      = apli_id_in --if wf is correctly defined, this can only be apli_id_in.
            AND   acpa.atri_id      = atri.id (+)   --calling attribute to put value in (can be null if expression)
            ORDER BY fopa_index ASC, fopa_id ASC
        )    
        LOOP
            IF cAtri.fopa_mode LIKE '%OUT' THEN
                log('Assigning outparameter '|| n ||' to attribute ' || cAtri.name);
                Pl_Flow.AssignProcessInstanceAttribute(
                    prin_id_in  => prin_id_in,
                    name_in     => cAtri.NAME,
                    value_in    => out_parm_tab(n)
                );
            END IF;
            n := n + 1;
        END LOOP;
    END;

BEGIN
    log( 'prin_id ' || prin_id_in || ', acti_id_in ' || acti_id_in || ', prce_id_in ' || prce_id_in ||
        ', start_mode_in ' || start_mode_in || ', finish_mode_in ' || finish_mode_in || ', implementation_in '  || implementation_in );
    /*------------------------------------------------------------------------
     * Calculate due date
     *------------------------------------------------------------------------*/
    IF days_due_in IS NOT NULL
    THEN
        l_due_date := date_created_in + days_due_in;
    END IF;
    /*------------------------------------------------------------------------
     * Fix for if this is called from an Oracle JOB, which has been created by an old pl/flow
     *------------------------------------------------------------------------*/
    IF pati_id_in = 0 THEN
        SELECT TO_NUMBER(acti.pati_query) INTO l_pati_id FROM wf_activities acti WHERE acti.id = acti_id_in AND acti.prce_id = prce_id_in;
    ELSE
        l_pati_id := pati_id_in;
    END IF;

    IF acin_id_in IS NULL
    THEN
        /*--------------------------------------------------------------------
         * Create 'the record'
         *--------------------------------------------------------------------*/
        INSERT INTO wf_activity_instances
        (   id                 -- activity instance primary key
        ,   prin_id            -- process instance primary key
        ,   acti_prce_id       -- process part of activity primary key
        ,   acti_id            -- activity part of activity primary key
        ,   date_created
        ,   date_started
        ,   date_ended
        ,   deli_id
        ,   date_due
        ,   state
        ,   remarks
        ,   worklist_display
        ,   session_state
        ,   negation_ind
        ,   pati_id
        ,   pati_id_exclude)
        VALUES 
        (   make_parallel( acin_seq.NEXTVAL )  -- see make_parallel
        ,   prin_id_in
        ,   prce_id_in
        ,   acti_id_in
        ,   date_created_in
        ,   NULL
        ,   NULL
        ,   deli_id_in
        ,   l_due_date
        ,   'NOTRUNNING'
        ,   NULL
        ,   NULL
        ,   EMPTY_BLOB()
        ,   'N'               --normal instance.
        ,   l_pati_id
        ,   pati_id_exclude_in
        )
        RETURNING id INTO l_acin_id;
    ELSE
        l_acin_id := acin_id_in;
        /* an acin has been created, but not started or even initialized.
         * The current values can be overwritten */
        OPEN acin_cursor(acin_id_in => acin_id_in);
        FETCH acin_cursor INTO acin_record;
        IF acin_cursor%NOTFOUND
        THEN
           RAISE_APPLICATION_ERROR( -20114, 'pl_flow.instantiate_activity_instance: ' ||
           'Activity instance with acin_id '||acin_id_in||' not found' );
        ELSE
            UPDATE wf_activity_instances
            SET prin_id            = prin_id_in -- process instance primary key
            ,   acti_prce_id       = prce_id_in -- process part of activity primary key
            ,   acti_id            = acti_id_in -- activity part of activity primary key
            ,   date_created       = date_created_in
            ,   date_started       = NULL
            ,   date_ended         = NULL
            ,   deli_id            = deli_id_in
            ,   date_due           = l_due_date
            ,   state              = 'NOTRUNNING'
            ,   remarks            = NULL
            ,   worklist_display   = NULL
            ,   session_state      = EMPTY_BLOB()
            ,   negation_ind       = 'N'
            ,   pati_id            = l_pati_id
            ,   pati_id_exclude    = pati_id_exclude_in
            WHERE CURRENT OF acin_cursor;
        END IF;
        CLOSE acin_cursor;
    END IF;
    /*------------------------------------------------------------------------
     * Is a worklist html query present?
     * Example worklist_display_query:
     * SELECT acti.name 
     * FROM wf_activity_instances acin
     * ,    wf_activities         acti
     * ,    wf_attribute_instances i
     * WHERE acin.id           = :acin_id
     * AND acin.acti_id        = acti.id
     * AND acin.acti_prce_id   = acti.prce_id
     * AND i.atri_id=xxx
     * AND i.prin_id=:prin_id
     * AND i.value=messages.id
     *------------------------------------------------------------------------*/
    SELECT worklist_display_query INTO l_worklist_display_query
    FROM  wf_activities
    WHERE prce_id =   prce_id_in
    AND   id      =   acti_id_in
    ;
    IF l_worklist_display_query IS NOT NULL
    THEN
        log( 'About to execute worklist_display_query using ' || l_acin_id|| ' : ' || l_worklist_display_query );
        BEGIN
            EXECUTE IMMEDIATE l_worklist_display_query INTO  l_worklist_line
            USING l_acin_id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RAISE_APPLICATION_ERROR( -20110,
                    'pl_flow.instantiate_activty_instance: The worklist display query didn''t return a result. (See wf_debug_log for query).' );
        END;
        UPDATE wf_activity_instances
           SET worklist_display =   l_worklist_line
         WHERE id=l_acin_id;
    END IF;
    /*------------------------------------------------------------------------
     * Automatic start of the activity?
     * note: also activities with subflows are started automatic.
     *------------------------------------------------------------------------*/
    IF start_mode_in        = 'AUTOMATIC'
    OR implementation_in    = 'SUBFLOW'
    OR plsql_proc_name_in  IS NOT NULL
    THEN
        log( 'activity instance ' || l_acin_id || ' started automatically' );
        pl_flow.ChangeActivityInstanceState(
              acin_id_in    =>  l_acin_id,
              state_in      =>  'RUNNING',
              pati_id_in    =>  pl_flow_participant );
    END IF;
    /*------------------------------------------------------------------------
     * If perf_pati_id_in is not null then there is an assigned human/robot (instead of a role/skill)
     * See also change activity instance state and delegate actictivity instance procedures
     *------------------------------------------------------------------------*/
    IF perf_pati_id_in IS NOT NULL
    THEN
        INSERT INTO wf_performers(
            id,
            acin_id,        -- activity instance primary key
            pati_id,        -- assigned participant
            state,
            date_created,
            accepted,       -- does the participant accept this assignment? Only used at reassignment.
            remarks,
            pefo_id )       -- 'delegated from' pefo id -> NULL in this case since it is not delegated yet.
        VALUES (
            make_parallel( pefo_seq.NEXTVAL ),  -- see make_parallel
            l_acin_id,
            perf_pati_id_in,     -- is null when acti.pati type is not human (i.e. one assigned person)
            'CURRENT',
            date_created_in,
            NULL,           -- only used at reassignment
            NULL,           -- no remarks yet
            NULL  );        -- no delegation at first start.
    END IF;
    /*--------------------------------------------------------------------------
     * If assi_pati_id_in is not null then there is an assigned participant
     * (human or role or...). NB: if perf_pati_id_in is not null, then this
     * participant should be the assigned participant or a role it can play. If
     * not, the workitem won't appear on a worklist. I have chosen to be able to
     * allow pati_id_in and assi_pati_id_in at the same time, so you can make
     * a human the performer, and if he rejects it, it can still be delegated to
     * a specific role.
     * See also OpenWorklist and reject procedures
     *--------------------------------------------------------------------------*/
    IF assi_pati_id_in IS NOT NULL
    THEN
        INSERT INTO wf_performers(
            id,
            acin_id,        -- activity instance primary key
            pati_id,        -- assigned participant
            state,
            date_created,
            accepted,       -- does the participant accept this assignment? Only used at reassignment.
            remarks,
            pefo_id )       -- 'delegated from' pefo id -> NULL in this case since it is not delegated yet.
        VALUES (
            make_parallel( pefo_seq.NEXTVAL ),  -- see make_parallel
            l_acin_id,
            assi_pati_id_in,-- is null when acti.pati type is not human (i.e. one assigned person)
            'ASSIGNED',
            date_created_in,
            'Y',            -- do not allow reject
            NULL,           -- no remarks yet
            NULL  );        -- no delegation at first start.
    END IF;

    /*------------------------------------------------------------------------
     * Is there a tool? Is it an auto pl/sql proc?
     *------------------------------------------------------------------------*/
    IF implementation_in = 'TOOL'
    AND plsql_proc_name_in IS NOT NULL
    THEN
        log( 'Implementation is TOOL, plsql_proc_name is ' ||plsql_proc_name_in );
        /*--------------------------------------------------------------------
         * Check that autoprocs have start and finished mode 'AUTOMATIC'
         *--------------------------------------------------------------------*/
        IF start_mode_in <> 'AUTOMATIC'
        OR finish_mode_in <> 'AUTOMATIC'
        THEN
            send_mail(  sender_name_in      => 'PL/FLOW',
                        sender_email_in     => def_sender_email,
                        recipient_name_in   => 'recipient of wf errors',
                        recipient_email_in  => mail_errors_to,
                        subject_in          => 'PL/FLOW runtime error',
                        body_in             => 'Start or finish mode of PL/SQL autoproc activity ' || prce_id_in || ' ' || acti_id_in || ' is not ''AUTOMATIC''. ' ||
                                               'Manual start and finish mode means explicit start and end by a user, which is impossible for a called PL/SQL procedure. ' ||
                                               '.. continuing as if start and finish mode = ''AUTOMATIC''.'
                     );
        END IF;
        /*--------------------------------------------------------------------
         * Clear the outparm table
         *--------------------------------------------------------------------*/
        PL_FLOW.out_parm_tab.DELETE;
        l_loopnr := 0;
        /*--------------------------------------------------------------------
         * Read the values of the attributes that are formal parameters
         *--------------------------------------------------------------------*/
        FOR tool_fopa_record in tool_fopa_cursor( apli_id_in=>apli_id_in
                                                , prin_id_in=>prin_id_in
                                                , prce_id_in=>prce_id_in
                                                , acti_id_in=>acti_id_in
                                                )
        LOOP
            PL_FLOW.out_parm_tab.EXTEND; 
            l_loopnr := l_loopnr + 1;
            /*----------------------------------------------------------------
             * If there is an expression, evaluate it into tool_fopa_record.value
             *----------------------------------------------------------------*/
            IF tool_fopa_record.expression IS NOT NULL
            THEN
                l_sql := 'SELECT ' || tool_fopa_record.expression ||
                         '  FROM WF_ACTIVITY_INSTANCES acin'      ||
                         ' WHERE acin.id=:acin_id_in ';
                log( 'About to exec SQL query to evaluate expression with acin_id ' || l_acin_id || ': ' || l_sql );
                EXECUTE IMMEDIATE l_sql
                INTO out_parm_tab(l_loopnr)
                USING l_acin_id;                  -- With the activity instance ID, everything can be fetched from the process and activity instance
            ELSE
log('out_parm_tab('||l_loopnr||')='||tool_fopa_record.value);
                out_parm_tab(l_loopnr) := tool_fopa_record.value;
            END IF;
            /*----------------------------------------------------------------
             * Comma separator.
             *----------------------------------------------------------------*/
            IF l_comma_in_parm_list THEN
                parameter_list := parameter_list || ', ';
                parameter_list_for_log := parameter_list_for_log || ', ';
            END IF;
            l_comma_in_parm_list := TRUE;
            /*----------------------------------------------------------------
             * Named notation?
             *----------------------------------------------------------------*/
            IF tool_fopa_record.name IS NOT NULL THEN
                parameter_list := parameter_list || tool_fopa_record.name || '=>';
                parameter_list := parameter_list || 'PL_FLOW.out_parm_tab(' || l_loopnr || ')';
                
                parameter_list_for_log := parameter_list_for_log || tool_fopa_record.name || '=>';
                parameter_list_for_log := parameter_list_for_log || out_parm_tab(l_loopnr);

                IF l_notation = 'P' THEN
                    RAISE_APPLICATION_ERROR( -20111,
                        'pl_flow.instantiate_activty_instance: Error: mixed named and positional notation in ' ||
                        'formal parameters for activity  ' || prce_id_in || ' ' || acti_id_in || '. Either specify all parameters by name, or by fopa_index.');
                END IF;
                l_notation := 'N';
            /*----------------------------------------------------------------
             * Or positional notation?
             *----------------------------------------------------------------*/
            ELSE
                parameter_list := parameter_list || 'PL_FLOW.out_parm_tab(' || l_loopnr || ')';
                IF l_notation = 'N' THEN
                    RAISE_APPLICATION_ERROR( -20112,
                        'pl_flow.instantiate_activty_instance: Error: mixed named and positional notation in ' ||
                        'formal parameters for activity  ' || prce_id_in || ' ' || acti_id_in || '. Either specify all parameters by name, or by fopa_index.');
                END IF;
                l_notation := 'P';
            END IF;

        END LOOP;

       log( 'Calling procedure ' ||   plsql_proc_name_in || '( ' || parameter_list_for_log || ');' );
        /*--------------------------------------------------------------------
         * This stuff is put in an extra block, so errors in the called procedure
         * can be catched and mailed to the wf administrator.
         *--------------------------------------------------------------------*/
        BEGIN
            EXECUTE IMMEDIATE
                   'BEGIN '
                 ||   plsql_proc_name_in || '( ' || parameter_list || ');'
                 || 'END;';
/**        EXCEPTION
        WHEN OTHERS THEN
            pl_flow.send_mail(  sender_name_in      => 'PL/FLOW',
                                sender_email_in     => def_sender_email,
                                recipient_name_in   => 'recipient of wf errors',
                                recipient_email_in  => mail_errors_to,
                                subject_in          => 'Error in calling TOOL ' || plsql_proc_name_in ,
                                body_in             => 'An error occurred when calling ' || plsql_proc_name_in || '( ' || parameter_list || ');'
                                                       || CHR(10) || CHR(13) || 'Error: ' || SQLERRM
                             );
***/
        END;
        /*--------------------------------------------------------------------
         * is there any any OUT parametes, save them into the wf_attribute_instances table
         *--------------------------------------------------------------------*/
      IF PL_FLOW.out_parm_tab.COUNT > 0 THEN
            Assignattrib;
      END IF;

    END IF;
    /*------------------------------------------------------------------------
     * Automatic finish. complete the activity instance.
     * (subflows are finished automatically by the completion of the subprocess instance.)
     *------------------------------------------------------------------------*/
    IF ( implementation_in = 'NO' OR implementation_in = 'TOOL' ) -->AND NOT 'SUBFLOW'!
    THEN
        IF finish_mode_in = 'AUTOMATIC'
        THEN
            pl_flow.ChangeActivityInstanceState(
                  acin_id_in    =>  l_acin_id,
                  state_in      =>  'COMPLETED',
                  pati_id_in    =>  pl_flow_participant );
            log( 'activity instance ' || l_acin_id || ' completed automatically' );
        END IF;
    /*------------------------------------------------------------------------
     * Is this activity a subflow? Then start a new proces instance.
     *------------------------------------------------------------------------*/
    ELSIF implementation_in = 'SUBFLOW'
    THEN
        SELECT make_parallel( prin_seq.NEXTVAL )
        INTO   l_prin_id
        FROM   DUAL;

        PL_FLOW.CreateProcessInstance(
            prce_id_in=>prce_id_subflow_in,
            prin_id_in=>l_prin_id
        );
        /*--------------------------------------------------------------------
         * Take care of IN parameters: store values of actual parameters in
         * attributes of the subprocess
         *--------------------------------------------------------------------
         * Read the values of the attributes that are formal parameters
         *--------------------------------------------------------------------*/
        FOR subf_fopa_record IN subf_fopa_cursor
        (   prce_id_subflow_in => prce_id_subflow_in
         ,  prin_id_in         => prin_id_in
         ,  acti_id_in         => acti_id_in
         ,  prce_id_in         => prce_id_in
        )
        LOOP
            /*----------------------------------------------------------------
             * If there is an expression, evaluate it into tool_fopa_record.value
             *----------------------------------------------------------------*/
            IF subf_fopa_record.expression IS NOT NULL
            THEN
                l_sql := 'SELECT ' || subf_fopa_record.expression ||
                            '  FROM WF_ACTIVITY_INSTANCES acin'      ||
                            ' WHERE acin.id=:acin_id_in ';
                log( 'About to exec SQL query to evaluate expression with acin_id ' || l_acin_id || ': ' || l_sql );
                EXECUTE IMMEDIATE l_sql
                INTO  subf_fopa_record.value
                USING l_acin_id;                  -- With the activity instance ID, everything can be fetched from the process and activity instance
            END IF;
            /*--------------------------------------------------------------------------
             * Set attribute value in the sub process
             *--------------------------------------------------------------------------*/
            log( 'About to assign in prin_id ' || l_prin_id || ' attribute ' || subf_fopa_record.name || ' with value ' || subf_fopa_record.value || '.' );
            Pl_Flow.AssignProcessInstanceAttribute(
                prin_id_in  => l_prin_id,
                name_in     => subf_fopa_record.name,
                value_in    => subf_fopa_record.value
            );

        END LOOP;
        /*--------------------------------------------------------------------
         * What kind of subflow execution?
         *--------------------------------------------------------------------*/
        /*--------------------------------------------------------------------
         * From: TC-1025-10 (p34)
         * In the case of synchronous execution the execution of the Activity
         * is suspended after a process instance of the referenced Process
         * Definition is initiated. After execution termination of this process
         * instance the Activity is resumed. Return parameters may be used
         * between the called and calling processes on completion of the
         * subflow. This style of subflow is characterized as hierarchic
         * subflow operation.
         *--------------------------------------------------------------------*/
        IF subflow_execution_in = 'SYNCHR' THEN
            -- and then suspend it.
            pl_flow.ChangeActivityInstanceState(
                  acin_id_in    =>  l_acin_id,
                  state_in      =>  'SUSPENDED',
                  pati_id_in    =>  pl_flow_participant );

            /*----------------------------------------------------------------
             * Link the 'parent' activity instance id to this new process
             * instance
             *----------------------------------------------------------------*/
            UPDATE wf_process_instances
            SET    acin_id = l_acin_id
            WHERE  id      = l_prin_id;
            
            SELECT remarks INTO l_remarks FROM wf_process_instances WHERE id = prin_id_in;
            AddProcessInstanceRemarks
            (   prin_id_in => l_prin_id
            ,   remarks_in => l_remarks
            );

        /*--------------------------------------------------------------------
         * From: TC-1025-10 (p34)
         * In the case of asynchronous execution the execution of the Activity
         * is continued after a process instance of the referenced Process
         * Definition is initiated (in this case execution proceeds to any post
         * activity split logic after subflow initiation. No return parameters
         * are supported from such called processes. Synchronization with the
         * initiated subflow, if required, has to be done by other means such
         * as events, not described in this document. This style of subflow is
         * characterized as chained (or forked) subflow operation.
         *--------------------------------------------------------------------*/
        ELSIF subflow_execution_in = 'ASYNCHR' THEN
            -- execution of activity proceeds to post activity split logic
            pl_flow.ChangeActivityInstanceState(
                  acin_id_in    =>  l_acin_id,
                  state_in      =>  'COMPLETED',
                  pati_id_in    =>  pl_flow_participant );
        ELSE
            RAISE_APPLICATION_ERROR( -20113,
                'pl_flow.instantiate_activty_instance: unknown subflow execution type ' || subflow_execution_in );
        END IF;

        /*--------------------------------------------------------------------
         * Finally, after all the attributes are in place, start the process.
         * (i.e.: create the first activity instance.)
         *--------------------------------------------------------------------*/
        SELECT pati_id INTO l_pati_id_subflow FROM wf_process_instances WHERE id=prin_id_in;
        pl_flow.StartProcess (
            prin_id_in => l_prin_id,
            pati_id_in => l_pati_id_subflow  -- the wf engine itself
        );
    END IF; -- end of if subflow

END instantiate_activity_instance;


/*
||==========================================================================
|| Internal procedure: clean_process_instance.
||
|| Called when a process instance is closed. (completed or terminated or aborted)
||
|| DESCRIPTION
||
|| Destroys data that is not necessary to keep when a process instance is closed.
||==========================================================================
*/
PROCEDURE clean_process_instance
(   prin_id_in IN wf_process_instances.id%TYPE
)
IS
BEGIN
    /*------------------------------------------------------------------------
     * Delete all the attribute instances with keep='N'
     *------------------------------------------------------------------------*/
    DELETE
      FROM wf_attribute_instances
     WHERE atri_id IN (
            SELECT DISTINCT id
              FROM wf_attributes
             WHERE keep='N') -- full table scan not bad; it's a small table.
       AND prin_id = prin_id_in;
    /*------------------------------------------------------------------------
     * Delete all the activity attribute instances with keep='N'
     *------------------------------------------------------------------------*/
    DELETE
      FROM wf_acti_attribute_instances
     WHERE acat_id IN (
            SELECT DISTINCT id
              FROM wf_activity_attributes
             WHERE keep='N') -- full table scan not bad; it's a small table.
       AND acin_id IN (
            SELECT id
              FROM wf_activity_instances
             WHERE prin_id = prin_id_in);      -- id's of the activity instances of this process instance.
    /*------------------------------------------------------------------------
     * Delete all the (faked) transition instances with negation_ind='Y'
     *------------------------------------------------------------------------*/
    DELETE FROM wf_transition_instances trin
    WHERE EXISTS (SELECT 1
                    FROM wf_activity_instances acin 
                   WHERE trin.acin_id_from = acin.id
                     AND acin.prin_id = prin_id_in)  --assume transitions to be between activity instances of the same process.
    AND trin.negation_ind = 'Y';

    /*------------------------------------------------------------------------
     * Delete all the (faked) activity instances with negation_ind='Y'
     *------------------------------------------------------------------------*/
    DELETE FROM wf_activity_instances acin
    WHERE acin.negation_ind = 'Y'
      AND NOT EXISTS  -- nog wachtende AND joins niet wissen als deze incomende arcs die niet faked zijn hebben
          (SELECT 1
             FROM wf_transition_instances trin
            WHERE trin.acin_id_to = acin.id
              AND trin.negation_ind = 'N')
      AND acin.prin_id = prin_id_in;
    
    --no ref constraints, because only 'Y' transitions attached to it, 
    --and they are deleted already
     
/*--------------------------------------------------------------------------
 * The application programmer really should not forget to commit!
 *--------------------------------------------------------------------------*/
--EXCEPTION
--    WHEN OTHERS THEN
--            ROLLBACK;
--            RAISE;             -- errors to caller
END clean_process_instance;

/*
||==========================================================================
|| Check deadlines
||
|| Depending on the DEADLINE.EXECUTION type (synchronous or asynchronous)
|| the activity instance is terminated or not. On arrival of a deadline, an
|| exception (not PL/SQL exception) is raised, which can be the condition for
|| a transition (with transition type 'exception')
||==========================================================================
*/
PROCEDURE check_deadlines
IS
    /*------------------------------------------------------------------------
     * Cursor to read all workitems that are late
     *------------------------------------------------------------------------*/
    CURSOR lateitem_cursor IS
        SELECT acin.id AS acin_id
        ,      acin.prin_id
        ,      acin.acti_prce_id
        ,      acin.acti_id
        ,      acin.date_created
        ,      acin.date_due - acin.date_created AS due_time_amount --due_days according to the deadline expression as it was executed previously
        ,      deli.execution
        ,      deli.exception_name
        FROM   wf_activity_instances acin
        ,      wf_deadlines          deli
        WHERE  deli.id           = acin.deli_id
        AND    acin.state        IN ( 'NOTRUNNING', 'SUSPENDED', 'RUNNING' )
        AND    acin.negation_ind = 'N'
        AND    acin.date_due     < SYSDATE;

    lateitem_record lateitem_cursor%ROWTYPE;

    /*------------------------------------------------------------------------
     * Cursor to fetch exception transitions
     *------------------------------------------------------------------------*/
    CURSOR transition_cursor(
        prce_id_in          IN wf_processes.id%TYPE,
        acti_id_in          IN wf_activities.id%TYPE,
        exception_name_in   IN wf_deadlines.exception_name%TYPE
        )
    IS
        SELECT t.acti_id_to
        ,      t.acti_id_from
        FROM  wf_transitions t
        WHERE t.condition         = exception_name_in
        AND   t.condition_type    = 'EXCEPTION'
        AND   t.acti_prce_id_from = prce_id_in
        AND   t.acti_id_from      = acti_id_in
        ;
    transition_record transition_cursor%ROWTYPE;

    /*------------------------------------------------------------------------
     * Cursor to get a new deadline?
     *------------------------------------------------------------------------*/
    CURSOR deadline_cursor
    (   prce_id_in IN wf_processes.id%TYPE
    ,   acti_id_in IN wf_activities.id%TYPE )
    IS
        SELECT d.id, d.execution, d.condition, d.exception_name
          FROM wf_deadlines d
         WHERE acti_prce_id = prce_id_in
           AND acti_id = acti_id_in;

    deadline_record deadline_cursor%ROWTYPE;

    l_due_days          NUMBER(15,5);
    l_due_days_lowest   NUMBER(15,5);
    l_deli_id           wf_deadlines.id%TYPE;

    l_acin_id           wf_activity_instances.id%TYPE;
    l_acti_join         wf_activities.join%TYPE;

BEGIN
    /*------------------------------------------------------------------------
     * Read all workitems that are late (SYSDATE > date_due AND deadline exists)
     *------------------------------------------------------------------------*/
    FOR lateitem_record IN lateitem_cursor
    LOOP
        /*--------------------------------------------------------------------
         * Find the transition that matches the deadline exception name
         *--------------------------------------------------------------------*/
        OPEN transition_cursor( lateitem_record.acti_prce_id
                              , lateitem_record.acti_id
                              , lateitem_record.exception_name );
        FETCH transition_cursor INTO transition_record;
        /*--------------------------------------------------------------------
         * If no transition found for this deadline, mail the workflow admin
         *--------------------------------------------------------------------*/
        IF transition_cursor%NOTFOUND THEN
            send_mail(  sender_name_in      => 'PL/FLOW',
                        sender_email_in     => def_sender_email,
                        recipient_name_in   => 'recipient of wf errors',
                        recipient_email_in  => mail_errors_to,
                        subject_in          => 'PL/FLOW runtime error',
                        body_in             => 'Check_deadline JOB:\nNo transition found for exception ' || lateitem_record.exception_name || ' raised on activity instance ' || lateitem_record.acin_id
                     );
        /*--------------------------------------------------------------------
         * Make the (first found) transition
         *--------------------------------------------------------------------*/
        ELSE
            /*----------------------------------------------------------------
             * Log a line
             *----------------------------------------------------------------*/
            log( 'Deadline reached on workitem ' || lateitem_record.acin_id );
            --log('deadline reached on workitem acin_id='||lateitem_record.acin_id||',prin_id='||lateitem_record.prin_id||',prce_id='||lateitem_record.acti_prce_id||',acti_id='||lateitem_record.acti_id);
            /*----------------------------------------------------------------
             * Check on workflow if transition not to AND-join
             *----------------------------------------------------------------*/
            SELECT join INTO l_acti_join 
            FROM wf_activities 
            WHERE prce_id = lateitem_record.acti_prce_id
            AND   id      = transition_record.acti_id_to
            ;
            IF l_acti_join = 'AND' THEN
                send_mail(  sender_name_in      => 'PL/FLOW',
                            sender_email_in     => def_sender_email,
                            recipient_name_in   => 'recipient of wf errors',
                            recipient_email_in  => mail_errors_to,
                            subject_in          => 'PL/FLOW runtime error',
                            body_in             => 'Check_deadline JOB:\nException transition cannot be part of an AND-join (exception ' || lateitem_record.exception_name || ' raised on activity instance ' || lateitem_record.acin_id || ')'
                );
                EXIT;
            END IF;
            /*----------------------------------------------------------------
             * create activity instance
             *----------------------------------------------------------------*/
            INSERT INTO wf_activity_instances(
                id             -- activity instance primary key
            ,   prin_id        -- process instance primary key
            ,   acti_prce_id   -- process part of activity primary key
            ,   acti_id        -- activity part of activity primary key
            ,   date_created
            ,   date_started
            ,   date_ended
            ,   deli_id
            ,   date_due
            ,   state
            ,   remarks
            ,   worklist_display
            ,   session_state
            ,   negation_ind )
            VALUES (
                make_parallel( acin_seq.NEXTVAL )  -- see make_parallel
            ,   lateitem_record.prin_id
            ,   lateitem_record.acti_prce_id
            ,   transition_record.acti_id_to
            ,   SYSDATE
            ,   NULL
            ,   NULL
            ,   NULL
            ,   NULL
            ,   'PRE-CREATED'   --not yet real. instantiation happens after calculation of other deadlines
            ,   NULL
            ,   NULL
            ,   EMPTY_BLOB()
            ,   'N' 
            )
            RETURNING id INTO l_acin_id;
            /*----------------------------------------------------------------
             * Create transition instance
             *----------------------------------------------------------------*/
            INSERT INTO wf_transition_instances (
                trsi_acti_prce_id_from
            ,   trsi_acti_id_from
            ,   trsi_acti_prce_id_to
            ,   trsi_acti_id_to
            ,   acin_id_from
            ,   acin_id_to
            ,   negation_ind
            )
            VALUES (
                lateitem_record.acti_prce_id
            ,   transition_record.acti_id_from
            ,   lateitem_record.acti_prce_id
            ,   transition_record.acti_id_to
            ,   lateitem_record.acin_id
            ,   l_acin_id
            ,   'N' --a real transition
            );
            /*----------------------------------------------------------------
             * Synchronous deadline: terminate timed out activity instance
             *----------------------------------------------------------------*/
            IF lateitem_record.execution = 'SYNCHR' THEN
                pl_flow.ChangeActivityInstanceState(
                      acin_id_in    =>  lateitem_record.acin_id
                ,     state_in      =>  'TERMINATED'
                ,     pati_id_in    =>  pl_flow_participant );
            /*----------------------------------------------------------------
             * Asynchronous deadline: is there a new deadline on the workitem?
             * (possible synchronous)
             *----------------------------------------------------------------*/
            ELSE

                FOR deadline_record IN deadline_cursor( lateitem_record.acti_prce_id
                                                      , lateitem_record.acti_id )
                LOOP
                    BEGIN
                        /*----------------------------------------------------
                         * Evaluate the deadline condition expression
                         * (in context of current Process Instance).
                         * Return only those with a condition greater than the
                         * current deadline.
                         *----------------------------------------------------*/
                        l_sql := 'SELECT duetime
                                  FROM   ( SELECT  ' || deadline_record.condition || ' AS duetime
                                           FROM    wf_process_instances
                                           WHERE   id = :prin_id
                                         )
                                  WHERE duetime > :due_time_amount
                                 ';
                        log( 'About to evaluate deadline condition expression with query ''' || l_sql || ''' using ' || TO_CHAR(lateitem_record.prin_id) );
                        EXECUTE IMMEDIATE l_sql
                        INTO l_due_days
                        USING lateitem_record.prin_id
                        ,     lateitem_record.due_time_amount
                        ;

                        IF l_due_days_lowest IS NULL         --none found yet
                        OR l_due_days_lowest > l_due_days    --other deadline found, with later deadline than current deadline, but earlier than other found later deadlines
                        THEN
                            l_due_days_lowest := l_due_days;
                            l_deli_id         := deadline_record.id;
                        END IF;
                        EXCEPTION
                            WHEN NO_DATA_FOUND
                            THEN
                                NULL; --No better deadline found -> ignore.
                            WHEN OTHERS THEN
                                send_mail(  sender_name_in      => 'PL/FLOW'
                                         ,  sender_email_in     => def_sender_email
                                         ,  recipient_name_in   => ''
                                         ,  recipient_email_in  => mail_errors_to
                                         ,  subject_in          => 'PL/FLOW runtime error'
                                         ,  body_in             => 'Error occurred in pl_flow.check_deadlines on deadline condition expression query ''' || l_sql || ''' using ' || TO_CHAR(lateitem_record.prin_id) || ' and ' || lateitem_record.due_time_amount
                                         );
                                RAISE;
                    END;
                END LOOP; --trough deadlines
                /*------------------------------------------------------------
                 * Change deadline.
                 *------------------------------------------------------------*/
                IF l_deli_id IS NOT NULL
                THEN
                    log( 'set new deadline' );
                    /*--------------------------------------------------------
                     * Set new deadline and date_due
                     *--------------------------------------------------------*/
                    UPDATE wf_activity_instances
                    SET    deli_id = l_deli_id
                    ,      date_due = lateitem_record.date_created + l_due_days_lowest
                    WHERE  id = lateitem_record.acin_id;
                ELSE --no new deadline found.
                    log( 'remove deadline' );
                    /*--------------------------------------------------------
                     * Remove deadline, but keep date_due
                     *--------------------------------------------------------*/
                    UPDATE wf_activity_instances
                    SET    deli_id = NULL
                    WHERE  id = lateitem_record.acin_id;
                END IF; --New Deadline
            END IF; --SYNCH or ASYNCH

            /*----------------------------------------------------------------
             * create activity instance and initiate it.
             *----------------------------------------------------------------*/
            create_activity_instance( -- create activity instance from the model
                lateitem_record.prin_id
            ,   lateitem_record.acti_prce_id
            ,   transition_record.acti_id_to
            ,   l_acin_id );

        END IF; --transition found
        CLOSE transition_cursor;
    END LOOP; --trough lateitem records

    COMMIT WORK;

END check_deadlines;

/*
||==========================================================================
|| Internal procedure: MOVE TO ARCHIVE.
||
|| Called by 'last activity checks'
||
|| DESCRIPTION
||
|| Copies the process instance-record + child-records to archive tables
|| and after that the original records are deleted.
||
||  - process instance: just 1 record
||  - all attribute instance(s) related to the process instance
||  - all activity instance(s) related to the process instance
||  - all transition instance(s) related to the activity instance(s)
||  - all activity attribute instance(s) related to the activity instance(s)
||  - all performer(s) related to the activity instance(s)
||==========================================================================
*/
PROCEDURE move_to_archive
(   prin_id_in IN wf_process_instances.id%TYPE
)
IS
    /*------------------------------------------------------------------------
     * Cursor to fetch process instance-record
     *------------------------------------------------------------------------*/
    CURSOR prin_cursor( prin_id_in IN wf_process_instances.id%TYPE )
    IS
        SELECT prin.*
        FROM   wf_process_instances prin
        WHERE  prin.id = prin_id_in
        FOR UPDATE
        ;
    prin_record prin_cursor%ROWTYPE;
    /*------------------------------------------------------------------------
     * Cursor to fetch activity instance-record(s) with process instance
     *------------------------------------------------------------------------*/
    CURSOR acin_cursor( acin_prin_id_in IN wf_activity_instances.prin_id%TYPE )
    IS
        SELECT acin.*
        FROM   wf_activity_instances acin
        WHERE  acin.prin_id = acin_prin_id_in
        FOR UPDATE
        ;
    /*------------------------------------------------------------------------
     * Cursor to fetch subprocess instance-record(s) of activity instance
     *------------------------------------------------------------------------*/
    CURSOR subprin_cursor( acin_id_in IN wf_process_instances.acin_id%TYPE )
    IS
        SELECT prin.*
        FROM   wf_process_instances prin
        WHERE  prin.acin_id = acin_id_in
        ;
    CURSOR trin_cursor ( acin_id_in IN wf_activity_instances.id%TYPE)
    IS
        SELECT *
        FROM  wf_transition_instances   trin
        WHERE trin.acin_id_from = acin_id_in
        OR    trin.acin_id_to   = acin_id_in
        FOR UPDATE
        ;
BEGIN
    /*------------------------------------------------------------------------
     * Move to archive can be disabled for debugging perpuses. See the set_archive procedure
     *------------------------------------------------------------------------*/
    IF NOT pl_flow.archive THEN
        GOTO end_move_to_archive;
    END IF;
    /*------------------------------------------------------------------------
     * Select, insert and delete process instance, and handle child records
     *------------------------------------------------------------------------*/
    OPEN prin_cursor( prin_id_in );
    FETCH prin_cursor INTO prin_record;
    IF prin_cursor%NOTFOUND
    THEN
       RAISE_APPLICATION_ERROR( -20130, 'pl_flow.move_to_archive: ' ||
           'Process instance with prin_id '||prin_id_in||' not found' );
    END IF;
    CLOSE prin_cursor;
    log('Moving process instance with prin_id '||prin_id_in||' to archive');
    /*------------------------------------------------------------------------
     * Insert process instance archive
     *------------------------------------------------------------------------*/
    INSERT INTO wf_process_instances_arch
           ( id
           , pati_id
           , acia_id
           , prce_id
           , date_created
           , date_started
           , date_ended
           , state
           , remarks )
    VALUES ( prin_record.id
           , prin_record.pati_id
           , prin_record.acin_id
           , prin_record.prce_id
           , prin_record.date_created
           , prin_record.date_started
           , prin_record.date_ended
           , prin_record.state
           , prin_record.remarks
           );
    /*------------------------------------------------------------------------
     * Select, insert and delete attribute instance(s)
     *------------------------------------------------------------------------*/
    INSERT INTO wf_attribute_instances_arch(
            pria_id,
            atri_id,
            value )
    SELECT atin.prin_id,
           atin.atri_id,
           atin.value
    FROM   wf_attribute_instances atin
    WHERE atin.prin_id = prin_record.id
    ;
    DELETE FROM wf_attribute_instances atin
    WHERE atin.prin_id = prin_record.id
    ;
    /*------------------------------------------------------------------------
     * Select, insert and delete activity instance, and handle child records
     *------------------------------------------------------------------------*/
    FOR acin_record IN acin_cursor( acin_prin_id_in => prin_record.id )
    LOOP
        log('Moving acin ' || acin_record.id || ' (' || acin_record.acti_prce_id
            || ' ' || acin_record.acti_id || ') to archive');
        /*--------------------------------------------------------------------
         * Insert activity instance archive
         *--------------------------------------------------------------------*/
        INSERT INTO wf_activity_instances_arch
        (   id
        ,   pria_id
        ,   acti_id
        ,   acti_prce_id
        ,   date_created
        ,   date_started
        ,   date_ended
        ,   deli_id
        ,   date_due
        ,   state
        ,   remarks
        ,   worklist_display)
        VALUES 
        (   acin_record.id
        ,   acin_record.prin_id
        ,   acin_record.acti_id
        ,   acin_record.acti_prce_id
        ,   acin_record.date_created
        ,   acin_record.date_started
        ,   acin_record.date_ended
        ,   acin_record.deli_id
        ,   acin_record.date_due
        ,   acin_record.state
        ,   acin_record.remarks
        ,   acin_record.worklist_display
        );
        /*--------------------------------------------------------------------
         * Move child processes to archive
         *--------------------------------------------------------------------*/
        FOR subprin_record IN subprin_cursor( acin_record.id)
        LOOP
            move_to_archive(prin_id_in => subprin_record.id);
        END LOOP;
        /*--------------------------------------------------------------------
         * Select, insert and delete transition instance(s)
         *--------------------------------------------------------------------*/
        FOR trin_record IN trin_cursor( acin_id_in => acin_record.id)
        LOOP
            BEGIN
                INSERT INTO wf_transition_instances_arch (
                        acia_id_from
                ,       acia_id_to
                ,       trsi_acti_prce_id_from
                ,       trsi_acti_id_from
                ,       trsi_acti_prce_id_to
                ,       trsi_acti_id_to)
                VALUES( trin_record.acin_id_from
                ,       trin_record.acin_id_to
                ,       trin_record.trsi_acti_prce_id_from
                ,       trin_record.trsi_acti_id_from
                ,       trin_record.trsi_acti_prce_id_to
                ,       trin_record.trsi_acti_id_to
                )
                ;
                DELETE FROM wf_transition_instances trin
                WHERE CURRENT OF trin_cursor
                ;
            EXCEPTION
                /* ----------------------------------------------------------
                 * It is not possible to insert when one of the two acins is
                 * not in archive. Don't do anything if this is the case. Just
                 * wait till this function is called on the other acin after it
                 * has moved to archive.
                 * -----------------------------------------------------------*/
                WHEN OTHERS THEN
                    IF SQLCODE = -2291 AND INSTR(SQLERRM, 'TRIA_ACIA') > 0 --ORA-02291: integrity constraint (PVT_DWO.TRIA_ACIA_FK) violated - parent key not found
                    THEN
                        NULL;
                    ELSE
                        ROLLBACK;
                        RAISE;
                    END IF;
            END;
        END LOOP; --trin loop
        /*--------------------------------------------------------------------
         * Select, insert and delete activity attribute instance(s)
         *--------------------------------------------------------------------*/
        INSERT INTO wf_acti_attrib_instances_arch(
                acat_id,
                acia_id,
                value )
        SELECT aain.acat_id,
               aain.acin_id,
               aain.value
        FROM   wf_acti_attribute_instances aain
        WHERE  aain.acin_id = acin_record.id
        ;
        DELETE FROM  wf_acti_attribute_instances aain
        WHERE aain.acin_id = acin_record.id
        ;
        /*--------------------------------------------------------------------
         * Select, insert and delete performer(s)
         *--------------------------------------------------------------------*/
        INSERT INTO wf_performers_arch(
                id,
                pear_id,
                pati_id,
                acia_id,
                date_created,
                state,
                accepted,
                remarks )
        SELECT  id,
                pefo_id,
                pati_id,
                acin_id,
                date_created,
                state,
                accepted,
                remarks
        FROM   wf_performers pefo
        WHERE  pefo.acin_id = acin_record.id
        ;
        DELETE
        FROM wf_performers pefo
        WHERE pefo.acin_id = acin_record.id
        ;
    END LOOP;

    /*------------------------------------------------------------------------
     * Delete activity instances
     *------------------------------------------------------------------------*/
     DELETE FROM wf_activity_instances acin
     WHERE acin.prin_id = prin_record.id
     ;
    /*------------------------------------------------------------------------
     * Delete process instance
     *------------------------------------------------------------------------*/
    DELETE FROM wf_process_instances prin
    WHERE prin.id = prin_id_in
    ;

    <<end_move_to_archive>>
    NULL;

END move_to_archive;

/*
||==========================================================================
|| PROCEDURE: last_activity_checks
||
|| Internal procedure
|| Called by acin_complete and acin_terminate and acin_abort and prin_abort
||
|| DESCRIPTION
|| Logic to complete (or terminate) the process instance and possible a
|| parent activity instance.
||
|| Parameters:
||  to_transition_found_in  True when there is a transition from the completed activity
||                          acin_id_in to another activity. (In the process definition)
||  transition_done_in      Set by acin_complete if this new activity has been
||                          made. If false and no_conditions_complete_process (package
||                          variable) then the process instance will be completed.
||==========================================================================
*/
PROCEDURE last_activity_checks
(   prin_id_in                IN  wf_process_instances.id%TYPE
,   to_transition_found_in    IN  BOOLEAN
,   transition_done_in        IN  BOOLEAN
)
IS
    /*------------------------------------------------------------------------
     * Cursor to see of other activity instances are open in the process instance
     * If this procedure is called while earlier in this transaction transitions have
     * been made to pre-created activity instances (that are yet to be 'really created')
     * then the process instance should not be moved to archive.
     *------------------------------------------------------------------------*/
    CURSOR acin_cursor( prin_id_in IN wf_process_instances.id%TYPE )
    IS
        SELECT 1
        FROM   wf_activity_instances
        WHERE  prin_id = prin_id_in
        AND    state IN ( 'NOTRUNNING', 'RUNNING', 'SUSPENDED'  -- open
                        , 'PRE-CREATED' )
        AND    negation_ind = 'N'
        ;
    acin_record acin_cursor%ROWTYPE;

    /*------------------------------------------------------------------------
     * Cursor to get out parameters of a subprocess
     *
     * A note about this cursor: (5 may 2004)
     * - If the mode of the formal parameter <> OUT, this cursor returns no result, but also no errors.
     * - If the definition of the actual parameter is not a reference to an attribute, see above (no results and no errors)
     *
     *   This might be difficult when debugging process definitions. A process definition checker is starting
     *   to get from 'handy' to 'really necessary'.
     *------------------------------------------------------------------------*/
    CURSOR outparm_cursor( prin_id_in IN wf_process_instances.id%TYPE
                         , prce_id_in IN wf_processes.id%TYPE
                         , acti_id_in IN wf_activities.id%TYPE
                         )
    IS
    SELECT spai.value AS result     -- value of subprocess attribute instance
    ,      cpa.name   AS cpaname    -- calling process attribute name to assign outparm to.
    FROM   wf_formal_parameters   sfp
    ,      wf_attribute_instances spai -- subprocess attribute instance
    ,      wf_actual_parameters   cap  -- calling process actual paramater. May not be an expression: must be a reference to an attribute
    ,      wf_attributes          cpa  -- calling process attribute
    WHERE  sfp.atri_id  = spai.atri_id -- id is only attribute in pk of wf_attributes - no need to add constraint on prce_id
    AND    sfp.fopa_mode LIKE '%OUT'
    AND    cap.fopa_id  = sfp.id       -- the link between calling and sub process instances.
    AND    cap.acti_id  = acti_id_in   -- the link between calling and sub process instances.
    AND    cap.acti_prce_id = prce_id_in-- the link between calling and sub process instances.
    AND    cap.atri_id  = cpa.id       -- this attribute in calling process gets value of spai.value
    AND    spai.prin_id = prin_id_in   -- just this subprocess instance id
    ;
    outparm_record  outparm_cursor%ROWTYPE;

    l_parent_acin_id            wf_activity_instances.id%TYPE;
    l_parent_prin_id            wf_process_instances.id%TYPE;
    l_parent_acti_id            wf_activities.id%TYPE;
    l_parent_prce_id            wf_processes.id%TYPE; 
    l_subflow_execution         wf_activities.subflow_execution%TYPE;
    l_state_of_parent_activity  wf_activity_instances.state%TYPE;

BEGIN
    /*------------------------------------------------------------------------
     * Check if this is the last workitem of this process instance.
     *------------------------------------------------------------------------*/
    OPEN acin_cursor( prin_id_in );
    FETCH acin_cursor INTO acin_record;
    /*------------------------------------------------------------------------
     * If yes, perform some checks..
     *------------------------------------------------------------------------*/
    IF acin_cursor%NOTFOUND THEN
        /*--------------------------------------------------------------------
         * IF there where no transitions originating from this activity in the
         * process model, THEN this is the last activity, so also complete the
         * process instance.
         * If there was a transition, then that activity is already completed
         * and has finished the process already.
         *--------------------------------------------------------------------*/
        IF NOT to_transition_found_in
        OR ( NOT transition_done_in AND no_conditions_complete_process )
        THEN
            log( 'Process instance '||prin_id_in ||' completed because no to-transitions found for workitem or transitions found, but none valid and package variable no_conditions_complete_process = TRUE' );
            SELECT acin_id INTO l_parent_acin_id
            FROM   wf_process_instances
            WHERE  id = prin_id_in
            ;
            log ('Subflow of: ' || l_parent_acin_id);
            /*----------------------------------------------------------------
             * Mark the process instance as COMPLETED
             * if it was not already CLOSED
             *----------------------------------------------------------------*/
            UPDATE wf_process_instances
            SET    state      = 'COMPLETED'
            ,      date_ended = SYSDATE
            WHERE  id         = prin_id_in
            AND    state NOT LIKE 'ABORTED'
            AND    state NOT LIKE 'TERMINATED'
            ;
            /*----------------------------------------------------------------
             * This proces and all its subflows are moved to archive, but
             * only if the entire process and all subflows have completed.
             * So if this is not the top proces, the process is not moved 
             * to archive. However, the process is cleaned of unimportant 
             * attributes in any case.
             *----------------------------------------------------------------*/
            /*----------------------------------------------------------------
             * Was this process instance a SYCHR subprocess?
             * If the subflow execution was asynchronous, there is nothing to be
             * done anymore (there are more comments in the instantiate_
             * activity_instance procedure).
             * However if the subflow execution was synchronous, the super 
             * activity has to be completed.
             *----------------------------------------------------------------*/
            IF l_parent_acin_id IS NOT NULL  --> IMPLIES SYNCHR
            THEN
                SELECT acti.subflow_execution
                ,      acti.id
                ,      acti.prce_id
                ,      acin.state
                ,      acin.prin_id
                INTO   l_subflow_execution
                ,      l_parent_acti_id
                ,      l_parent_prce_id
                ,      l_state_of_parent_activity
                ,      l_parent_prin_id
                FROM   wf_activity_instances acin
                ,      wf_activities         acti
                WHERE  acin.acti_id      = acti.id
                AND    acin.acti_prce_id = acti.prce_id
                AND    acin.id           = l_parent_acin_id;
                log ('SYNCHR = ' || l_state_of_parent_activity);
                /*------------------------------------------------------------
                 * return 'OUT' parameters of this process instance
                 *------------------------------------------------------------*/
                FOR outparm_record IN outparm_cursor( prin_id_in => prin_id_in  -- THIS process instance (subprocess)
                                                    , prce_id_in => l_parent_prce_id
                                                    , acti_id_in => l_parent_acti_id)
                LOOP
                    -- set value
                    log( 'Put outparm from finished subproces in: prin_id '  ||
                      l_parent_prin_id || ' name ' || outparm_record.cpaname ||
                      ' value ' || outparm_record.result );
                    AssignProcessInstanceAttribute (
                        prin_id_in  => l_parent_prin_id,        -- CALLING prin
                        name_in     => outparm_record.cpaname,
                        value_in    => outparm_record.result
                    );
                END LOOP;
                /*------------------------------------------------------------
                 * Clean unimportant variables, but do not move to archive (yet)
                 *------------------------------------------------------------*/
                clean_process_instance( prin_id_in=>prin_id_in );
                /*------------------------------------------------------------
                 * Only if the parent activity is still SUSPENDED
                 * (and not aborted or terminated)
                 *------------------------------------------------------------*/
                IF l_state_of_parent_activity = 'SUSPENDED'
                THEN
                    /*--------------------------------------------------------
                     * then resume and then complete it.
                     *--------------------------------------------------------*/
                    pl_flow.ChangeActivityInstanceState(
                          acin_id_in    =>  l_parent_acin_id,
                          state_in      =>  'RUNNING',
                          pati_id_in    =>  pl_flow_participant );
                    pl_flow.ChangeActivityInstanceState(
                          acin_id_in    =>  l_parent_acin_id,
                          state_in      =>  'COMPLETED',
                          pati_id_in    =>  pl_flow_participant );
                END IF; --if suspended
            ELSE
                /*------------------------------------------------------------
                 * Top process. Clean unimportant variables and move process 
                 * and all subflows to archive
                 *------------------------------------------------------------*/
                clean_process_instance( prin_id_in=>prin_id_in );
                move_to_archive(prin_id_in => prin_id_in);
            END IF; -- if synchr subflow
        END IF; --no to-transition
        /*--------------------------------------------------------------------
         * If transitions found, but no condition was met, issue a warning?
         *--------------------------------------------------------------------*/
        IF to_transition_found_in
        AND NOT transition_done_in
        AND NOT no_conditions_complete_process
        THEN
            RAISE_APPLICATION_ERROR( -20140,
                'pl_flow.ChangeActivityInstanceState: Possible transitions exists but no condition was met. Error in application? If not, set PL_FLOW.no_conditions_complete_process  to TRUE.' );
        END IF; -- to transition found?

    END IF; -- no other workitems?
    CLOSE acin_cursor;

END last_activity_checks;

/*
||==========================================================================
|| CreateProcessInstance - Create an instance of a previously defined process.
||
|| DESCRIPTION
|| The instantiation of the process is separated from starting it. This may
|| seem a bit odd, why instantiate before starting the process instance?
|| One scenario is that the first activity is runned automatically (a plsql
|| job) and needs an attribute as parameter. (e.g. mail adress)
|| The attribute has te be assigned to a process instance, before the process
|| (and the first automatic activity) is started.
||
|| Exceptions:  invalid_process_definition
||==========================================================================
*/
PROCEDURE CreateProcessInstance
(   prce_id_in IN wf_processes.id%TYPE
,   prin_id_in IN wf_process_instances.id%TYPE )
IS

    CURSOR attribute_cursor( prce_id_in IN wf_processes.id%TYPE )
        IS
    SELECT id, prce_id, name, length, initial_value, keep
      FROM wf_attributes
     WHERE prce_id=prce_id_in
       AND initial_value IS NOT NULL;

    attribute_record    attribute_cursor%ROWTYPE;

BEGIN
    /*------------------------------------------------------------------------
     * Create a new process instance.
     *------------------------------------------------------------------------*/
    INSERT INTO wf_process_instances(
            id,
            prce_id,
            pati_id,
            date_created,
            date_started,
            date_ended,
            state,
            remarks )
        VALUES (
            prin_id_in,
            prce_id_in,
            NULL,
            SYSDATE,
            NULL,
            NULL,
            'NOTSTARTED',
            NULL );
    /*------------------------------------------------------------------------
     * Create attribute instances with default values
     *------------------------------------------------------------------------*/
    FOR attribute_record IN attribute_cursor( prce_id_in=>prce_id_in )
    LOOP
        AssignProcessInstanceAttribute (
            prin_id_in  =>prin_id_in,
            name_in     =>attribute_record.name,
            value_in    =>attribute_record.initial_value
        );
    END LOOP;
/*--------------------------------------------------------------------------
 * Exception given
 *--------------------------------------------------------------------------
 * When inserting with a parent that does not exist, oracle gives the error
 * ORA-02291: integrity constraint parent key not found.
 * This is always an error of the application programmer, so we won't make it look nice.
 *--------------------------------------------------------------------------*/
--  invalid_operation EXCEPTION;  -- Operation is invalid
--  invalid_operation_errcode CONSTANT PLS_INTEGER:= -20000;
--  PRAGMA EXCEPTION_INIT(invalid_operation, -20000);
--EXCEPTION
--    WHEN OTHERS THEN            -- most likely always parent key doesn't exist.
--        ROLLBACK;           -- just raise this to the application programmers.
--        RAISE;              -- raise same error to app.
END CreateProcessInstance;

/*
||==========================================================================
|| StartProcess - Start the previously created process instance.
||
||
|| DESCRIPTION  Assign participant to the process instance
||      Set the start date to sysdate
||      Instantiate start activity(s)
||
|| Exceptions:  invalid_process_instance    (ora no data found)
||      invalid participant     (ora parent key not found)
||      cannot start process more than once
||      no activities to start
||==========================================================================
*/
PROCEDURE StartProcess
(   prin_id_in IN wf_process_instances.id%TYPE
,   pati_id_in IN wf_participants.id%TYPE
)
IS
    current_state   wf_process_instances.state%TYPE;
    prce_id         wf_processes.id%TYPE;
    /*------------------------------------------------------------------------
     * Cursor to fetch start activities (the ones without a to-transition)
     * Or the one with the lowest number.
     *------------------------------------------------------------------------*/
    CURSOR activity_cursor( prce_id_in IN wf_processes.id%TYPE )
    IS
        SELECT a.id AS acti_id
          FROM wf_activities a
         WHERE a.prce_id = prce_id_in                   -- from this process
           AND NOT EXISTS (
                SELECT 1
                  FROM wf_transitions t
                 WHERE t.acti_prce_id_to = prce_id_in   -- process part of activity primary key
                   AND t.acti_id_to = a.id              -- activity part of activity primary key
                          );

    /*------------------------------------------------------------------------
     * Or the one with the lowest number used when above query returns no results.
     *------------------------------------------------------------------------*/
    CURSOR activity_cursor_2( prce_id_in IN wf_processes.id%TYPE )
    IS
        SELECT min(a.id) AS acti_id
          FROM wf_activities a
         WHERE a.prce_id = prce_id_in;                   -- from this process

    activity_record activity_cursor%ROWTYPE;

    record_found    BOOLEAN DEFAULT FALSE;
BEGIN
    /*------------------------------------------------------------------------
     * Does the process instance exist? (implicit no data found)
     *------------------------------------------------------------------------*/
    SELECT state
      INTO current_state
      FROM wf_process_instances
     WHERE id = prin_id_in;
    /*------------------------------------------------------------------------
     * Is it not started yet?
     *------------------------------------------------------------------------*/
    IF current_state <> 'NOTSTARTED'
    THEN
        RAISE_APPLICATION_ERROR( -20010,
        'pl_flow.StartProcess: Cannot start a process more than one time.' );
    END IF;
    /*------------------------------------------------------------------------
     * Create a new process instance
     * (while at it, return the process instance id for activity instantiation.)
     *------------------------------------------------------------------------*/
       UPDATE wf_process_instances
          SET state = 'RUNNING',
              date_started = SYSDATE,
              pati_id = pati_id_in
        WHERE id = prin_id_in
    RETURNING prce_id INTO prce_id; -- parameter for cursor below
    /*------------------------------------------------------------------------
     * Instantiate start activities
     *------------------------------------------------------------------------*/
    FOR activity_record IN activity_cursor( prce_id )
    LOOP
        create_activity_instance( prin_id_in, prce_id, activity_record.acti_id );
        record_found := TRUE;
    END LOOP;
    /*------------------------------------------------------------------------
     * When there are no records found, pick the lowest activity number for the start activity.
     *------------------------------------------------------------------------*/
    IF NOT record_found THEN
        FOR activity_record IN activity_cursor_2( prce_id )
        LOOP
            create_activity_instance( prin_id_in, prce_id, activity_record.acti_id );
            record_found := TRUE;
        END LOOP;
        /*--------------------------------------------------------------------
         * When still no start activities are found, then there are no activities in the proces definition!
         *--------------------------------------------------------------------*/
        IF NOT record_found THEN
            RAISE_APPLICATION_ERROR( -20011, 'pl_flow.StartProcess: no activities to start. (bug in model?)' );
        END IF;
    END IF;
/*--------------------------------------------------------------------------
 * Exception given
 *--------------------------------------------------------------------------
 * ORA-02291: integrity constraint parent key not found -> invalid participant
 * This is always an error of the application programmer, so we won't make it look nice.
 *--------------------------------------------------------------------------*/
--  invalid_process_definition EXCEPTION;
--  PRAGMA EXCEPTION_INIT ( invalid_participant, -2291 );
--EXCEPTION
--    WHEN OTHERS
--    THEN
--        ROLLBACK;
--        RAISE;              -- raise same error to app.

END StartProcess;       -- responsible (human) participant;

/*
||==========================================================================
|| ChangeProcessInstanceState - Changes the state of the named process instance.
||
|| DESCRIPTION
||
|| States are: notstarted, running, suspended, completed, terminated, aborted
||
|| Allowed states for the parameter are: running, suspended, terminated, aborted.
||
|| So, actually the semantics of this procedure is the composite of:
||  suspendprocessinstance,
||  resumeprocessinstance,
||  terminateprocessinstance,
||  abortprocessinstance
||
|| Starting a process instance for the first time should be done with
|| startprocessinstance.
||
|| Exceptions:  invalid_process_instance
||      invalid_state
||      state_transition_not_allowed
||==========================================================================
*/
PROCEDURE ChangeProcessInstanceState
(   prin_id_in IN wf_process_instances.id%TYPE
,   state_in IN wf_process_instances.state%TYPE )
IS
    current_state       wf_process_instances.state%TYPE;

    /*************************************************************************
     * Resume sub procedure
     *************************************************************************/
    PROCEDURE prin_resume IS
    BEGIN
        /*--------------------------------------------------------------------
         * Resume a suspended process instance. (do we want some sort of
         * logging in remarks here?)
         *--------------------------------------------------------------------*/
        UPDATE wf_process_instances
           SET state = state_in
         WHERE id = prin_id_in;
    END;

    /***************************************************************************
     * Suspend sub procedure
     ***************************************************************************/
    PROCEDURE prin_suspend IS
    BEGIN
        UPDATE wf_process_instances
           SET state = state_in
         WHERE id = prin_id_in;
    END;

    /***************************************************************************
     * Terminate sub procedure
     ***************************************************************************/
    PROCEDURE prin_terminate IS
        -- cursor to get notrunning workitems
        CURSOR workitem_cursor( prin_id_in  IN  wf_processes.id%TYPE )
        IS
          SELECT *
          FROM   wf_activity_instances
          WHERE  prin_id = prin_id_in
          AND    state IN ('NOTRUNNING', 'CREATED')
          ;
        workitem_record workitem_cursor%ROWTYPE;
    BEGIN
        /*--------------------------------------------------------------------
         * Note that termination simply marks the process instance as
         * terminated. Running or suspended activity instances are not touched
         * and remain active until the changeactivityinstance procedure is
         * called and will notice the process instance is flagged for
         * termination.
         *--------------------------------------------------------------------*/
        UPDATE wf_process_instances
           SET state = state_in
         WHERE id = prin_id_in;
        /*--------------------------------------------------------------------
         * The 'NOTRUNNING' workitems can be TERMINATED immediately
         *--------------------------------------------------------------------*/
        FOR workitem_record IN workitem_cursor( prin_id_in )
        LOOP
            ChangeActivityInstanceState( workitem_record.id, 'TERMINATED', 1 );
        END LOOP;
        /*--------------------------------------------------------------------
         * no need to archive (last-activity_checks): this is done by
         * changeActivityInstanceState of the notrunning
         * (or later by the still open) workitems. There are open workitems,
         * otherwise this function wasn't called
         *--------------------------------------------------------------------*/
    END;

    /**************************************************************************
     * Abort sub procedure
     **************************************************************************/
    PROCEDURE prin_abort IS
        CURSOR acin_cursor (prin_id_in IN wf_process_instances.id%TYPE)
        IS
            SELECT id
            FROM   wf_activity_instances
            WHERE  prin_id = prin_id_in
            ;
        acin_row acin_cursor%ROWTYPE;
    BEGIN
        /*--------------------------------------------------------------------------
         * Abort the process instance
         *--------------------------------------------------------------------------*/
        UPDATE wf_process_instances
        SET    state = state_in
        WHERE  id    = prin_id_in
        ;
        /*--------------------------------------------------------------------
         * Abort also aborts al open activity instances immediately.
         * prevent string concatenation too long by trimming the longest part
         *--------------------------------------------------------------------*/
        UPDATE wf_activity_instances
        SET state         = state_in
        ,   session_state = EMPTY_BLOB()      -- delete the session state if there was one.
        ,   date_ended    = SYSDATE
        ,   remarks       = SUBSTRB(remarks, 1, 3850) || '<br>Aborted by abort on process instance on ' || TO_CHAR( SYSDATE, 'DD-MON-YYYY HH:MI:SS' )
        WHERE prin_id = prin_id_in
        ;

        FOR acin_row IN acin_cursor(prin_id_in => prin_id_in)
        LOOP
            /*----------------------------------------------------------------
             * If the activity has an open subprocess, abort it.
             *----------------------------------------------------------------*/
            FOR r IN (
                SELECT id FROM wf_process_instances
                 WHERE acin_id = acin_row.id
                 AND   state != 'COMPLETED'
                 AND   state != 'ABORTED'
                 AND   state != 'TERMINATED'
            )
            LOOP
                ChangeProcessInstanceState( r.id, 'ABORTED' );
            END LOOP;
        END LOOP;

        /*--------------------------------------------------------------------
         * Check if this is the last activity in the process and if yes,
         * complete the process instance and possible parent processes.
         *--------------------------------------------------------------------*/
        last_activity_checks(
            prin_id_in                =>    prin_id_in,
            to_transition_found_in    =>    FALSE,
            transition_done_in        =>    FALSE
        );
    END;

BEGIN   -- ChangeProcessInstanceState Parent procedure
    /*--------------------------------------------------------------------------
     * Get current record.
     *--------------------------------------------------------------------------*/
    SELECT state INTO current_state
    FROM   wf_process_instances
    WHERE  id = prin_id_in;
    /*--------------------------------------------------------------------------
     * Is transition allowed?
     * See wfmc spec (http://www.wfmc.org/standards/docs/if2v20.pdf) p168
     * for allowed transitions.
     *
     *  CURRENT     NEW state
     *
     *  suspended   running   } Currently not used / implemented.
     *  running     suspended } State only changes, nothing else.
     *  running     aborted
     *****  running ****    completed   (*** done by completing the last activity instance, not this procedure)
     *  running     terminated
     *  suspended   aborted
     *  suspended   terminated
     *  notstarted  aborted
     *  notstarted  terminated
     *****  notstarted **** running     (*** done by start_process, here it gives an error)
     *
     *  terminated  abort       (not wfmc standard, but needed to implemented the right semantics for abort)
     *
     *--------------------------------------------------------------------------*/
    IF current_state = 'SUSPENDED'     AND state_in = 'RUNNING'    THEN prin_resume();
    ELSIF current_state = 'RUNNING'    AND state_in = 'SUSPENDED'  THEN prin_suspend();
    ELSIF current_state = 'RUNNING'    AND state_in = 'ABORTED'    THEN prin_abort();
    ELSIF current_state = 'RUNNING'    AND state_in = 'TERMINATED' THEN prin_terminate();
    ELSIF current_state = 'SUSPENDED'  AND state_in = 'ABORTED'    THEN prin_abort();
    ELSIF current_state = 'SUSPENDED'  AND state_in = 'TERMINATED' THEN prin_terminate();
    ELSIF current_state = 'NOTSTARTED' AND state_in = 'ABORTED'    THEN prin_abort();
    ELSIF current_state = 'NOTSTARTED' AND state_in = 'TERMINATED' THEN prin_terminate();
    ELSIF current_state = 'TERMINATED' AND state_in = 'ABORTED'    THEN prin_abort();
    /*--------------------------------------------------------------------------
     * A special error message in this case
     *--------------------------------------------------------------------------*/
    ELSIF  current_state = 'NOTSTARTED' AND state_in = 'RUNNING'
    THEN    RAISE_APPLICATION_ERROR( -20020,
        'pl_flow.ChangeProcessInstanceState: Start a process instance with startprocess.' );
    /*--------------------------------------------------------------------------
     * Ignore some stuff
     *--------------------------------------------------------------------------*/
    ELSIF current_state = 'ABORTED' AND state_in = 'ABORTED'        THEN NULL;
    /*--------------------------------------------------------------------------
     * All other things are wrong.
     *--------------------------------------------------------------------------*/
    ELSE
        RAISE_APPLICATION_ERROR( -20021,
        'pl_flow.ChangeProcessInstanceState: Invalid transition: from ' || current_state || ' to ' || state_in || ' is not possible.' );
    END IF;
/*--------------------------------------------------------------------------
 * Exceptions
 *--------------------------------------------------------------------------*/
/***EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;       -- to what savepoint?
        RAISE;          -- same error to app. (because this is the app programmers mistake)
--  WHEN constraint_violation_on_update -- invalid state (welk nummer is dit?)
    WHEN OTHERS THEN
        ROLLBACK;
     RAISE;
***/

END ChangeProcessInstanceState;

/*
||==========================================================================
|| WMChangeActivityInstanceState - Changes the state of the named activity instance.
||
|| DESCRIPTION
||
|| States are: NOTRUNNING, RUNNING, SUSPENDED, COMPLETED, TERMINATED, ABORTED
||   and 'FAKED', 'CREATED' (internal state, indicating an acin that has not fired / has been simulated)
||
|| Allowed states for the parameter are: NOTRUNNING, RUNNING, SUSPENDED, TERMINATED, ABORTED and FAKED.
||
|| AN ACTIVITY INSTANCE CAN ONLY BE RETURNED TO THE NOTRUNNING STATE, WHEN THE APPLICATION
|| USER HAS NOT DONE ANYTHING YET. (CAN THIS BE CHECKED BY THE WORKFLOW ENGINE?)
||
|| This procedure is the composite of :
||  start activity instance,    (participant starts with work)
||  release activity instance,  (participant decides not to do something after it is assigned)
||  suspend activity instance,  (participant decides to put the job of till later)
||  resume activity instance,   (participant resumes a suspended job)
||  complete activity instance, (participant is ready with the job)
||  terminate activity instance,    (the job is terminated gently)
||  abort activity instance     (the job is aborted)
||
|| Exceptions:  invalid_process_instance -- not in this implementation.
||      invalid_activity_instance
||      invalid_state
||      state_transition_not_allowed
||==========================================================================
*/
PROCEDURE ChangeActivityInstanceState
--    prin_id_in  IN   wf_activity_instances.prin_id%TYPE, -- process instance is not primary key in this implementation.
(   acin_id_in  IN   wf_activity_instances.id%TYPE
,   state_in    IN   wf_activity_instances.state%TYPE
,   pati_id_in  IN   wf_participants.id%TYPE )
IS
    current_state      wf_activity_instances.state%TYPE;
    process_state      wf_process_instances.state%TYPE;
    new_state          wf_activity_instances.state%TYPE;
    pati_id_performer  wf_participants.id%TYPE                  DEFAULT NULL;

    l_is_proxy_of   INTEGER DEFAULT 0;                  -- for caching result of is_proxy_of function call
    l_dummy         INTEGER;                            -- dummy var for SQL select into construct
    l_pati_id       wf_activity_instances.pati_id%TYPE;
    l_pati_id_exclude  wf_activity_instances.pati_id_exclude%TYPE;

    /*------------------------------------------------------------------------
     * Cursor to get the current performer of an activity. Possible NULL.
     *------------------------------------------------------------------------*/
    CURSOR performer_cursor( acin_id_in IN wf_activity_instances.id%TYPE ) IS
        SELECT f.pati_id
        FROM   wf_performers  f
        WHERE  f.acin_id = acin_id_in      -- performers of the activity instance
        AND    f.state   ='CURRENT'          -- only the last performer
        AND    (f.accepted IS NULL OR f.accepted <> 'N')
    ;
    performer_record    performer_cursor%ROWTYPE;

    /*************************************************************************
     * Start- sub procedure
     *************************************************************************/
    PROCEDURE acin_start IS
        l_performer_id wf_performers.id%TYPE;
    BEGIN
        /*--------------------------------------------------------------------
         * Update the assigned performer record. (if present)
         * -assume that a participant only starts workitems that are not
         *  assigned or assigned to him or his role or the person he is proxy of
         *--------------------------------------------------------------------*/
        UPDATE wf_performers
        SET    accepted ='Y'
        WHERE  acin_id  = acin_id_in
        AND    state    = 'ASSIGNED'
        AND    accepted IS NULL
        ;
        IF SQL%ROWCOUNT <> 0 THEN
		log('SUB-PROCEDURE of ChangeActivityInstanceState::acin_start acin='||acin_id_in||' pati='||pati_id_in||' update set accepted flag where state is ASSIGNED');
		END IF;
        /*--------------------------------------------------------------------
         * If a proxy takes over, change the current perfomer
         *--------------------------------------------------------------------*/
        UPDATE wf_performers
        SET state = 'OVERTAKEN'
        WHERE acin_id = acin_id_in
        AND   pati_id != pati_id_in
        AND   state   = 'CURRENT'
        AND   (accepted IS NULL OR accepted='Y')
        RETURNING id INTO l_performer_id
        ;
        IF SQL%ROWCOUNT <> 0 THEN
		log('SUB-PROCEDURE of ChangeActivityInstanceState::acin_start acin='||acin_id_in||' pati='||pati_id_in||' update state to OVERTAKEN where state is CURRENT');
		END IF;
        /*--------------------------------------------------------------------
         * Create or update the performer record. (workitems assigned to humans
         * get a performer record at creation of the workitem)
         *--------------------------------------------------------------------*/
        UPDATE wf_performers
        SET    accepted='Y'
        ,      state = 'CURRENT'
        WHERE  acin_id = acin_id_in
        AND    state = 'CURRENT'
        AND    ( accepted IS NULL OR accepted = 'Y')
        AND    pati_id = pati_id_in
        ;
        IF SQL%ROWCOUNT <> 0 THEN
		log('SUB-PROCEDURE of ChangeActivityInstanceState::acin_start acin='||acin_id_in||' pati='||pati_id_in||' update state to CURRENT ');
		END IF;
        -- no record updated? Then create a performer record.
        IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO wf_performers(
                id,
                acin_id,        -- activity instance primary key
                pati_id,        -- assigned participant
                state,
                date_created,
                accepted,       -- does the participant accept this assignment? Only used at reassignment.
                remarks,
                pefo_id ) -- the performing of this job is delegated to another performer.
            VALUES (
                make_parallel( pefo_seq.NEXTVAL ),  -- see make_parallel
                acin_id_in,
                pati_id_in,     -- is null when acti.pati type is not human (i.e. one assigned person)
                'CURRENT',
                SYSDATE,
                'Y',            -- start activity implies accept
                NULL,           -- no remarks yet
                l_performer_id  ); -- no delegation at first start, but if overtaken, then use that performer.
        END IF;
        /*--------------------------------------------------------------------
         * Set state is running on the activity instance
         *--------------------------------------------------------------------*/
        UPDATE wf_activity_instances
        SET    state        = new_state
        ,      date_started = SYSDATE
        WHERE  id           = acin_id_in;

    END;
    /*************************************************************************
     * Release sub procedure
     *
     * Semantics of changing an activity instance to notrunning is releasing
     * the lock (of a participant) on the work-item. The activity instance will
     * then reappear (on refresh) on worklists.
     * This can be the case when someone decides not wanting a task, after
     * clicking on it on the worklist. (the application will need a button like
     * 'release and put back on worklist')
     *************************************************************************/
    PROCEDURE acin_release IS
        human_participant   wf_participants.id%TYPE;
        date_started_loc    wf_activity_instances.date_started%TYPE;
        l_pefo_id           wf_performers.id%TYPE;
    BEGIN
        /*--------------------------------------------------------------------
         * Get performer if human parcipant
         * (see create activity instance for the meaning of this.)
         *--------------------------------------------------------------------*/
        SELECT p.pati_id
        ,      i.date_started
        ,      p.id
        INTO   human_participant
        ,      date_started_loc
        ,      l_pefo_id
        FROM wf_activity_instances i
        ,    wf_performers p
        WHERE i.id = p.acin_id
        AND   p.state    = 'CURRENT'   -- only the current performer.
        AND   p.accepted = 'Y'
        AND   i.id       = acin_id_in
        ;
        /*--------------------------------------------------------------------
         * Change the current performer record into a record that the performer
         * has released it (for historical purposes only, the rest of the
         * wf engine will ignore 'RELEASED' performer records.).
         *--------------------------------------------------------------------*/
        UPDATE wf_performers
        SET   state = 'RELEASED'
        WHERE id    = l_pefo_id
        ;
        /*--------------------------------------------------------------------
         * Return activity instance to previous state.
         * IMPORTANT: The (former) performer is not deleted. So queries for the
         * worklist must not show the last performer, when the state is
         * 'NOTRUNNING'.
         * prevent string concatenation too long by trimming the longest part
         *--------------------------------------------------------------------*/
        UPDATE wf_activity_instances
           SET state = new_state,
               date_started = NULL,
               remarks = SUBSTRB( remarks, 1, 3700)
                    || '<br>Released by pati_id '
                    || pati_id_in
                    || ' on ' || TO_CHAR( SYSDATE, 'DD-MON-YYYY HH:MI:SS' )
                    || '<br>(originally started by pati_id '
                    || human_participant
                    || ' on ' || TO_CHAR( date_started_loc, 'DD-MON-YYYY HH:MI:SS' ) || ')'
         WHERE id = acin_id_in;
    END;
    /**************************************************************************
     * Suspend sub procedure
     **************************************************************************/
    PROCEDURE acin_suspend IS
    BEGIN
        /*--------------------------------------------------------------------
         * Suspend activity instance
         * prevent string concatenation too long by trimming the longest part
         *--------------------------------------------------------------------*/
        UPDATE wf_activity_instances
        SET    state   = new_state
        ,      remarks = SUBSTRB(remarks, 1, 3900) || '<br>Suspended on ' || TO_CHAR( SYSDATE, 'DD-MON-YYYY HH:MI:SS' )
        WHERE  id = acin_id_in;
    END;
    /***************************************************************************
     * Resume sub procedure
     ***************************************************************************/
    PROCEDURE acin_resume IS
        l_performer_id wf_performers.id%TYPE;
    BEGIN
        /*--------------------------------------------------------------------
         * Resume activity instance
         * prevent string concatenation too long by trimming the longest part
         *--------------------------------------------------------------------*/
        UPDATE wf_activity_instances
        SET    state         = new_state
        ,      session_state = EMPTY_BLOB()       -- delete the session_state
        ,      remarks       = SUBSTRB(remarks, 1, 3900)
               || '<br>Resumed on '
               || TO_CHAR( SYSDATE, 'DD-MON-YYYY HH:MI:SS' )
        WHERE  id            = acin_id_in;

        /*--------------------------------------------------------------------
         * If a proxy takes over, change the current perfomer
         *--------------------------------------------------------------------*/
        UPDATE wf_performers
        SET    state = 'OVERTAKEN'
        WHERE acin_id  = acin_id_in
        AND   pati_id != pati_id_in
        AND   state    = 'CURRENT'
        AND   (accepted IS NULL OR accepted = 'Y')
        RETURNING id INTO l_performer_id
        ;
        /*--------------------------------------------------------------------
         * Create or update the performer record. (when a proxy takes over, there is no record yet.)
         *--------------------------------------------------------------------*/
        UPDATE wf_performers
        SET    accepted = 'Y'
        ,      state    = 'CURRENT'
        WHERE  acin_id = acin_id_in
        AND    state = 'CURRENT'
        AND    (accepted IS NULL OR accepted = 'Y')
        AND    pati_id = pati_id_in
        ;
        -- no record updated? Then create a performer record.
        IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO wf_performers(
                id,
                acin_id,        -- activity instance primary key
                pati_id,        -- assigned participant
                state,
                date_created,
                accepted,       -- does the participant accept this assignment? Only used at reassignment.
                remarks,
                pefo_id ) -- the performing of this job is delegated to another performer.
            VALUES (
                make_parallel( pefo_seq.NEXTVAL ),  -- see make_parallel
                acin_id_in,
                pati_id_in,     -- is null when acti.pati type is not human (i.e. one assigned person)
                'CURRENT',
                SYSDATE,
                'Y',            -- start activity implies accept
                NULL,           -- no remarks yet
                l_performer_id  );        -- no delegation at first start, but kind of delegation on takeover by proxy
        END IF;
    END acin_resume;

    /**************************************************************************
     * Complete sub procedure;
     * Note the difference between actions on the model and the instance.
     * On completion, all arcs that satisfy their conditions are created, as
     * well as the activity instances they are connected to (if they have not
     * been created previously). An activity instance that has instances of every
     * incoming transition is executed.
     * For conditional AND (joins) it is necessary that it knows how many threads
     * have to be synchronized. For this purpose, fake transition instances are
     * created. If an activity instance only has fake incoming transitions, the
     * activity instance is faked as well.
     **************************************************************************/
    PROCEDURE acin_complete
    (    acin_id_in IN wf_activity_instances.id%TYPE
    ,    state_in   IN wf_activity_instances.state%TYPE
    )
    IS
        TYPE weak_curtype IS REF CURSOR;
        /*--------------------------------------------------------------------
         * Cursor to fetch conditions
         *--------------------------------------------------------------------*/
        condition_cursor weak_curtype;
        CURSOR condition_type_cursor
        IS
            SELECT 1 AS yesno FROM DUAL;
        condition_record condition_type_cursor%ROWTYPE;

        /*--------------------------------------------------------------------
         * Cursor to fetch to-transitions
         *--------------------------------------------------------------------*/
        CURSOR transitions_out_cursor(
            prce_id_in IN wf_processes.id%TYPE
        ,   acti_id_in IN wf_activities.id%TYPE )
        IS
            SELECT t.acti_id_to
            ,      t.condition
            ,      t.condition_type
            ,      DECODE(condition, 'OTHERWISE', 1, 0 )  AS otherwise_order_last -- 1 is bigger than 0, otherwise's are last. (see order by)
            FROM   wf_transitions t
            WHERE t.acti_prce_id_from = prce_id_in
            AND   t.acti_id_from      = acti_id_in
            AND   (t.condition_type   IS NULL or t.condition_type != 'EXCEPTION')
            ORDER BY otherwise_order_last
            ;

        /* -------------------------------------------------------------------
         * cursor that finds all incoming transitions from a specific activity.
         * Used to check if an activity instance can be used as target for a
         * transition instance.
         *--------------------------------------------------------------------*/
        CURSOR trin_in_from_acti_cursor (
            prce_id_in      IN wf_processes.id%TYPE
        ,   acti_id_to_in   IN wf_activities.id%TYPE
        ,   acti_id_from_in IN wf_activities.id%TYPE
        ,   acin_id_to_in   IN wf_activity_instances.id%TYPE
        )
        IS
            SELECT trin.acin_id_from
            ,      trin.acin_id_to
            FROM   wf_transition_instances trin
            WHERE acin_id_to             = acin_id_to_in
            AND   trsi_acti_prce_id_from = prce_id_in
            AND   trsi_acti_prce_id_to   = prce_id_in
            AND   trsi_acti_id_from      = acti_id_from_in
            AND   trsi_acti_id_to        = acti_id_to_in
            ;
        trin_in_from_acti_record  trin_in_from_acti_cursor%ROWTYPE;

        /*--------------------------------------------------------------------
         * cursor that gets all incoming transitions and transition instances
         * for an activity instance. Used to see if all incoming threads of an
         * AND-join are finished.
         *--------------------------------------------------------------------*/
        CURSOR valid_transitions_in_cursor(
            acin_id_to_in   wf_transition_instances.acin_id_to%TYPE
        ,   acti_id_to_in   wf_transitions.acti_id_to%TYPE
        ,   prce_id_in      wf_transition_instances.trsi_acti_prce_id_from%TYPE)
        IS
            SELECT trin.*
            FROM wf_transitions          trsi
            ,    wf_transition_instances trin
            WHERE trsi.acti_prce_id_to       = prce_id_in
            AND   trsi.acti_id_to            = acti_id_to_in
            AND   (trsi.condition_type   IS NULL or trsi.condition_type != 'EXCEPTION')
            AND   trin.acin_id_to               (+) = acin_id_to_in
            AND   trin.trsi_acti_id_from        (+) = trsi.acti_id_from
            AND   trin.trsi_acti_id_to          (+) = trsi.acti_id_to
            AND   trin.trsi_acti_prce_id_from   (+) = trsi.acti_prce_id_from
            AND   trin.trsi_acti_prce_id_to     (+) = trsi.acti_prce_id_to
            ;

        /* ------------------------------------------------------------------
         * Cursor that selects all created transition instances together with
         * the type of join
         * ------------------------------------------------------------------*/
        CURSOR valid_transitions_out_cursor (
            acin_id_from_in wf_transition_instances.acin_id_to%TYPE
        ,   acti_id_from_in wf_transitions.acti_id_from%TYPE
        ,   prce_id_in      wf_transition_instances.trsi_acti_prce_id_from%TYPE)
        IS
            SELECT trin.acin_id_to      acin_id_to
            ,      trin.trsi_acti_id_to acti_id_to
            ,      trin.negation_ind    negation_ind
            ,      acti.join            join
            FROM wf_transition_instances trin
            ,    wf_activities acti  --next activity
            WHERE acti.prce_id           = prce_id_in
            AND   acti.id                = trin.trsi_acti_id_to
            AND   trin.acin_id_from      = acin_id_from_in
            AND   trin.trsi_acti_id_from = acti_id_from_in
            ;

        /* ------------------------------------------------------------------
         * loops over the newly created transition_instances and
         * activity_instances to delete them.
         * ------------------------------------------------------------------*/
        CURSOR delete_transitions_out_cursor (
            acin_id_from_in wf_transition_instances.acin_id_to%TYPE )
        IS
            SELECT trin.*
            FROM  wf_transition_instances  trin
            ,     wf_transitions           trsi
            WHERE trin.acin_id_from      = acin_id_from_in
            AND   trsi.acti_id_from      = trin.trsi_acti_id_from
            AND   trsi.acti_prce_id_from = trin.trsi_acti_prce_id_from
            AND   trsi.acti_id_to        = trin.trsi_acti_id_to
            AND   trsi.acti_prce_id_to   = trin.trsi_acti_prce_id_to
            AND   (trsi.condition_type   IS NULL or trsi.condition_type != 'EXCEPTION') -- an asynchr. exception could already have been fired from this acin. Do not delete this transition_acin, we have not created it.
            FOR UPDATE
            ;

        /*--------------------------------------------------------------------
         * Finds all AND-join activity instances that wait for incoming threads
         * to finish
         *--------------------------------------------------------------------*/
        CURSOR acin_cursor(
            acti_id_in IN wf_activity_instances.id%TYPE
        ,   prin_id_in IN wf_activity_instances.prin_id%TYPE )
        IS
            SELECT acin.id AS acin_id
            ,      acin.acti_id
            FROM   wf_activity_instances acin
            WHERE  acti_id      = acti_id_in
            AND    prin_id      = prin_id_in
            AND    state        = 'NOTRUNNING'
            ;

        this_split             wf_activities.split%TYPE;
        this_acti_id           wf_activities.id%TYPE;
        this_prce_id           wf_processes.id%TYPE;
        this_prin_id           wf_process_instances.id%TYPE;
        this_negation_ind      wf_activity_instances.negation_ind%TYPE;

        condition_evaluation   BOOLEAN DEFAULT FALSE; --can this transition be fired?
        has_real_transition    BOOLEAN DEFAULT FALSE; --Is there a real transition from this acin? (If not, we should stop and not make fake transitions)
        has_valid_transition   BOOLEAN DEFAULT FALSE; --Is there a transition that evaluated to true? (If so, do not create another when XOR).
        fire_acin              BOOLEAN DEFAULT TRUE;  --can this activity_instance be started? (depends on other transitions_in and if acin is faked.)
        transition_done        BOOLEAN DEFAULT FALSE; -- is true after a transition is done. Used for last_activity_checks
        new_acin_id_to         wf_activity_instances.id%TYPE; --the acin with which the transition instance should connect
        transition_negation_ind wf_transition_instances.negation_ind%TYPE; --is the transition a real transition ('N') or a fake one ('Y')?
        acin_negation_ind       wf_transition_instances.negation_ind%TYPE; --is the activity instance normal ('N') or is it faked ('Y')?
        l_number_of_conditions PLS_INTEGER;
        to_transition_found    PLS_INTEGER DEFAULT 0; -- used to determine whether this is the last activity in the process, and to check if an AND-split has multiple transitions.

    BEGIN
        /*-------------------------------------------------------------------
         * Complete this activity instance.
         * prevent string concatenation too long by trimming the longest part
         *--------------------------------------------------------------------*/
        UPDATE wf_activity_instances
        SET state = state_in
        ,   session_state = EMPTY_BLOB()       -- delete the session_state
        ,   date_ended = SYSDATE
        ,   remarks = SUBSTRB(remarks, 1, 3900)
            || 'Completed on '
            || TO_CHAR( SYSDATE, 'DD-MON-YYYY HH:MI:SS' )
        WHERE id = acin_id_in;
        /*--------------------------------------------------------------------
         * Get the model of this activity (split, prce_id, acti_id, prin_id) -
         *--------------------------------------------------------------------*/
        SELECT    split
        ,         acti_id
        ,         prce_id
        ,         prin_id
        ,         negation_ind
        INTO this_split
        ,    this_acti_id
        ,    this_prce_id
        ,    this_prin_id
        ,    this_negation_ind
        FROM  wf_activities         a
        ,     wf_activity_instances i
        WHERE a.id      = i.acti_id
        AND   a.prce_id = i.acti_prce_id
        AND   i.id      = acin_id_in
        ;
        --RAO log('Acin ' || acin_id_in || ' of (' || this_prce_id || ' ' || this_acti_id || ') has completed. Checking transitions out...');
        log('proc='||this_prce_id||'/'||this_prin_id||' acti='||this_acti_id||'/'||acin_id_in|| ' completed. Checking transitions ...');
        /*--------------------------------------------------------------------
         * Loop through all to-activities from this activity instance.
         *--------------------------------------------------------------------*/
        FOR transition_out_record IN transitions_out_cursor(this_prce_id, this_acti_id)
        LOOP
            to_transition_found := to_transition_found + 1; --also used for last_activity_check
            /*----------------------------------------------------------------
             * When multiple to-transitions found, the split type of this
             * activity may not be NULL
             *----------------------------------------------------------------*/
            IF to_transition_found > 1
            AND this_split IS NULL
            THEN
                RAISE_APPLICATION_ERROR( -20030,
                    'pl_flow.acin_complete: Error: there is more than one outgoing transition of activity '
                        || this_prce_id || ' ' || this_acti_id || ' but the split type is NULL. It should be ''AND'' or ''XOR''.' );
            END IF;

            /*----------------------------------------------------------------
             * Check condition(s). Fire the transition if the condition(s)
             * evaluate to TRUE
             *----------------------------------------------------------------*/
            condition_evaluation := FALSE; --initialize after loop

            IF this_negation_ind = 'Y'
            THEN
                /* -----------------------------------------------------------
                 * Wen this activity instance was faked, we have to
                 * continue the faking, so every condition evaluates to a
                 * 'TRUE'
                 *------------------------------------------------------------*/
                condition_evaluation := TRUE;
                log('faked transition ' || this_acti_id || '-' || transition_out_record.acti_id_to || ' evaluates to true');
            ELSIF transition_out_record.condition IS NULL
            THEN
                /*------------------------------------------------------------
                 * 'No condition' evaluates to true.
                 *------------------------------------------------------------*/
                condition_evaluation := TRUE;
                log('transition ' || this_acti_id || '-' || transition_out_record.acti_id_to || ' with no condition evaluates to true');
            ELSIF transition_out_record.condition_type = 'CONDITION'
            THEN
                IF transition_out_record.condition = 'OTHERWISE'
                THEN
                    /*--------------------------------------------------------
                     * Otherwise..->fire condition if all other conditions
                     * failed.
                     * [condition = OTHERWISE means that the other transitions
                     *  already have been checked, because of sorting of
                     *  transition cursor. So if the other ones are not valid,
                     * this transition becomes valid.]
                     *--------------------------------------------------------*/
                    IF has_valid_transition = FALSE
                    THEN
                        condition_evaluation := TRUE;
                        log('otherwise transition ' || this_acti_id || '-' || transition_out_record.acti_id_to || ' evaluates to true');
                    END IF;
                ELSE -- transition_out_record.condition <> 'OTHERWISE'
                    /*--------------------------------------------------------
                     * A condition with part of an SQL expression. This needs
                     * to be queried to determine whether the transition
                     * should be fired.
                     *--------------------------------------------------------*/
                    /*--------------------------------------------------------
                     * When there are multiple conditions in the condition
                     * (check by number of OR's found in the condition string),
                     * then each of these conditions must be true.
                     * ->the sum of yesno must be equal to (the nr of OR's+1)
                     *   SELECT  sum(yesno), count(*), min(yesno) from
                     *   ( SELECT 1 as yesno
                     *     FROM wf_attributes a, wf_attribute_instances i
                     *     WHERE i.atri_id = a.id
                     *     and   PRIN_ID=1
                     *     AND (
                     *        a.name='APPROVED' and i.value='Y'
                     *     OR a.name='HAPPY' and i.value='N' )
                     *   )
                     *--------------------------------------------------------*/
                    l_number_of_conditions :=
                        LENGTH( transition_out_record.condition ) -
                        LENGTH( REPLACE( UPPER(transition_out_record.condition), ' OR ', '123' ) )
                        + 1; -- By counting the difference in string-length of the string with ' OR ' (4 chars) replaced by 3 chars, you know how many ' OR 's have been replaced
                    l_sql := 'SELECT SUM(yesno) FROM (
                               SELECT 1 AS yesno
                               FROM  wf_attributes a, wf_attribute_instances i
                               WHERE i.atri_id = a.id
                               AND   i.prin_id = :prin_id
                               AND   (' || transition_out_record.condition || ') )';
                    log( 'About to execute query for validation transition condition ''' || l_sql || ''' using prin_id = ' || this_prin_id );
                    OPEN condition_cursor FOR
                        l_sql
                        USING this_prin_id;    -- yh 2002 03 07: important: check in this process id.
                    FETCH condition_cursor INTO condition_record;
                    /*--------------------------------------------------------
                     * If true, then create the activity instance.
                     *--------------------------------------------------------*/
                    IF condition_cursor%FOUND THEN
                        log( 'Number of conditions: ' || l_number_of_conditions || ', number of conditions found true: ' || NVL(condition_record.yesno, 0) );
                        IF condition_record.yesno >= l_number_of_conditions THEN         -- if all conditions returned a record in the previous query..
                            condition_evaluation := TRUE;
                        END IF;
                    END IF;
                    CLOSE condition_cursor;
                END IF; --IF condition OTHERWISE
            ELSE
                RAISE_APPLICATION_ERROR( -20031, 'pl_flow.acin_complete(): Unknown transition condition type ' || transition_out_record.condition_type || ' and condition ' || transition_out_record.condition );
            END IF; --IF condition_type

            /* ---------------------------------------------------------------
             * Fire the transition and create a new transition instance
             * ---------------------------------------------------------------*/
            IF this_split = 'AND'
            OR condition_evaluation = TRUE
            THEN
                /* -----------------------------------------------------------
                 * create the arc and the acin it is connecting to.
                 * If the condition returned false, but the split is an
                 * AND-split, create fake arcs / transitions for the
                 * AND-join to synchronize on
                 * -----------------------------------------------------------*/

                /*------------------------------------------------------------
                 * If split type is XOR, the transition is fired exclusively;
                 * the first matching transition will be chosen.
                 *------------------------------------------------------------*/
                IF this_split = 'XOR' AND has_valid_transition = TRUE
                THEN
                    IF this_negation_ind = 'Y'
                    THEN
                        /* ---------------------------------------------------
                         * If faked, then just pick one of the XORs. There has
                         * to be another transition (otherwise no XOR), but
                         * that one will always evaluate to TRUE. This is not an
                         * error in the process definition, so don't mail.
                         * ---------------------------------------------------*/
                        NULL;
                    ELSE
                        /* ---------------------------------------------------
                         * a real error in the process definition: multiple
                         * conditions evaluate to TRUE
                         * ---------------------------------------------------*/
                         send_mail(  sender_name_in      => 'PL/FLOW',
                                    sender_email_in     => def_sender_email,
                                    recipient_name_in   => '',
                                    recipient_email_in  => mail_errors_to,
                                    subject_in          => 'PL/FLOW runtime error',
                                    body_in             => 'On completion of activity instance ' || acin_id_in || ' more than one transition matched the XOR split type'
                                 );
                    END IF; -- faked
                    /* Do not create more transition instances */
                    log('XOR has already fired. Skipping transition ' || this_acti_id || '-' || transition_out_record.acti_id_to);
                    EXIT;

                END IF; --this split = 'XOR' AND transition already done

                new_acin_id_to := NULL;
                /* -----------------------------------------------------------
                 * check if there is already an activity instance to connect
                 * the transition instance to (if target is AND-join, other
                 * transitions could have created the acin already).
                 * An activity can have multiple instances within a process
                 * instance due to loops. If the activity instance found
                 * already has an arc from the current activity, the acin
                 * cannot be used (it is already used by another loop)
                 *------------------------------------------------------------*/
                FOR acin_record IN acin_cursor (
                    acti_id_in => transition_out_record.acti_id_to
                ,   prin_id_in => this_prin_id
                )
                LOOP
                    OPEN trin_in_from_acti_cursor(
                          prce_id_in      => this_prce_id
                        , acti_id_to_in   => acin_record.acti_id
                        , acti_id_from_in => this_acti_id
                        , acin_id_to_in   => acin_record.acin_id
                    );
                    FETCH trin_in_from_acti_cursor
                    INTO  trin_in_from_acti_record
                    ;
                    IF trin_in_from_acti_cursor%NOTFOUND --not already connected
                    THEN
                        /*----------------------------------------------------
                         * use this activity instance
                         * ---------------------------------------------------*/
                        new_acin_id_to := acin_record.acin_id;
                        log('using target acin with id '|| new_acin_id_to);
                        CLOSE trin_in_from_acti_cursor;
                        EXIT;
                    END IF;
                    CLOSE trin_in_from_acti_cursor;
                END LOOP;
                IF new_acin_id_to IS NULL THEN
                    /*--------------------------------------------------------
                     * If there is no acin yet to connect the trin to,
                     * pre-create it.
                     * -------------------------------------------------------*/
                    INSERT INTO wf_activity_instances
                    (   id             -- activity instance primary key
                    ,   prin_id        -- process instance primary key
                    ,   acti_prce_id   -- process part of activity primary key
                    ,   acti_id        -- activity part of activity primary key
                    ,   date_created
                    ,   date_started
                    ,   date_ended
                    ,   deli_id
                    ,   date_due
                    ,   state
                    ,   remarks
                    ,   worklist_display
                    ,   session_state
                    ,   negation_ind
                    ) VALUES 
                    (   make_parallel( acin_seq.NEXTVAL )  -- see make_parallel
                    ,   this_prin_id
                    ,   this_prce_id
                    ,   transition_out_record.acti_id_to
                    ,   SYSDATE
                    ,   NULL
                    ,   NULL
                    ,   NULL
                    ,   NULL
                    ,   'PRE-CREATED'
                    ,   NULL
                    ,   NULL
                    ,   EMPTY_BLOB()
                    ,   this_negation_ind -- if this is a pre-creation on a fake thread, propagate the fakeness.
                    )
                    RETURNING id INTO new_acin_id_to;
                    log('created target acin with id '|| new_acin_id_to);
                END IF;

                /* -----------------------------------------------------------
                 * Create the transition instance
                 * -----------------------------------------------------------*/
                IF condition_evaluation = TRUE AND this_negation_ind = 'N'
                THEN
                    transition_negation_ind := 'N';
                    has_real_transition := TRUE;
                    --if activity instance was created previously as 'fake', now make it real.
                    --(otherwise cleanprocessinstance fails on abortprocess because there are real arcs connected to fake acins.)
                    UPDATE wf_activity_instances SET negation_ind = 'N' WHERE id = new_acin_id_to;
                ELSE
                    transition_negation_ind := 'Y';
                END IF;
                INSERT INTO wf_transition_instances (
                    trsi_acti_prce_id_from
                ,   trsi_acti_id_from
                ,   trsi_acti_prce_id_to
                ,   trsi_acti_id_to
                ,   acin_id_from
                ,   acin_id_to
                ,   negation_ind
                )
                VALUES (
                    this_prce_id
                ,   this_acti_id
                ,   this_prce_id
                ,   transition_out_record.acti_id_to
                ,   acin_id_in
                ,   new_acin_id_to
                ,   transition_negation_ind
                );
                /* -----------------------------------------------------------
                 * A transition has been created. IF this is an XOR split, it
                 * means that no other transitions are allowed.
                 * -----------------------------------------------------------*/
                has_valid_transition := TRUE;
                log('Created fake='||transition_negation_ind||' transition '||this_acti_id||'-'||transition_out_record.acti_id_to);
            END IF; --fire = true or type = split and not exception

        END LOOP;

        /* -------------------------------------------------------------------
         * Check if type corresponds with number of transitions out.
         * -------------------------------------------------------------------*/
        IF to_transition_found <= 1 AND this_split IS NOT NULL
        THEN
            send_mail(  sender_name_in      => 'PL/FLOW',
                        sender_email_in     => def_sender_email,
                        recipient_name_in   => '',
                        recipient_email_in  => mail_errors_to,
                        subject_in          => 'PL/FLOW runtime error',
                        body_in             => 'Not multiple transitions found from activity ' || this_prce_id || ' ' || this_acti_id || ' (instance ' || acin_id_in || '), but SPLIT type is defined as ' || this_split
            );
        END IF;

        /* -------------------------------------------------------------------
         * Activity instances and transitions have been initialized/created.
         * This has to happen before firing, otherwise the fired activity
         * instance could finish and think it was the last activity instance
         * and move all to archive, while this function still has to process
         * the other transitions
         *--------------------------------------------------------------------*/
        /* We should only fire all transition_instances/activity_instances, if
         * this acin was already faked, or if there is at least one real
         * transition. Otherwise we might end up in a loop faking
         * -------------------------------------------------------------------*/
        IF this_negation_ind = 'Y'
        OR has_real_transition = TRUE
        THEN
            FOR valid_transitions_out_record IN valid_transitions_out_cursor (
                acin_id_from_in => acin_id_in
            ,   acti_id_from_in => this_acti_id
            ,   prce_id_in      => this_prce_id)
            LOOP
                IF valid_transitions_out_record.join = 'XOR'
                OR valid_transitions_out_record.join IS NULL
                THEN
                    --XOR means: the first transition that evaluates to true is used.
                    --null means: this is the only transition. use it!
                    --A transition instance is present for sure
                    fire_acin := TRUE;
                    acin_negation_ind := valid_transitions_out_record.negation_ind;
                ELSE --AND-join
                    /* ------------------------------------------------------- 
                     * Check the acin if all transitions have an instance
                     * acin is faked when
                     *          all incoming transition instances are fake
                     *      OR  not all incoming transitions are present
                     * -------------------------------------------------------*/
                    acin_negation_ind := 'Y'; --start pessimistic
                    fire_acin := TRUE;  --acin should not be executed at all if not all trin are present
                    FOR valid_transition_in_record IN valid_transitions_in_cursor(
                        acin_id_to_in   => valid_transitions_out_record.acin_id_to
                    ,   acti_id_to_in   => valid_transitions_out_record.acti_id_to
                    ,   prce_id_in      => this_prce_id
                    )
                    LOOP
                        IF valid_transition_in_record.acin_id_to IS NULL
                        THEN --not all trin present, so do not fire acin!
                            fire_acin := FALSE;
                            acin_negation_ind := 'Y'; -- not all incoming transitions present?
                            EXIT;
                        END IF;
                        IF valid_transition_in_record.negation_ind = 'N'
                        THEN
                            acin_negation_ind := 'N';
                        END IF;
                    END LOOP;

                END IF; --join is xor or null or not.

                /* FIRE acin if all conditions met */
                IF fire_acin = TRUE
                THEN
                    IF acin_negation_ind = 'N'
                    THEN
                        -- Create the previously pre-created activity instance.
                        create_activity_instance(
                            prin_id_in => this_prin_id
                        ,   prce_id_in => this_prce_id
                        ,   acti_id_in => valid_transitions_out_record.acti_id_to
                        ,   acin_id_in => valid_transitions_out_record.acin_id_to
                        );
                    ELSE  --all transition_instances are faked
                        -- Fake thread, so continue walking fake thread.
                        -- Make state running and then complete.
                        UPDATE wf_activity_instances
                        SET state = 'RUNNING'
                        ,   negation_ind = 'Y'
                        WHERE id  = valid_transitions_out_record.acin_id_to
                        ;
                        ChangeActivityInstanceState(
                            acin_id_in => valid_transitions_out_record.acin_id_to
                        ,   state_in   => 'COMPLETED'
                        ,   pati_id_in => pl_flow_participant
                        );
                    END IF;
                    transition_done := TRUE;
                    log(' Fired acin '||valid_transitions_out_record.acin_id_to|| ' as fake:' ||acin_negation_ind);
                ELSE
                    --remove state=PRE-CREATED; we now know it has to be created, there are valid transitions.
                    --but beware of acin_negation_ind, this may still be Y!!
                    UPDATE wf_activity_instances
                    SET state = 'NOTRUNNING'
                    ,   negation_ind = acin_negation_ind
                    WHERE id  = valid_transitions_out_record.acin_id_to;
                    log(' acin '||valid_transitions_out_record.acin_id_to|| ' cannot fire (not all threads ready)');
                END IF;
            END LOOP;
        ELSE
            /* ---------------------------------------------------------------
             * It appears that there was no real transition starting from this
             * completed activity instance.
             * We should stop, and the faked arcs and pre-created acins should be
             * removed again.
             * ---------------------------------------------------------------*/
            log('No real and valid transitions starting from '||acin_id_in||'. Deleting transition instances and acins created');
            FOR delete_transition_out_record IN delete_transitions_out_cursor(
                acin_id_from_in => acin_id_in)
            LOOP
                new_acin_id_to := delete_transition_out_record.acin_id_to;

                --remove arc
                DELETE FROM wf_transition_instances
                WHERE CURRENT OF delete_transitions_out_cursor
                ;
                --remove acin
                BEGIN
                    DELETE FROM wf_activity_instances
                    WHERE id = new_acin_id_to;
                EXCEPTION  --if ref error, skip
                    WHEN OTHERS THEN
                        IF SQLCODE = -2292 AND INSTR(SQLERRM, 'TRIN_ACIN') > 0 --ORA-02292: integrity constraint (PVT_DWO.TRIA_ACIA_FK) violated - child record found
                        THEN
                            /* This acin was not created in this execution.
                             * Leave it untouched */
                            NULL;
                        ELSE
                            ROLLBACK;
                            RAISE;
                        END IF;
                END;
            END LOOP; --loop over transition instances out
        END IF; --has real transition
        /*--------------------------------------------------------------------
         * Check if this is the last activity in the process and if yes,
         * complete the process instance and possible parent processes.
         * NB: Nothing is done if a transition has been made. 
         *     The other acin will complete the process.
         *--------------------------------------------------------------------*/
        log( 'Checking if acin ' || acin_id_in || ' ('||this_prce_id || ' '
             ||this_acti_id || ') is the last acin of prin ' || this_prin_id);
        last_activity_checks(
            prin_id_in                =>    this_prin_id
        ,   to_transition_found_in    =>    (to_transition_found > 0)
        ,   transition_done_in        =>    transition_done
        );

    --EXCEPTION
    --    WHEN OTHERS THEN
    --        ROLLBACK;           -- rollback changes
    --        RAISE;              -- errors to caller
    END acin_complete;

    /**************************************************************************
     * Abort sub procedure
     **************************************************************************/
    PROCEDURE acin_abort
    (   acin_id_in  wf_activity_instances.id%TYPE
    ,   pati_id_in  wf_participants.id%TYPE
    ,   state_in    wf_activity_instances.state%TYPE
    )
    IS
        l_prin_id   wf_process_instances.id%type;
    BEGIN
        /*--------------------------------------------------------------------
         * Abort activity instance
         * prevent string concatenation too long by trimming the longest part
         *--------------------------------------------------------------------*/
        UPDATE wf_activity_instances
           SET state = state_in,
               session_state = EMPTY_BLOB(), -- delete the session state if there was one.
               date_ended = SYSDATE,
               remarks = SUBSTRB(remarks, 1, 3850)
                || '<br>Aborted by pati_id '
                || pati_id_in
                || ' on ' || TO_CHAR( SYSDATE, 'DD-MON-YYYY HH:MI:SS' )
         WHERE id = acin_id_in
         RETURNING prin_id INTO l_prin_id
         ;

        /*--------------------------------------------------------------------
         * If the activity has an open subprocess, abort it.
         *--------------------------------------------------------------------*/
        FOR r IN ( SELECT id FROM wf_process_instances
                   WHERE acin_id = acin_id_in
                   AND   state != 'COMPLETED'
                   AND   state != 'ABORTED'
                   AND   state != 'TERMINATED'
                 )
        LOOP
            ChangeProcessInstanceState( r.id, 'ABORTED' );
        END LOOP;
        log( 'Checking if acin ' || acin_id_in || ' is the last acin of prin ' || l_prin_id );
        last_activity_checks(
            prin_id_in                =>    l_prin_id,
            to_transition_found_in    =>    FALSE,
            transition_done_in        =>    FALSE
        );

    --EXCEPTION
    --    WHEN OTHERS THEN
    --        ROLLBACK;           -- rollback changes
    --        RAISE;              -- errors to caller
    END acin_abort;

    /***************************************************************************
     * Terminate sub procedure
     ***************************************************************************/
    PROCEDURE acin_terminate IS
        l_prin_id   wf_process_instances.id%type;
    BEGIN
        /*--------------------------------------------------------------------
         * Terminate activity instance
         * prevent string concatenation too long by trimming the longest part
         *--------------------------------------------------------------------*/
        UPDATE wf_activity_instances
           SET state = new_state,
               session_state = EMPTY_BLOB(),       -- delete the session_state
               date_ended = SYSDATE,
               remarks = SUBSTRB(remarks, 1, 3850)
                 || '<br>Terminated by pati_id '
                 || pati_id_in
                 || ' on ' || TO_CHAR( SYSDATE, 'DD-MON-YYYY HH:MI:SS' )
         WHERE id = acin_id_in
         RETURNING prin_id INTO l_prin_id;
        /*--------------------------------------------------------------------
         * Check if this is the last activity in the process and if yes,
         * complete the process instance and possible parent processes.
         *--------------------------------------------------------------------*/
        log( 'Checking if acin ' || acin_id_in || ' is the last acin of prin ' || l_prin_id );
        last_activity_checks(
            prin_id_in                =>    l_prin_id,
            to_transition_found_in    =>    FALSE,
            transition_done_in        =>    FALSE
        );
    END acin_terminate;

BEGIN
    /*------------------------------------------------------------------------
     * Only HUMAN participants (and SYSTEM) may do stuff with workitems.
     *------------------------------------------------------------------------*/
    IF NOT participant_is_human( pati_id_in )
    AND NOT participant_is_type( pati_id_in, 'SYSTEM' )
    THEN
        RAISE_APPLICATION_ERROR( -20033,
            'pl_flow.ChangeActivityInstanceState: Only HUMAN and SYSTEM participants may act on workitems.' );
    END IF;
    /*------------------------------------------------------------------------
     * Get current activity instance and process instance states.
     * Should return exactly 1 record.
     *------------------------------------------------------------------------*/
    SELECT p.state
    ,      a.state
    ,      a.pati_id
    ,      a.pati_id_exclude
    INTO   process_state
    ,      current_state
    ,      l_pati_id
    ,      l_pati_id_exclude
    FROM wf_activity_instances a
    ,    wf_process_instances p
    WHERE a.prin_id = p.id    -- join activity instances with process instances
    AND   a.id      = acin_id_in  -- this activity instance
    ;
    /*------------------------------------------------------------------------
     * Get the current performer (if it exists)
     *------------------------------------------------------------------------*/
    OPEN performer_cursor( acin_id_in );
    FETCH performer_cursor INTO performer_record;
    IF performer_cursor%FOUND THEN
        pati_id_performer := performer_record.pati_id;
    END IF;
    /*------------------------------------------------------------------------
     * If an assigned participant is present...
     * the current participant should be the same if he releases, suspends or
     * starts the process.
     *------------------------------------------------------------------------*/
    IF pati_id_performer IS NOT NULL
    OR pati_id_in <> pl_flow_participant    -- wf engine itself may do anything
    THEN
        /*--------------------------------------------------------------------
         * Check whether pati_id_in is a proxy of the current performer
         *--------------------------------------------------------------------*/
        l_is_proxy_of := is_proxy_of( proxy_pati_id_in=>pati_id_in
                                    , human_pati_id_in=>pati_id_performer);
        /*--------------------------------------------------------------------
         * Block change when participants are different and pati_id_in has no
         * permissions to do the change.
         *--------------------------------------------------------------------*/
        IF ( state_in = 'NOTRUNNING'
            OR state_in = 'RUNNING'
            OR state_in = 'SUSPENDED' )
        AND pati_id_performer <> pati_id_in
        AND l_is_proxy_of = 0
        THEN
            RAISE_APPLICATION_ERROR( -20034,
            'pl_flow.ChangeActivityInstanceState: Only the assigned participant or its proxy can perform this change.' );
        END IF;
    END IF;
    /*------------------------------------------------------------------------
     * In the case of a new workitem (change from NOTRUNNING to RUNNING)
     * check whether the participant has the role to perform this job.
     *------------------------------------------------------------------------*/
    IF current_state = 'NOTRUNNING'
    AND state_in = 'RUNNING'
    AND pati_id_in <> pl_flow_participant -- again, system may do everything :-)
    THEN
        /*--------------------------------------------------------------------
         * If the participant type of l_pati_id is HUMAN
         * and it is equal to pati_id_in then the change is allowed.
         * IF the participant is null, then any participant may perform the 
         * activity
         *--------------------------------------------------------------------*/
        IF (    participant_is_human( l_pati_id )
            AND l_pati_id = pati_id_in)
        OR l_pati_id IS NULL
        THEN
            NULL; -- it's ok
        ELSE
            /*----------------------------------------------------------------
             * Check whether the pati_id (role) of the activity is
             * in the roles the participant has.
             *----------------------------------------------------------------*/
            BEGIN
                EXECUTE IMMEDIATE
                  'SELECT 1
                   FROM   TABLE(pl_flow.has_roles( :pati_id ))
                   WHERE  COLUMN_VALUE = :role_pati_id'
                INTO l_dummy
                USING pati_id_in, l_pati_id;
                /*------------------------------------------------------------
                 * No data found error means that the participant doesn't have
                 * the correct role
                 *------------------------------------------------------------*/
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    RAISE_APPLICATION_ERROR( -20035,
                        'pl_flow.ChangeActivityInstanceState: Participant '
                        || pati_id_in || ' is not granted the required role '
                        || l_pati_id || ' to perform this activity.'
                    );
            END;
        END IF;
        /* -------------------------------------------------------------------
         * Check if the participant is excluded from performing this activity 
         * instance.
         * -------------------------------------------------------------------*/
        IF l_pati_id_exclude IS NOT NULL AND l_pati_id_exclude = pati_id_in THEN
            RAISE_APPLICATION_ERROR( -20037,
                        'pl_flow.ChangeActivityInstanceState: Participant '
                        || pati_id_in || ' is prohibited to perform this activity.'
                    );
        END IF;
    END IF;
    /*------------------------------------------------------------------------
     * If termination pending, and the new state of this activity instance is
     * not abort, then the new state of this activity will be 'TERMINATED'
     *------------------------------------------------------------------------*/
    new_state := state_in;
    IF process_state = 'TERMINATED'
        AND state_in <> 'ABORTED'
    THEN
        new_state := 'TERMINATED';     -- should this be communicated to user?
    END IF;
    /*------------------------------------------------------------------------
     * Is transition allowed?
     * See wfmc spec (http://www.wfmc.org/standards/docs/if2v20.pdf) p170
     * for allowed transitions.
     *
     *  CURRENT     NEW state
     *
     *  notrunning  running
     *  notrunning  suspended   ** ???
     *  notrunning  aborted
     *  notrunning  terminated
     *  running     notrunning
     *  running     suspended
     *  running     completed
     *  running     aborted
     *  running     terminated
     *  suspended   notrunning
     *  suspended   running
     *  suspended   aborted
     *  suspended   terminated
     *
     *  terminated  aborted     ** not wfmc standard
     *
     *------------------------------------------------------------------------*/
    IF current_state = 'NOTRUNNING'    AND new_state = 'RUNNING'    THEN acin_start();
------- ELSIF current_state = 'NOTRUNNING' AND new_state = 'SUSPENDED'  THEN acin_suspend();
    ELSIF current_state = 'NOTRUNNING' AND new_state = 'ABORTED'    THEN acin_abort( acin_id_in, pati_id_in, new_state );
    ELSIF current_state = 'NOTRUNNING' AND new_state = 'TERMINATED' THEN acin_terminate();
    ELSIF current_state = 'RUNNING'    AND new_state = 'NOTRUNNING' THEN acin_release();
    ELSIF current_state = 'RUNNING'    AND new_state = 'SUSPENDED'  THEN acin_suspend();
    ELSIF current_state = 'RUNNING'    AND new_state = 'COMPLETED'  THEN acin_complete( acin_id_in, state_in );
    ELSIF current_state = 'RUNNING'    AND new_state = 'ABORTED'    THEN acin_abort( acin_id_in, pati_id_in, new_state );
    ELSIF current_state = 'RUNNING'    AND new_state = 'TERMINATED' THEN acin_terminate();
    ELSIF current_state = 'SUSPENDED'  AND new_state = 'NOTRUNNING' THEN acin_release();
    ELSIF current_state = 'SUSPENDED'  AND new_state = 'RUNNING'    THEN acin_resume();
    ELSIF current_state = 'SUSPENDED'  AND new_state = 'ABORTED'    THEN acin_abort( acin_id_in, pati_id_in, new_state );
    ELSIF current_state = 'SUSPENDED'  AND new_state = 'TERMINATED' THEN acin_terminate();
    ELSIF current_state = 'TERMINATED' AND new_state = 'ABORTED'    THEN acin_abort( acin_id_in, pati_id_in, new_state );

    /*------------------------------------------------------------------------
     * All other things are wrong.
     *------------------------------------------------------------------------*/
    ELSE
        RAISE_APPLICATION_ERROR( -20036,
        'pl_flow.ChangeActivityInstanceState('||acin_id_in||'): Invalid transition: from '
            || current_state || ' to ' || new_state || ' is not possible.' );
    END IF;
/***
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;       -- to what savepoint?
        RAISE;          -- same error to app. (because this is the app programmers mistake)
***/
--  WHEN constraint_violation_on_update -- invalid state (welk nummer is dit?)
--  WHEN OTHERS THEN
--      ROLLBACK;
--      RAISE;

END ChangeActivityInstanceState;

/*
||==========================================================================
|| WMAssignProcessInstanceAttribute - Assign the proper attribute to process
|| instance(s)
||
|| DESCRIPTION
||
|| This command tells the WFM Engine to assign an attribute, change an
|| attribute or to change the value of an attribute of a process instance.
||
|| This command changes the value of an attribute of a process instance.
|| Attributes of process instances are of the kind called Process Control and
|| Process Relevant Data. These attributes are specified as
|| quadruplets of name, type, length and value.
||
|| WMTErrRetType WMAssignProcessInstanceAttribute (
||      in WMTPSessionHandle psession_handle,
||      in WMTPProcInstID pproc_inst_id,
||      in WMTPAttrName pattribute_name,
||      in WMTInt32 attribute_type,
||      in WMTInt32 attribute_length,
||      in WMTPText pattribute_value)
||
|| exceptions:  invalid_process_instance
||      invalid_attribute
||      attribute_assignment_failed
||
|| Attributes with 'initial values' are assigned this value on creation
|| of the process instance.
||==========================================================================
*/
PROCEDURE AssignProcessInstanceAttribute
(   prin_id_in IN wf_process_instances.id%TYPE
,   name_in IN wf_attributes.name%TYPE
,   value_in IN wf_attribute_instances.value%TYPE
)
IS
    new_value   wf_attribute_instances.value%TYPE;
    atri_id_loc wf_attributes.id%TYPE;
    atri_data_type  wf_attributes.data_type%TYPE;
    atri_length wf_attributes.length%TYPE;
BEGIN
    log( 'prin_id_in=>' || prin_id_in || ', name_in=>' || name_in || ', value_in=>' || value_in );
    /*------------------------------------------------------------------------
     * Get attribute id by name (change this to ref by id later?)
     *------------------------------------------------------------------------*/
    BEGIN
        SELECT id, data_type, length
            INTO atri_id_loc, atri_data_type, atri_length
            FROM wf_attributes
            WHERE name_in = name
            AND prce_id = (SELECT prce_id FROM wf_process_instances WHERE id=prin_id_in);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RAISE_APPLICATION_ERROR( -20040,
                'pl_flow.AssignProcessInstanceAttribute: Unknown process attribute name ' || name_in || '.' );
    END;
    /*------------------------------------------------------------------------
     * Check for the correct datatype
     * INTEGER? Check with TO_NUMBER. Gives ORA-01722 of not a number.
     *------------------------------------------------------------------------*/
    IF atri_data_type = 'INTEGER'
    THEN
        new_value := TO_CHAR( TO_NUMBER( value_in ) );  -- if not number there is an exception
    /*------------------------------------------------------------------------
     * BOOLEAN with upper( val ) = {TRUE|FALSE} ?
     *------------------------------------------------------------------------*/
    ELSIF atri_data_type = 'BOOLEAN'
    THEN
        new_value := UPPER(value_in);   -- if not number there is an exception
        IF new_value <> 'TRUE' OR new_value <> 'FALSE'
        THEN
            RAISE_APPLICATION_ERROR( -20041,
            'pl_flow.AssignProcessInstanceAttribute: ' || value_in || ' is not TRUE or FALSE.' );
        END IF;
    /*------------------------------------------------------------------------
     * CHARACTER
     *------------------------------------------------------------------------*/
    ELSIF atri_data_type = 'CHARACTER'
    THEN
    /*------------------------------------------------------------------------
     * Truncate or give error if length > length
     *------------------------------------------------------------------------*/
        IF LENGTH( value_in ) > atri_length
        THEN
            RAISE_APPLICATION_ERROR( -20042,
            'pl_flow.AssignProcessInstanceAttribute: The predefined max. length of attribute ' ||atri_id_loc ||' is smaller than the lengt of "' || value_in || '".' );
        END IF;
        new_value := value_in;
    END IF;
    /*------------------------------------------------------------------------
     * Value is NULL? Then delete
     *------------------------------------------------------------------------*/
    IF LENGTH( new_value ) IS NULL THEN
        DELETE FROM wf_attribute_instances
              WHERE atri_id = atri_id_loc
                AND prin_id = prin_id_in;
    ELSE
    /*------------------------------------------------------------------------
     * Create or replace attribute instance
     *------------------------------------------------------------------------*/
        UPDATE wf_attribute_instances
           SET value = new_value
         WHERE prin_id = prin_id_in
           AND atri_id = atri_id_loc;
        /*--------------------------------------------------------------------
         * No records updated? Then make a new record
         *--------------------------------------------------------------------*/
        IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO wf_attribute_instances
                        ( atri_id, prin_id, value )
                 VALUES ( atri_id_loc, prin_id_in, new_value );
        END IF;
    END IF;

/***
EXCEPTION
    WHEN OTHERS THEN
            ROLLBACK;
            RAISE;             -- errors to caller
***/
END AssignProcessInstanceAttribute;


/*
||==========================================================================
|| WMAssignActivityInstanceAttribute - Assign an attribute to an activity
|| instance.
||
|| DESCRIPTION
||
|| This command tells the WFM Engine to assign an attribute, to change an
|| attribute or to change the value of an attribute of the activity instance
|| within a named process definition.
|| This command changes the value of the attributes of a activity instance.
|| These attributes of activity instances are of the kind called Process
|| Control and Process Relevant Data. These attributes are specified
|| as quadruplets of name, type, length and value.
|| WMTErrRetType WMAssignActivityInstanceAttribute (
||      in WMTPSessionHandle psession_handle,
||      in WMTPProcDefID pproc_def_id,
||      in WMTPActivityInstID pactivity_inst_id,
||      in WMTPAttrName pattribute_name,
||      in WMTInt32 attribute_type,
||      in WMTInt32 attribute_length,
||      in WMTPText pattribute_value)
||
|| exceptions:  invalid_process_instance
||      invalid_activity_instance
||      invalid_attribute           ORA-01722 : invalid number
||      attribute_assignment_failed
||
|| Implementation: why the default value in the process definition, when
|| creation is done during assignment?
||==========================================================================
*/
PROCEDURE AssignActi_InstanceAttribute
(   acin_id_in IN wf_activity_instances.id%TYPE
,   name_in IN wf_activity_attributes.name%TYPE
,   value_in IN wf_acti_attribute_instances.value%TYPE)
IS
    new_value   wf_acti_attribute_instances.value%TYPE;
    acat_id_loc wf_activity_attributes.id%TYPE;
    acat_data_type  wf_activity_attributes.data_type%TYPE;
    acat_length wf_activity_attributes.length%TYPE;
BEGIN
    /*------------------------------------------------------------------------
     * Get attribute id by name (change this to ref by id later?)
     *------------------------------------------------------------------------*/
    BEGIN
        SELECT id, data_type, length
          INTO acat_id_loc, acat_data_type, acat_length
          FROM wf_activity_attributes
         WHERE name = name_in;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RAISE_APPLICATION_ERROR( -20050,
                'pl_flow.AssignActi_InstanceAttribute: Unknown activity attribute name ' || name_in || '.' );
    END;
    /*------------------------------------------------------------------------
     * Check for the correct datatype
     * INTEGER? Check with TO_NUMBER. Gives ORA-01722 of not a number.
     *------------------------------------------------------------------------*/
    IF acat_data_type = 'INTEGER'
    THEN
        new_value := TO_CHAR( TO_NUMBER( value_in ) );  -- if not number there is an exception
    /*------------------------------------------------------------------------
     * BOOLEAN with upper( val ) = {TRUE|FALSE} ?
     *------------------------------------------------------------------------*/
    ELSIF acat_data_type = 'BOOLEAN'
    THEN
        new_value := UPPER(value_in);   -- if not number there is an exception
        IF new_value <> 'TRUE' OR new_value <> 'FALSE'
        THEN
            RAISE_APPLICATION_ERROR( -20051,
            'pl_flow.AssignActi_InstanceAttribute: ' || value_in || ' is not TRUE or FALSE.' );
        END IF;
    /*------------------------------------------------------------------------
     * CHARACTER
     *------------------------------------------------------------------------*/
    ELSIF acat_data_type = 'CHARACTER'
    THEN
        /*--------------------------------------------------------------------
         * Truncate or give error if length > length
         *--------------------------------------------------------------------*/
        IF LENGTH( value_in ) > acat_length
        THEN
            RAISE_APPLICATION_ERROR( -20052,
                'pl_flow.AssignActi_InstanceAttribute: ' || value_in ||
                ' is bigger than max length ' || acat_length || '.'
            );
        END IF;
        new_value := value_in;
    END IF;

    /*------------------------------------------------------------------------
     * Create or replace attribute instance
     *------------------------------------------------------------------------*/
    UPDATE wf_acti_attribute_instances
    SET    value = new_value
    WHERE acin_id = acin_id_in
    AND   acat_id = acat_id_loc
    ;
    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO wf_acti_attribute_instances
                    ( acat_id, acin_id, value )
             VALUES ( acat_id_loc, acin_id_in, new_value );
    END IF;

/**EXCEPTION
    WHEN OTHERS THEN
            ROLLBACK;
            RAISE;             -- errors to caller
            **/
END AssignActi_InstanceAttribute;

/*
||==========================================================================
 * AddProcessInstanceRemarks - Adds a remark to an process instance.
 *
 * DESCRIPTION
 *
 * This command is not wfmc standard. It adds a remark to the process instance.
 *
 * Exceptions:  invalid_process_instance
||==========================================================================
*/
PROCEDURE AddProcessInstanceRemarks
(   prin_id_in IN wf_process_instances.id%TYPE
,   remarks_in IN wf_process_instances.remarks%TYPE )
IS
l_remarks varchar2(9000);
BEGIN
    -- prevent string concatenation too long by putting the concatenation in a 
    -- big_enough var
    SELECT remarks INTO l_remarks FROM wf_process_instances WHERE id = prin_id_in;
    l_remarks := l_remarks || remarks_in;
    /*------------------------------------------------------------------------
     * Update the process instance
     *------------------------------------------------------------------------*/
    UPDATE wf_process_instances
    SET    remarks = SUBSTRB( l_remarks, 1, 4000 )
    WHERE  id = prin_id_in;

/***
EXCEPTION
    WHEN OTHERS THEN
            ROLLBACK;
            RAISE;             -- errors to caller
***/
END AddProcessInstanceRemarks;

/*
||==========================================================================
|| AddActivityInstanceRemarks - Adds a remark to an activity instance.
||
|| DESCRIPTION
||
|| This command is not wfmc standard. It adds a remark to the activity instance.
||
|| Exceptions:  invalid_activity_instance
||==========================================================================
*/
PROCEDURE AddActivityInstanceRemarks
(   acin_id_in IN wf_activity_instances.id%TYPE
,   remarks_in IN wf_activity_instances.remarks%TYPE )
IS
l_remarks varchar2(9000);
BEGIN
    -- prevent string concatenation too long by putting the concatenation in a 
    -- big_enough var
    SELECT remarks INTO l_remarks FROM wf_activity_instances WHERE id = acin_id_in;
    l_remarks := l_remarks || remarks_in;
    /*------------------------------------------------------------------------
     * Update the activity instance
     *------------------------------------------------------------------------*/
    UPDATE wf_activity_instances
    SET    remarks = SUBSTRB( l_remarks, 1, 4000 )
    WHERE  id = acin_id_in;

/***
EXCEPTION
    WHEN OTHERS THEN
            ROLLBACK;
            RAISE;             -- errors to caller
***/
END AddActivityInstanceRemarks;

/*
||==========================================================================
|| delegate_activity_instance - Delegate an activity instance to a new
|| participant.
||
|| DESCRIPTION
||
|| This command delegates performing an activity to another participant.
|| Delegation is currently not supported by the WFMC.
|| The target participant has the option not to accept the delegation.
|| In that case the previous participant will still be responsible.
|| This function is 'equal' to WMReassignWorkitem
||
|| Exceptions:
||      invalid_activity_instance
||      invalid participant
||==========================================================================
*/
PROCEDURE delegate_activity_instance
(   acin_id_in    IN wf_activity_instances.id%TYPE
,   pati_id_to_in IN wf_participants.id%TYPE         -- the target participant
,   remarks_in    IN wf_performers.remarks%TYPE      -- remark to the target
)
IS
    CURSOR performer_cursor( acin_id_in IN wf_performers.acin_id%TYPE )
    IS
        SELECT id
        ,      pati_id
        FROM   wf_performers
        WHERE state    = 'CURRENT'
        AND   accepted = 'Y'
        AND   acin_id  = acin_id_in
        FOR UPDATE                         -- OF wf_performers
        ;
    performer_record performer_cursor%ROWTYPE;

    l_state           wf_activity_instances.state%TYPE;
    l_pati_id_exclude wf_activity_instances.pati_id_exclude%TYPE;

BEGIN
    /*------------------------------------------------------------------------
     * Only suspended activities (possibly with a saved session state)
     * may be delegated.
     *------------------------------------------------------------------------*/
    SELECT state
    ,      pati_id_exclude
    INTO   l_state
    ,      l_pati_id_exclude
    FROM   wf_activity_instances
    WHERE  id = acin_id_in
    ;
    IF l_state <> 'SUSPENDED'
    THEN
        RAISE_APPLICATION_ERROR( -20060,
        'pl_flow.delegate_activity_instance: State of activity instance ' || acin_id_in || ' must be SUSPENDED before delegation (current state is ' || l_state || ').' );
    END IF;
    /*------------------------------------------------------------------------
     * Delegate only to persons who are allowed to perform the activity instance
     *------------------------------------------------------------------------*/
    IF pati_id_to_in = l_pati_id_exclude 
    THEN
        RAISE_APPLICATION_ERROR( -20061,
        'pl_flow.delegate_activity_instance: cannot delegate to someone who is prohibited to perform the activity instance (' || acin_id_in || ').' );
    END IF;
    /*------------------------------------------------------------------------
     * Get current performer. This is the first record of the performer cursor
     *------------------------------------------------------------------------*/
    OPEN performer_cursor( acin_id_in );
    FETCH performer_cursor INTO performer_record;
    /*------------------------------------------------------------------------
     * Create the new performer record.
     *------------------------------------------------------------------------*/
    INSERT INTO wf_performers(
        id
    ,   acin_id      -- activity instance primary key
    ,   pati_id      -- assigned participant
    ,   state
    ,   date_created
    ,   accepted     -- does the participant accept this assignment? Only used at reassignment.
    ,   remarks
    ,   pefo_id )    -- the performing of this job is delegated to another performer.
    VALUES (
        make_parallel( pefo_seq.NEXTVAL )  -- see make_parallel
    ,   acin_id_in
    ,   pati_id_to_in -- is null when acti.pati type is not human (i.e. one assigned person)
    ,   'CURRENT'
    ,   SYSDATE
    ,   NULL          -- *!*!*! difference from normal performer record create: the target has to accept or reject!!
    ,   NULL
    ,   performer_record.id  -- 'parent' performer record.
    );
    /*------------------------------------------------------------------------
     * Update the previous performer record
     *------------------------------------------------------------------------*/
    UPDATE wf_performers
    SET    state   = 'DELEGATED'
    ,      remarks = remarks_in           -- remarks of the source participant
    WHERE CURRENT OF performer_cursor     -- the record still selected for update. See cursor def.
    ;
    CLOSE performer_cursor;

/*--------------------------------------------------------------------------
 * Delegate errors to caller
 *--------------------------------------------------------------------------*/
/***
EXCEPTION
    WHEN OTHERS THEN
            ROLLBACK;
            RAISE;             -- errors to caller
***/
END  delegate_activity_instance;

/*
||==========================================================================
|| save_session_state - Saves state of a session.
||
|| DESCRIPTION
|| session_state_out    - descriptor of session state that is returned.
||
|| Exceptions:
||==========================================================================
*/
PROCEDURE save_session_state
(   acin_id_in        IN   wf_activity_instances.id%TYPE
,   session_state_out OUT  wf_activity_instances.session_state%TYPE
)
IS
    lob_loc        BLOB;
BEGIN
    /*--------------------------------------------------------------------------
     * Create (or destroy) previous session state and make new emtpy blob
     *--------------------------------------------------------------------------*/
    UPDATE wf_activity_instances
    SET    session_state = EMPTY_BLOB()
    WHERE  id = acin_id_in
    RETURNING session_state INTO session_state_out
    ;

    -- session_state_out is out var.
END save_session_state;

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
PROCEDURE grant_role
(   pati_id_in    IN  wf_participants.id%TYPE
,   role_name_in  IN  wf_participants.name%TYPE
)
IS
    CURSOR check_loop_cursor
    ( arg1_in IN wf_participant_relations.pati_id_arg1%TYPE
    , arg2_in IN wf_participant_relations.pati_id_arg2%TYPE
    )
    IS 
        SELECT 1 FROM (
            SELECT DISTINCT pati_id_arg2 AS pati_id
            FROM wf_participant_relations r
            WHERE r.relation_type='GRANT'
            CONNECT BY PRIOR r.pati_id_arg2 = r.pati_id_arg1
                         AND r.relation_type='GRANT'                -- grant is transitive
            START WITH r.pati_id_arg1 = arg1_in
        ) grants
        WHERE grants.pati_id = arg2_in
    ;
    check_loop_record check_loop_cursor%ROWTYPE;
    
    l_pati_id   wf_participants.id%TYPE;
BEGIN
    /*------------------------------------------------------------------------
     * Is role_name_in the name of a role?
     * This gives 'no_data_found' when the role is not found.
     *------------------------------------------------------------------------*/
    SELECT id
    INTO  l_pati_id
    FROM  wf_participants
    WHERE participant_type = 'ROLE'
    AND   name             = role_name_in
    ;
    
    IF l_pati_id = pati_id_in 
    THEN
        RAISE_APPLICATION_ERROR( -20072,
            'pl_flow.grant_role: a role cannot be granted to itself' );
    END IF;
    
    OPEN check_loop_cursor(arg1_in => l_pati_id, arg2_in => pati_id_in );
    FETCH check_loop_cursor INTO check_loop_record;
    IF check_loop_cursor%FOUND
    THEN
        RAISE_APPLICATION_ERROR( -20073,
            'pl_flow.grant_role: cannot create loop in grants' );
    END IF;

    /*------------------------------------------------------------------------
     * Put the record in the database
     * Only insert the values when the grant record is not yet found!
     *------------------------------------------------------------------------*/
    INSERT INTO wf_participant_relations( pati_id_arg1, pati_id_arg2, relation_type )
    SELECT pati_id_in
    ,      l_pati_id
    ,      'GRANT'
    FROM DUAL
    WHERE NOT EXISTS (
        SELECT 1
        FROM  wf_participant_relations
        WHERE relation_type = 'GRANT'
        AND   pati_id_arg1  = pati_id_in
        AND   pati_id_arg2  = l_pati_id
    );
END grant_role;

/*
||==========================================================================
|| revoke_role - Revoke a previously granted role (overloaded)
||
|| DESCRIPTION
||     pati_id_in          the HUMAN, SYSTEM, OU or ROLE who is revoked the..
||     role_pati_id_in     the participant id of the ROLE that is to be revoked.
||
|| Exceptions:
||==========================================================================
*/
PROCEDURE revoke_role
(   pati_id_in        IN  wf_participants.id%TYPE
,   role_pati_id_in   IN  wf_participants.id%TYPE
)
IS
BEGIN
    /*------------------------------------------------------------------------
     * Remove any matching record from the database.
     *------------------------------------------------------------------------*/
    DELETE FROM wf_participant_relations
    WHERE relation_type = 'GRANT'
    AND   pati_id_arg1  = pati_id_in
    AND   pati_id_arg2  = role_pati_id_in
    ;
END revoke_role;

/*
||==========================================================================
|| revoke_role - Revoke a previously granted role (overloaded)
||
|| DESCRIPTION
||              pati_id_in      the HUMAN, SYSTEM, OU or ROLE who is revoked the..
||              role_name_in    the name of the ROLE that is to be revoed.
||
|| Exceptions:
||==========================================================================
*/
PROCEDURE revoke_role
(   pati_id_in    IN  wf_participants.id%TYPE
,   role_name_in  IN  wf_participants.name%TYPE
)
IS
    l_pati_id   wf_participants.id%TYPE;
BEGIN
    /*------------------------------------------------------------------------
     * Is role_name_in the name of a role?
     * This gives 'no_data_found' when the role is not found.
     *------------------------------------------------------------------------*/
    SELECT id INTO l_pati_id
    FROM  wf_participants
    WHERE participant_type = 'ROLE'
    AND   name             = role_name_in
    ;
    /*------------------------------------------------------------------------
     * Revoke the role
     *------------------------------------------------------------------------*/
    revoke_role( pati_id_in=>pati_id_in, role_pati_id_in=>l_pati_id );

END revoke_role;

/*
||==========================================================================
|| add_proxy - Add a proxy participant to a participant (overloaded)
||
||      Pre: proxy_pati_id_in is the ID of a HUMAN or ROLE participant
||           human_pati_id_in is the ID of a HUMAN participant
||
||     Post: The pair <proxy_pati_id_in,human_pati_id_in> is added to the
||           relation 'PROXY OF'
||
|| DESCRIPTION
||
|| Exceptions:
||==========================================================================
*/
PROCEDURE add_proxy
(   human_pati_id_in  IN  wf_participants.id%TYPE
,   proxy_pati_id_in  IN  wf_participants.id%TYPE
)
IS
    l_pati_id           wf_participants.id%TYPE;
    l_participant_type  wf_participants.participant_type%TYPE;
BEGIN
    /*------------------------------------------------------------------------
     * Check participant types
     *------------------------------------------------------------------------*/
    IF NOT participant_is_human( human_pati_id_in )
    THEN
        RAISE_APPLICATION_ERROR( -20070,
            'pl_flow.add_proxy: the participant type of participant '
            || human_pati_id_in || ' must be ''HUMAN''.' );
    END IF;
    IF NOT (
               participant_is_type( proxy_pati_id_in, 'HUMAN' )
            OR participant_is_type( proxy_pati_id_in, 'ROLE' )
           )
    THEN
        RAISE_APPLICATION_ERROR( -20071,
            'pl_flow.add_proxy: the participant type of participant '
            || proxy_pati_id_in || ' must be ''HUMAN'' or ''ROLE''.' );
    END IF;
    /*------------------------------------------------------------------------
     * Put the record in the database
     * Only insert the values when the relation is not yet found!
     *------------------------------------------------------------------------*/
    INSERT INTO wf_participant_relations( pati_id_arg1, pati_id_arg2, relation_type )
         SELECT proxy_pati_id_in, human_pati_id_in, 'PROXY OF'
           FROM DUAL
          WHERE NOT EXISTS
            ( SELECT 1
               FROM wf_participant_relations
              WHERE relation_type='PROXY OF'
                AND pati_id_arg1=proxy_pati_id_in
                AND pati_id_arg2=human_pati_id_in );

END add_proxy;

/*
||==========================================================================
|| add_proxy - Add a proxy participant to a participant  (overloaded)
||
|| Pre: proxy_role_name_in    the name of the ROLE participant that is the proxy
||      human_pati_id_in      the HUMAN participant that will be proxied
||
|| Post: add_proxy( id, human_pati_id_in ) is called where id
||       is the participant id of the ROLE with name proxy_role_name_in
||
|| Exceptions:
||            NO_DATA_FOUND when there is no role with name proxy_role_name_in
||            Application error when type of human_pati_id_in <> 'HUMAN'
||==========================================================================
*/
PROCEDURE add_proxy
(   proxy_role_name_in    IN  wf_participants.name%TYPE
,   human_pati_id_in      IN  wf_participants.id%TYPE
)
IS
    l_pati_id   wf_participants.id%TYPE;
BEGIN
    /*------------------------------------------------------------------------
     * Check participant types
     *------------------------------------------------------------------------*/
    IF NOT participant_is_human( human_pati_id_in )
    THEN
        RAISE_APPLICATION_ERROR( -20075,
            'pl_flow.add_proxy: the participant type of participant '
            || human_pati_id_in || ' must be ''HUMAN''.' );
    END IF;
    /*------------------------------------------------------------------------
     * Get the pati_id of the role.
     * This gives 'no_data_found' when the role is not found.
     *------------------------------------------------------------------------*/
    SELECT id INTO l_pati_id
    FROM  wf_participants
    WHERE participant_type = 'ROLE'
    AND   name             = proxy_role_name_in
    ;
    /*------------------------------------------------------------------------
     * Put the record in the database
     *------------------------------------------------------------------------*/
    add_proxy( proxy_pati_id_in => l_pati_id
             , human_pati_id_in => human_pati_id_in )
    ;
END add_proxy;

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
PROCEDURE remove_proxy
(   proxy_pati_id_in  IN  wf_participants.id%TYPE
,   human_pati_id_in  IN  wf_participants.id%TYPE
)
IS
BEGIN
    /*------------------------------------------------------------------------
     * Remove the proxy relationship
     *------------------------------------------------------------------------*/
    DELETE FROM wf_participant_relations
    WHERE relation_type = 'PROXY OF'
    AND   pati_id_arg1  = proxy_pati_id_in
    AND   pati_id_arg2  = human_pati_id_in
    ;
END remove_proxy;

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
PROCEDURE remove_proxy
(   proxy_role_name_in  IN  wf_participants.name%TYPE
,   human_pati_id_in  IN  wf_participants.id%TYPE
)
IS
    l_pati_id   wf_participants.id%TYPE;
BEGIN
    /*------------------------------------------------------------------------
     * Is role_name_in the name of a role?
     * This gives 'no_data_found' when the role is not found.
     *------------------------------------------------------------------------*/
    SELECT id INTO l_pati_id
    FROM  wf_participants
    WHERE participant_type = 'ROLE'
    AND   name             = proxy_role_name_in;
    /*------------------------------------------------------------------------
     * Remove the proxy relationship
     *------------------------------------------------------------------------*/
    remove_proxy( proxy_pati_id_in => l_pati_id
                , human_pati_id_in => human_pati_id_in )
    ;
END remove_proxy;

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
PROCEDURE send_mail
(   smtp_server_in      IN  VARCHAR2    DEFAULT defsmtphost    -- max   64
,   domain_in           IN  VARCHAR2    DEFAULT defdomain      -- max   64
,   sender_name_in      IN  VARCHAR2                           -- max   64
,   sender_email_in     IN  VARCHAR2                           -- max   64
,   recipient_name_in   IN  VARCHAR2                           -- max   64
,   recipient_email_in  IN  VARCHAR2                           -- max   64
,   subject_in          IN  VARCHAR2                           -- max  256 ?
,   body_in             IN  VARCHAR2                           -- max 1000 ?
)
IS
    l_conn              utl_smtp.connection;

    /*------------------------------------------------------------------------
     * Local procedure for sending headers.
     *------------------------------------------------------------------------*/
    PROCEDURE send_header(name IN VARCHAR2, header IN VARCHAR2) AS
    BEGIN
        utl_smtp.write_data(l_conn, name || ': ' || header || utl_tcp.CRLF);
    END;

BEGIN
	-- RAO return without sending email - Temporary to avoid SMTP errors
	return;

    l_conn := utl_smtp.open_connection( smtp_server_in );
--    utl_smtp.helo(l_conn, domain_in);
--    utl_smtp.mail(l_conn, sender_email_in);
    utl_smtp.rcpt(l_conn, recipient_email_in);
    -- utl_smtp.rcpt(l_conn, 'BCC:info@oopsthisshouldbeglobalpackageparameter.nl' );
    utl_smtp.open_data(l_conn);
    -- you may want to change this for your own timezone.
    send_header('Date', TO_CHAR(SYSDATE,'Dy, DD Mon RR HH24:MI:SS', 'nls_date_language=english' ) || ' ' || replace(SESSIONTIMEZONE,':') );
    send_header('From',    '"' || sender_name_in || '" <' || sender_email_in || '>');
    send_header('To',      '"' || recipient_name_in || '" <' || recipient_email_in || '>');
    send_header('Subject', subject_in );
    utl_smtp.write_data(l_conn, utl_tcp.CRLF || body_in );
    utl_smtp.close_data(l_conn);
    utl_smtp.quit(l_conn);
EXCEPTION
    WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
        BEGIN
            utl_smtp.quit(l_conn);
        EXCEPTION
            WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
                NULL; -- When the SMTP server is down or unavailable, we don't have
                      -- a connection to the server. The quit call will raise an
                      -- exception that we can ignore.
        END;
        -- Raise no errors at all to the caller. Maybe log something to a file.
        -- Remember this can be called from a job!
        -- raise_application_error(-20000,
        --  'Failed to send mail due to the following error: ' || sqlerrm);
END send_mail;

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
)
IS
    l_acin_state      wf_activity_instances.state%TYPE;
    l_pati_type       wf_participants.participant_type%TYPE;
    l_pati_id_exclude wf_activity_instances.pati_id_exclude%TYPE;

    CURSOR assign_cursor (
        acin_id_in   IN  wf_activity_instances.id%TYPE
    ,   pati_type_in IN  wf_participants.participant_type%TYPE
    )
    IS
        SELECT pefo.*
        FROM   wf_performers   pefo, wf_participants pati
        WHERE  pefo.state    = 'ASSIGNED'
        AND    pefo.acin_id  = acin_id_in
        AND    (accepted IS NULL OR accepted = 'Y')
        AND    pati.id       = pefo.pati_id
        AND    pati.participant_type = pati_type_in
        FOR UPDATE
    ;
    assign_record assign_cursor%ROWTYPE;
BEGIN
    SELECT state, pati_id_exclude
    INTO l_acin_state, l_pati_id_exclude
    FROM wf_activity_instances
    WHERE id = acin_id_in
    ;
    
    SELECT participant_type INTO l_pati_type
    FROM wf_participants pati
    WHERE pati.id = pati_id_in;

    /*------------------------------------------------------------------------
     * only assign if state is NOTRUNNING
     *------------------------------------------------------------------------*/
    IF (l_acin_state != 'NOTRUNNING')
    THEN
        RAISE_APPLICATION_ERROR( -20080,
            'pl_flow.assign_workitem: cannot assign workitem when state <> NOTRUNNING' );
    END IF;
    /*------------------------------------------------------------------------
     * Assign only to persons who are allowed to perform the activity instance
     *------------------------------------------------------------------------*/
    IF pati_id_in = l_pati_id_exclude
    THEN
        RAISE_APPLICATION_ERROR( -20061,
        'pl_flow.assign_workitem: cannot assign to someone who is prohibited to perform the activity instance (' || acin_id_in || ').' );
    END IF;

    /*------------------------------------------------------------------------
     * check if acin was previously assigned
     *------------------------------------------------------------------------*/
    OPEN assign_cursor( acin_id_in => acin_id_in, pati_type_in => l_pati_type);
    FETCH assign_cursor INTO assign_record;

    IF assign_cursor%FOUND THEN
        IF assign_record.pati_id = pati_id_in
        THEN
            RAISE_APPLICATION_ERROR( -20081,
                'pl_flow.assign_workitem: workitem already assigned to participant' );
        END IF;
        
        -- disable old assignrecord
        UPDATE wf_performers
        SET accepted = 'N'
        WHERE CURRENT OF assign_cursor  -- the record still selected for update. See cursor def.
        ;
    END IF;
    
    INSERT INTO wf_performers 
    (   id
    ,   pefo_id
    ,   pati_id
    ,   acin_id
    ,   date_created
    ,   state
    ,   accepted
    ,   remarks
    ) VALUES 
    (   make_parallel( pefo_seq.NEXTVAL )
    ,   assign_record.id --link to previous assign record (if present)
    ,   pati_id_in
    ,   acin_id_in
    ,   SYSDATE
    ,   'ASSIGNED'
    ,   NULL
    ,   remarks_in
    );
    CLOSE assign_cursor;
END;

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
)
IS
    CURSOR assign_cursor (
        acin_id_in  IN  wf_activity_instances.id%TYPE
    )
    IS
        SELECT pefo.*
        FROM   wf_performers   pefo
        WHERE  (   pefo.state = 'ASSIGNED' OR pefo.state = 'CURRENT')
        AND    pefo.pati_id = pati_id_in 
        AND    pefo.acin_id = acin_id_in
        AND    accepted IS NULL
        FOR UPDATE
    ;
    assign_record assign_cursor%ROWTYPE;
BEGIN

    --check if pati was previously assigned
    OPEN assign_cursor( acin_id_in);
    FETCH assign_cursor INTO assign_record;

    IF assign_cursor%FOUND THEN --
        --Reject assignment
        UPDATE wf_performers
        SET accepted = 'N'
        ,   remarks  = remarks_in
        WHERE CURRENT OF assign_cursor
        ;

        --restore previous performer or assignment
        UPDATE wf_performers
        SET state   = assign_record.state --'CURRENT' or 'ASSIGNED'
        ,   remarks = null
        ,   accepted = 'Y'
        WHERE id = assign_record.pefo_id
        ;
    ELSE
        RAISE_APPLICATION_ERROR( -20090,
            'pl_flow.reject_workitem: cannot reject workitem that is not assigned or already accepted/rejected' );
    END IF;
    CLOSE assign_cursor;
END;

END pl_flow;
/
show errors

--quit
--/
--PROMPT this job is submitted here to make sure that there is a deadline job.
--DECLARE
--    l_job_out   BINARY_INTEGER;
--BEGIN
--        DBMS_JOB.SUBMIT(
--            l_job_out,
--            'pl_flow.check_deadlines();',
--            SYSDATE,
--            'SYSDATE+1/24/30'
--        );
--END;
--/
--quit
--/

