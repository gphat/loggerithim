#!/usr/bin/perl

use lib "/usr/local/apache/lib/perl";

use Data::Dumper;

use Loggerithim::Database;

print "\nLoggerithim 6.2.2 DB Upgrade script\n\n";


my $db = Loggerithim::Database->new();
my $dbh = $db->connect();

eval {
###############################################################################
# Changes:
#
# Fix types for 'Linux Memory' attribute
# Drop type column for user table

###############################################################################
# Fix 'Linux Memory' attribute
###############################################################################
print "Fixed bad types for Linux Memory Attribute.\n";
my $fixattsth = $dbh->prepare("UPDATE attributes SET types='memAvailReal,memBuffered,memCached' WHERE name='Linux Memory'");
$fixattsth->execute();
$fixattsth->finish();

###############################################################################
# Drop type column in users
###############################################################################
print "Dropping type column from users table.\n";
my $typesth = $dbh->prepare("ALTER TABLE users DROP COLUMN type");
$typesth->execute();
$typesth->finish();
};

if($@) {
	print $@."\n";
	print "\nAn error ocurred, no changes were made.\n";
	$dbh->rollback();
} else {
	print "\nNo errors detected, Loggerithim successfully upgraded.\n";
	$dbh->commit();
}
$dbh->disconnect();
