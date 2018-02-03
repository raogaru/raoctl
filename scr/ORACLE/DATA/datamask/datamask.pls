-- ######################################################################
-- File : datamask.pls
-- Arguments: 1.table_owner 2.table_name 3.column_name 4.value_expression 5.if_condition
-- ######################################################################
set verify off echo off feedback off time off timing off linesi 1000 trimspool on pagesize 0
set serveroutput on size 1000000
define v_hash_line='######################################################################'
define v_limit=100 	-- bulk collection limit
define v_px=16		-- parallelism
alter session enable parallel query;
alter session enable parallel dml;
alter session force parallel dml parallel &v_px;
alter session set current_schema=RAO;
exec dbms_application_info.set_module('DATAMASK','&1..&2..&3');
spool datamask.lst append
PROMPT &v_hash_line

select to_char(sysdate, 'yyyy-mm-dd hh24:mi:ss')||' &1..&2..&3 MASKING STARTED' from dual;
-- ======================================================================
DECLARE
	CURSOR rec_cur IS SELECT /*+ parallel(a,&v_px) */ rowid, &4 FROM &1..&2 a WHERE &3 is not null and (&5);
	TYPE column_t IS TABLE OF &1..&2..&3.%TYPE;
	TYPE rowid_t IS TABLE OF ROWID INDEX BY PLS_INTEGER;
	rowid_tab rowid_t;
	colval_tab column_t;
	v_idx	number:=0;
	v_rowcnt	number:=0;
	v_date	date:=sysdate;
	v_start	date:=sysdate;
	v_masked number:=0;
BEGIN
	dbms_output.enable(1000000);

	SELECT count(1) INTO v_masked FROM data_mask_log 
	where own='&1' and tab='&2' and col='&3';
	IF v_masked=1 THEN 
		dbms_output.put_line(to_char(sysdate,'yyyy-mm-dd hh24:mi:ss')||' &1..&2..&3 Already Masked');
		RETURN;
	ELSE
		insert into data_mask_log
		(id, own, tab, col,start_time, end_time, row_count, a_db, a_user, a_host)
		values (
		  data_mask_seq.nextval , upper('&1') , upper('&2') , upper('&3')
		, sysdate , null , null
		, substr(SYS_CONTEXT('USERENV','DB_NAME'),1,30)
		, substr(SYS_CONTEXT('USERENV','CURRENT_USER'),1,30)
		, substr(SYS_CONTEXT('USERENV','HOST'),1,100)
		);
		commit;
	END IF;

	-- proceed with masking
	OPEN rec_cur;
	LOOP
		FETCH rec_cur BULK COLLECT INTO rowid_tab, colval_tab LIMIT &v_limit;
		EXIT WHEN rowid_tab.COUNT() = 0;
		v_rowcnt := v_rowcnt + rowid_tab.COUNT();
		v_idx := v_idx + 1;
		dbms_application_info.set_action (to_char(v_idx)||' &1..&2..&3');
		v_date:=sysdate;
		FORALL i IN rowid_tab.FIRST .. rowid_tab.LAST
			UPDATE /*+ parallel(a,&v_px) */ &1..&2 a SET &3 = colval_tab(i) WHERE rowid= rowid_tab(i);
		COMMIT;

		--dbms_lock.sleep(dbms_random.value(3,10));

		dbms_output.put_line(to_char(sysdate,'yyyy-mm-dd hh24:mi:ss')||' &1..&2..&3 Iteration='||to_char(v_idx)||' Elapsed='||to_char(round((sysdate-v_date)*24*60,1))||'min Rowcount='||to_char(v_rowcnt));
	END LOOP;
	dbms_output.put_line(to_char(sysdate,'yyyy-mm-dd hh24:mi:ss')||' &1..&2..&3 MASKING SUMMARY Iterations='||to_char(v_idx)||' Elapsed='||to_char(round((sysdate-v_start)*24*60,1))||'min Rowcount='||to_char(v_rowcnt));
END;
/
-- ======================================================================
select to_char(sysdate, 'yyyy-mm-dd hh24:mi:ss')||' &1..&2..&3 MASKING COMPLETED' from dual;
PROMPT &v_hash_line
select '' from dual;
exec dbms_application_info.set_module(null,null);
update data_mask_log 
set end_time=sysdate 
where own=upper('&1') 
and tab=upper('&2') 
and col=upper('&3');
commit;
spool off
-- ======================================================================
--
-- end of file
--
