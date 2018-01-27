--
-- DATA MASK test case table 
--
drop table T01_SSN ;

create table T01_SSN (
o char(11),
ha char(11),
h4 char(11),
h5 char(11),
h6 char(11),
sa char(11),
s4 char(11),
s5 char(11),
s6 char(11),
ma char(11),
m4 char(11),
m5 char(11),
m6 char(11)
);

create public synonym T01_SSN for SYS.T01_SSN;

insert /*+ append no logging */ 
into T01_SSN  (o)
select 
to_char(round(dbms_random.value(100,999),0))||'-'||
to_char(round(dbms_random.value(10,99),0))||'-'||
to_char(round(dbms_random.value(1000,9999),0)) o
from  dual
connect by leveL <= 350;
commit;

update T01_SSN set
ha =o,
h4 =o,
h5 =o,
h6 =o,
sa =o,
s4 =o,
s5 =o,
s6 =o,
ma =o,
m4 =o,
m5 =o,
m6 =o ;
commit;

--
--
--
