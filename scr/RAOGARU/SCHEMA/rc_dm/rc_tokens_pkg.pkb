create or replace package body rc_tokens_pkg is
-- ----------------------------------------------------------------------
procedure dbg(p_msg in varchar2) is
begin
	if g_debug then
		dbms_output.put_line(p_msg);
	end if;
end;
-- ----------------------------------------------------------------------
procedure parse_tokens(p_str IN VARCHAR2) is
l_string   VARCHAR2(100) := replace(p_str,'_',',');
l_tablen  BINARY_INTEGER;
l_tab     DBMS_UTILITY.uncl_array;
l_abbr varchar2(30);
l_cnt number(3):=0;

begin
dbg('........Input String: '||p_str);
dbms_utility.comma_to_table (list=>l_string, tablen=>l_tablen, tab=>l_tab);
for i IN 1 .. l_tablen loop
	if g_validate then
		select count(1) into l_cnt from tokens where abbr=l_tab(i);
		if l_cnt=0 then
			dbg('........Token '||l_tab(i)||' Invalid');
			if g_populate then
				insert into tokens (abbr, text) values (l_tab(i),l_tab(i));
			end if;
		else
			dbg('....Token '||l_tab(i)||' Valid');
		end if;
	else
		dbg('Token '||l_tab(i));
	end if;
end loop;
end;
-- ----------------------------------------------------------------------
procedure scan_schema (p_schema in varchar2, p_populate in boolean default false) is
begin
	g_populate:=p_populate;
	dbg('Scanning Schema '||p_schema);
	for c in (select decode(object_type,
			'UNDEFINED',1, 
			'INDEX', 2, 
			'TABLE', 3, 
			'CLUSTER', 4, 
			'VIEW', 5, 
			'SYNONYM', 6, 
			'SEQUENCE', 7, 
			'PROCEDURE', 8, 
			'FUNCTION', 9, 
			'PACKAGE', 11, 
			'PACKAGE BODY', 12, 
			'TRIGGER', 13, 
			'TYPE', 14, 
			'TYPE BODY', 19, 
			'TABLE PARTITION', 20, 
			'INDEX PARTITION', 21, 
			'LOB', 22, 
			'LIBRARY', 23, 
			'DIRECTORY', 24, 
			'QUEUE', 28, 
			'JAVA SOURCE', 29, 
			'JAVA CLASS', 30, 
			'JAVA RESOURCE', 32, 
			'INDEXTYPE', 33, 
			'OPERATOR', 34, 
			'TABLE SUBPARTITION', 35, 
			'INDEX SUBPARTITION', 40, 
			'LOB PARTITION', 41, 
			'LOB SUBPARTITION', 42, 
			'MATERIALIZED VIEW', 43, 
			'DIMENSION', 44, 
			'CONTEXT', 46, 
			'RULE SET', 47, 
			'RESOURCE PLAN', 48, 
			'CONSUMER GROUP', 51, 
			'SUBSCRIPTION', 52, 
			'LOCATION', 55, 
			'XML SCHEMA', 56, 
			'JAVA DATA', 57, 
			'EDITION', 59, 
			'RULE', 60, 
			'CAPTURE', 61, 
			'APPLY', 62, 
			'EVALUATION CONTEXT', 66, 
			'JOB', 67, 
			'PROGRAM', 68, 
			'JOB CLASS', 69, 
			'WINDOW', 72, 
			'SCHEDULER GROUP', 74, 
			'SCHEDULE', 79, 
			'CHAIN', 81, 
			'FILE GROUP', 82, 
			'MINING MODEL', 87, 
			'ASSEMBLY', 90, 
			'CREDENTIAL', 92, 
			'CUBE DIMENSION', 93, 
			'CUBE', 94, 
			'MEASURE FOLDER', 95, 
			'CUBE BUILD PROCESS', 100, 
			'FILE WATCHER', 101, 
			'DESTINATION', 102,'
			0') object_order, 
			object_type,
			object_name 
		from all_objects 
		where owner=p_schema 
		order by object_order, object_type
	)
	loop
		scan_object(p_schema,c.object_type, c.object_name,g_populate);
	end loop;
end;
-- ----------------------------------------------------------------------
procedure scan_object (p_schema in varchar2,p_obj_type in varchar2, p_obj_name in varchar2, p_populate in boolean default false) is
begin
	g_populate:=p_populate;
	dbg('Scanning Object '||p_obj_type||' '||p_obj_name);
	parse_tokens(p_obj_name);
	if p_obj_type = 'TABLE' or p_obj_type='VIEW' THEN 
		scan_columns(p_schema, p_obj_name,g_populate);
	end if;
end;
-- ----------------------------------------------------------------------
procedure scan_columns (p_schema in varchar2,p_obj_name in varchar2, p_populate in boolean default false) is
begin
	g_populate:=p_populate;
	dbg('Scanning Object columns '||p_schema||'.'||p_obj_name);
	for c in (select column_name from all_tab_columns where owner=p_schema and table_name=p_obj_name)
	loop
		dbg('Validating column '||p_schema||'.'||p_obj_name||'.'||c.column_name);
		parse_tokens(c.column_name);
	end loop;
end;
-- ----------------------------------------------------------------------
end rc_tokens_pkg;
/
show errors
