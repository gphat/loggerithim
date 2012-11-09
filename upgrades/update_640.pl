#!/usr/bin/perl

use lib "../lib";

use Data::Dumper;

use Loggerithim::Database;

print "\nLoggerithim 6.4.0 DB Upgrade script\n\n";

open STDERR, "| perl -ne 'print unless /^NOTICE:  /'";

my $db = Loggerithim::Database->new();
my $dbh = $db->connect();

eval {
###############################################################################
# Changes:
#
# Add the attribute sigil to the hostattr_data view
# Set username to UNIQUE in users
# Set ip to UNIQUE in hosts
# Set name to UNIQUE in reporters
# Set name to UNIQUE in reports
# Set name to UNIQUE in smeeplets
# Create groups table
# Create objects table
# Create groupusers table
# Create groupobjects table
# Create groupuser view
# Create the sessions table
# Create the annotations table

###############################################################################
# Add the attribute sigil to the hostattr_data view
###############################################################################
print "Adding attribute sigil to the hostattr_data view.\n";
$dbh->do("DROP VIEW hostattr_data");
$dbh->do("CREATE VIEW hostattr_data AS SELECT ha.hostattrid, h.hostid, h.hostname, a.attributeid, a.name, a.sigil FROM hostattrs ha, hosts h, attributes a WHERE ha.hostid = h.hostid AND ha.attributeid = a.attributeid;");

###############################################################################
# Add the UNIQUE constraint to the users table on username
###############################################################################
print "Adding UNIQUE constraint to the users table on username.\n";
$dbh->do("ALTER TABLE users ADD CONSTRAINT users_username UNIQUE(username)");

###############################################################################
# Add the UNIQUE constraint to the hosts table on ip
###############################################################################
print "Adding UNIQUE constraint to the hosts table on ip.\n";
$dbh->do("ALTER TABLE hosts ADD CONSTRAINT hosts_ip UNIQUE(ip)");

###############################################################################
# Add the UNIQUE constraint to the reporters table on name
###############################################################################
print "Adding UNIQUE constraint to the reporters table on name.\n";
$dbh->do("ALTER TABLE reporters ADD CONSTRAINT reporters_name UNIQUE(name)");

###############################################################################
# Add the UNIQUE constraint to the reports table on name
###############################################################################
print "Adding UNIQUE constraint to the reports table on name.\n";
$dbh->do("ALTER TABLE reports ADD CONSTRAINT reports_name UNIQUE(name)");

###############################################################################
# Add the UNIQUE constraint to the smeeplets table on name
###############################################################################
print "Adding UNIQUE constraint to the smeeplets table on name.\n";
$dbh->do("ALTER TABLE smeeplets ADD CONSTRAINT smeeplets_name UNIQUE(name)");

###############################################################################
# Create the groups table.
###############################################################################
print "Creating groups table.\n";
$dbh->do("CREATE SEQUENCE groups_groupid_seq");
$dbh->do("CREATE TABLE groups (
		groupid		BIGINT CONSTRAINT pk_groupid NOT NULL PRIMARY KEY DEFAULT nextval('groups_groupid_seq'),
		name		VARCHAR(50) NOT NULL UNIQUE
)");

###############################################################################
# Create the objects table.
###############################################################################
print "Creating objects table.\n";
$dbh->do("CREATE SEQUENCE objects_objectid_seq");
$dbh->do("CREATE TABLE objects (
		objectid	BIGINT CONSTRAINT pk_objectid NOT NULL PRIMARY KEY DEFAULT nextval('objects_objectid_seq'),
		name		VARCHAR(50) NOT NULL UNIQUE
)");

my $insobjs = $dbh->prepare("INSERT INTO objects (name) VALUES (?)");

my @objs = qw(Attribute Contact Department Event Group Host Job Notification Object Profile Reporter ResourceGroup Resource Smeeplet System User);
foreach my $obj (@objs) {
	$insobjs->execute($obj);
}

###############################################################################
# Create the groupusers table.
###############################################################################
print "Creating groupusers table.\n";
$dbh->do("CREATE SEQUENCE groupusers_groupuserid_seq");
$dbh->do("CREATE TABLE groupusers (
		groupuserid	BIGINT CONSTRAINT pk_groupuserid NOT NULL PRIMARY KEY DEFAULT nextval('groupusers_groupuserid_seq'),
		groupid		BIGINT NOT NULL REFERENCES groups,
		userid		BIGINT NOT NULL REFERENCES users
)");

###############################################################################
# Create the groupobjects table.
###############################################################################
print "Creating groupobjects table.\n";
$dbh->do("CREATE SEQUENCE groupobjects_groupobjectid_seq");
$dbh->do("CREATE TABLE groupobjects (
		groupobjectid	BIGINT CONSTRAINT pk_groupobjectid NOT NULL PRIMARY KEY DEFAULT nextval('groupobjects_groupobjectid_seq'),
		groupid			BIGINT NOT NULL REFERENCES groups,
		objectid		BIGINT NOT NULL REFERENCES objects,
		read			BIT NOT NULL,
		write			BIT NOT NULL,
		remove			BIT NOT NULL
)");

###############################################################################
# Create the groupuser view.
###############################################################################
print "Creating groupuser view.\n";
$dbh->do("CREATE VIEW groupuser_data
		AS
		SELECT gu.groupuserid, g.groupid, g.name,
			u.userid, u.username
		FROM groupusers gu, groups g, users u
		WHERE gu.groupid = g.groupid AND
		gu.userid = u.userid
");

###############################################################################
# Create the sessions table.
###############################################################################
print "Creating sessions table.\n";
$dbh->do("CREATE TABLE sessions (
		id char(32) NOT NULL PRIMARY KEY,
		a_session TEXT
)");

};

###############################################################################
# Create the annotations table.
###############################################################################
print "Creating annotations table.\n";
$dbh->do("CREATE SEQUENCE annotations_annotationid_seq");
$dbh->do("CREATE TABLE annotations (
	annotationid	BIGINT CONSTRAINT pk_annotations NOT NULL PRIMARY KEY DEFAULT nextval('annotations_annotationid_seq'),
	systemid		BIGINT NOT NULL REFERENCES systems,
	sigil			VARCHAR(10) NOT NULL UNIQUE,
	comment			VARCHAR(255)
)");

###############################################################################
# Create the threshold_data view.
###############################################################################
print "Creating threshold_data view.\n";
$dbh->do("CREATE VIEW threshold_data
	AS
	SELECT t.thresholdid, t.hostid AS hostid, h.hostname AS hostname,
	t.resourceid AS resourceid, r.name as resource, t.severity, t.value,
	t.key
	FROM thresholds t, hosts h, resources r
	WHERE t.hostid = h.hostid AND t.resourceid = r.resourceid"
);

###############################################################################
# Create the mediums table.
###############################################################################
print "Creating mediums table.\n";
$dbh->do("CREATE SEQUENCE mediums_mediumid_seq");
$dbh->do("CREATE TABLE mediums (
	mediumid	BIGINT CONSTRAINT pk_mediums
		NOT NULL PRIMARY KEY DEFAULT nextval('mediums_medium_seq'),
	name		VARCHAR(20) UNIQUE NOT NULL,
	handler		VARCHAR(100) NOT NULL
)");

###############################################################################
# Drop notification_data view
###############################################################################
print "Dropping notification_data view.\n";
$dbh->do("DROP VIEW notification_data");

###############################################################################
# Modify contacts table to handle mediums.
###############################################################################
print "Modifying contacts table.\n";
$dbh->do("ALTER TABLE contacts ADD mediumid BIGINT REFERENCES mediums;");
$dbh->do("UPDATE contacts SET mediumid=1 WHERE type='email'");
$dbh->do("UPDATE contacts SET mediumid=2 WHERE type='pager'");
$dbh->do("ALTER TABLE contacts ALTER COLUMN mediumid SET NOT NULL");
$dbh->do("ALTER TABLE contacts DROP type");

###############################################################################
# Create contact_data view.
###############################################################################
print "Creating contact_data view.\n";
$dbh->do("CREATE VIEW contact_data
	AS
	SELECT c.contactid, c.userid as userid, u.username AS username,
	u.fullname AS fullname, c.value AS value, c.mediumid AS mediumid,
	m.name AS medium
	FROM contacts c, users u, mediums m
	WHERE c.userid = u.userid AND c.mediumid = m.mediumid"
);

###############################################################################
# Refactor notifications table.
###############################################################################
print "Refactoring notifications table, all your notifications will be removed.\n";
$dbh->do("DROP TABLE notifications");
$dbh->do("CREATE TABLE notifications (
	notificationid	BIGINT CONSTRAINT pk_notificationid
		NOT NULL PRIMARY KEY DEFAULT nextval('notif_notificationid_seq'),
	jobid			BIGINT NOT NULL REFERENCES jobs (jobid),
	groupid			BIGINT NOT NULL REFERENCES groups (groupid),
	systemid		BIGINT NOT NULL REFERENCES systems (systemid)
)");

if($@) {
	print $@."\n";
	print "\nAn error ocurred, no changes were made.\n";
	$dbh->rollback();
} else {
	print "\nNo errors detected, Loggerithim successfully upgraded.\n";
	$dbh->commit();
}
$dbh->disconnect();
