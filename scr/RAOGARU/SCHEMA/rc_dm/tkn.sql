set serveroutput on size 100000
@rc_tokens_pkg.pks
@rc_tokens_pkg.pkb

--exec rc_tokens_pkg.scan_schema('RC_IAM');
--exec rc_tokens_pkg.scan_schema('RC_IAM',true);

--exec rc_tokens_pkg.scan_schema('RC_PCM');
exec rc_tokens_pkg.scan_schema('RC_PCM',true);

--exec rc_tokens_pkg.scan_schema('SYSTEM');
