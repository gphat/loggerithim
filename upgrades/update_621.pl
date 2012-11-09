#!/usr/bin/perl

use lib "/usr/local/apache/lib/perl";

use Data::Dumper;

use Loggerithim::Database;

print "\nLoggerithim 6.2.1 DB Upgrade script\n\n";


my $db = Loggerithim::Database->new();
my $dbh = $db->connect();

eval {
###############################################################################
# Changes:
#
# Drop and recreate the smeeplets table to get rid of the 'thresholds' field
# Insert the new 'LastUpdated' Smeeplet

###############################################################################
# Get a list of all Smeeplets
###############################################################################
my $smeepsth = $dbh->prepare("SELECT smeepletid, name, description FROM smeeplets");
$smeepsth->execute();

my ($smeepid, $smeepname, $smeepdesc);
$smeepsth->bind_columns(\($smeepid, $smeepname, $smeepdesc));

my @smeeps;
while($smeepsth->fetch()) {
	push(@smeeps, {
		ID			=> $smeepid,
		Name		=> $smeepname,
		Description	=> $smeepdesc,
	});
}
$smeepsth->finish();

###############################################################################
# Drop the existing smeeplets table
###############################################################################
my $dropsmeepsth = $dbh->prepare("DROP TABLE smeeplets");
$dropsmeepsth->execute();
$dropsmeepsth->finish();

###############################################################################
# Create the new smeeplets table
###############################################################################
my $createtablesth = $dbh->prepare(
	"CREATE TABLE smeeplets (
		smeepletid	BIGINT CONSTRAINT pk_smeeplet
			NOT NULL PRIMARY KEY DEFAULT nextval('smeeplets_smeepletid_seq'),
		name		VARCHAR(50) NOT NULL,
		description	VARCHAR(255)
	)"
);
$createtablesth->execute();
$createtablesth->finish();

###############################################################################
# Reinsert the Smeeplets
###############################################################################
my $reinsertsmeeps = $dbh->prepare(
	"INSERT INTO smeeplets (smeepletid, name, description) VALUES (?, ?, ?)"
);
foreach my $smeep (@smeeps) {
	$reinsertsmeeps->execute($smeep->{'ID'}, $smeep->{'Name'}, $smeep->{'Description'});
}
$reinsertsmeeps->finish();

###############################################################################
# Insert the new Smeeplet
###############################################################################
my $addnewsmeep = $dbh->prepare(
	"INSERT INTO smeeplets (name, description) VALUES (?, ?)"
);
$addnewsmeep->execute("LastUpdated", "Find Hosts that may not be responding");
$addnewsmeep->finish();

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
