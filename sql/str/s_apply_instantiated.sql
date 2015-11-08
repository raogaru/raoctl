
set pagesi 1000 linesi 1000 trimspool on head on feedback off
col source_database format a12 head SOURCE_DB
col source_schema format a12
col apply_database_link format a12 head APPLY_DBLINK

select source_database, instantiation_scn scn, apply_database_link 
from dba_apply_instantiated_global;

select source_database, source_schema,instantiation_scn,apply_database_link 
from dba_apply_instantiated_schemas;

select source_database, source_object_owner,source_object_name,source_object_type ,instantiation_scn inst_scn , ignore_scn , apply_database_link 
from dba_apply_instantiated_objects;
