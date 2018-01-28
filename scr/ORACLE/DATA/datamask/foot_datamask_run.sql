--arg-1 table_owner
--arg-2 table_name
--arg-3 column_name
select to_char(sysdate, 'yyyy-mm-dd hh24:mi:ss')||' &1..&2..&3 MASKING COMPLETED' from dual;
PROMPT ######################################################################
select '' from dual;
exec dbms_application_info.set_module(null,null);
update data_mask_log 
set end_time=sysdate 
where own=upper('&1') 
and tab=upper('&2') 
and col=upper('&3');
commit;
spool off
