RAOGARU raoctl Data Model Scanning Objects

-- ======================================================================

How to Install ?

	@dm

-- ======================================================================

What is tokens pacakge for ?

	Tokens package is to split any string into tokens and validate whether a token isknown to enterprise data dictionary.

How to Run Tokens Package ?

	set serveroutput on size 100000

	-- do not populate tokens table
	exec rc_tokens_pkg.scan_schema('RC_IAM',false);  

	-- populate tokens table (first time)
	exec rc_tokens_pkg.scan_schema('RC_IAM',true);  

-- ======================================================================

what is rules package for ?

	Rules package is to scan for data modeling best practices 101.

How to Run Rules Package?

	set serveroutput on size 100000

	exec rc_rules_pkg.scan_schema('RC_IAM');

-- ======================================================================
