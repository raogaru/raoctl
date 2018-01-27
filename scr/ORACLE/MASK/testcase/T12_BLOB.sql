--
-- DATA MASK test case table 
--
drop table T12_BLOB ;

create table T12_BLOB (
o blob,
a blob,
f blob,
v blob
);

create public synonym T12_BLOB for T12_BLOB;

/*
insert 
into T12_BLOB  (o)
select 
dbms_random.string('P',round(dbms_random.value(10,50),0))
from  dual
connect by leveL <= 250;
commit;
*/

declare
   v_clob        clob:=null;
   v_blob        blob:=null;
   v_dest_offset integer := 1;
   v_src_offset  integer := 1;
   v_warn        integer;
   v_ctx         integer := dbms_lob.default_lang_ctx;
begin
   for idx in 1..5
   loop
     v_clob := v_clob || dbms_random.string('p', 1000);
   end loop;
   dbms_lob.createtemporary( v_blob, false );
   dbms_lob.converttoblob(v_blob,
                          v_clob,
                          dbms_lob.lobmaxsize,
                          v_dest_offset,
                          v_src_offset,
                          dbms_lob.default_csid,
                          v_ctx,
                          v_warn);
   insert into T12_BLOB (o)
     select v_blob from dual
     connect by level <= 250;
end;
/

update T12_BLOB set
a =o,
f =o,
v =o 
;

commit;

--
--
