--
-- DATA MASK test case table 
--
drop table T12_BLOB ;

create table T12_BLOB (
o blob,
empty blob,
fixed_size blob,
variable_size blob
);

create public synonym T12_BLOB for T12_BLOB;

insert 
into T12_BLOB  (o)
with a as (select 1  from dual connect by level <=1000)
select 
to_blob(utl_raw.cast_to_raw(dbms_random.string('P',round(dbms_random.value(100,500),0))))
from a a1, a a2
where rownum<50;
commit;

update T12_BLOB set
empty =o,
fixed_size =o,
variable_size =o 
;

commit;

--
--
