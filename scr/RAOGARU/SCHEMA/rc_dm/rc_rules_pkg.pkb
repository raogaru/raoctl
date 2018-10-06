create or replace package body rc_rules_pkg is
-- ----------------------------------------------------------------------
procedure dbg(p_msg in varchar2) is
begin
	if g_debug then
		dbms_output.put_line(p_msg);
	end if;
end;
-- ----------------------------------------------------------------------
procedure msg(p_rule in number, p_msg in varchar2) is 
begin
	dbg('Rule#'||to_char(p_rule)||':'||p_msg);

end;
-- ----------------------------------------------------------------------
procedure violation(p_obj in varchar2) is 
begin
	dbg('....Rule#'||g_rule_num||' violation : '||p_obj);

end;
-- ======================================================================
-- PRIMARY KEY RULES 
-- ----------------------------------------------------------------------
procedure rule_1001 is
begin
	g_rule_num:=1001;
	g_rule_txt:='All tables to have primary key';
	msg(g_rule_num, g_rule_txt);
	for c in (
		select table_name 
		from all_tables 
		where owner=g_schema
		minus
		select table_name 
		from all_constraints 
		where owner=g_schema 
		and constraint_type='P'
		)
	loop
		violation(c.table_name);
	end loop;
end;
-- ----------------------------------------------------------------------
procedure rule_1002 is
begin
	g_rule_num:=1002;
	g_rule_txt:='Primary key constraint name is <table_name>_PK';
	msg(g_rule_num, g_rule_txt);
	for c in (
		select table_name 
		from all_tables 
		where owner=g_schema
		minus
		select table_name 
		from all_constraints 
		where owner=g_schema 
		and constraint_type='P' 
		and constraint_name=table_name||'_PK'
		)
	loop
		violation(c.table_name);
	end loop;
end;
-- ----------------------------------------------------------------------
procedure rule_1003 is
begin
	g_rule_num:=1003;
	g_rule_txt:='Primary key indexes to be owned by table owner';
	msg(g_rule_num, g_rule_txt);
	for c in (
		select table_name 
		from all_tables 
		where owner=g_schema
		minus
		select table_name 
		from all_indexes 
		where owner=g_schema 
		and table_owner=g_schema
		and index_name=table_name||'_PK'
		)
	loop
		violation(c.table_name);
	end loop;
end;
-- ----------------------------------------------------------------------
procedure rule_1004 is
begin
	g_rule_num:=1004;
	g_rule_txt:='Primary key indexes are pre-created unique indexes';
	msg(g_rule_num, g_rule_txt);
	for c in (
		select table_name 
		from all_tables 
		where owner=g_schema
		minus
		select table_name 
		from all_indexes 
		where owner=g_schema 
		and table_owner=g_schema
		and index_name=table_name||'_PK'
		and uniqueness='UNIQUE'
		)
	loop
		violation(c.table_name);
	end loop;
end;
-- ----------------------------------------------------------------------
procedure rule_1005 is
begin
	g_rule_num:=1005;
	g_rule_txt:='Primary key constraints are enabled';
	msg(g_rule_num, g_rule_txt);
	for c in (
		select table_name 
		from all_tables 
		where owner=g_schema
		minus
		select table_name 
		from all_constraints 
		where owner=g_schema 
		and constraint_type='P' 
		and status='ENABLED'
		)
	loop
		violation(c.table_name);
	end loop;
end;
-- ----------------------------------------------------------------------
procedure rule_1006 is
begin
	g_rule_num:=1006;
	g_rule_txt:='Primary key constraint name and its index name match';
	msg(g_rule_num, g_rule_txt);
	for c in (
		select table_name 
		from all_tables 
		where owner=g_schema
		minus
		select table_name 
		from all_constraints 
		where owner=g_schema 
		and index_owner=g_schema
		and constraint_type='P' 
		and constraint_name=index_name
		)
	loop
		violation(c.table_name);
	end loop;
end;
-- ----------------------------------------------------------------------
procedure rule_1007 is
begin
	g_rule_num:=1007;
	g_rule_txt:='xxx';
	msg(g_rule_num, g_rule_txt);
end;
-- ----------------------------------------------------------------------
procedure rule_1008 is
begin
	g_rule_num:=1008;
	g_rule_txt:='yyy';
	msg(g_rule_num, g_rule_txt);
end;
-- ----------------------------------------------------------------------
procedure rule_set_1000_pk is
begin
	msg(1000, 'RULE SET - PRIMARY KEY');
	rule_1001;
	rule_1002;
	rule_1003;
	rule_1004;
	rule_1005;
	rule_1006;
	--rule_1007;
	--rule_1008;
end;
-- ======================================================================
-- FOREIGN KEY RULES 
-- ----------------------------------------------------------------------
procedure rule_1101 is
begin
	g_rule_num:=1101;
	g_rule_txt:='Foreign key constraint name like <table_name>_FK%';
	msg(g_rule_num, g_rule_txt);
	for c in (
		select table_name, constraint_name
		from all_constraints 
		where owner=g_schema 
		and constraint_type='R' 
		and constraint_name not like table_name||'_FK%'
		)
	loop
		violation(c.table_name||' FK is '||c.constraint_name);
	end loop;
end;
-- ----------------------------------------------------------------------
procedure rule_1102 is
begin
	g_rule_num:=1102;
	g_rule_txt:='Foreign key constraings are enabled';
	msg(g_rule_num, g_rule_txt);
	for c in (
		select table_name, constraint_name
		from all_constraints 
		where owner=g_schema 
		and constraint_type='R' 
		and status!='ENABLED'
		)
	loop
		violation(c.table_name||' FK is '||c.constraint_name);
	end loop;
end;
-- ----------------------------------------------------------------------
procedure rule_1103 is
begin
	g_rule_num:=1103;
	g_rule_txt:='Foreign key constraings are valid';
	msg(g_rule_num, g_rule_txt);
	for c in (
		select table_name , constraint_name
		from all_constraints 
		where owner=g_schema 
		and constraint_type='R' 
		and invalid='VALID'
		)
	loop
		violation(c.table_name||' FK is '||c.constraint_name);
	end loop;
end;
-- ----------------------------------------------------------------------
procedure rule_1104 is
begin
	g_rule_num:=1104;
	g_rule_txt:='Foreign key reference table owner same as FK owner';
	msg(g_rule_num, g_rule_txt);
	for c in (
		select owner, constraint_name, table_name , r_owner, r_constraint_name
		from all_constraints 
		where owner=g_schema 
		and constraint_type='R' 
		and owner!=r_owner
		)
	loop
		violation('FK='||c.constraint_name||
			' Table='||c.owner||'.'||c.table_name||
			' ReferenceTablePK='||c.r_owner||'.'||c.r_constraint_name);
	end loop;
end;
-- ----------------------------------------------------------------------
procedure rule_1105 is
begin
	g_rule_num:=1105;
	g_rule_txt:='Foreign key constraint require indexes on same column set/order';
	msg(g_rule_num, g_rule_txt);
/*
	for c in (
		select table_name, column_name, position
		from all_cons_columns
		where owner=g_schema
		minus
		select table_name , column_name, column_position
		from all_ind_columns
		where index_owner=g_schema 
		)
	loop
		violation(c.table_name);
	end loop;
*/
end;
-- ----------------------------------------------------------------------
procedure rule_1106 is
begin
	g_rule_num:=1106;
	g_rule_txt:='yyy';
	msg(g_rule_num, g_rule_txt);
end;
-- ----------------------------------------------------------------------
procedure rule_1107 is
begin
	g_rule_num:=1107;
	g_rule_txt:='yyy';
	msg(g_rule_num, g_rule_txt);
end;
-- ----------------------------------------------------------------------
procedure rule_1108 is
begin
	g_rule_num:=1108;
	g_rule_txt:='yyy';
	msg(g_rule_num, g_rule_txt);
end;
-- ----------------------------------------------------------------------
procedure rule_set_1100_fk is
begin
	msg(1100, 'RULE SET - FOREIGN KEY');
	rule_1101;
	rule_1102;
	rule_1103;
	rule_1104;
	rule_1105;
	rule_1106;
	rule_1107;
	rule_1108;
end;
-- ======================================================================
-- ----------------------------------------------------------------------
procedure scan_schema (p_schema in varchar2 default 'SYSTEM') is
begin
	g_schema:=p_schema;
	dbg('Scanning Schema '||p_schema);
	rule_set_1000_pk;
	rule_set_1100_fk;
end;
-- ----------------------------------------------------------------------
end rc_rules_pkg;
/
show errors
