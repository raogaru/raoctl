--
-- DATA MASK test case table 
--
drop table T01_SSN ;

create table T01_SSN (
o char(11),
hash_all char(11),
hash_4 char(11),
hash_5 char(11),
hash_6 char(11),
star_all char(11),
star_4 char(11),
star_5 char(11),
star_6 char(11),
mask_all char(11),
mask_4 char(11),
mask_5 char(11),
mask_6 char(11)
);

insert /*+ append no logging */ 
into T01_SSN  (o)
with a as (select 1  from dual connect by level <=1000)
select 
to_char(round(dbms_random.value(100,999),0))||'-'||
to_char(round(dbms_random.value(10,99),0))||'-'||
to_char(round(dbms_random.value(1000,9999),0)) o
from a a1, a a2
where rownum<500;
commit;


update T01_SSN set
HASH_ALL =o,
hash_4 =o,
hash_5 =o,
hash_6 =o,
star_all =o,
star_4 =o,
star_5 =o,
star_6 =o,
mask_all =o,
mask_4 =o,
mask_5 =o,
mask_6 =o ;
commit;

--
--
--
--
-- DATA MASK test case table 
--
drop table T02_CC_VISA ;

create table T02_CC_VISA (
o char(19),
hash_all char(19),
hash_4 char(19),
hash_6 char(19),
hash_8 char(19),
star_all char(19),
star_4 char(19),
star_6 char(19),
star_8 char(19),
mask_all char(19),
mask_4 char(19),
mask_6 char(19),
mask_8 char(19)
);

insert /*+ append no logging */ 
into T02_CC_VISA  (o)
with a as (select 1  from dual connect by level <=1000)
select 
to_char(round(dbms_random.value(1000,9999),0))||'-'||
to_char(round(dbms_random.value(1000,9999),0))||'-'||
to_char(round(dbms_random.value(1000,9999),0))||'-'||
to_char(round(dbms_random.value(1000,9999),0))
from a a1, a a2
where rownum<500;
commit;

update T02_CC_VISA set
hash_all =o,
hash_4 =o,
hash_6 =o,
hash_8 =o,
star_all =o,
star_4 =o,
star_6 =o,
star_8 =o,
mask_all =o,
mask_4 =o,
mask_6 =o,
mask_8 =o ;
commit;

--
--
--
--
-- DATA MASK test case table
--
drop table T03_CC_AMEX ;

create table T03_CC_AMEX (
o char(17),
hash_all char(17),
hash_5 char(17),
hash_8 char(17),
hash_11 char(17),
star_all char(17),
star_5 char(17),
star_8 char(17),
star_11 char(17),
mask_all char(17),
mask_5 char(17),
mask_8 char(17),
mask_11 char(17)
);

insert /*+ append no logging */ 
into T03_CC_AMEX  (o)
with a as (select 1  from dual connect by level <=1000)
select 
to_char(round(dbms_random.value(1000,9999),0))||'-'||
to_char(round(dbms_random.value(100000,999999),0))||'-'||
to_char(round(dbms_random.value(10000,99999),0))
from a a1, a a2
where rownum<500;
commit;

update T03_CC_AMEX set
hash_all =o,
hash_5 =o,
hash_8 =o,
hash_11 =o,
star_all =o,
star_5 =o,
star_8 =o,
star_11 =o,
mask_all =o,
mask_5 =o,
mask_8 =o,
mask_11 =o ;
commit;

--
--
--
--
-- DATA MASK test case table
--
drop table T04_PHONE ;

create table T04_PHONE (
o char(12),
hash_all char(12),
hash_4 char(12),
hash_7 char(12),
star_all char(12),
star_4 char(12),
star_7 char(12),
mask_all char(12),
mask_4 char(12),
mask_7 char(12)
);

create public synonym T04_PHONE for T04_PHONE;

insert /*+ append no logging */ 
into T04_PHONE  (o)
with a as (select 1  from dual connect by level <=1000)
select 
to_char(round(dbms_random.value(100,999),0))||'-'||
to_char(round(dbms_random.value(100,999),0))||'-'||
to_char(round(dbms_random.value(1000,9999),0))
from a a1, a a2
where rownum<5000;
commit;

update T04_PHONE set
hash_all =o,
hash_4 =o,
hash_7 =o,
star_all =o,
star_4 =o,
star_7 =o,
mask_all =o,
mask_4 =o,
mask_7 =o ;
commit;

--
--
--
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
where rownum<500;
commit;

update T11_CLOB set
empty =o,
fixed_size =o,
variable_size =o 
;

commit;

--
--
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
--
-- DATA MASK test case table 
--
drop table T13_DATE ;

create table T13_DATE (
o date,
RANDOM_DT date,
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
with a as (select 1  from dual connect by level <=1000)
select 
trunc(sysdate+dbms_random.value(0,366))
from a a1, a a2
where rownum<500;
commit;

update T13_DATE set
RANDOM_DT =o,
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
--
-- DATA MASK test case table 
--
drop table T14_TIME ;

create table T14_TIME (
o timestamp with local time zone,
RANDOM_TM timestamp with local time zone,
FIXED_TM timestamp with local time zone,
--
PLUS_HH timestamp with local time zone,
MINUS_HH timestamp with local time zone,
--
PLUS_MI timestamp with local time zone,
MINUS_MI timestamp with local time zone,
--
PLUS_SS timestamp with local time zone,
MINUS_SS timestamp with local time zone
);

create public synonym T14_TIME for T14_TIME;

insert /*+ append no logging */ 
into T14_TIME  (o)
with a as (select 1  from dual connect by level <=1000)
select 
systimestamp+dbms_random.value(0,366)
from a a1, a a2
where rownum<500;
commit;

update T14_TIME set
RANDOM_TM =o,
FIXED_TM =o,
PLUS_HH =o,
MINUS_HH=o,
PLUS_MI =o,
MINUS_MI=o,
PLUS_SS =o,
MINUS_SS=o
;

commit;

--
--
--
-- DATA MASK test case table 
--
drop table T15_STRING ;

create table T15_STRING (
o varchar2(50),
FIXED_STR varchar2(50),
UPPER_STR varchar2(50),
LOWER_STR varchar2(50),
MIXED_STR varchar2(50),
ALPHANUM_STR varchar2(50),
PRINTABLE_STR varchar2(50),
PREFIX_STR varchar2(50),
SUFFIX_STR varchar2(50)
);

insert /*+ append no logging */ 
into T15_STRING  (o)
with a as (select 1  from dual connect by level <=1000)
select 
dbms_random.string('X',10)
from a a1, a a2
where rownum<500;
commit;


update T15_STRING set
FIXED_STR =o,
UPPER_STR =o,
LOWER_STR =o,
MIXED_STR =o,
ALPHANUM_STR =o,
PRINTABLE_STR =o,
PREFIX_STR =o,
SUFFIX_STR =o
;
commit;

--
--
--
--
-- DATA MASK test case table 
--
drop table T16_NUMBER ;

create table T16_NUMBER (
o number,
FIXED_NUM number,
PLUS_NUM number,
MINUS_NUM number,
RAND_INT number,
RAND_INT_BETWEEN number,
RAND_DEC number
);

insert /*+ append no logging */ 
into T16_NUMBER  (o)
with a as (select 1  from dual connect by level <=1000)
select 
round(dbms_random.value(1000000,2000000),2)
from a a1, a a2
where rownum<500;
commit;


update T16_NUMBER set
FIXED_NUM =o,
PLUS_NUM =o,
MINUS_NUM =o,
RAND_INT =o,
RAND_INT_BETWEEN =o,
RAND_DEC =o
;
commit;

--
--
--
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
