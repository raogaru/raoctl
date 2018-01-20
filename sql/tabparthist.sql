prompt TABLE PARTITION HISTORGRAMS for table_name = '&1' and column_name = '&2'
select * from DBA_PART_HISTOGRAMS 
where table_name = upper('&1') and column_name=upper('&2')
order by partition_name, bucket_number;

