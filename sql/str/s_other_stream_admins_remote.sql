-- TITLE1: Streams Admins Allow Remote Access
-- TITLE2: Listing Users Who Allow Access to Remote Oracle Streams Administrators
-- DESC: You can configure a user to allow access to remote Oracle Streams administrators by running the GRANT_REMOTE_ADMIN_ACCESS procedure in the DBMS_STREAMS_AUTH package. Such a user allows the remote Oracle Streams administrator to perform administrative actions in the local database using a database link.  Typically, you configure such a user at a local source database if a downstream capture process captures changes originating at the local source database. The Oracle Streams administrator at a downstream capture database administers the source database using this connection.

COLUMN USERNAME HEADING 'Users Who Allow Remote Access' FORMAT A30

SELECT USERNAME FROM DBA_STREAMS_ADMINISTRATOR
  WHERE ACCESS_FROM_REMOTE = 'YES'; 
