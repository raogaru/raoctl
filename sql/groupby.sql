-- 1: table_name 2: column_name
select &2, count(1) from &1 group by &2 order by &2;
