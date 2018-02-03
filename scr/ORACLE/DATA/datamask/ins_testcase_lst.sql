insert into data_mask_lst 
select data_mask_seq.nextval, owner, table_name, column_name,'TEST_ALG',null,null
from all_tab_columns
where owner='&1'
and table_name='&2'
order by column_id
;
