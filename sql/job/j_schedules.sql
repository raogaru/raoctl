select 
 OWNER
,SCHEDULE_NAME
,SCHEDULE_TYPE
,START_DATE
,REPEAT_INTERVAL
,EVENT_QUEUE_OWNER
,EVENT_QUEUE_NAME
,EVENT_QUEUE_AGENT
,EVENT_CONDITION
,FILE_WATCHER_OWNER
,FILE_WATCHER_NAME
,END_DATE
from
DBA_SCHEDULER_SCHEDULES;