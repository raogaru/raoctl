select owner, view_name from dba_views where view_name like upper('&1%&2%');
