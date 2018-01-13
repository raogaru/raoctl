ALTER TABLESPACE tbs_01 
    BEGIN BACKUP; 
--The following statement signals to the database that the backup is finished:

ALTER TABLESPACE tbs_01 
   END BACKUP; 

DOCUMENT
Moving and Renaming Tablespaces: Example 
This example moves and renames a datafile associated with the tbs_02 tablespace, created in "Enabling Autoextend for a Tablespace: Example", from diskb:tbs_f5.dat to diska:tbs_f5.dat:
#

--Take the tablespace offline using an ALTER TABLESPACE statement with the OFFLINE clause:

ALTER TABLESPACE tbs_02 OFFLINE NORMAL; 
--Copy the file from diskb:tbs_f5.dat to diska:tbs_f5.dat using your operating system commands.

--Rename the datafile using an ALTER TABLESPACE statement with the RENAME DATAFILE clause:

ALTER TABLESPACE tbs_02
  RENAME DATAFILE 'diskb:tbs_f5.dat'
  TO              'diska:tbs_f5.dat'; 
--Bring the tablespace back online using an ALTER TABLESPACE statement with the ONLINE clause:

ALTER TABLESPACE tbs_02 ONLINE;
DOCUMENT
Adding and Dropping Datafiles and Tempfiles: Examples 
The following statement adds a datafile to the tablespace. When more space is needed, new 10-kilobytes extents will be added up to a maximum of 100 kilobytes:
#
ALTER TABLESPACE tbs_03 
    ADD DATAFILE 'tbs_f04.dbf'
    SIZE 100K
    AUTOEXTEND ON
    NEXT 10K
    MAXSIZE 100K;
--The following statement drops the empty datafile:

ALTER TABLESPACE tbs_03
    DROP DATAFILE 'tbs_f04.dbf';
--The following statements add a tempfile to the temporary tablespace created in "Creating a Temporary Tablespace: Example" and then drops the tempfile:

ALTER TABLESPACE temp_demo ADD TEMPFILE 'temp05.dbf' SIZE 5 AUTOEXTEND ON;

ALTER TABLESPACE temp_demo DROP TEMPFILE 'temp05.dbf';
--Managing Space in a Temporary Tablespace: Example 
--The following statement manages the space in the temporary tablespace created in "Creating a Temporary Tablespace: Example" using the SHRINK SPACE clause. The KEEP clause is omitted, so the database will attempt to shrink the tablespace as much as possible as long as other tablespace storage attributes are satisfied.

ALTER TABLESPACE temp_demo SHRINK SPACE;
--Adding an Oracle-managed Datafile: Example 
--The following example adds an Oracle-managed datafile to the omf_ts1 tablespace (see "Creating Oracle-managed Files: Examples" for the creation of this tablespace). The new datafile is 100M and is autoextensible with unlimited maximum size:

ALTER TABLESPACE omf_ts1 ADD DATAFILE; 
--Changing Tablespace Logging Attributes: Example 
--The following example changes the default logging attribute of a tablespace to NOLOGGING:

ALTER TABLESPACE tbs_03 NOLOGGING;
--Altering a tablespace logging attribute has no affect on the logging attributes of the existing schema objects within the tablespace. The tablespace-level logging attribute can be overridden by logging specifications at the table, index, and partition levels.

--Changing Undo Data Retention: Examples 
--The following statement changes the undo data retention for tablespace undots1 to normal undo data behavior:

ALTER TABLESPACE undots1
  RETENTION NOGUARANTEE;
--The following statement changes the undo data retention for tablespace undots1 to behavior that preserves unexpired undo data:

ALTER TABLESPACE undots1
  RETENTION GUARANTEE;


