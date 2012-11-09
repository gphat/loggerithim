#!/usr/bin/perl
use strict;

use lib '/usr/local/loggerithim/lib';

use Loggerithim::Database;
use Loggerithim::Host;

$| = 1;

my $id = shift;

my $host = Loggerithim::Host->retrieve($id);

if(!($host->ip())) {
	print "Couldn't find host $id.\n";
	exit(1);
}

print "Host to delete is ".$host->name()." (".$host->ip().")\n";
GETINPUT: print "Are you sure you want to remove this host and ALL it's data? [n]: ";
my $confirm = <STDIN>;
chomp($confirm);
if($confirm eq "n") {
	print "Fine, goodbye.\n";
	exit(0);
} elsif($confirm ne "y") {
	print "\nExpecting something along the lines of 'n' or 'y'.\n\n";
	goto GETINPUT;
}

print "If you say so...\n";

my $db = Loggerithim::Database->new();
my $dbh = $db->connect();

my $affected;

print "Deleting metrics for host $id...";
my $delmetrics = $dbh->prepare("DELETE FROM metrics WHERE hostid=?");
$affected = $delmetrics->execute($id);
$delmetrics->finish();
print "Removed $affected rows.\n";

print "Deleting cached metrics for host $id...";
my $delcachemetrics = $dbh->prepare("DELETE FROM metrics WHERE hostid=?");
$affected = $delcachemetrics->execute($id);
$delcachemetrics->finish();
print "Removed $affected rows.\n";


print "Deleting attributes for host $id...";
my $delattributes = $dbh->prepare("DELETE FROM hostattrs WHERE hostid=?");
$affected = $delattributes->execute($id);
$delattributes->finish();
print "Removed $affected rows.\n";

print "Deleting thresholds for host $id...";
my $delthresholds = $dbh->prepare("DELETE FROM thresholds WHERE hostid=?");
$affected = $delthresholds->execute($id);
$delthresholds->finish();
print "Removed $affected rows.\n";

print "Deleting host $id...";
my $delhost = $dbh->prepare("DELETE FROM hosts WHERE hostid=?");
$affected = $delhost->execute($id);
$delhost->finish();
print "Removed $affected rows.\n";

$dbh->disconnect();
