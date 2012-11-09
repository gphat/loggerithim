#!/usr/bin/perl

use lib "../lib";

use Loggerithim::Database;

print "\nLoggerithim 7.0.0 DB Upgrade script\n\n";

open STDERR, "| perl -ne 'print unless /^NOTICE:  /'";

my $db = Loggerithim::Database->new();
my $dbh = $db->connect();

eval {
###############################################################################
# Changes:
#
# Drop all views
# Rename cached_metrics.type to cached_metrics.resgroupid
# Rename metrics.type to metrics.resgroupid
# Setup metrics.hostid foreign key
# Drop all report rows
# Drop name and hosts columns from reports
# Add attributeid to reports
# Make profiles.name unique
# Make resources.name unique
# Rename hosts.hostname to name
# Drop constraints on events table

###############################################################################
# Create the saves table.
###############################################################################
print "Dropping views.\n";
$dbh->do("DROP VIEW contact_data");
$dbh->do("DROP VIEW groupuser_data");
$dbh->do("DROP VIEW hostattr_data");
$dbh->do("DROP VIEW host_data");
$dbh->do("DROP VIEW profattr_data");
$dbh->do("DROP VIEW threshold_data");

###############################################################################
# Rename cached_metrics.type to cached_metrics.resgroupid
###############################################################################
print "Renaming cached_metrics.type to cached_metrics.resgroupid.\n";
$dbh->do("ALTER TABLE cached_metrics RENAME COLUMN type TO resgroupid");
$dbh->do("ALTER TABLE cached_metrics ADD CONSTRAINT cached_metrics_resgroups FOREIGN KEY (resgroupid) REFERENCES resgroups");

###############################################################################
# Rename metrics.type to metrics.resourceid
###############################################################################
print "Renaming metrics.type to metrics.resourceid.\n";
$dbh->do("ALTER TABLE metrics RENAME COLUMN type TO resgroupid");
$dbh->do("ALTER TABLE metrics ADD CONSTRAINT metrics_resgroups FOREIGN KEY (resgroupid) REFERENCES resgroups");

###############################################################################
# Rename custom_metrics.type to custom_metrics.resourceid
###############################################################################
print "Renaming custom_metrics.type to custom_metrics.resourceid.\n";
$dbh->do("ALTER TABLE custom_metrics RENAME COLUMN type TO resgroupid");
$dbh->do("ALTER TABLE custom_metrics ADD CONSTRAINT custom_metrics_resgroups FOREIGN KEY (resgroupid) REFERENCES resgroups");

###############################################################################
# Setup metrics.hostid foreign key
###############################################################################
print "Setting up metrics.hostid foreign key.\n";
$dbh->do("ALTER TABLE metrics ADD CONSTRAINT metrics_hosts FOREIGN KEY (hostid) REFERENCES hosts");

###############################################################################
# Drop All Reports
###############################################################################
print "Dropping all reports.\n";
$dbh->do("DELETE FROM reports WHERE reportid != NULL");

###############################################################################
# Drop names and hosts columns of reports
###############################################################################
print "Dropping names and hosts of reports.\n";
$dbh->do("ALTER TABLE reports DROP COLUMN name");
$dbh->do("ALTER TABLE reports DROP COLUMN hosts");

###############################################################################
# Add attributeid to reports
###############################################################################
print "Adding attributeid to reports.\n";
$dbh->do("ALTER TABLE reports ADD COLUMN attributeid BIGINT");
$dbh->do("ALTER TABLE reports ALTER COLUMN attributeid SET NOT NULL");
$dbh->do("ALTER TABLE reports ADD CONSTRAINT reports_attributes FOREIGN KEY (attributeid) REFERENCES attributes");

###############################################################################
# Make attributes.interval NOT NULL
###############################################################################
print "Making attributes.interval NOT NULL.\n";
$dbh->do("ALTER TABLE reports ALTER COLUMN interval SET NOT NULL");

###############################################################################
# Make profiles.name UNIQUE
###############################################################################
print "Making profiles.name UNIQUE.\n";
$dbh->do("ALTER TABLE profiles ADD CONSTRAINT profiles_name UNIQUE(name)");

###############################################################################
# Rename hosts.hostname to hosts.name
###############################################################################
print "Rename hosts.hostname to hosts.name.\n";
$dbh->do("ALTER TABLE hosts RENAME hostname TO name");

###############################################################################
# Make resources.name UNIQUE
###############################################################################
print "Making resources.name UNIQUE.\n";
$dbh->do("ALTER TABLE resources ADD CONSTRAINT resources_name UNIQUE(name)");

###############################################################################
# Drop constraints on events table
###############################################################################
print "Allowing NULL in events.jobid and events.hostid.\n";
$dbh->do("ALTER TABLE events ALTER COLUMN jobid DROP NOT NULL");
$dbh->do("ALTER TABLE events ALTER COLUMN hostid DROP NOT NULL");

###############################################################################
# Rename event_text to message in events, childevents, and archivedevents
###############################################################################
print "Rename event_text to message in events, childevents, and archivedevents.\n";
$dbh->do("ALTER TABLE events RENAME event_text TO message");
$dbh->do("ALTER TABLE childevents RENAME event_text TO message");
$dbh->do("ALTER TABLE archivedevents RENAME event_text TO message");
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
