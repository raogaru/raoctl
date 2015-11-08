-- TITLE1: Local Stream Admins
-- TITLE2: Displaying Local Oracle Stream Administrators
-- DESC: You can grant privileges to a local Oracle Streams administrator by running the GRANT_ADMIN_PRIVILEGE procedure in the DBMS_STREAMS_AUTH package. The DBA_STREAMS_ADMINISTRATOR data dictionary view contains only the local Oracle Streams administrators created with the grant_privileges parameter set to TRUE when the GRANT_ADMIN_PRIVILEGE procedure was run for the user. If you created an Oracle Streams administrator using generated scripts and set the grant_privileges parameter to FALSE when the GRANT_ADMIN_PRIVILEGE procedure was run for the user, then the DBA_STREAMS_ADMINISTRATOR data dictionary view does not list the user as an Oracle Streams administrator.

COLUMN USERNAME HEADING 'Local Streams Administrator' FORMAT A30

SELECT USERNAME FROM DBA_STREAMS_ADMINISTRATOR
  WHERE LOCAL_PRIVILEGES = 'YES';
