select sample_time, session_id sid, sql_id, sql_plan_hash_value, sal_plan_line_id, event, time_waited, delta_time
from ash
where to_char(sample_time,'yyyy-mm-dd hh24:mi')=to_char(sysdate,'yyyy-mm-dd ')||'&1'
order by sample_time;
