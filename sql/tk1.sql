WITH DATA AS
( SELECT 
'word1_word2_word3_word4_word5_word6'
 str FROM dual
 )
 SELECT trim(regexp_substr(str, '[^_]+', 1, LEVEL)) str
 FROM DATA
 CONNECT BY instr(str, '_', 1, LEVEL - 1) > 0
/
