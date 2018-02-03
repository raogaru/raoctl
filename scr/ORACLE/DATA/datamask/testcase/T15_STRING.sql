--
-- DATA MASK test case table 
--
drop table T15_STRING ;

create table T15_STRING (
o varchar2(50),
FIXED_STR varchar2(50),
UPPER_STR varchar2(50),
LOWER_STR varchar2(50),
MIXED_STR varchar2(50),
ALPHANUM_STR varchar2(50),
PRINTABLE_STR varchar2(50),
PREFIX_STR varchar2(50),
SUFFIX_STR varchar2(50)
);

insert /*+ append no logging */ 
into T15_STRING  (o)
with a as (select 1  from dual connect by level <=1000)
select 
dbms_random.string('X',10)
from a a1, a a2
where rownum<500;
commit;


update T15_STRING set
FIXED_STR =o,
UPPER_STR =o,
LOWER_STR =o,
MIXED_STR =o,
ALPHANUM_STR =o,
PRINTABLE_STR =o,
PREFIX_STR =o,
SUFFIX_STR =o
;
commit;

--
--
--
