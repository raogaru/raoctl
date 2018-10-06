create or replace package rc_rules_pkg is
	g_debug boolean := true;
	g_schema varchar2(30):=null;
	g_rule_num   number(8):=null;
	g_rule_txt   varchar2(100):=null;
	procedure scan_schema (p_schema in varchar2 default 'SYSTEM');
end rc_rules_pkg;
/
