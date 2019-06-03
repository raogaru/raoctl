select hour_min, cpu 
from (
select to_char(sample_time, 'yyyy-mm-dd hh24:mi') hour_min, 
round(sum(tm_delta_cpu_time)/1000000,0) cpu
,rpad('>',round(sum(tm_delta_cpu_time)/10000000,0),'*') howmuch_cpu
from ash
where to_char(sample_time, 'yyyy-mm-dd hh24') = to_char(sysdate, 'yyyy-mm-dd ')||'&1'
and sql_id is not null
and tm_delta_cpu_time is not null
group by 
to_char(sample_time, 'yyyy-mm-dd hh24:mi') 
) 
where cpu>0
order by hour_min;
