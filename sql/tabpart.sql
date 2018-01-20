set linesi 200 trimspool on
col table_owner format a10 
col table_name format a30 
col partition_name format a12 
col tablespace_name format a15 
col high_value format a50

select table_owner, table_name, partition_position pos, partition_name, subpartition_count sp_cnt, tablespace_name, num_rows 
from dba_tab_partitions
--, high_value
where table_name like upper('&1%')
order by table_owner, table_name, partition_position;
