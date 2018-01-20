select COLUMN_NAME			
,NUM_DISTINCT	
--,LOW_VALUE	
--,HIGH_VALUE
,DENSITY				
,NUM_NULLS			
,NUM_BUCKETS	
,LAST_ANALYZED
,SAMPLE_SIZE				
,GLOBAL_STATS			
,USER_STATS			
,AVG_COL_LEN	
,HISTOGRAM	
from dba_tab_col_statistics
where table_name=upper('&1')
order by column_name;
