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
my $ORACLE_SID=(qw(RAO));
my ($i, $dbh, $sth, @row, $sql);

#####################################################################
# MAIN program
#####################################################################

#create user ash identified by ash default tablespace system temporary tablespace temp;
#grant create session, select_any_table to ash;

# read sqlfile
local $/=undef;
print "ASH Stream starting using SQL File ", $ARGV[0], "\n";

open FILE, $ARGV[0] or die "Couldn't open file: $!";
$sql = <FILE>;
close FILE;
#print "SQL file open successful\n";

#print "Connecting to $ORACLE_SID\n" ;
$dbh = DBI->connect( "dbi:Oracle:$ORACLE_SID", "ASH", "ASH") or die "Can't connect to DB Oracle database: $DBI::errstr\n";
  
$sth = $dbh->prepare( $sql ) or die "Can't prepare SQL statement: $DBI::errstr\n";

$sth->execute or die "Can't execute SQL statement: $DBI::errstr\n";
  
# Retrieve the returned rows of data
while ( @row = $sth->fetchrow_array() ) {print "Row: @row\n"};

#while ($row = $sth->fetchrow_array) {  
#	if (@row) { print join(", ", @row), "\n"; }
#}

#print "Disconnecting from $ORACLE_SID\n" ;
$dbh->disconnect or warn "Disconnection failed: $DBI::errstr\n";

print "Done\n" ;

#
# End of script
#
