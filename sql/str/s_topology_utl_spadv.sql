-- TITLE:Collecting Oracle Streams Statistics Using the UTL_SPADV Package

DOC

*** Advanced Monitoring of Oracle Streams ***

Install UTL_SPADV package using $ORACLE_HOME/rdbms/admin/utlspadv.sql
Either collect current statistics once, or create a job 

Collect stats once:	
	exec UTL_SPADV.COLLECT_STATS

Create continuous monitoring:
	exec UTL_SPADV.START_MONITORING

Check monitoring:
	select UTL_SPADV.IS_MONITORING
	    (job_name=> 'STREAMS$_MONITORING_JOB', client_name => NULL);

Alter monitoring:
	exec UTL_SPADV.ALTER_MONITORING( interval => 120);

Stop monitoring:
	exec UTL_SPADV.STOP_MONITORING

Observe stats:
	SELECT SHOW_STATS_TABLE FROM STREAMS$_PA_MONITORING;
	exec UTL_SPADV.SHOW_STATS(path_stat_table=>'STREAMS$_PA_SHOW_PATH_STAT');

#
