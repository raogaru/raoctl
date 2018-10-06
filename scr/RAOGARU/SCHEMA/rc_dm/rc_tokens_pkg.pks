create or replace package rc_tokens_pkg is
	g_debug boolean := true;
	g_validate boolean := true; -- validate token from TKN table
	g_populate boolean := false; -- populate TKN table if token does not exists
	
	procedure scan_schema (p_schema in varchar2, p_populate in boolean default false);
	procedure scan_object (p_schema in varchar2, p_obj_type in varchar2, p_obj_name in varchar2, p_populate in boolean default false);
	procedure scan_columns (p_schema in varchar2, p_obj_name in varchar2, p_populate in boolean default false);
end rc_tokens_pkg;
/
