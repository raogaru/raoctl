-- TITLE1:
-- TITLE2: Displaying the Substitute Key Columns Specified at a Destination Database
-- DESC: You can designate a substitute key at a destination database, which is a column or set of columns that Oracle can use to identify rows in the table during apply. You can use substitute key columns to specify key columns for a table that has no primary key, or they can be used instead of a table's primary key when the table is processed by any apply process at a destination database.

COLUMN OBJECT_OWNER HEADING 'Table Owner' FORMAT A20
COLUMN OBJECT_NAME HEADING 'Table Name' FORMAT A20
COLUMN COLUMN_NAME HEADING 'Substitute Key Name' FORMAT A20
COLUMN APPLY_DATABASE_LINK HEADING 'Database Link|for Remote|Apply' FORMAT A15

SELECT OBJECT_OWNER, OBJECT_NAME, COLUMN_NAME, APPLY_DATABASE_LINK 
  FROM DBA_APPLY_KEY_COLUMNS
  ORDER BY APPLY_DATABASE_LINK, OBJECT_OWNER, OBJECT_NAME;
