select hour
, io_read_mb
, io_write_mb
, io_read_mb+io_write_mb io_total_mb
from (
select hour
, round(io_read_bytes/1024/1024,0) io_read_mb
, round(io_write_bytes/1024/1024,0) io_write_mb 
from (
select to_char(sample_time,'yyyy-mm-dd hh24') hour
,sum(delta_read_io_bytes) io_read_bytes
,sum(delta_write_io_bytes) io_write_bytes
from ash
where trunc(sample_time)>=trunc(sysdate)-1
and (delta_read_io_bytes+delta_write_io_bytes)>0
and sql_id is not null
and tm_delta_cpu_time is not null
group by to_char(sample_time,'yyyy-mm-dd hh24')
)
where io_read_bytes+io_write_bytes >0
)
order by hour;
