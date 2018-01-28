-- ######################################################################

create sequence DATA_MASK_SEQ;

-- ######################################################################

create table DATA_MASK_ALG (
  id number(3) not null
, typ varchar2(30) not null
, alg varchar2(30) not null
, txt varchar2(100) not null
);

comment on table DATA_MASK_ALG is 'Data Masking Algorithms list';

comment on column DATA_MASK_ALG.id is 'Data Masking Algorithm sequence ID';
comment on column DATA_MASK_ALG.typ is 'Data Masking Algorithm Data Type for this Algorithm';
comment on column DATA_MASK_ALG.alg is 'Data Masking Algorithm Name';
comment on column DATA_MASK_ALG.txt is 'Data Masking Algorithm Description Text';

create unique index DATA_MASK_ALG_IX01 on DATA_MASK_ALG (id);
create unique index DATA_MASK_ALG_PK on DATA_MASK_ALG(alg);

alter table DATA_MASK_ALG add constraint DATA_MASK_ALG_PK primary key (alg) using index DATA_MASK_ALG_PK;

--
-- ######################################################################

create table DATA_MASK_LIST ( 
  id number not null
, own varchar2(30) not null
, tab varchar2(30) not null
, col varchar2(30) not null
, alg varchar2(30) not null
, val varchar2(30)
, con varchar2(100)
) ;

create unique index DATA_MASK_LIST_PK on DATA_MASK_LIST (own,tab,col);

alter table DATA_MASK_LIST 
add constraint DATA_MASK_LIST 
primary key (own,tab,col);

alter table DATA_MASK_LIST 
add constraint DATA_MASK_LIST_FK01 
foreign key (alg) 
references DATA_MASK_ALG(alg);

comment on table DATA_MASK_LIST is 'Data Masking Attribute List';

comment on column DATA_MASK_LIST.id is 'Data Masking Attribute List sequence ID';
comment on column DATA_MASK_LIST.own is 'Data Masking Attribute Table Owner Name';
comment on column DATA_MASK_LIST.tab is 'Data Masking Attribute Table Name';
comment on column DATA_MASK_LIST.col is 'Data Masking Attribute Column Name';
comment on column DATA_MASK_LIST.alg is 'Data Masking Attribute Masking Algorithm';
comment on column DATA_MASK_LIST.val is 'Data Masking Attribute Value Expression';
comment on column DATA_MASK_LIST.con is 'Data Masking Attribute Where/IF Cluase Condition';

-- ######################################################################

create table DATA_MASK_LOG (
 id number(8) not null
,own varchar2(30) not null
,tab varchar2(30) not null
,col varchar2(30) not null
,start_time date not null
,end_time date
,row_count number
,a_db varchar2(30) not null
,a_user varchar2(30) not null
,a_host varchar2(100) not null
,a_ipaddr varchar2(15) not null
);

create unique index DATA_MASK_LOG_IX01 on DATA_MASK_LOG (id);
create unique index DATA_MASK_LOG_PK on DATA_MASK_LOG(own,tab,col);

alter table DATA_MASK_LOG 
add constraint DATA_MASK_LOG_PK 
primary key (own, tab, col) 
using index DATA_MASK_LOG_PK;

alter table DATA_MASK_LOG
add constraint DATA_MASK_LOG_FK01 
foreign key (own,tab,col) 
references DATA_MASK_LIST(own, tab,col);

comment on table DATA_MASK_LOG is 'Data Masking Execution Log';

comment on column DATA_MASK_LOG.id is 'Data Masking Execution Log Sequence ID';
comment on column DATA_MASK_LOG.tab is 'Data Masking Execution Log Table Name';
comment on column DATA_MASK_LOG.col is 'Data Masking Execution Log Column Name';
comment on column DATA_MASK_LOG.start_time is 'Data Masking Execution Start DateTime';
comment on column DATA_MASK_LOG.end_time is 'Data Masking Execution End DateTime ';
comment on column DATA_MASK_LOG.row_count is 'Data Masking Execution Row Count';
comment on column DATA_MASK_LOG.a_db is 'Data Masking Execution Audit - Database Name';
comment on column DATA_MASK_LOG.a_user is 'Data Masking Execution Audit - User Name';
comment on column DATA_MASK_LOG.a_host is 'Data Masking Execution Audit - Host Name';
comment on column DATA_MASK_LOG.a_ipaddr is 'Data Masking Execution Audit - IP Address';

-- ######################################################################

create or replace view DATA_MASK_STATUS 
as
select 
id, tab as table_name, col as column_name, 
to_char(start_time,'yyyy-mm-dd hh24:mi:ss') start_time, 
to_char(end_time,'yyyy-mm-dd hh24:mi:ss') end_time,
round((end_time-start_time)*24*60,1) elapsed_minutes,
row_count
from DATA_MASK_LOG order by id;

-- ######################################################################

@@mskpkg.pks
@@mskpkg.pkb

-- ######################################################################
