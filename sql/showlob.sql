set pagesi 1000 lines 150 trims on
col column_name format a30
select owner, table_name, column_name, segment_name, index_name, tablespace_name 
from dba_lobs 
where table_name =upper('&1')
or column_name =upper('&1')
or segment_name =upper('&1')
or index_name =upper('&1')
;
