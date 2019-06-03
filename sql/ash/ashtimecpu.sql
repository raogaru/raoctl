select sql_id, cpu_sec from (
select sql_id, round(sum(tm_delta_cpu_time/1000000),0) cpu_sec
from ash
where to_char(sample_time,'yyyy-mm-dd hh24:mi')=to_char(sysdate,'yyyy-mm-dd ')||'&1'
and sql_id is not null
and tm_delta_cpu_time is not null
group by sql_id
) where cpu_sec > 2
order by cpu_sec;
