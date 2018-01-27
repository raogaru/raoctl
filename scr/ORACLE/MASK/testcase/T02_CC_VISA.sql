--
-- DATA MASK test case table 
--
drop table T02_CC_VISA ;

create table T02_CC_VISA (
o char(19),
ha char(19),
h4 char(19),
h6 char(19),
h8 char(19),
sa char(19),
s4 char(19),
s6 char(19),
s8 char(19),
ma char(19),
m4 char(19),
m6 char(19),
m8 char(19)
);

create public synonym T02_CC_VISA for SYS.T02_CC_VISA;

insert /*+ append no logging */ 
into T02_CC_VISA  (o)
select 
to_char(round(dbms_random.value(1000,9999),0))||'-'||
to_char(round(dbms_random.value(1000,9999),0))||'-'||
to_char(round(dbms_random.value(1000,9999),0))||'-'||
to_char(round(dbms_random.value(1000,9999),0))
from  dual
connect by leveL <= 350;
commit;

update T02_CC_VISA set
ha =o,
h4 =o,
h6 =o,
h8 =o,
sa =o,
s4 =o,
s6 =o,
s8 =o,
ma =o,
m4 =o,
m6 =o,
m8 =o ;
commit;

--
--
--
