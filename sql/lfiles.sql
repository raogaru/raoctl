set pagesi 1000 linesi 120 trimspool on
col member format a45
select l.thread#,lf.group#,lf.type,lf.member 
from v$logfile lf, v$log l 
where l.group#=lf.group#
order by l.thread#, lf.group#;
