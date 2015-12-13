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
- Check constraint definitions
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

set verify off linesize 132 feedback off trimspool on pagesi 0
column c new_val v_nowtime
select to_char(sysdate,'DD-MON-YYYY HH24:MI') c from dual;
set pagesi 1000

define USR_A='RAO'
define PWD_A='rao123'
define TNS_A='DB51'
define USR_B='RAO'
define PWD_B='rao123'
define TNS_B='DB52'
define rc_prefix='RC_SCHCOMP_'

DOC
accept USR_A char prompt 'Enter USR_A username:'
accept PWD_A char prompt 'Enter PWD_A password:' hide
accept TNS_A char prompt 'Enter TNS_A :'
accept USR_B char prompt 'Enter USR_B username:'
accept PWD_B char prompt 'Enter PWD_B password:' hide
accept TNS_B char prompt 'Enter TNS_B :' 
accept rc_prefix char prompt 'Enter Schema Compare Prefix String :' 
#

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- DROP PREVIOUS COMPARISION OBJECTS (IF EXISTS)
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT
declare
begin
	begin
	for c in (select table_name from user_tables where table_name like '&rc_prefix%')
	loop
		execute immediate 'DROP TABLE '||c.table_name;
	end loop;
	exception
	when others then
	null;
	end;
end;
/

spool dbdiff
PROMPT
PROMPT
PROMPT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT SCHEMA DEFINITION DIFFERENCES     
PROMPT
PROMPT Date    : &v_nowtime        
PROMPT SCHEMA_A: &USR_A@&TNS_A
PROMPT SCHEMA_B: &USR_B@&TNS_B
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT
PROMPT
--set echo on feed on
create database link &TNS_A connect to &USR_A identified by &PWD_A using '&TNS_A';
create database link &TNS_B connect to &USR_B identified by &PWD_B using '&TNS_B';
whenever sqlerror exit 1;
PROMPT
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT  TABLES COMMON BETWEEN &USR_A.@&TNS_A AND &USR_B.@&TNS_B
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
create table &rc_prefix.common_tables as
select table_name from dba_tables@&TNS_A where owner='&USR_A'
intersect
select table_name from dba_tables@&TNS_B where owner='&USR_B'
/
select table_name from &rc_prefix.common_tables
/
PROMPT
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT  TABLES MISSING IN &USR_A.@&TNS_A 
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select table_name from dba_tables@&TNS_B where owner='&USR_B'
minus
select table_name from dba_tables@&TNS_A where owner='&USR_A'
/
PROMPT
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT  TABLES MISSING IN &USR_B.@&TNS_B 
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select table_name from dba_tables@&TNS_A where owner='&USR_A'
minus
select table_name from dba_tables@&TNS_B where owner='&USR_B'
/
PROMPT
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT COLUMNS MISSING IN &USR_A.@&TNS_A FOR COMMON TABLES
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select table_name,column_name from dba_tab_columns@&TNS_B 
where owner='&USR_B' and table_name in (select table_name from &rc_prefix.common_tables)
minus
select table_name,column_name from dba_tab_columns@&TNS_A
where owner='&USR_A' and table_name in (select table_name from &rc_prefix.common_tables)
/
PROMPT
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT COLUMNS MISSING IN &USR_B.@&TNS_B FOR COMMON TABLES
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select table_name,column_name from dba_tab_columns@&TNS_A
where owner='&USR_A' and table_name in (select table_name from &rc_prefix.common_tables)
minus
select table_name,column_name from dba_tab_columns@&TNS_B
where owner='&USR_B' and table_name in (select table_name from &rc_prefix.common_tables)
/
PROMPT
PROMPT
PROMPT
create table &rc_prefix.diff_cols1
( 
 TABLE_NAME      VARCHAR2(30),
 COLUMN_NAME     VARCHAR2(30),
 DATA_TYPE       VARCHAR2(9),
 DATA_LENGTH     NUMBER,
 DATA_PRECISION  NUMBER,
 DATA_SCALE      NUMBER,
 NULLABLE        VARCHAR2(1),
 COLUMN_ID       NUMBER,
 DEFAULT_LENGTH  NUMBER,
 DATA_DEFAULT    VARCHAR2(2000)
)
/

create table &rc_prefix.diff_cols2
(
 TABLE_NAME      VARCHAR2(30),
 COLUMN_NAME     VARCHAR2(30),
 DATA_TYPE       VARCHAR2(9),
 DATA_LENGTH     NUMBER,
 DATA_PRECISION  NUMBER,
 DATA_SCALE      NUMBER,
 NULLABLE        VARCHAR2(1),
 COLUMN_ID       NUMBER,
 DEFAULT_LENGTH  NUMBER,
 DATA_DEFAULT    VARCHAR2(2000)
)
/

-- ----------------------------------------

DECLARE
cursor c1 is
select l.table_name , l.column_name, l.data_type , l.data_length, l.data_precision , l.data_scale ,
 l.nullable, l.column_id , l.default_length , l.data_defaulT
from dba_tab_columns@&TNS_A l, &rc_prefix.common_tables c
where l.owner='&USR_A' and c.table_name=l.table_name and l.owner='&USR_A';

TYPE rec is record (
 TABLE_NAME      VARCHAR2(30),
 COLUMN_NAME     VARCHAR2(30),
 DATA_TYPE       VARCHAR2(9),
 DATA_LENGTH     NUMBER,
 DATA_PRECISION  NUMBER,
 DATA_SCALE      NUMBER,
 NULLABLE        VARCHAR2(1),
 COLUMN_ID       NUMBER,
 DEFAULT_LENGTH  NUMBER,
 DATA_DEFAULT    VARCHAR2(2000)
);
c rec;
BEGIN
 open c1;
 loop
   fetch c1 into c;
    exit when c1%NOTFOUND;
    insert into &rc_prefix.diff_cols1 values 
    (c.table_name,c.column_name,c.data_type,c.data_length,
     c.data_precision, c.data_scale, c.nullable, c.column_id, 
     c.default_length, c.data_default);
end loop;
end;
/

-- ----------------------------------------

DECLARE
cursor c1 is
select l.table_name , l.column_name, l.data_type , l.data_length, l.data_precision , l.data_scale ,
 l.nullable, l.column_id , l.default_length , l.data_defaulT
from dba_tab_columns@&TNS_B l, &rc_prefix.common_tables c
where l.owner='&USR_B' and c.table_name=l.table_name and l.owner='&USR_B';

TYPE rec is record (
 TABLE_NAME      VARCHAR2(30),
 COLUMN_NAME     VARCHAR2(30),
 DATA_TYPE       VARCHAR2(9),
 DATA_LENGTH     NUMBER,
 DATA_PRECISION  NUMBER,
 DATA_SCALE      NUMBER,
 NULLABLE        VARCHAR2(1),
 COLUMN_ID       NUMBER,
 DEFAULT_LENGTH  NUMBER,
 DATA_DEFAULT    VARCHAR2(2000)
);
c rec;
begin
 open c1;
 loop
   fetch c1 into c;
    exit when c1%NOTFOUND;
    insert into &rc_prefix.diff_cols2 values 
    (c.table_name,c.column_name,c.data_type,c.data_length,
     c.data_precision, c.data_scale, c.nullable, c.column_id, 
     c.default_length, c.data_default);
end loop;
end;
/

-- ----------------------------------------

column table_name format a20
column column_name format a20
column param format a15
column local_value format a20
column remote_value format a20
set arraysize 1
set maxdata 32000

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT DIFFERENCE IN COLUMN DEFINITIONS FOR COMMON TABLES
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select l.table_name,l.column_name,'DATA_DEFAULT' param, l.data_default &TNS_A._value, r.data_default &TNS_B._value
from &rc_prefix.diff_cols1 l, &rc_prefix.diff_cols2 r 
where l.table_name=r.table_name and l.column_name=r.column_name and l.data_default != r.data_default
union
select l.table_name,l.column_name,'DATA_TYPE',l.data_type,r.data_type 
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
union
select l.table_name,l.column_name,'COLUMN_ID',to_char(l.column_id), to_char(r.column_id) 
from &rc_prefix.diff_cols1 l, &rc_prefix.diff_cols2 r 
where l.table_name=r.table_name and l.column_name=r.column_name and l.column_id != r.column_id
union
select l.table_name,l.column_name,'DEFAULT_LENGTH',to_char(l.default_length), to_char(r.default_length) 
from &rc_prefix.diff_cols1 l, &rc_prefix.diff_cols2 r 
where l.table_name=r.table_name and l.column_name=r.column_name and l.default_length != r.default_length
order by 1,2
/                
         
create table &rc_prefix.common_indexes as
select table_name, index_name from dba_indexes@&TNS_A
where table_owner='&USR_A' and table_name in (select table_name from &rc_prefix.common_tables)
intersect
select table_name, index_name from dba_indexes@&TNS_B
where table_owner='&USR_B' and table_name in (select table_name from &rc_prefix.common_tables)
/

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT INDEXES MISSING IN &USR_A.@&TNS_A FOR COMMON TABLES
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select table_name, index_name from dba_indexes@&TNS_B
where table_owner='&USR_B' and table_name in (select table_name from &rc_prefix.common_tables)
minus
select table_name, index_name from &rc_prefix.common_indexes
/

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT INDEXES MISSING IN &USR_B.@&TNS_B FOR COMMON TABLES
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select table_name, index_name from dba_indexes@&TNS_A
where table_owner='&USR_A' and table_name in (select table_name from &rc_prefix.common_tables)
minus
select table_name, index_name from &rc_prefix.common_indexes
/

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT COMMON INDEXES WITH DIFFERENT UNIQUENESS
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select a.table_name, a.index_name, a.uniqueness &TNS_A._value, b.uniqueness &TNS_B._value
from dba_indexes@&TNS_A a, dba_indexes@&TNS_B b
where a.table_owner='&USR_A'
and b.table_owner='&USR_B'
and a.index_name = b.index_name
and a.uniqueness != b.uniqueness
and (a.table_name, a.index_name) in
(select table_name, index_name from &rc_prefix.common_indexes)
/

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT INDEX COLUMNS MISSING &USR_A.@&TNS_A FOR COMMON INDEXES
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select index_name, column_name from dba_ind_columns@&TNS_B
where table_owner='&USR_B' 
and (table_name,index_name)  in (select table_name,index_name from &rc_prefix.common_indexes)
minus
select index_name, column_name from dba_ind_columns@&TNS_A
where table_owner='&USR_A' 
and (table_name,index_name)  in (select table_name,index_name from &rc_prefix.common_indexes)
/

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT INDEX COLUMNS MISSING &USR_B.@&TNS_B FOR COMMON INDEXES
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select index_name, column_name from dba_ind_columns@&TNS_A
where table_owner='&USR_A' 
and (table_name,index_name)  in (select table_name,index_name from &rc_prefix.common_indexes)
minus
select index_name, column_name from dba_ind_columns@&TNS_B
where table_owner='&USR_B' 
and (table_name,index_name)  in (select table_name,index_name from &rc_prefix.common_indexes)
/

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT INDEX COLUMNS POSITIONED DIFFERENTLY FOR COMMON INDEXES
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select a.index_name, a.column_name, a.column_position &TNS_A._value, b.column_position &TNS_B._value
from dba_ind_columns@&TNS_A a, dba_ind_columns@&TNS_B b
where a.table_owner='&TNS_A'
and b.table_owner='&TNS_B'
and (a.table_name,a.index_name) in (select table_name,index_name from &rc_prefix.common_indexes) 
and b.index_name = a.index_name
and b.table_name = a.table_name
and a.column_name = b.column_name
and a.column_position != b.column_position
/
 
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT CONSTRAINTS MISSING &USR_A.@&TNS_A FOR COMMON TABLES
PROMPT (WORKS ONLY FOR CONSTRAINT WITH NON SYSTEM GENERATED NAMES)
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select table_name,constraint_name from dba_constraints@&TNS_B
where owner='&TNS_B' 
and constraint_name not like 'SYS%' 
and table_name in (select table_name from &rc_prefix.common_tables)
minus
select table_name,constraint_name from dba_constraints@&TNS_A 
where owner='&TNS_A' 
and constraint_name not like 'SYS%' 
and table_name in (select table_name from &rc_prefix.common_tables)
/

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT CONSTRAINTS MISSING &USR_B.@&TNS_B FOR COMMON TABLES
PROMPT (WORKS ONLY FOR CONSTRAINT WITH NON SYSTEM GENERATED NAMES)
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select table_name,constraint_name from dba_constraints@&TNS_A
where owner='&TNS_A' 
and constraint_name not like 'SYS%' 
and table_name in (select table_name from &rc_prefix.common_tables)
minus
select table_name,constraint_name from dba_constraints@&TNS_B
where owner='&TNS_B' 
and constraint_name not like 'SYS%' 
and table_name in (select table_name from &rc_prefix.common_tables)
/

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT COMMON CONSTRAINTS, TYPE MISMATCH
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select a.constraint_name,a.constraint_type &TNS_A._value, b.constraint_type &TNS_B._value
from dba_constraints@&TNS_A a, dba_constraints@&TNS_B b 
where a.owner='&TNS_A'
and b.owner='&TNS_B'
and a.table_name = b.table_name 
and a.constraint_name=b.constraint_name 
and a.constraint_type !=b.constraint_type
/

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT COMMON CONSTRAINTS, TABLE MISMATCH
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select a.constraint_name,a.table_name,b.table_name from
dba_constraints@&TNS_A a, dba_constraints@&TNS_B b,
(select z.constraint_name from 
(select constraint_name, table_name from dba_constraints@&TNS_A where owner='&TNS_A' 
union
select constraint_name, table_name from dba_constraints@&TNS_B where owner='&TNS_B') z
group by constraint_name having count(*) >1) q
where a.owner='&TNS_A'
and b.owner='&TNS_B'
and a.constraint_name = q.constraint_name 
and b.constraint_name=q.constraint_name
and a.table_name != b.table_name;

create table &rc_prefix.common_const as
select constraint_name, constraint_type, table_name 
from dba_constraints@&TNS_A where owner='&USR_A'
intersect 
select constraint_name, constraint_type, table_name 
from dba_constraints@&TNS_B where owner='&USR_B';

delete from &rc_prefix.common_const where constraint_name in 
(select constraint_name from &rc_prefix.common_const 
group by constraint_name having count(*) > 1);

delete from &rc_prefix.common_const where constraint_name like 'SYS%';
commit;

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT  DIFFERENCES IN COLUMN USAGE FOR CONSTRAINT DEFINITIONS
PROMPT  (Unique key, Primary Key, Foreign key)
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
declare
cursor c1 is
select a.constraint_name,a.position,a.column_name,b.constraint_type 
from dba_cons_columns@&TNS_A a, &rc_prefix.common_const b
where a.owner='&USR_A' and a.constraint_name=b.constraint_name
union
select a.constraint_name,a.position,a.column_name,b.constraint_type 
from dba_cons_columns@&TNS_B a, &rc_prefix.common_const b
where a.owner='&USR_A' and a.constraint_name=b.constraint_name
minus
(select a.constraint_name,a.position,a.column_name,b.constraint_type 
   from dba_cons_columns@&TNS_A a, &rc_prefix.common_const b
   where a.owner='&USR_A' and a.constraint_name=b.constraint_name
intersect
select a.constraint_name,a.position,a.column_name,b.constraint_type 
  from dba_cons_columns@&TNS_B a, &rc_prefix.common_const b
  where a.owner='&USR_A' and a.constraint_name=b.constraint_name
);
i binary_integer;
begin
for c in c1 loop
   dbms_output.put_line('COLUMN USAGE DIFFERENCE FOR '||c.constraint_type||
            ' CONSTRAINT '||c.constraint_name);
   dbms_output.put_line('. Local columns:');
   i:=1;
   for c2 in (select column_name col from dba_cons_columns@&TNS_A 
             where owner='&USR_A' and constraint_name=c.constraint_name order by position) 
   loop
      dbms_output.put_line('.   '||c2.col);
  end loop;
   i:=1;
   dbms_output.put_line('. Remote columns:');
   for c3 in (select column_name col from dba_cons_columns@&TNS_B 
             where owner='&USR_B' and constraint_name=c.constraint_name 
             ) 
   loop
      dbms_output.put_line('.   '||c3.col);
  end loop;
end loop;
end;
/

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT DIFFERENCES IN CHECK CONSTRAINT DEFINITIONS
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set serveroutput on
DECLARE 
cursor c1 is 
select constraint_name,constraint_type,table_name 
from &rc_prefix.common_const where constraint_type='C';
cons varchar2(50);
tab1 varchar2(50);
tab2 varchar2(50);
search1 varchar2(32000);
search2 varchar2(32000);
begin
dbms_output.enable(100000);
for c in c1 loop
  select search_condition into search1 from dba_constraints@&TNS_A 
   where owner='&USR_A' and constraint_name=c.constraint_name;

  select search_condition into search2 from dba_constraints@&TNS_B 
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

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT TRIGGERS MISSING IN &USR_A.@&TNS_A
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select trigger_name from dba_Triggers@&TNS_B where owner='&USR_B' 
minus 
select trigger_name from dba_Triggers@&TNS_A where owner='&USR_A'
/

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT TRIGGERS MISSING IN &USR_B.@&TNS_B
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select trigger_name from dba_Triggers@&TNS_A where owner='&USR_A' 
minus 
select trigger_name from dba_Triggers@&TNS_B where owner='&USR_B'
/

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT TRIGGER DEFINITION DIFFERENCES ON COMMON TRIGGERS
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set serveroutput on
declare
cursor c1 is 
select trigger_name,trigger_type,triggering_event, table_name,referencing_names,rtrim(when_clause,' '),
status,rtrim(replace(description,'"&&USR_A".',null),' ') description, trigger_body 
from dba_Triggers@&TNS_A where owner='&USR_A' ;
nam1 varchar2(30);
type1 varchar2(16);
event1 varchar2(26);
table1 varchar2(30);
ref1 varchar2(87);
when1 varchar2(2000);
status1 varchar2(8);
desc1 varchar2(2000);
body1 varchar2(32000);
type2 varchar2(16);
event2 varchar2(26);
table2 varchar2(30);
ref2 varchar2(87);
when2 varchar2(2000);
status2 varchar2(8);
desc2 varchar2(2000);
body2 varchar2(32000);
pr_head boolean;
begin
dbms_output.enable(100000);
open c1;
loop
 fetch c1 into nam1,type1,event1,table1,ref1,when1,status1,desc1,body1;
 exit when c1%notfound;
 begin
  select trigger_type,triggering_event, table_name,referencing_names,rtrim(when_clause,' '),status,                 
  rtrim(replace(description,upper('"&USR_B".'),null),' ') description, trigger_body 
  into type2,event2,table2,ref2,when2,status2,desc2,body2 
  from dba_triggers@&TNS_B
  where owner='&USR_B' and trigger_name=nam1;
  pr_head := FALSE;
  if table1 != table2 then
    dbms_output.put_line('T R I G G E R : '||nam1);
    dbms_output.put_line('-------------------------------------------------'||
                         '-----------------------');
    pr_head := TRUE;
    dbms_output.put_line('   ');
    dbms_output.put_line('DEFINED ON DIFFERENT TABLES!');
    dbms_output.put_line('.   &TNS_A table_name  : '||table1);
    dbms_output.put_line('.   &TNS_B table_name: '||table2);
  end if;
  if event1 != event2 then
    if not pr_head then
     dbms_output.put_line('T R I G G E R : '||nam1);
     dbms_output.put_line('-------------------------------------------------'||
                          '-----------------------');
     pr_head := TRUE;
    end if;
    dbms_output.put_line('   ');
    dbms_output.put_line('DEFINED FOR DIFFERENT EVENTS!');
    dbms_output.put_line('. &TNS_A event: '||event1);
    dbms_output.put_line('. &TNS_B event: '||event2);
  end if;
  if type1 != type2 then
    if not pr_head then
     dbms_output.put_line('T R I G G E R : '||nam1);
     dbms_output.put_line('-------------------------------------------------'||
                          '-----------------------');
     pr_head := TRUE;
    end if;
    dbms_output.put_line('   ');
    dbms_output.put_line('DIFFERENT TYPES!');
    dbms_output.put_line('. &TNS_A type: '||type1);
    dbms_output.put_line('. &TNS_B type: '||type2);
  end if;
  if ref1 != ref2 then
    if not pr_head then
     dbms_output.put_line('T R I G G E R : '||nam1);
     dbms_output.put_line('-------------------------------------------------'||
                          '-----------------------');
     pr_head := TRUE;
    end if;
    dbms_output.put_line('   ');
    dbms_output.put_line('DIFFERENT REFERENCES!');
    dbms_output.put_line('. &TNS_A ref: '||ref1);
    dbms_output.put_line('. &TNS_B ref: '||ref2);
  end if;
    if when1 != when2 then
    dbms_output.put_line('   ');
    if not pr_head then
     dbms_output.put_line('T R I G G E R : '||nam1);
     dbms_output.put_line('-------------------------------------------------'||
                          '-----------------------');
     pr_head := TRUE;
    end if;
    dbms_output.put_line('DIFFERENT WHEN CLAUSES!');
    dbms_output.put_line('. &TNS_A when_clause:');
    dbms_output.put_line(when1);
    dbms_output.put_line('. &TNS_B when_clause: ');
    dbms_output.put_line(when2);
  end if;
  if status1 != status2 then
    dbms_output.put_line('   ');
    dbms_output.put_line('DIFFERENT STATUS!');
    dbms_output.put_line('. &TNS_A status: '||status1);
    dbms_output.put_line('. &TNS_B status: '||status2);
  end if;
 if replace(desc1,chr(10),'') != replace(desc2,chr(10),'') then
    dbms_output.put_line('   ');
    dbms_output.put_line('DIFFERENT DESCRIPTIONS!');
    dbms_output.put_line('&TNS_A definition: ');
    dbms_output.put_line(desc1);
    dbms_output.put_line('&TNS_A definition: ');
    dbms_output.put_line(desc2);
  end if;
  if body1 != body2 then
    dbms_output.put_line('   ');
    dbms_output.put_line('THE PL/SQL BLOCKS ARE DIFFERENT! ');
    dbms_output.put_line('   ');
  end if;
  exception when NO_DATA_FOUND then null;
  when others then raise_application_error(-20010,SQLERRM);
 end;
end loop;
end;
/

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT MISSING PROCEDURES/PACKAGES/FUNCTIONS IN REMOTE SCHEMA
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select distinct name,type from dba_source@&TNS_A where owner='&TNS_A'
minus 
select distinct name,type from dba_source@&TNS_B where owner='&TNS_B'
/

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT MISSING PROCEDURES/PACKAGES/FUNCTIONS IN LOCAL SCHEMA
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select distinct name,type from dba_source@&TNS_B where owner='&TNS_B' 
minus 
select distinct name,type from dba_source@&TNS_A where owner='&TNS_A'
/

create table &rc_prefix.comcod as
select distinct name,type from dba_source@&TNS_A where owner='&TNS_A'
intersect 
select distinct name,type from dba_source@&TNS_B where owner='&TNS_B'
/

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT PROCEDURES/PACKAGES/FUNCTIONS WITH DIFFERENT DEFINITIONS
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select distinct q.name object_name, q.type object_type from 
(select a.name,a.type,a.line,a.text from dba_source@&TNS_A a, &rc_prefix.comcod b where a.owner='&USR_A' and a.name=b.name 
union 
select a.name,a.type,a.line,a.text from dba_source@&TNS_B a, &rc_prefix.comcod b where owner='&TNS_B' and a.name=b.name 
minus
(select a.name,a.type,a.line,a.text from dba_source@&TNS_A a, &rc_prefix.comcod b where owner='&TNS_A' and a.name=b.name 
 intersect
select a.name,a.type,a.line,a.text from dba_source@&TNS_B a, &rc_prefix.comcod b where owner='&TNS_B' and a.name=b.name )) q
/

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT  VIEWS MISSING IN &USR_A.@&TNS_A
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
create table &rc_prefix.common_views as
select view_name from dba_views@&TNS_A where owner='&TNS_A' 
intersect
select view_name from dba_views@&TNS_B where owner='&TNS_B'
/

select view_name from dba_views@&TNS_B where owner='&TNS_B'
minus
select view_name from &rc_prefix.common_views
/

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT  VIEWS MISSING IN &USR_B.@&TNS_B
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select view_name from dba_views@&TNS_A where owner='&TNS_A'
minus
select view_name from &rc_prefix.common_views
/

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT VIEWS WITH DIFFERENCES IN THE DEFINITION
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
declare
def1 varchar2(32000);
def2 varchar2(32000);
len1 number;
len2 number;
i number;
cursor c1 is select view_name from &rc_prefix.common_views;
begin
dbms_output.enable(100000);
for c in c1 loop
  select text,text_length into def1,len1 from dba_views@&TNS_A where owner='&TNS_A' and view_name=c.view_name;
  select text,text_length into def2,len2 from dba_Views@&TNS_B where owner='&TNS_B' and view_name=c.view_name;
        i := 1;
  def1:=replace(def1,' ','');
  def2:=replace(def2,' ','');
  if def1 != def2 or length(def1) != length(def2) then
    dbms_output.put_line(lpad('-',35+length(c.view_name),'-'));
    dbms_output.put_line('|  '||c.view_name ||
                         '                               |');
    dbms_output.put_line(lpad('-',35+length(c.view_name),'-'));
        dbms_output.put_line('Local text_length:   ' || to_char(len1));
        dbms_output.put_line('Remote text_length):  ' || to_char(len2));
    dbms_output.put_line(' ');
        i := 1;
        while i <= length(def1) loop
           if substr(def1,i,240) != substr(def2,i,240) then
                   dbms_output.put_line('Difference at offset ' || to_char(i)
);
                   dbms_output.put_line('   &TNS_A:   ' || substr(def1,i,240));
                   dbms_output.put_line('   &TNS_B:  ' || substr(def2,i,240));
       end if;
           i := i + 240;
    end loop;
  end if;
  if length(def2) > length(def1) then
         dbms_output.put_line('&TNS_B longer than &TNS_A. Next 255 bytes:    ');
         dbms_output.put_line(substr(def2,length(def1),255));
  end if;
end loop;
end;
/

PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT CLEAN UP TEMPORARY OBJECTS
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
drop database link &TNS_A;
drop database link &TNS_B;
drop table &rc_prefix.comcod;
drop table &rc_prefix.diff_cols1;
drop table &rc_prefix.diff_cols2;
drop table &rc_prefix.common_tables;
drop table &rc_prefix.common_views;
drop table &rc_prefix.common_indexes;
drop table &rc_prefix.common_const;
spool off
set verify on feedback on
undef a
undef b
undef c
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT  END OF REPORT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
