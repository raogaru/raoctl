select hour, cpu 
from (
select to_char(sample_time, 'yyyy-mm-dd hh24') hour, 
round(sum(tm_delta_cpu_time)/1000000,0) cpu
,rpad('>',round(sum(tm_delta_cpu_time)/10000000,0),'*') howmuch_cpu
from ash
where trunc(sample_time)>= trunc(sysdate)-1
and sql_id is not null
and tm_delta_cpu_time is not null
group by 
to_char(sample_time, 'yyyy-mm-dd hh24') 
) 
where cpu>0
order by hour;
