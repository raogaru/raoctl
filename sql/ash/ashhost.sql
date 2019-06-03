select sample_time, session_id sid, sql_id, event, time_waited, delta_time 
from ash
where sample_time>trunc(sysdate)
and machine='&1'
order by sample_time;
