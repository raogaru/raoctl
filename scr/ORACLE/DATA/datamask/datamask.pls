/* ######################################################################
-- File : mask_generic.sql
-- Arguments:
-- 1 table owner
-- 2 table name
-- 3 column name
-- 4 value expression
-- 5 if condition
 ###################################################################### */
@@head_datamask_run &1 &2 &3
DECLARE
	CURSOR rec_cur IS SELECT /*+ parallel(a,&v_px) */ rowid, &4 FROM &1..&2 a WHERE &3 is not null and (&5);
	TYPE val_tab_t IS TABLE OF &1..&2..&3.%TYPE;
	TYPE rowid_t IS TABLE OF ROWID INDEX BY PLS_INTEGER;
	rowid_tab rowid_t;
	out_tab val_tab_t;
	v_idx	number:=0;
	v_rowcnt	number:=0;
	v_date	date:=sysdate;
	v_start	date:=sysdate;
BEGIN
	dbms_output.enable(1000000);
	OPEN rec_cur;
	LOOP
		FETCH rec_cur BULK COLLECT INTO rowid_tab, out_tab LIMIT &v_limit;
		EXIT WHEN rowid_tab.COUNT() = 0;
		v_rowcnt := v_rowcnt + rowid_tab.COUNT();
		v_idx := v_idx + 1;
		dbms_application_info.set_action (to_char(v_idx)||' &1..&2..&3');
		v_date:=sysdate;
		FORALL i IN rowid_tab.FIRST .. rowid_tab.LAST
			UPDATE /*+ parallel(a,&v_px) */ &1..&2 a SET &3 = out_tab(i) WHERE rowid= rowid_tab(i);
		COMMIT;

		dbms_output.put_line(to_char(sysdate,'yyyy-mm-dd hh24:mi:ss')||' &1..&2..&3 Iteration='||to_char(v_idx)||' Elapsed='||to_char(round((sysdate-v_date)*24*60,1))||'min Rowcount='||to_char(v_rowcnt));
	END LOOP;
	dbms_output.put_line(to_char(sysdate,'yyyy-mm-dd hh24:mi:ss')||' &1..&2..&3 MASKING SUMMARY Iterations='||to_char(v_idx)||' Elapsed='||to_char(round((sysdate-v_start)*24*60,1))||'min Rowcount='||to_char(v_rowcnt));
END;
/
@@foot_datamask_run &1 &2 &3
--
-- end of file
--
