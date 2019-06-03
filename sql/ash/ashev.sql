select sample_time, session_id sid, sql_id, sql_plan_hash_value, sal_plan_line_id, event, time_waited, delta_time
from ash
where event like '&1%' 
order by sample_time;
