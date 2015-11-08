-- TITLE1: Non Compatible Objects
-- TITLE2: Listing the Database Objects That Are Not Compatible with Capture Processes
-- DESC: A database object is not compatible with capture processes if capture processes cannot capture changes to it. 

DOC
If capture processes automatically filter out changes to a database object, then the rule sets used by the capture processes do not need to filter them out explicitly. For example, capture processes automatically filter out changes to domain indexes. However, if changes to incompatible database objects are not filtered out automatically, then the rule sets used by the capture process must filter them out to avoid errors.

For example, suppose the rule sets for a capture process instruct the capture process to capture all of the changes made to a specific schema. Also suppose that the query in this section shows that one object in this schema is not compatible with capture processes, and that changes to the object are not filtered out automatically. In this case, you can add a rule to the negative rule set for the capture process to filter out changes to the incompatible database object.
#

COLUMN OWNER HEADING 'Object|Owner' FORMAT A8
COLUMN TABLE_NAME HEADING 'Object Name' FORMAT A30
COLUMN REASON HEADING 'Reason' FORMAT A30
COLUMN AUTO_FILTERED HEADING 'Auto|Filtered?' FORMAT A9

SELECT OWNER, TABLE_NAME, REASON, AUTO_FILTERED FROM DBA_STREAMS_UNSUPPORTED;

