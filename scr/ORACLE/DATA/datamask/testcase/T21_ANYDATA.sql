--
-- DATA MASK test case table 
--

-- OBJECT specification
CREATE OR REPLACE TYPE T21_ANYDATA_emp_TYP AS OBJECT (
  emp_typ CHAR(1),
  emp_name VARCHAR2(30),
  emp_id   NUMBER,
  emp_hired DATE,
  emp_login TIMESTAMP
);
/

drop table T21_ANYDATA ;

create table T21_ANYDATA (
id number,
typ VARCHAR2(30),
my_data SYS.ANYDATA
);

-- insert rows
insert /*+ append no logging */ 
into T21_ANYDATA  (id)
with a as (select level  from dual connect by level <=1000)
select rownum
from a a1, a a2
where rownum<1000;
commit;

-- initiaize data type
declare
	i number:=0;
begin
	for c in (select id from T21_ANYDATA order by id)
	loop
	i:=i+1;
	if i = 10 then
		i:=1;
	end if;
	update T21_ANYDATA set typ= (case i
	when 1 then 'CHAR'
	when 2 then 'VARCHAR2' 
	when 3 then 'NUMBER' 
	when 4 then 'DATE' 
	when 5 then 'TIMESTAMP' 
	when 6 then 'CLOB' 
	when 7 then 'BLOB' 
	when 8 then 'RAW' 
	when 9 then 'OBJECT'
	else 'Unknown'
	end
	) where id=c.id;
	end loop;
end;
/

-- update anydata column with respective data types
-- sys.anydata conversion not working for clob and blob hence added not in clause
update T21_ANYDATA set my_data = (
CASE typ
when 'CHAR' 	then SYS.ANYDATA.convertCHAR(dbms_random.string('X',10)) 
when 'VARCHAR2' then SYS.ANYDATA.convertVARCHAR2(dbms_random.string('X',round(dbms_random.value(10,50),0))) 
when 'NUMBER'  	then SYS.ANYDATA.convertNUMBER(round(dbms_random.value(1000000,2000000),2)) 
when 'DATE'  	then SYS.ANYDATA.convertDATE(trunc(sysdate+dbms_random.value(0,366))) 
when 'TIMESTAMP'  then SYS.ANYDATA.convertTIMESTAMP(systimestamp+dbms_random.value(0,366)) 
when 'CLOB'  	then SYS.ANYDATA.convertCLOB(dbms_random.string('X',round(dbms_random.value(10,50),0))) 
when 'BLOB'  	then SYS.ANYDATA.convertBLOB(to_blob(utl_raw.cast_to_raw(dbms_random.string('P',round(dbms_random.value(100,500),0))))) 
when 'RAW'  	then SYS.ANYDATA.convertRAW(utl_raw.cast_to_raw(dbms_random.string('P',round(dbms_random.value(100,500),0)))) 
when 'OBJECT' 	then SYS.ANYDATA.convertOBJECT(T21_ANYDATA_emp_TYP('E','FirstName LastName',123, sysdate, systimestamp)) 
else null
end
)
where typ not in ('CLOB','BLOB'); 
commit;

create or replace force view T21_ANYDATA_VIEW as
select id,typ, 
(case typ
when 'CHAR' 	then SYS.ANYDATA.accessCHAR(my_data)
when 'VARCHAR2' then SYS.ANYDATA.accessVARCHAR2(my_data)
when 'NUMBER'  	then SYS.ANYDATA.accessNUMBER(my_data)
when 'DATE'  	then SYS.ANYDATA.accessDATE(my_data)
when 'TIMESTAMP'  then SYS.ANYDATA.accessTIMESTAMP(my_data)
when 'CLOB'  	then SYS.ANYDATA.accessCLOB(my_data)
when 'BLOB'  	then SYS.ANYDATA.accessBLOB(my_data)
when 'RAW'  	then SYS.ANYDATA.accessRAW(my_data)
else null
end) data_value
from T21_ANYDATA
where typ='CHAR';

--
--
--
