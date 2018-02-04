--
-- DATA MASK test case table
--
drop table T03_CC_AMEX ;

create table T03_CC_AMEX (
o char(17),
hash_all char(17),
hash_5 char(17),
hash_8 char(17),
hash_11 char(17),
star_all char(17),
star_5 char(17),
star_8 char(17),
star_11 char(17),
mask_all char(17),
mask_5 char(17),
mask_8 char(17),
mask_11 char(17)
);

insert /*+ append no logging */ 
into T03_CC_AMEX  (o)
with a as (select 1  from dual connect by level <=1000)
select 
to_char(round(dbms_random.value(1000,9999),0))||'-'||
to_char(round(dbms_random.value(100000,999999),0))||'-'||
to_char(round(dbms_random.value(10000,99999),0))
from a a1, a a2
where rownum<500000;
commit;

update T03_CC_AMEX set
hash_all =o,
hash_5 =o,
hash_8 =o,
hash_11 =o,
star_all =o,
star_5 =o,
star_8 =o,
star_11 =o,
mask_all =o,
mask_5 =o,
mask_8 =o,
mask_11 =o ;
commit;

--
--
--
