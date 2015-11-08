-- TITLE1: Apply Coordinators
-- TITLE2: Displaying General Information About Each Coordinator Process
-- DESC: A coordinator process gets transactions from the reader server and passes these transactions to apply servers. The coordinator process name is APnn, where nn is a coordinator process number.

COLUMN APPLY_NAME HEADING 'Apply Process|Name' FORMAT A17
COLUMN PROCESS_NAME HEADING 'Coordinator|Process|Name' FORMAT A11
COLUMN SID HEADING 'Session|ID' FORMAT 9999
COLUMN SERIAL# HEADING 'Session|Serial|Number' FORMAT 9999
COLUMN STATE HEADING 'State' FORMAT A21

SELECT c.APPLY_NAME,
       SUBSTR(s.PROGRAM,INSTR(s.PROGRAM,'(')+1,4) PROCESS_NAME,
       c.SID,
       c.SERIAL#,
       c.STATE
       FROM V$STREAMS_APPLY_COORDINATOR c, V$SESSION s
       WHERE c.SID = s.SID AND
             c.SERIAL# = s.SERIAL#;
