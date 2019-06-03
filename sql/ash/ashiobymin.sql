select hour_min
, io_read_mb
, io_write_mb
, io_read_mb+io_write_mb io_total_mb
from (
select hour_min
, round(io_read_bytes/1024/1024,0) io_read_mb
, round(io_write_bytes/1024/1024,0) io_write_mb 
from (
select to_char(sample_time,'yyyy-mm-dd hh24:mi') hour_min
,sum(delta_read_io_bytes) io_read_bytes
,sum(delta_write_io_bytes) io_write_bytes
from ash
where to_char(sample_time,'yyyy-mm-dd hh24')=to_char(sysdate,'yyyy-mm-dd ')||'&1'
and (delta_read_io_bytes+delta_write_io_bytes)>0
and sql_id is not null
and tm_delta_cpu_time is not null
group by to_char(sample_time,'yyyy-mm-dd hh24:mi')
)
where io_read_bytes+io_write_bytes >0
)
order by hour_min;
