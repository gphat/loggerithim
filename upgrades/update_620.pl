#!/usr/bin/perl

use lib "/usr/local/apache/lib/perl";

use Data::Dumper;

use Loggerithim::Database;

print "\nLoggerithim 6.2.0 DB Upgrade script\n\n";


my $db = Loggerithim::Database->new();
my $dbh = $db->connect();

eval {
###############################################################################
# Changes:
#
# Drop a recreate hostattrs to set proper ON UPDATE behavior
# Add sigil column to Attributes
# Set sigil to same value as name for existing Attributes
# Make name column UNIQUE in Attributes
# Add new Attributes

###############################################################################
# Store the list of Host Attributes
###############################################################################
my $hostattrsth = $dbh->prepare("SELECT hostid, attributeid FROM hostattrs");
$hostattrsth->execute();

my ($hahostid, $haattrid);
$hostattrsth->bind_columns(\($hahostid, $haattrid));

my @hattrs;
while($hostattrsth->fetch()) {
	push(@hattrs, {
		HostID		=> $hahostid,
		AttributeID	=> $haattrid,
	});
}
$hostattrsth->finish();

###############################################################################
# Drop the existing Host Attributes view
###############################################################################
my $drophaviewsth = $dbh->prepare("DROP VIEW hostattr_data");
$drophaviewsth->execute();
$drophaviewsth->finish();

###############################################################################
# Drop the existing Host Attributes table
###############################################################################
my $drophattrsth = $dbh->prepare("DROP TABLE hostattrs");
$drophattrsth->execute();
$drophattrsth->finish();


###############################################################################
# Create the new Host Attributes table, with proper ON UPDATE actions
###############################################################################
my $createtablesth = $dbh->prepare(
	"CREATE TABLE hostattrs (
		hostattrid BIGINT CONSTRAINT pk_hostattrs
			NOT NULL PRIMARY KEY DEFAULT nextval('hostattr_hostattrid_seq'),
		hostid		BIGINT NOT NULL REFERENCES hosts (hostid) ON UPDATE CASCADE,
		attributeid	BIGINT NOT NULL REFERENCES attributes (attributeid) ON UPDATE CASCADE
	)"
);
$createtablesth->execute();
$createtablesth->finish();

###############################################################################
# Recreate the Host Attributes view.
###############################################################################
my $createhaviewsth = $dbh->prepare(
	"CREATE VIEW hostattr_data
		AS
		SELECT ha.hostattrid, h.hostid, h.hostname,
			a.attributeid, a.name
		FROM hostattrs ha, hosts h, attributes a
		WHERE ha.hostid = h.hostid AND
			ha.attributeid = a.attributeid"
);
$createhaviewsth->execute();
$createhaviewsth->finish();

###############################################################################
# Reinsert the Host Attributes
###############################################################################
my $reinserthattr = $dbh->prepare(
	"INSERT INTO hostattrs (hostid, attributeid) VALUES (?, ?)"
);
foreach my $hattr (@hattrs) {
	$reinserthattr->execute($hattr->{'HostID'}, $hattr->{'AttributeID'});
}
$reinserthattr->finish();

###############################################################################
# Add the sigil column to the Attributes table.
###############################################################################
my $addsigilsth = $dbh->prepare(
	"ALTER TABLE attributes ADD sigil VARCHAR(50)"
);
$addsigilsth->execute();
$addsigilsth->finish();

###############################################################################
# Set the new sigil column to the value of the current Attribute name.
###############################################################################
my $listattrsth = $dbh->prepare("SELECT attributeid, name FROM attributes");
$listattrsth->execute();

$listattrsth->bind_columns(\($attrid, $attrname));

$setsigilsth = $dbh->prepare("UPDATE attributes SET sigil=? WHERE attributeid=?");
while($listattrsth->fetch()) {
	$setsigilsth->execute($attrname, $attrid);
}
$setsigilsth->finish();
$listattrsth->finish();

###############################################################################
# Create a UNIQUE constraint for the name column
###############################################################################
my $nameconststh = $dbh->prepare("ALTER TABLE attributes ADD CONSTRAINT attribute_name UNIQUE(name)");
$nameconststh->execute();
$nameconststh->finish();

###############################################################################
# Add the new Attributes
###############################################################################
my $addattsth = $dbh->prepare(
	"INSERT INTO attributes (name, sigil, types, hours, macros, url)
	 VALUES (?, ?, ?, ?, ?, ?)"
);

@newattrs = (
	{
		Name	=> "CPU",
		Sigil	=> "CPU",
		Types	=> "cpuIdle,cpuUser,cpuSys",
		Hours	=> 24,
		Macros	=> "",
		URL		=> ""
	},{
		Name	=> "Linux Memory",
		Sigil	=> "Memory",
		Types	=> "memAvailReal,memBuffered,memCached",
		Hours	=> 24,
		Macros	=> "",
		URL		=> ""
	},{
		Name	=> "Solaris Memory",
		Sigil	=> "Memory",
		Types	=> "memAvailReal",
		Hours	=> 24,
		Macros	=> "",
		URL		=> ""
	},{
		Name	=> "Load Averages",
		Sigil	=> "Load",
		Types	=> "loaLoad1,loaLoad2,loaLoad3",
		Hours	=> 4,
		Macros	=> "",
		URL		=> ""
});

foreach my $attr (@newattrs) {
	$addattsth->execute($attr->{'Name'}, $attr->{'Sigil'}, $attr->{'Types'},
		$attr->{'Hours'}, $attr->{'Macros'}, $attr->{'URL'});
}

$addattsth->finish();
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
