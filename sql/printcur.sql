set serveroutput on size 10000
set linesize 200 trims on recsepchar "-"
define input_query='&1'
exec print_table('&input_query');
