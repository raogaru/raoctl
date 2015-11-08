-- TITLE:Run Streams Performance Advisor and then Query DBA_TP_% views in same session
exec DBMS_STREAMS_ADVISOR_ADM.ANALYZE_CURRENT_PERFORMANCE;
exec dbms_lock.sleep(5);
exec DBMS_STREAMS_ADVISOR_ADM.ANALYZE_CURRENT_PERFORMANCE;
exec dbms_lock.sleep(5);
exec DBMS_STREAMS_ADVISOR_ADM.ANALYZE_CURRENT_PERFORMANCE;

