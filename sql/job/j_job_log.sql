select 
 LOG_ID
,LOG_DATE
,OWNER
,JOB_NAME
,JOB_SUBNAME
,JOB_CLASS
,OPERATION
,STATUS
,USER_NAME
,CLIENT_ID
,GLOBAL_UID
,CREDENTIAL_OWNER
,CREDENTIAL_NAME
,DESTINATION_OWNER
,DESTINATION
from DBA_SCHEDULER_JOB_LOG;
