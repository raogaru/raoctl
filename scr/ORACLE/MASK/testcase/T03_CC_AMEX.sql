--
-- DATA MASK test case table
--
drop table T03_CC_AMEX ;

create table T03_CC_AMEX (
o char(17),
ha char(17),
h5 char(17),
h8 char(17),
h11 char(17),
sa char(17),
s5 char(17),
s8 char(17),
s11 char(17),
ma char(17),
m5 char(17),
m8 char(17),
m11 char(17)
);

create public synonym T03_CC_AMEX for SYS.T03_CC_AMEX;

insert /*+ append no logging */ 
into T03_CC_AMEX  (o)
select 
to_char(round(dbms_random.value(1000,9999),0))||'-'||
to_char(round(dbms_random.value(100000,999999),0))||'-'||
to_char(round(dbms_random.value(10000,99999),0))
from  dual
connect by leveL <= 350;
commit;

update T03_CC_AMEX set
ha =o,
h5 =o,
h8 =o,
h11 =o,
sa =o,
s5 =o,
s8 =o,
s11 =o,
ma =o,
m5 =o,
m8 =o,
m11 =o ;
commit;

--
--
--
