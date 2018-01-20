set linesi 1000 trimspool on pagesi 1000
col owner format a10
col db_link format a10
col username format a10
col host format a10
select owner, db_link, username, host from dba_db_links order by 1,2;
