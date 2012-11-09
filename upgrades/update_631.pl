#!/usr/bin/perl

use lib "/usr/local/apache/lib/perl";

use Data::Dumper;

use Loggerithim::Database;

print "\nLoggerithim 6.3.1 DB Upgrade script\n\n";


my $db = Loggerithim::Database->new();
my $dbh = $db->connect();

eval {
###############################################################################
# Changes:
#
# Correct misspelled constraint name in attributes table.
# Add UNIQUE constraint to name in resgroups table.
# Add UNIQUE constraint to name in systems table.
# Add UNIQUE constraint to name in departments table.
# Add UNIQUE constraint to hostname in hosts table.
# Add UNIQUE constraint to ip in hosts table.

###############################################################################
# Fix misspelled attributes constraint.
###############################################################################
print "Fixing misspelled attributes constraint.\n";
my $fixattsth = $dbh->prepare("ALTER TABLE attributes DROP CONSTRAINT atttribute_name");
$fixattsth->execute();
$fixattsth->finish();

my $newconsth = $dbh->prepare("ALTER TABLE attributes ADD CONSTRAINT attribute_name UNIQUE(name)");
$newconsth->execute();
$newconsth->finish();

###############################################################################
# Add UNIQUE constraint to resgroups.
###############################################################################
print "Adding UNIQUE constraint to name in resgroups.\n";
my $resconsth = $dbh->prepare("ALTER TABLE resgroups ADD CONSTRAINT resgroup_name UNIQUE(name)");
$resconsth->execute();
$resconsth->finish();

###############################################################################
# Add UNIQUE constraint to systems.
###############################################################################
print "Adding UNIQUE constraint to name in systems.\n";
my $sysconsth = $dbh->prepare("ALTER TABLE systems ADD CONSTRAINT system_name UNIQUE(name)");
$sysconsth->execute();
$sysconsth->finish();

###############################################################################
# Add UNIQUE constraint to departments.
###############################################################################
print "Adding UNIQUE constraint to name in departments.\n";
my $depconsth = $dbh->prepare("ALTER TABLE departments ADD CONSTRAINT department_name UNIQUE(name)");
$depconsth->execute();
$depconsth->finish();

###############################################################################
# Add UNIQUE constraint to hosts.
###############################################################################
print "Adding UNIQUE constraint to hostname in departments.\n";
my $hostconsth = $dbh->prepare("ALTER TABLE hosts ADD CONSTRAINT host_hostname UNIQUE(hostname)");
$hostconsth->execute();
$hostconsth->finish();

###############################################################################
# Add UNIQUE constraint to hosts.
###############################################################################
print "Adding UNIQUE constraint to ip in departments.\n";
my $hostcon2sth = $dbh->prepare("ALTER TABLE hosts ADD CONSTRAINT host_ip UNIQUE(ip)");
$hostcon2sth->execute();
$hostcon2sth->finish();
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
