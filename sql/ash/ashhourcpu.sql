-- top cpu consuming sql for a given hour
select sql_id, sum(tm_delta,cpu_time)
from ash
where to_char(sample_time,'yyyy-mm-dd hh24')=to_char(sysdate,'yyyy-mm-dd ')||'&1'
and sql_id is not null
and tm_delta_cpu_time is not null
group by sql_id
order by sum(tm_delta_cpu_time);
