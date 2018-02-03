--
-- DATA MASK test case table 
--
drop table T16_NUMBER ;

create table T16_NUMBER (
o number,
FIXED_NUM number,
PLUS_NUM number,
MINUS_NUM number,
RAND_INT number,
RAND_INT_BETWEEN number,
RAND_DEC number
);

insert /*+ append no logging */ 
into T16_NUMBER  (o)
with a as (select 1  from dual connect by level <=1000)
select 
round(dbms_random.value(1000000,2000000),2)
from a a1, a a2
where rownum<500;
commit;


update T16_NUMBER set
FIXED_NUM =o,
PLUS_NUM =o,
MINUS_NUM =o,
RAND_INT =o,
RAND_INT_BETWEEN =o,
RAND_DEC =o
;
commit;

--
--
--
