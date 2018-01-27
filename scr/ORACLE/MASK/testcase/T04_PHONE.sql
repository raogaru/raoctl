--
-- DATA MASK test case table
--
drop table T04_PHONE ;

create table T04_PHONE (
o char(12),
ha char(12),
h4 char(12),
h7 char(12),
sa char(12),
s4 char(12),
s7 char(12),
ma char(12),
m4 char(12),
m7 char(12)
);

create public synonym T04_PHONE for T04_PHONE;

insert /*+ append no logging */ 
into T04_PHONE  (o)
select 
to_char(round(dbms_random.value(100,999),0))||'-'||
to_char(round(dbms_random.value(100,999),0))||'-'||
to_char(round(dbms_random.value(1000,9999),0))
from  dual
connect by leveL <= 250;
commit;

update T04_PHONE set
ha =o,
h4 =o,
h7 =o,
sa =o,
s4 =o,
s7 =o,
ma =o,
m4 =o,
m7 =o ;
commit;

--
--
--
