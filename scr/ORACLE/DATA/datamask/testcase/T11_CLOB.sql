--
-- DATA MASK test case table 
--
drop table T11_CLOB ;

create table T11_CLOB (
o clob,
empty clob,
fixed_size clob,
variable_size clob
);

create public synonym T11_CLOB for T11_CLOB;

insert /*+ append no logging */ 
into T11_CLOB  (o)
with a as (select 1  from dual connect by level <=1000)
select 
dbms_random.string('X',round(dbms_random.value(10,50),0))
from a a1, a a2
where rownum<500000;
commit;

update T11_CLOB set
empty =o,
fixed_size =o,
variable_size =o 
;

commit;

--
--
