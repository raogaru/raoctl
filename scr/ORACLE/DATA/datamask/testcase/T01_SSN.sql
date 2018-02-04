--
-- DATA MASK test case table 
--
drop table T01_SSN ;

create table T01_SSN (
o char(11),
hash_all char(11),
hash_4 char(11),
hash_5 char(11),
hash_6 char(11),
star_all char(11),
star_4 char(11),
star_5 char(11),
star_6 char(11),
mask_all char(11),
mask_4 char(11),
mask_5 char(11),
mask_6 char(11)
);

insert /*+ append no logging */ 
into T01_SSN  (o)
with a as (select 1  from dual connect by level <=1000)
select 
to_char(round(dbms_random.value(100,999),0))||'-'||
to_char(round(dbms_random.value(10,99),0))||'-'||
to_char(round(dbms_random.value(1000,9999),0)) o
from a a1, a a2
where rownum<500000;
commit;


update T01_SSN set
HASH_ALL =o,
hash_4 =o,
hash_5 =o,
hash_6 =o,
star_all =o,
star_4 =o,
star_5 =o,
star_6 =o,
mask_all =o,
mask_4 =o,
mask_5 =o,
mask_6 =o ;
commit;

--
--
--
