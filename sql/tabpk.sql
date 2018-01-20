col constraint_name format a30
col column_name format a30
col position format 9999
select c.constraint_name , cc.position, cc.column_name
from dba_constraints c, dba_cons_columns cc
where c.constraint_name=cc.constraint_name
and c.table_name=upper('&1')
and c.constraint_type='P'
order by cc.position;
