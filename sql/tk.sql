WITH DATA AS
(SELECT view_name str FROM dba_views where view_name like 'DBA%')
 SELECT distinct str, level,trim(regexp_substr(str, '[^_]+', 1, LEVEL)) token
 FROM DATA
 CONNECT BY instr(str, '_', 1, LEVEL - 1) > 0
ORDER BY str, level
/
