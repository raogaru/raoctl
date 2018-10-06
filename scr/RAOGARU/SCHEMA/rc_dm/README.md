RAOGARU raoctl Data Model Scanning Objects

How to Install ?
	@dm

How to Run Tokens Package ?

	set serveroutput on size 100000

	-- do not populate tokens table
	exec rc_tokens_pkg.scan_schema('RC_IAM',false);  

	-- populate tokens table (first time)
	exec rc_tokens_pkg.scan_schema('RC_IAM',true);  

