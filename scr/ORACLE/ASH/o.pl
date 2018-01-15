#!/usr/bin/perl -w
#####################################################################
# Perl DBI Oracle POC
#####################################################################
use lib "/usr/lib/perl5" ;
use lib "/usr/local/lib/perl5" ;
use lib "/oracle/software/11.2.0/perl/lib/site_perl/5.10.0/i686-linux-thread-multi" ;
use strict;
use Switch;
use warnings;
use DBI;
use POSIX;

#====================================================================
# global variables
#my @ORACLE_SID=(qw(DB51 DB52 DB53));
my @ORACLE_SID=(qw(RAO SRI NIK ));
my ($i, $db_count, @dbh, @sth, @row);

#####################################################################
# MAIN program
#####################################################################

$db_count=1;
for ($i=0; $i<$db_count; $i++) {
	print "Connecting to $ORACLE_SID[$i]\n" ;
	$dbh[$i] = DBI->connect( "dbi:Oracle:$ORACLE_SID[$i]", "SMS", "SMS")
		or die "Can't connect to DB51 Oracle database: $DBI::errstr\n";
}
  
for ($i=0; $i<$db_count; $i++) {
	$sth[$i] = $dbh[$i]->prepare( "SELECT * FROM dbo.hb" ) 
		or die "Can't prepare SQL statement: $DBI::errstr\n";
	$sth[$i]->execute 
		or die "Can't execute SQL statement: $DBI::errstr\n";
}
  
# Retrieve the returned rows of data
for ($i=0; $i<$db_count; $i++) {
	while ( @${$row[$i]} ) = $sth[$i]->fetchrow_array() ) {
   	   print "Row: @row\n";
	}
	warn "Data fetching terminated early by error: $DBI::errstr\n" if $DBI::err;
}

for ($i=0; $i<$db_count; $i++) {
	print "Disconnecting from $ORACLE_SID[$i]\n" ;
	$dbh[$i]->disconnect
	    or warn "Disconnection failed: $DBI::errstr\n";
}

print "Done\n" ;

#
# End of script
#
