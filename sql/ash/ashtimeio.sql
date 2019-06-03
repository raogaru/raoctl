select sql_id, io_read_mb, io_write_mb, io_read_mb+io_write_mb io_total_mb
from (
select sql_id
, round(sum(delta_read_io_bytes)/1024/1024,0) io_read_mb
, round(sum(delta_write_io_bytes)/1024/1024,0) io_write_mb 
from ash
where to_char(sample_time,'yyyy-mm-dd hh24:mi')=to_char(sysdate,'yyyy-mm-dd ')||'&1'
and delta_read_io_bytes+delta_write_io_bytes>0
and tm_delta_cpu_time is not null
group by sql_id
) where io_read_mb+io_write_mb>100
order by io_read_mb;
