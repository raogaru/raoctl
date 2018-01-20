--
-- close pluggable database
--
define v_pdb_name='&1'
ALTER PLUGGABLE DATABASE &v_pdb_name close;
