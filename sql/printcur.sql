set serveroutput on size 10000
set pagesi 0 linesize 200 trims on recsepchar "-"
define input_query='&1'
exec print_table('&input_query');
