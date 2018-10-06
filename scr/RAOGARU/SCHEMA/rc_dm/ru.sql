set serveroutput on size 100000
@rc_rules_pkg.pks
@rc_rules_pkg.pkb
--exec rc_rules_pkg.scan_schema;
exec rc_rules_pkg.scan_schema('RC_IAM');
