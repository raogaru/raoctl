col owner format a12
col pos format 9
col column_name format a30
select owner, name, column_position pos, column_name 
from dba_part_key_columns
where object_type='TABLE'
order by owner, name, column_position;
