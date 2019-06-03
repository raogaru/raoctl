CREATE OR REPLACE FUNCTION comma_to_table(p_list IN VARCHAR2)
RETURN tokens PIPELINED 
AS
     l_string LONG := p_list || '_';
     l_comma_index PLS_INTEGER;
     l_index PLS_INTEGER := 1;
BEGIN
     LOOP
       l_comma_index := INSTR(l_string, '_', l_index);
       EXIT WHEN l_comma_index = 0;
       PIPE ROW ( TRIM(SUBSTR(l_string, l_index, l_comma_index - l_index)));
       l_index := l_comma_index + 1;
     END LOOP;
     RETURN;
END comma_to_table;
/
