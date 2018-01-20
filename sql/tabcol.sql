set pagesu 1000 head on feedback onlinesi 1000 trimspool on
col owner format a10
select owner, table_name, column_name from dba_tab_columns
where column_name like upper('%&1%')
/
