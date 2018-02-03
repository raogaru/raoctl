--
-- DATA MASK test case table
--
drop table T04_PHONE ;

create table T04_PHONE (
o char(12),
hash_all char(12),
hash_4 char(12),
hash_7 char(12),
star_all char(12),
star_4 char(12),
star_7 char(12),
mask_all char(12),
mask_4 char(12),
mask_7 char(12)
);

create public synonym T04_PHONE for T04_PHONE;

insert /*+ append no logging */ 
into T04_PHONE  (o)
with a as (select 1  from dual connect by level <=1000)
select 
to_char(round(dbms_random.value(100,999),0))||'-'||
to_char(round(dbms_random.value(100,999),0))||'-'||
to_char(round(dbms_random.value(1000,9999),0))
from a a1, a a2
where rownum<5000;
commit;

update T04_PHONE set
hash_all =o,
hash_4 =o,
hash_7 =o,
star_all =o,
star_4 =o,
star_7 =o,
mask_all =o,
mask_4 =o,
mask_7 =o ;
commit;

--
--
--
