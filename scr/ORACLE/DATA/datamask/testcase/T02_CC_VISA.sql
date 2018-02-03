--
-- DATA MASK test case table 
--
drop table T02_CC_VISA ;

create table T02_CC_VISA (
o char(19),
hash_all char(19),
hash_4 char(19),
hash_6 char(19),
hash_8 char(19),
star_all char(19),
star_4 char(19),
star_6 char(19),
star_8 char(19),
mask_all char(19),
mask_4 char(19),
mask_6 char(19),
mask_8 char(19)
);

insert /*+ append no logging */ 
into T02_CC_VISA  (o)
with a as (select 1  from dual connect by level <=1000)
select 
to_char(round(dbms_random.value(1000,9999),0))||'-'||
to_char(round(dbms_random.value(1000,9999),0))||'-'||
to_char(round(dbms_random.value(1000,9999),0))||'-'||
to_char(round(dbms_random.value(1000,9999),0))
from a a1, a a2
where rownum<500;
commit;

update T02_CC_VISA set
hash_all =o,
hash_4 =o,
hash_6 =o,
hash_8 =o,
star_all =o,
star_4 =o,
star_6 =o,
star_8 =o,
mask_all =o,
mask_4 =o,
mask_6 =o,
mask_8 =o ;
commit;

--
--
--
