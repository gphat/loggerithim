#!/usr/bin/perl

use lib "../lib";

use Loggerithim::Database;
use Loggerithim::Resource;
use Loggerithim::ResourceGroup;

print "\nLoggerithim 6.4.2 DB Upgrade script\n\n";

open STDERR, "| perl -ne 'print unless /^NOTICE:  /'";

my $db = Loggerithim::Database->new();
my $dbh = $db->connect();

eval {
###############################################################################
# Changes:
#
# Create the saves table
# Drop the UNIQUE constraint on annotations.sigil
# Create the logs table
# Add SysOSVer Resource
# Add None Attribute

###############################################################################
# Create the saves table.
###############################################################################
print "Creating saves table.\n";
$dbh->do("CREATE SEQUENCE saves_saveid_seq");
$dbh->do("CREATE TABLE saves (
		saveid		BIGINT CONSTRAINT pk_saveid NOT NULL PRIMARY KEY DEFAULT nextval('saves_saveid_seq'),
		userid		BIGINT NOT NULL REFERENCES users,
		page		VARCHAR(50) NOT NULL,
		params		TEXT NOT NULL,
		name		VARCHAR(50) NOT NULL
)");

###############################################################################
# Drop UNIQUE constraint on annotations' sigil field.
###############################################################################
print "Dropping UNIQUE constraint on annotations' sigil field.\n";
$dbh->do("ALTER TABLE annotations DROP CONSTRAINT annotations_sigil_key");

###############################################################################
# Create logs table.
###############################################################################
print "Creating logs table.\n";
$dbh->do("CREATE SEQUENCE logs_logid_seq");
$dbh->do("CREATE TABLE logs (
	logid		BIGINT CONSTRAINT pk_logs
		NOT NULL PRIMARY KEY DEFAULT nextval('logs_logid_seq'),
	timestamp	TIMESTAMP NOT NULL,
	package		VARCHAR(255),
	line		VARCHAR(10),
	message		TEXT NOT NULL
)");

###############################################################################
# Add SysOSVer Resource.
###############################################################################
print "Adding SysOSVer Resource.\n";
my $rg = Loggerithim::ResourceGroup->getIDByName("static");
my $res = Loggerithim::Resource->new();
$res->name("SysOSVer");
$res->index(4);
$res->resgroupid($rg->id());
$res->commit();

###############################################################################
# Add None Attribute.
###############################################################################
print "Adding None Attribute.\n";
my $attr = Loggerithim::Attribute->new();
$attr->name("None");
$attr->commit();
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
