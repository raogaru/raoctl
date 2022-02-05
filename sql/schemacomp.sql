/*  
This script compares the schema objects.
THE SCRIPT COMPARES THE FOLLOWING:
- Existence of tables
- Existence of columns
- Column definitions
- Existence of indexes
- Index definitions (column usage)
- Existence of constraints
- Constraint definitions (table, type and reference)
- Constraint column usage (for unique, primary key and foreign keys)
- Existence of synonyms
- Existence of views
- Existence of triggers
- Definition of triggers
- Existence of procedure/packages/functions
- Definition of procedures/packages/functions
The script drops and creates a few temporary objects with prefix provided as input
*/

undef rc_prefix
undef a
undef b
undef c
undef USR_A
undef PWD_A 
undef TNS_A
undef USR_B
undef PWD_B 
undef TNS_B
undef v_nowtime
undef v_yyyymmdd

set markup HTML ON
set verify off linesize 132 feedback off trimspool on pagesi 0
set long 1000
column c new_val v_nowtime
select to_char(sysdate,'DD-MON-YYYY-HH24:MI') c from dual;
column c2 new_val v_yyyymmdd
select to_char(sysdate,'YYYYMMDD_HH24MISS') c2 from dual;
set pagesi 1000

define USR_A='&1'
--define PWD_A='xxxx'
define TNS_A='@&2'
--
define USR_B='&3'
--define PWD_B='xxxx'
define TNS_B='@&4'
--
define rc_prefix='RC_'
define rc_SPOOL='&5'

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- DROP PREVIOUS COMPARISION OBJECTS (IF EXISTS)
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT
declare
v_sql varchar2(1000);
begin
	begin
	for c in (select table_name from user_tables where table_name like '&rc_prefix%')
	loop
		v_sql:= 'DROP TABLE '||c.table_name;
		dbms_output.put_line(v_sql);
		execute immediate v_sql;
	end loop;
	exception
	when others then
	null;
	end;
end;
/

--spool SCHDIFF_REPORT_&USR_A._&TNS_A._&USR_B._&TNS_B._&v_yyyymmdd..html
--spool /Users/rvangar/Downloads/SchemaCompare_&USR_A._&v_yyyymmdd..html
--spool SCHDIFF_REPORT_&v_yyyymmdd..rpt
spool &rc_SPOOL
PROMPT # ======================================================================
PROMPT # SCHEMA DIFFERENCES REPORT
PROMPT #
PROMPT # Date    : &v_nowtime        
PROMPT # SCHEMA_A: &USR_A&TNS_A
PROMPT # SCHEMA_B: &USR_B&TNS_B
PROMPT # ======================================================================
PROMPT

--set echo on feed on
--create database link &TNS_A connect to &USR_A identified by &PWD_A using '&TNS_A';
--create database link &TNS_B connect to &USR_B identified by &PWD_B using '&TNS_B';

set echo off feed off
whenever sqlerror exit 1;

PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # OBJECT COUNT INFORMATION
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select a.object_type, a.object_count a_object_count, b.object_count b_object_count
from
(select object_type, count(1) object_count from all_objects&TNS_A where owner='&USR_A' group by object_type) a
FULL OUTER JOIN 
(select object_type, count(1) object_count from all_objects&TNS_B where owner='&USR_B' group by object_type) b
on a.object_type=b.object_type
/

PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # REPORT BEGIN
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--RAOTEMP column table_name format a50
--RAOTEMP column index_name format a50
--RAOTEMP column column_name format a50
--  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  TABLES COMMON BETWEEN &USR_A.&TNS_A AND &USR_B.&TNS_B
--  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
create table &rc_prefix.common_tables as
select table_name from all_tables&TNS_A where owner='&USR_A'
intersect
select table_name from all_tables&TNS_B where owner='&USR_B'
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # TABLES MISSING IN &USR_A.&TNS_A 
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select table_name from all_tables&TNS_B where owner='&USR_B'
minus
select table_name from all_tables&TNS_A where owner='&USR_A'
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # TABLES MISSING IN &USR_B.&TNS_B 
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select table_name from all_tables&TNS_A where owner='&USR_A'
minus
select table_name from all_tables&TNS_B where owner='&USR_B'
/


--RAOPROMPT
--RAOPROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--RAOPROMPT PARTITION TYPE DIFFERENCES FOR COMMON TABLES
--RAOPROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--RAOselect table_name, a.partitioning_type a_partitioning_type, b.partitioning_type b_partitioning_type
--RAOfrom all_part_tables&TNS_A a,
--RAOfrom all_part_tables&TNS_B b
--RAOwhere a.owner='&USR_A' 
--RAOand  a.owner=b.owner
--RAOand a.table_name=b.table_name
--RAOand a.partitioning_type!=b.partitioning_type
--RAO/
--RAO
--RAO
--RAOPROMPT
--RAOPROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--RAOPROMPT # PARTITION COLUMN DIFFERENCES FOR COMMON TABLES
--RAOPROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--RAOselect name, object_type, a.part_cols a_part_cols, b.part_cols b_part_cols
--RAOfrom 
--RAO(select name, object_type, listagg(column_name,',') WITHIN GROUP (ORDER BY column_position) AS part_cols
--RAOfrom all_part_key_columns&TNS_A
--RAOwhere owner='&USR_A'
--RAOgroup by name,object_type) a,
--RAO(select name, object_type, listagg(column_name,',') WITHIN GROUP (ORDER BY column_position) AS part_cols
--RAOfrom all_part_key_columns&TNS_B
--RAOwhere owner='&USR_B'
--RAOgroup by name,object_type) b
--RAOwhere a.name=b.name
--RAOand a.object_type=b.object_type
--RAOand a.part_cols!=b.part_cols
--RAO/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # COLUMNS MISSING IN &USR_A.&TNS_A FOR COMMON TABLES
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select table_name,column_name from all_tab_columns&TNS_B 
where owner='&USR_B' and table_name in (select table_name from &rc_prefix.common_tables)
minus
select table_name,column_name from all_tab_columns&TNS_A
where owner='&USR_A' and table_name in (select table_name from &rc_prefix.common_tables)
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # COLUMNS MISSING IN &USR_B.&TNS_B FOR COMMON TABLES
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select table_name,column_name from all_tab_columns&TNS_A
where owner='&USR_A' and table_name in (select table_name from &rc_prefix.common_tables)
minus
select table_name,column_name from all_tab_columns&TNS_B
where owner='&USR_B' and table_name in (select table_name from &rc_prefix.common_tables)
/

PROMPT
--  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  create tables to identify column definition differences
--  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
create table &rc_prefix.diff_cols1
(table_name varchar2(128), column_name varchar2(128), data_type varchar2(128), data_length number,
data_precision number, data_scale number, nullable varchar2(1), column_id number, default_length number);

create table &rc_prefix.diff_cols2
(table_name varchar2(128), column_name varchar2(128), data_type varchar2(128), data_length number,
data_precision number, data_scale number, nullable varchar2(1), column_id number, default_length number);

-- ----------------------------------------
-- insert into &rc_prefix.diff_cols1

DECLARE
cursor c1 is
select l.table_name,l.column_name,l.data_type,l.data_length,l.data_precision,l.data_scale,l.nullable,l.column_id,l.default_length 
from all_tab_columns&TNS_A l, &rc_prefix.common_tables c
where l.owner='&USR_A' and c.table_name=l.table_name ;

TYPE rec is record (
 table_name varchar2(128), column_name varchar2(128), data_type varchar2(128), data_length number,
 data_precision number, data_scale number, nullable varchar2(1), column_id number, default_length number);
c rec;
BEGIN
 open c1;
 loop
   fetch c1 into c;
    exit when c1%NOTFOUND;
    insert into &rc_prefix.diff_cols1 values 
    (c.table_name,c.column_name,c.data_type,c.data_length,c.data_precision,c.data_scale,c.nullable,c.column_id,c.default_length);
 end loop;
end;
/

-- ----------------------------------------
-- insert into &rc_prefix.diff_cols2

DECLARE
cursor c1 is
select l.table_name,l.column_name,l.data_type,l.data_length,l.data_precision,l.data_scale,l.nullable,l.column_id,l.default_length 
from all_tab_columns&TNS_B l, &rc_prefix.common_tables c
where l.owner='&USR_B' and c.table_name=l.table_name ;

TYPE rec is record (
 table_name varchar2(128), column_name varchar2(128), data_type varchar2(128), data_length number,
 data_precision number, data_scale number, nullable varchar2(1), column_id number, default_length number);
c rec;
begin
 open c1;
 loop
   fetch c1 into c;
    exit when c1%NOTFOUND;
    insert into &rc_prefix.diff_cols2 values 
    (c.table_name,c.column_name,c.data_type,c.data_length,c.data_precision,c.data_scale,c.nullable,c.column_id,c.default_length);
 end loop;
end;
/

-- ----------------------------------------

--RAOTEMP column table_name format a50
--RAOTEMP column column_name format a50
--RAOTEMP column param format a15
set arraysize 1
--set maxdata 32000
set maxdata 4000
set linesi 1000 trims on
--RAOTEMP column A_value format a50
--RAOTEMP column B_value format a50

PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # DIFFERENCE IN COLUMN DEFINITIONS FOR COMMON TABLES
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select l.table_name,l.column_name,'DATA_TYPE' param ,l.data_type A_value,r.data_type B_value
from &rc_prefix.diff_cols1 l, &rc_prefix.diff_cols2 r 
where l.table_name=r.table_name and l.column_name=r.column_name and l.data_type != r.data_type
union
select l.table_name,l.column_name,'DATA_LENGTH',to_char(l.data_length), to_char(r.data_length) 
from &rc_prefix.diff_cols1 l, &rc_prefix.diff_cols2 r 
where l.table_name=r.table_name and l.column_name=r.column_name and l.data_length != r.data_length
union
select l.table_name,l.column_name,'DATA_PRECISION', to_char(l.data_precision),to_char(r.data_precision) 
from &rc_prefix.diff_cols1 l, &rc_prefix.diff_cols2 r 
where l.table_name=r.table_name and l.column_name=r.column_name and l.data_precision != r.data_precision
union
select l.table_name,l.column_name,'DATA_SCALE',to_char(l.DATA_SCALE), to_char(r.data_scale) 
from &rc_prefix.diff_cols1 l, &rc_prefix.diff_cols2 r 
where l.table_name=r.table_name and l.column_name=r.column_name and l.data_scale != r.data_scale
union
select l.table_name,l.column_name,'NULLABLE',l.nullable,r.nullable 
from &rc_prefix.diff_cols1 l, &rc_prefix.diff_cols2 r 
where l.table_name=r.table_name and l.column_name=r.column_name and l.nullable != r.nullable
--RAOunion
--RAOselect l.table_name,l.column_name,'COLUMN_ID',to_char(l.column_id), to_char(r.column_id) 
--RAOfrom &rc_prefix.diff_cols1 l, &rc_prefix.diff_cols2 r 
--RAOwhere l.table_name=r.table_name and l.column_name=r.column_name and l.column_id != r.column_id
union
select l.table_name,l.column_name,'DEFAULT_LENGTH',to_char(l.default_length), to_char(r.default_length) 
from &rc_prefix.diff_cols1 l, &rc_prefix.diff_cols2 r 
where l.table_name=r.table_name and l.column_name=r.column_name and l.default_length != r.default_length
--RAOX union
--RAOX select l.table_name,l.column_name,'DATA_DEFAULT' , l.data_default , r.data_default
--RAOX from &rc_prefix.diff_cols1 l, &rc_prefix.diff_cols2 r 
--RAOX where l.table_name=r.table_name and l.column_name=r.column_name and l.data_default != r.data_default
order by 1,2
/                
         
create table &rc_prefix.common_indexes as
select table_name, index_name from all_indexes&TNS_A
where table_owner='&USR_A' and table_name in (select table_name from &rc_prefix.common_tables)
intersect
select table_name, index_name from all_indexes&TNS_B
where table_owner='&USR_B' and table_name in (select table_name from &rc_prefix.common_tables)
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # INDEXES MISSING IN &USR_A.&TNS_A FOR COMMON TABLES BY NAMES
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select rownum,table_name, index_name from (
select table_name, index_name from all_indexes&TNS_B
where table_owner='&USR_B' and table_name in (select table_name from &rc_prefix.common_tables)
minus
select table_name, index_name from &rc_prefix.common_indexes
)
order by table_name,index_name
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # INDEXES MISSING IN &USR_A.&TNS_A FOR COMMON TABLES BY COLUMN_LIST
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set linesi 1000 trims on 
--RAOTEMP col table_name format a50
--RAOTEMP col ind_cols format a1000
select rownum,table_name, ind_cols
from (
(select table_name, ind_cols from (
select table_name, index_name, listagg(column_name,',') WITHIN GROUP (ORDER BY column_position) AS ind_cols
from all_ind_columns&TNS_B
where index_owner='&USR_B' and table_name in (select table_name from &rc_prefix.common_tables)
group by table_name,index_name))
minus
(select table_name, ind_cols from (
select table_name, index_name, listagg(column_name,',') WITHIN GROUP (ORDER BY column_position) AS ind_cols
from all_ind_columns&TNS_A
where index_owner='&USR_A'
group by table_name,index_name))
)
order by table_name,ind_cols
/

PROMPT

PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # INDEXES MISSING IN &USR_B.&TNS_B FOR COMMON TABLES BY NAMES
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select rownum,table_name, index_name from (
select table_name, index_name from all_indexes&TNS_A
where table_owner='&USR_A' and table_name in (select table_name from &rc_prefix.common_tables)
minus
select table_name, index_name from &rc_prefix.common_indexes
)
order by table_name,index_name
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # INDEXES MISSING IN &USR_B.&TNS_B FOR COMMON TABLES BY COLUMN_LIST
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set linesi 1000 trims on 
--RAOTEMP col table_name format a50
--RAOTEMP col ind_cols format a1000
select rownum,table_name, ind_cols
from (
(select table_name, ind_cols from (
select table_name, index_name, listagg(column_name,',') WITHIN GROUP (ORDER BY column_position) AS ind_cols
from all_ind_columns&TNS_A
where index_owner='&USR_A' and table_name in (select table_name from &rc_prefix.common_tables)
group by table_name,index_name))
minus
(select table_name, ind_cols from (
select table_name, index_name, listagg(column_name,',') WITHIN GROUP (ORDER BY column_position) AS ind_cols
from all_ind_columns&TNS_B
where index_owner='&USR_B'
group by table_name,index_name))
)
order by table_name, ind_cols
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # INDEX NAMES DIFFERENT FOR SAME SET OF COLUMN_LIST
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set linesi 1000 trims on 
--RAOTEMP col table_name format a50
--RAOTEMP col ind_columns format a1000
--RAOTEMP col index_name_on_A format a50
--RAOTEMP col index_name_on_B format a50
select rownum,table_name, ind_cols, index_name_on_A, index_name_on_B
from (
select a.table_name, a.ind_cols, a.index_name index_name_on_A, b.index_name index_name_on_B
from
(select table_name, index_name, ind_cols from (
select table_name, index_name, listagg(column_name,',') WITHIN GROUP (ORDER BY column_position) AS ind_cols
from all_ind_columns&TNS_A
where index_owner='&USR_A'
group by table_name,index_name)) a,
(select table_name, index_name, ind_cols from (
select table_name, index_name, listagg(column_name,',') WITHIN GROUP (ORDER BY column_position) AS ind_cols
from all_ind_columns&TNS_B
where index_owner='&USR_B'
group by table_name,index_name)) b
where a.table_name=b.table_name
and a.ind_cols=b.ind_cols
and a.index_name!=b.index_name)
order by table_name, ind_cols;
 
PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # COMMON INDEXES WITH DIFFERENT UNIQUENESS
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select a.table_name, a.index_name, a.uniqueness A_value, b.uniqueness B_value
from all_indexes&TNS_A a, all_indexes&TNS_B b
where a.table_owner='&USR_A'
and b.table_owner='&USR_B'
and a.index_name = b.index_name
and a.uniqueness != b.uniqueness
and (a.table_name, a.index_name) in
(select table_name, index_name from &rc_prefix.common_indexes)
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # INDEX COLUMNS MISSING &USR_A.&TNS_A FOR COMMON INDEXES
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select index_name, column_name from all_ind_columns&TNS_B
where table_owner='&USR_B' 
and (table_name,index_name)  in (select table_name,index_name from &rc_prefix.common_indexes)
minus
select index_name, column_name from all_ind_columns&TNS_A
where table_owner='&USR_A' 
and (table_name,index_name)  in (select table_name,index_name from &rc_prefix.common_indexes)
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # INDEX COLUMNS MISSING &USR_B.&TNS_B FOR COMMON INDEXES
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select index_name, column_name from all_ind_columns&TNS_A
where table_owner='&USR_A' 
and (table_name,index_name)  in (select table_name,index_name from &rc_prefix.common_indexes)
minus
select index_name, column_name from all_ind_columns&TNS_B
where table_owner='&USR_B' 
and (table_name,index_name)  in (select table_name,index_name from &rc_prefix.common_indexes)
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # INDEX COLUMNS POSITIONED DIFFERENTLY FOR COMMON INDEXES
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select a.index_name, a.column_name, a.column_position A_value, b.column_position B_value
from all_ind_columns&TNS_A a, all_ind_columns&TNS_B b
where a.table_owner='&USR_A'
and b.table_owner='&USR_B'
and (a.table_name,a.index_name) in (select table_name,index_name from &rc_prefix.common_indexes) 
and b.index_name = a.index_name
and b.table_name = a.table_name
and a.column_name = b.column_name
and a.column_position != b.column_position
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # CONSTRAINTS MISSING &USR_A.&TNS_A FOR COMMON TABLES
PROMPT # (works only for constraint with non system generated names)
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select table_name,constraint_name from all_constraints&TNS_B
where owner='&USR_B' 
and constraint_name not like 'SYS%' 
and table_name in (select table_name from &rc_prefix.common_tables)
minus
select table_name,constraint_name from all_constraints&TNS_A 
where owner='&USR_A' 
and constraint_name not like 'SYS%' 
and table_name in (select table_name from &rc_prefix.common_tables)
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # CONSTRAINTS MISSING &USR_B.&TNS_B FOR COMMON TABLES
PROMPT # (works only for constraint with non system generated names)
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select table_name,constraint_name from all_constraints&TNS_A
where owner='&USR_A' 
and constraint_name not like 'SYS%' 
and table_name in (select table_name from &rc_prefix.common_tables)
minus
select table_name,constraint_name from all_constraints&TNS_B
where owner='&USR_B' 
and constraint_name not like 'SYS%' 
and table_name in (select table_name from &rc_prefix.common_tables)
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # COMMON CONSTRAINTS, TYPE MISMATCH
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select a.constraint_name,a.constraint_type A_value, b.constraint_type B_value
from all_constraints&TNS_A a, all_constraints&TNS_B b 
where a.owner='&USR_A'
and b.owner='&USR_B'
and a.table_name = b.table_name 
and a.constraint_name=b.constraint_name 
and a.constraint_type !=b.constraint_type
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # COMMON CONSTRAINTS, TABLE MISMATCH
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select a.constraint_name,a.table_name,b.table_name from
all_constraints&TNS_A a, all_constraints&TNS_B b,
(select z.constraint_name from 
(select constraint_name, table_name from all_constraints&TNS_A where owner='&USR_A' 
union
select constraint_name, table_name from all_constraints&TNS_B where owner='&USR_B') z
group by constraint_name having count(*) >1) q
where a.owner='&USR_A'
and b.owner='&USR_B'
and a.constraint_name = q.constraint_name 
and b.constraint_name=q.constraint_name
and a.table_name != b.table_name;

create table &rc_prefix.common_const as
select constraint_name, constraint_type, table_name 
from all_constraints&TNS_A where owner='&USR_A'
intersect 
select constraint_name, constraint_type, table_name 
from all_constraints&TNS_B where owner='&USR_B';

delete from &rc_prefix.common_const where constraint_name in 
(select constraint_name from &rc_prefix.common_const 
group by constraint_name having count(*) > 1);

delete from &rc_prefix.common_const where constraint_name like 'SYS%';
commit;

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # DIFFERENCES IN COLUMN USAGE FOR CONSTRAINT DEFINITIONS
PROMPT # (Unique key, Primary Key, Foreign key)
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
declare
cursor c1 is
select a.constraint_name,a.position,a.column_name,b.constraint_type 
from all_cons_columns&TNS_A a, &rc_prefix.common_const b
where a.owner='&USR_A' and a.constraint_name=b.constraint_name
union
select a.constraint_name,a.position,a.column_name,b.constraint_type 
from all_cons_columns&TNS_B a, &rc_prefix.common_const b
where a.owner='&USR_A' and a.constraint_name=b.constraint_name
minus
(select a.constraint_name,a.position,a.column_name,b.constraint_type 
   from all_cons_columns&TNS_A a, &rc_prefix.common_const b
   where a.owner='&USR_A' and a.constraint_name=b.constraint_name
intersect
select a.constraint_name,a.position,a.column_name,b.constraint_type 
  from all_cons_columns&TNS_B a, &rc_prefix.common_const b
  where a.owner='&USR_A' and a.constraint_name=b.constraint_name
);
i binary_integer;
begin
for c in c1 loop
   dbms_output.put_line('COLUMN USAGE DIFFERENCE FOR '||c.constraint_type||
            ' CONSTRAINT '||c.constraint_name);
   dbms_output.put_line('. Local columns:');
   i:=1;
   for c2 in (select column_name col from all_cons_columns&TNS_A 
             where owner='&USR_A' and constraint_name=c.constraint_name order by position) 
   loop
      dbms_output.put_line('.   '||c2.col);
  end loop;
   i:=1;
   dbms_output.put_line('. Remote columns:');
   for c3 in (select column_name col from all_cons_columns&TNS_B 
             where owner='&USR_B' and constraint_name=c.constraint_name 
             ) 
   loop
      dbms_output.put_line('.   '||c3.col);
  end loop;
end loop;
end;
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # DIFFERENCES IN CHECK CONSTRAINT DEFINITIONS
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set serveroutput on
DECLARE 
cursor c1 is 
select constraint_name,constraint_type,table_name 
from &rc_prefix.common_const where constraint_type='C';
cons varchar2(128);
tab1 varchar2(128);
tab2 varchar2(128);
search1 varchar2(32000);
search2 varchar2(32000);
begin
dbms_output.enable(100000);
for c in c1 loop
  select search_condition into search1 from all_constraints&TNS_A 
   where owner='&USR_A' and constraint_name=c.constraint_name;

  select search_condition into search2 from all_constraints&TNS_B 
   where owner='&USR_B' and constraint_name=c.constraint_name;

  if search1 != search2 then
   dbms_output.put_line('Check constraint '||c.constraint_name|| ' defined differently!');
   dbms_output.put_line('. &TNS_A definition:');
   dbms_output.put_line('.  '||search1);
   dbms_output.put_line('. &TNS_B definition:');
   dbms_output.put_line('.  '||search2);
  end if;
end loop;
end;
/

--RAOTEMP col synonym_name format a50
create table &rc_prefix.common_synonyms as
select synonym_name from all_synonyms&TNS_A where owner='&USR_A' 
intersect
select synonym_name from all_synonyms&TNS_B where owner='&USR_B'
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # SYNONYMS MISSING IN &USR_A.&TNS_A
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select rownum,synonym_name from (
select synonym_name from all_synonyms&TNS_B where owner='&USR_B' 
minus
select synonym_name from &rc_prefix.common_synonyms 
)
order by synonym_name
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # SYNONYMS MISSING IN &USR_B.&TNS_B
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select rownum,synonym_name from (
select synonym_name from all_synonyms&TNS_A where owner='&USR_A' 
minus
select synonym_name from &rc_prefix.common_synonyms 
)
order by synonym_name
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # SYNONYM DIFFERENCES FOR COMMON SYNONYMS
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select a.synonym_name,
decode(a.table_owner,b.table_owner,null,a.table_owner) a_table_owner,
decode(a.table_owner,b.table_owner,null,b.table_owner) b_table_owner,
decode(a.table_name,b.table_name,null,a.table_name) a_table_name,
decode(a.table_name,b.table_name,null,b.table_name) b_table_name,
a.db_link, b.db_link
from all_synonyms&TNS_A a, all_synonyms&TNS_B b
where a.owner='&USR_A'
and a.owner=b.owner
and a.synonym_name=b.synonym_name
and (a.table_owner!=b.table_owner 
	or a.table_name!=b.table_name
	or (a.db_link is null and b.db_link is not null)
	or (a.db_link is not null and b.db_link is null))
order by a.synonym_name
/


PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # TRIGGERS MISSING IN &USR_A.&TNS_A
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select trigger_name from all_Triggers&TNS_B where owner='&USR_B' 
minus 
select trigger_name from all_Triggers&TNS_A where owner='&USR_A'
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # TRIGGERS MISSING IN &USR_B.&TNS_B
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select trigger_name from all_Triggers&TNS_A where owner='&USR_A' 
minus 
select trigger_name from all_Triggers&TNS_B where owner='&USR_B'
/

--RAOPROMPT
--RAOPROMPT
--RAOPROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--RAOPROMPT TRIGGER DEFINITION DIFFERENCES ON COMMON TRIGGERS
--RAOPROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--RAOset serveroutput on
--RAOdeclare
--RAOcursor c1 is 
--RAOselect trigger_name,trigger_type,triggering_event, table_name,referencing_names,rtrim(when_clause,' '),
--RAOstatus,rtrim(replace(description,'"&&USR_A".',null),' ') description, trigger_body 
--RAOfrom all_Triggers&TNS_A where owner='&USR_A' ;
--RAOnam1 varchar2(128);
--RAOtype1 varchar2(16);
--RAOevent1 varchar2(26);
--RAOtable1 varchar2(128);
--RAOref1 varchar2(87);
--RAOwhen1 varchar2(2000);
--RAOstatus1 varchar2(8);
--RAOdesc1 varchar2(2000);
--RAObody1 varchar2(32000);
--RAOtype2 varchar2(16);
--RAOevent2 varchar2(26);
--RAOtable2 varchar2(128);
--RAOref2 varchar2(87);
--RAOwhen2 varchar2(2000);
--RAOstatus2 varchar2(8);
--RAOdesc2 varchar2(2000);
--RAObody2 varchar2(32000);
--RAOpr_head boolean;
--RAObegin
--RAOdbms_output.enable(100000);
--RAOopen c1;
--RAOloop
--RAO fetch c1 into nam1,type1,event1,table1,ref1,when1,status1,desc1,body1;
--RAO exit when c1%notfound;
--RAO begin
--RAO  select trigger_type,triggering_event, table_name,referencing_names,rtrim(when_clause,' '),status,                 
--RAO  rtrim(replace(description,upper('"&USR_B".'),null),' ') description, trigger_body 
--RAO  into type2,event2,table2,ref2,when2,status2,desc2,body2 
--RAO  from all_triggers&TNS_B
--RAO  where owner='&USR_B' and trigger_name=nam1;
--RAO  pr_head := FALSE;
--RAO  if table1 != table2 then
--RAO    dbms_output.put_line('T R I G G E R : '||nam1);
--RAO    dbms_output.put_line('-------------------------------------------------'||
--RAO                         '-----------------------');
--RAO    pr_head := TRUE;
--RAO    dbms_output.put_line('   ');
--RAO    dbms_output.put_line('DEFINED ON DIFFERENT TABLES!');
--RAO    dbms_output.put_line('.   &TNS_A table_name  : '||table1);
--RAO    dbms_output.put_line('.   &TNS_B table_name: '||table2);
--RAO  end if;
--RAO  if event1 != event2 then
--RAO    if not pr_head then
--RAO     dbms_output.put_line('T R I G G E R : '||nam1);
--RAO     dbms_output.put_line('-------------------------------------------------'||
--RAO                          '-----------------------');
--RAO     pr_head := TRUE;
--RAO    end if;
--RAO    dbms_output.put_line('   ');
--RAO    dbms_output.put_line('DEFINED FOR DIFFERENT EVENTS!');
--RAO    dbms_output.put_line('. &TNS_A event: '||event1);
--RAO    dbms_output.put_line('. &TNS_B event: '||event2);
--RAO  end if;
--RAO  if type1 != type2 then
--RAO    if not pr_head then
--RAO     dbms_output.put_line('T R I G G E R : '||nam1);
--RAO     dbms_output.put_line('-------------------------------------------------'||
--RAO                          '-----------------------');
--RAO     pr_head := TRUE;
--RAO    end if;
--RAO    dbms_output.put_line('   ');
--RAO    dbms_output.put_line('DIFFERENT TYPES!');
--RAO    dbms_output.put_line('. &TNS_A type: '||type1);
--RAO    dbms_output.put_line('. &TNS_B type: '||type2);
--RAO  end if;
--RAO  if ref1 != ref2 then
--RAO    if not pr_head then
--RAO     dbms_output.put_line('T R I G G E R : '||nam1);
--RAO     dbms_output.put_line('-------------------------------------------------'||
--RAO                          '-----------------------');
--RAO     pr_head := TRUE;
--RAO    end if;
--RAO    dbms_output.put_line('   ');
--RAO    dbms_output.put_line('DIFFERENT REFERENCES!');
--RAO    dbms_output.put_line('. &TNS_A ref: '||ref1);
--RAO    dbms_output.put_line('. &TNS_B ref: '||ref2);
--RAO  end if;
--RAO    if when1 != when2 then
--RAO    dbms_output.put_line('   ');
--RAO    if not pr_head then
--RAO     dbms_output.put_line('T R I G G E R : '||nam1);
--RAO     dbms_output.put_line('-------------------------------------------------'||
--RAO                          '-----------------------');
--RAO     pr_head := TRUE;
--RAO    end if;
--RAO    dbms_output.put_line('DIFFERENT WHEN CLAUSES!');
--RAO    dbms_output.put_line('. &TNS_A when_clause:');
--RAO    dbms_output.put_line(when1);
--RAO    dbms_output.put_line('. &TNS_B when_clause: ');
--RAO    dbms_output.put_line(when2);
--RAO  end if;
--RAO  if status1 != status2 then
--RAO    dbms_output.put_line('   ');
--RAO    dbms_output.put_line('DIFFERENT STATUS!');
--RAO    dbms_output.put_line('. &TNS_A status: '||status1);
--RAO    dbms_output.put_line('. &TNS_B status: '||status2);
--RAO  end if;
--RAO if replace(desc1,chr(10),'') != replace(desc2,chr(10),'') then
--RAO    dbms_output.put_line('   ');
--RAO    dbms_output.put_line('DIFFERENT DESCRIPTIONS!');
--RAO    dbms_output.put_line('&TNS_A definition: ');
--RAO    dbms_output.put_line(desc1);
--RAO    dbms_output.put_line('&TNS_A definition: ');
--RAO    dbms_output.put_line(desc2);
--RAO  end if;
--RAO  if body1 != body2 then
--RAO    dbms_output.put_line('   ');
--RAO    dbms_output.put_line('THE PL/SQL BLOCKS ARE DIFFERENT! ');
--RAO    dbms_output.put_line('   ');
--RAO  end if;
--RAO  exception when NO_DATA_FOUND then null;
--RAO  when others then raise_application_error(-20010,SQLERRM);
--RAO end;
--RAOend loop;
--RAOend;
--RAO/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # MISSING PROCEDURES/PACKAGES/FUNCTIONS IN &USR_B.&TNS_B
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--RAOTEMP col name format a50
--RAOTEMP col type format a30
select distinct name,type from all_source&TNS_A where owner='&USR_A'
minus 
select distinct name,type from all_source&TNS_B where owner='&USR_B'
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # MISSING PROCEDURES/PACKAGES/FUNCTIONS IN &USR_A.&TNS_A
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select distinct name,type from all_source&TNS_B where owner='&USR_B' 
minus 
select distinct name,type from all_source&TNS_A where owner='&USR_A'
/

create table &rc_prefix.comcod as
select distinct name,type from all_source&TNS_A where owner='&USR_A'
intersect 
select distinct name,type from all_source&TNS_B where owner='&USR_B'
/

--RAOcol object_name format a50
--RAOcol object_type format a30
--RAOPROMPT
--RAOPROMPT
--RAOPROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--RAOPROMPT PROCEDURES/PACKAGES/FUNCTIONS WITH DIFFERENT DEFINITIONS
--RAOPROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--RAOselect distinct q.name object_name, q.type object_type from 
--RAO(select a.name,a.type,a.line,a.text from all_source&TNS_A a, &rc_prefix.comcod b where a.owner='&USR_A' and a.name=b.name 
--RAOunion 
--RAOselect a.name,a.type,a.line,a.text from all_source&TNS_B a, &rc_prefix.comcod b where owner='&USR_B' and a.name=b.name 
--RAOminus
--RAO(select a.name,a.type,a.line,a.text from all_source&TNS_A a, &rc_prefix.comcod b where owner='&USR_A' and a.name=b.name 
--RAO intersect
--RAOselect a.name,a.type,a.line,a.text from all_source&TNS_B a, &rc_prefix.comcod b where owner='&USR_B' and a.name=b.name )) q
--RAO/

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- create common_views table
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--RAOTEMP col view_name format a50
create table &rc_prefix.common_views as
select view_name from all_views&TNS_A where owner='&USR_A' 
intersect
select view_name from all_views&TNS_B where owner='&USR_B'
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # VIEWS MISSING IN &USR_A.&TNS_A
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select rownum, view_name from (
select view_name from all_views&TNS_B where owner='&USR_B'
minus
select view_name from &rc_prefix.common_views
)
/

PROMPT
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # VIEWS MISSING IN &USR_B.&TNS_B
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select rownum, view_name from (
select view_name from all_views&TNS_A where owner='&USR_A'
minus
select view_name from &rc_prefix.common_views
)
/

--RAOPROMPT
--RAOPROMPT
--RAOPROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--RAOPROMPT VIEWS WITH DIFFERENCES IN THE DEFINITION
--RAOPROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--RAOdeclare
--RAOdef1 varchar2(32000);
--RAOdef2 varchar2(32000);
--RAOlen1 number;
--RAOlen2 number;
--RAOi number;
--RAOcursor c1 is select view_name from &rc_prefix.common_views;
--RAObegin
--RAOdbms_output.enable(100000);
--RAOfor c in c1 loop
--RAO  select text,text_length into def1,len1 from all_views&TNS_A where owner='&USR_A' and view_name=c.view_name;
--RAO  select text,text_length into def2,len2 from all_Views&TNS_B where owner='&USR_B' and view_name=c.view_name;
--RAO        i := 1;
--RAO  def1:=replace(def1,' ','');
--RAO  def2:=replace(def2,' ','');
--RAO  if def1 != def2 or length(def1) != length(def2) then
--RAO    dbms_output.put_line(lpad('-',35+length(c.view_name),'-'));
--RAO    dbms_output.put_line('|  '||c.view_name ||
--RAO                         '                               |');
--RAO    dbms_output.put_line(lpad('-',35+length(c.view_name),'-'));
--RAO        dbms_output.put_line('Local text_length:   ' || to_char(len1));
--RAO        dbms_output.put_line('Remote text_length):  ' || to_char(len2));
--RAO    dbms_output.put_line(' ');
--RAO        i := 1;
--RAO        while i <= length(def1) loop
--RAO           if substr(def1,i,240) != substr(def2,i,240) then
--RAO                   dbms_output.put_line('Difference at offset ' || to_char(i)
--RAO);
--RAO                   dbms_output.put_line('   &TNS_A:   ' || substr(def1,i,240));
--RAO                   dbms_output.put_line('   &TNS_B:  ' || substr(def2,i,240));
--RAO       end if;
--RAO           i := i + 240;
--RAO    end loop;
--RAO  end if;
--RAO  if length(def2) > length(def1) then
--RAO         dbms_output.put_line('&TNS_B longer than &TNS_A. Next 255 bytes:    ');
--RAO         dbms_output.put_line(substr(def2,length(def1),255));
--RAO  end if;
--RAOend loop;
--RAOend;
--RAO/

PROMPT
--  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  CLEAN UP TEMPORARY OBJECTS
--  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--drop database link &TNS_A;
--drop database link &TNS_B;

#
drop table &rc_prefix.comcod;
drop table &rc_prefix.diff_cols1;
drop table &rc_prefix.diff_cols2;
--drop table &rc_prefix.common_tables;
drop table &rc_prefix.common_views;
drop table &rc_prefix.common_indexes;
drop table &rc_prefix.common_const;
drop table &rc_prefix.common_synonyms;
#
undef a
undef b
undef c
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT # REPORT END
PROMPT # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

spool off
set verify on feedback on
set markup html OFF
