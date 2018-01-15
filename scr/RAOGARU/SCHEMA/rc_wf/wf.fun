-- ----------------------------------------------------------------------
-- wf.fun
-- ----------------------------------------------------------------------

PROMPT Creating Functions ...

CREATE OR REPLACE PROCEDURE WHO_CALLED_ME(
owner      out varchar2,
name       out varchar2,
lineno     out number,
caller_t   out varchar2 )
AS
    call_stack  varchar2(4096) default dbms_utility.format_call_stack;
    n           number;
    found_stack BOOLEAN default FALSE;
    line        varchar2(255);
    cnt         number := 0;
BEGIN
--
    loop
        n := instr( call_stack, chr(10) );
        exit when ( cnt = 3 or n is NULL or n = 0 );
--
        line := substr( call_stack, 1, n-1 );
        call_stack := substr( call_stack, n+1 );
--
        if ( NOT found_stack ) then
            if ( line like '%handle%number%name%' ) then
                found_stack := TRUE;
            end if;
        else
            cnt := cnt + 1;
/* line is like
0x56b84cf0       103  package body PLFLOW.PL_FLOW
*/

            -- cnt : 1=ME    2=MyCaller 3=TheirCaller
            if ( cnt = 3 ) then
                lineno := to_number(substr( line, 11, 10 ));
                line   := substr( line, 23 );
                if ( line like 'pr%' ) then
                    n := length( 'procedure ' );
                elsif ( line like 'fun%' ) then
                    n := length( 'function ' );
                elsif ( line like 'package body%' ) then
                    n := length( 'package body ' );
                elsif ( line like 'pack%' ) then
                    n := length( 'package ' );
                elsif ( line like 'anonymous%' ) then
                    n := length( 'anonymous block ' );
                else
                    n := null;
                end if;
                if ( n is not null ) then
                   caller_t := ltrim(rtrim(upper(substr( line, 1, n-1 ))));
                else
                   caller_t := 'TRIGGER';
                end if;

                line := substr( line, nvl(n,1) );
                n := instr( line, '.' );
                owner := ltrim(rtrim(substr( line, 1, n-1 )));
                name  := ltrim(rtrim(substr( line, n+1 )));
            end if;
        end if;
    end loop;
END;
/

-- ----------------------------------------------------------------------
-- WHO_AM_I
-- ----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION WHO_AM_I 
RETURN VARCHAR2 
IS
    l_owner        varchar2(30);
    l_name      varchar2(30);
    l_lineno    number;
    l_type      varchar2(30);
BEGIN
   who_called_me( l_owner, l_name, l_lineno, l_type );
   return l_owner || '.' || l_name;
END;
/

/***************************************************************************
 * MAKE_PARALLEL
 * Multiply a number and add offset.
 * Each value from a sequence should be made parallel!
 * Usage: INSERT INTO table (ID) values (make_parallel(table_seq.NEXTVAL))
 ***************************************************************************/
CREATE OR REPLACE FUNCTION make_parallel( number_in	PLS_INTEGER)
RETURN PLS_INTEGER
IS

	sequence_multiplier	INTEGER	DEFAULT 2;	-- number of (parallel) servers. Use 1 for single server
	sequence_offset		INTEGER DEFAULT 1;	-- number of this server (should be different on each server!). Use 0 for a single server.
BEGIN
	RETURN number_in * sequence_multiplier + sequence_offset;
END make_parallel;
/

-- ----------------------------------------------------------------------
-- wf.fun
-- ----------------------------------------------------------------------
