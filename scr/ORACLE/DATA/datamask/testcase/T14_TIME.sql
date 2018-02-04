--
-- DATA MASK test case table 
--
drop table T14_TIME ;

create table T14_TIME (
o timestamp with local time zone,
RANDOM_TM timestamp with local time zone,
FIXED_TM timestamp with local time zone,
--
PLUS_HH timestamp with local time zone,
MINUS_HH timestamp with local time zone,
--
PLUS_MI timestamp with local time zone,
MINUS_MI timestamp with local time zone,
--
PLUS_SS timestamp with local time zone,
MINUS_SS timestamp with local time zone
);

create public synonym T14_TIME for T14_TIME;

insert /*+ append no logging */ 
into T14_TIME  (o)
with a as (select 1  from dual connect by level <=1000)
select 
systimestamp+dbms_random.value(0,366)
from a a1, a a2
where rownum<500000;
commit;

update T14_TIME set
RANDOM_TM =o,
FIXED_TM =o,
PLUS_HH =o,
MINUS_HH=o,
PLUS_MI =o,
MINUS_MI=o,
PLUS_SS =o,
MINUS_SS=o
;

commit;

--
--
