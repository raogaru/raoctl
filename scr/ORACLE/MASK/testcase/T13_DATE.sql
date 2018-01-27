--
-- DATA MASK test case table 
--
drop table T13_DATE ;

create table T13_DATE (
o date,
FIXED_DT date,
PAST_DT date,
FUTURE_DT date,
ADD_DD date,
ADD_MM date,
ADD_YY date
);

create public synonym T13_DATE for T13_DATE;

insert /*+ append no logging */ 
into T13_DATE  (o)
select 
trunc(sysdate+dbms_random.value(0,366))
from  dual
connect by leveL <= 250;
commit;

update T13_DATE set
FIXED_DT =o,
PAST_DT =o,
FUTURE_DT =o,
ADD_DD =o,
ADD_MM =o,
ADD_YY =o 
;

commit;

--
--
