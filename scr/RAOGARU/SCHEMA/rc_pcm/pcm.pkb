create or replace package body pcm_pkg is
-- ----------------------------------------------------------------------
procedure dbg(p_msg in varchar2) is
begin
	if g_debug=1 then
		dbms_output.put_line(p_msg);
	end if;
end;
-- ----------------------------------------------------------------------
procedure list_chn is
begin
	dbg('');
end;
-- ----------------------------------------------------------------------
procedure list_prc (p_chn_id in number) is
begin
	dbg('');
end;
-- ----------------------------------------------------------------------
procedure list_stp (p_prc_id in number) is
begin
	dbg('inside list-stp '|| p_prc_id);
end;

-- ----------------------------------------------------------------------
procedure exec_chn (p_chn_id in number) is
begin
	dbg('Executing Chain'||to_char(p_chn_id));
	for c in (select prc_id from prc_grp where chn_id=p_chn_id)
	loop
		dbg('....Calling Process '||to_char(c.prc_id));
		exec_prc(c.prc_id);
	end loop;
end;
-- ----------------------------------------------------------------------
procedure exec_prc (p_prc_id in number) is
begin
	dbg('....Executing Process '||to_char(p_prc_id));
	for c in (select stp_id from stp_grp where prc_id=p_prc_id)
	loop
		dbg('........Calling Step '||to_char(c.stp_id));
		exec_stp(c.stp_id);
	end loop;
end;
-- ----------------------------------------------------------------------
procedure exec_stp (p_stp_id in number) is
begin
	dbg('........Executing Step '||to_char(p_stp_id));
	for c in (select name, prg from stp where id=p_stp_id)
	loop
		dbg('........Invoking Step ID='||to_char(p_stp_id)||' Name='||c.name||' What='||c.prg);
		-- example
		rc_pcm.pcm_pkg.list_stp(p_stp_id);
	end loop;
end;
-- ----------------------------------------------------------------------
end pcm_pkg;
/
show errors
