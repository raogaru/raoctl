--arg-1 table_owner
--arg-1 table_name
--arg-2 column_name
set verify off echo off feedback off time off timing off linesi 1000 trimspool on pagesize 0
set serveroutput on size 1000000
define v_limit=100 	-- bulk collection limit
define v_px=16		-- parallelism
alter session enable parallel query;
alter session enable parallel dml;
alter session force parallel dml parallel &v_px;
alter session set current_schema=RAO;
exec dbms_application_info.set_module('PIIMASK','&1..&2..&3');
spool piimask.lst append
PROMPT ######################################################################
insert into data_mask_log
(id, own, tab, col,start_time, end_time, row_count, a_db, a_user, a_host, a_ipaddr)
values (
  data_mask_seq.nextval
, upper('&1')
, upper('&2')
, upper('&3')
, sysdate
, null
, null
, substr(SYS_CONTEXT('USERENV','DB_NAME'),1,30)
, substr(SYS_CONTEXT('USERENV','CURRENT_USER'),1,30)
, substr(SYS_CONTEXT('USERENV','HOST'),1,100)
, substr(SYS_CONTEXT('USERENV','IP_ADDRESS'),1,15)
);
commit;
select to_char(sysdate, 'yyyy-mm-dd hh24:mi:ss')||' &1..&2..&3 MASKING STARTED' from dual;
