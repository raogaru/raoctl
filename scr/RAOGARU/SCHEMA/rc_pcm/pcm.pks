create or replace package pcm_pkg is
	g_debug number(8):=1;
	-- list
	procedure list_chn;
	procedure list_prc (p_chn_id in number);
	procedure list_stp (p_prc_id in number);

	procedure exec_chn (p_chn_id in number);
	procedure exec_prc (p_prc_id in number);
	procedure exec_stp (p_stp_id in number);
end pcm_pkg;
/
