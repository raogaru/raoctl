--
-- DATA MASK test case table 
--
drop table T11_CLOB ;

create table T11_CLOB (
o clob,
a clob,
f clob,
v clob
);

create public synonym T11_CLOB for T11_CLOB;

insert /*+ append no logging */ 
into T11_CLOB  (o)
select 
dbms_random.string('X',round(dbms_random.value(10,50),0))
from  dual
connect by leveL <= 250;
commit;

update T11_CLOB set
a =o,
f =o,
v =o 
;

commit;

--
--
