set linesi 1000 trimspool on
col state format a80
 select CAPTURE_NAME, state from  v$streams_capture
/
