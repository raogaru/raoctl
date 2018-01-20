col sid_serial format a12
select sid||'.'||serial# sid_serial, status, osuser, process, machine from v$session where username=upper('&1');
