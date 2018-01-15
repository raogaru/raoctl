-- ----------------------------------------------------------------------
-- flow.trg
-- ----------------------------------------------------------------------

PROMPT Creating Triggers ...

/*
||==========================================================================
|| TRIGGER: wf_procdef_acpa
||       Pre: :new is the new actual parameters record.
||      Post: constraints are satisfied or an error is raised
|| DESCRIPTION
|| Process definition checks for actual parameters.
||      XOR on atri_id and expression
||==========================================================================
*/

CREATE OR REPLACE TRIGGER wf_procdef_acpa
BEFORE UPDATE OR INSERT ON wf_actual_parameters
FOR EACH ROW
BEGIN
    IF  :new.atri_id IS NULL AND :new.expression IS NULL THEN
        RAISE_APPLICATION_ERROR( -20000, 'wf_actual_parameters ('||:new.id||') : Specify either an attribute id (atri_id) or an expression to use as actual parameter.' );
    END IF;
    IF  :new.atri_id IS NOT NULL AND :new.expression IS NOT NULL THEN
        RAISE_APPLICATION_ERROR( -20000, 'wf_actual_parameters ('||:new.id||') : Choose either an attribute id (atri_id) or an expression to use as actual parameter, but not both.' );
    END IF;
END;
/

/*
||==========================================================================
|| TRIGGER: wf_procdef_fopa
||   
||       Pre: :new is the newrecord.
||
||      Post: constraints are satisfied or
||            an error is raised
|| 
|| DESCRIPTION
|| 
|| Process definition checks for actual parameters.
||     XOR on prce_id and apl_id
||     Because a parameter can be of a (sub)process OR of an application, but not both at once.
||==========================================================================
*/

CREATE OR REPLACE TRIGGER wf_procdef_fopa
BEFORE UPDATE OR INSERT ON wf_formal_parameters
FOR EACH ROW
BEGIN
IF  :new.prce_id IS NULL AND :new.apli_id IS NULL THEN
	RAISE_APPLICATION_ERROR( -20000, 'wf_formal_parameters ('||:new.id||') : A formal parameter is parameter of a (sub)process, OR parameter of an application.'
|| ' Specify either an process id (prcei_id) OR an application id (apli_id).' );
END IF;
IF  :new.prce_id IS NOT NULL AND :new.apli_id IS NOT NULL THEN
	RAISE_APPLICATION_ERROR( -20000, 'wf_formal_parameters ('||:new.id||') : A formal parameter is parameter of a (sub)process, OR parameter of an application, but not both. '
|| ' Choose either an process id (prcei_id) OR an application id (apli_id).' );
END IF;

END;
/

-- ----------------------------------------------------------------------
-- flow.trg
-- ----------------------------------------------------------------------
