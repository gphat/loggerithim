#!/usr/bin/perl

#==============================================================#
# Loggerithim Database Setup Script                            #
#  Credits to Sam Tregar and Bricolage, from which most of     #
#  script was originally derived.                              #
#==============================================================#

use strict;
use DBI;

# Global DB connection, comes from initialize(), then from the new db
my $dbh;
my @sql;

our ($host, $port, $dbuser, $dbpass);

# Get DB connect info
print "\nOn what host is your database running?: [localhost] ";
my $host = <STDIN>;
chomp($host);
if($host eq "") {
	$host = "localhost";
}

print "\nOn what port should I connect?: [5432] ";
my $port = <STDIN>;
chomp($port);
if($port eq "") {
	$port = "5432";
}

print "\nWhat username should I use to connect to your database?: [] ";
my $dbuser = <STDIN>;
chomp($dbuser);

print "\nWhat password should I use with that username?: [] ";
my $dbpass = <STDIN>;
chomp($dbpass);

initialize($host, $port, $dbuser, $dbpass);

print "\n---- Creating Loggerithim Database ----\n\n";
# Create the user
print "Creating user....\n";
print "\nEnter a password for the Loggerithim database: [] ";
my $dbpass = <STDIN>;
chomp($dbpass);
exec_sql("CREATE USER loggerithim WITH PASSWORD '$dbpass' CREATEDB CREATEUSER");

# Create the database
print "Creating database...\n";
exec_sql("CREATE DATABASE loggerithim");

$dbh->disconnect();

my $dsn;
if($host = "localhost") {
	$dsn = "dbi:Pg:dbname=loggerithim";
} else {
	$dsn = "dbi:Pg:dbname=loggerithim;host=$host;port=$port";
}
$dbh = DBI->connect($dsn, "loggerithim", $dbpass, {
	RaiseError	=> 1,
	AutoCommit	=> 1,
	PrintError	=> 0
});
print "\nReconnected as loggerithim...\n";

# Catch those damned warnings.
open STDERR, "| perl -ne 'print unless /^NOTICE:  /'" or die "Can't pipe STDERR: $!\n";

insert_file_set(@sql);

print "\n---- Creating Administrative User ----\n\n";

print "Enter a username for the Loggerithim Administrator: [admin] ";
my $user = <STDIN>;
chomp($user);
if($user eq "") {
	$user = "admin";
}
my $pass = "";
while($pass eq "") {
	print "Enter a password for '$user': [] ";
	$pass = <STDIN>;
	chomp($pass);
}
print "Enter the Administrator's full name: [Administrator] ";
my $fullname = <STDIN>;
chomp($fullname);
if($fullname eq "") {
	$fullname = "Administrator";
}

exec_sql("INSERT INTO users (username, password, fullname) VALUES ('$user', '$pass', '$fullname')");
exec_sql("INSERT INTO groupusers (groupid, userid) VALUES (1, 1)");

for(my $i = 1; $i <= 17; $i++) {
	exec_sql("INSERT INTO groupobjects (groupid, objectid, read, write, remove) VALUES (1, $i, 1, 1, 1)");
}

print "Administrator added.\n";

$dbh->disconnect();

print "Enter the smtp server Loggerithim should use to send mail: [localhost] ";
my $smtp = <STDIN>;
chomp($smtp);
if($smtp eq "") {
	$smtp = "localhost";
}

print "Enter the a string Loggerithim should use to encode cookies: [] ";
my $secret = <STDIN>;
chomp($secret);

open LOGGERCONF, ">/etc/loggerithim.xml";
print LOGGERCONF "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n";
print LOGGERCONF "<configuration>\n";
print LOGGERCONF " <database>\n";
print LOGGERCONF "  <host>$host</host>\n";
print LOGGERCONF "  <port>$port</port>\n";
print LOGGERCONF "  <password>$dbpass</password>\n";
print LOGGERCONF " </database>\n";
print LOGGERCONF " <smtp_server>$smtp</smtp_server>\n";
print LOGGERCONF " <secret>$secret</secret>\n";
print LOGGERCONF " <caching>\n";
print LOGGERCONF "  <object>0</object>\n";
print LOGGERCONF "  <template>0</template>\n";
print LOGGERCONF " </caching>\n";
print LOGGERCONF " <prefix>/usr/local</prefix>\n";
print LOGGERCONF " <serverport>4442</serverport>\n";
print LOGGERCONF "</configuration>\n";
close LOGGERCONF;

print "/etc/loggerithim.xml written.\n";

print "\nThis is the end of the automated part of Loggerithim's install.  Please consult\n";
print "the documentation for further instructions.\n";

exit;

sub initialize {
	my $h = shift();
	my $po = shift();
	my $u = shift();
	my $p = shift();
	# Setup the DSN, use the template1 db, since we know it will
	# exist.
	my $dsn = "dbi:Pg:dbname=template1;host=$h;port=$po";

	# Connect.
	$dbh = DBI->connect($dsn, $u, $p, {
		RaiseError	=> 1,
		AutoCommit	=> 1,
		PrintError	=> 0,
	});

	# Yeah, this is kinda ugly, but these tables must be added
	# in a particular order to maintain integrity!
	@sql = qw(
		resgroups_table.sql
		resources_table.sql
		departments_table.sql
		systems_table.sql
		hosts_table.sql
		annotations_table.sql
		metrics_table.sql
		cached_metrics_table.sql
		custom_metrics_table.sql
		attributes_table.sql
		smeeplets_table.sql
		jobs_table.sql
		users_table.sql
		groups_table.sql
		objects_table.sql
		groupusers_table.sql
		groupobjects_table.sql
		thresholds_table.sql
		reporters_table.sql
		reports_table.sql
		events_table.sql
		childevents_table.sql
		archivedevents_table.sql
		mediums_table.sql
		contacts_table.sql
		notifications_table.sql
		hostattrs_table.sql
		profiles_table.sql
		profattrs_table.sql
		sessions_table.sql
		logs_table.sql
		saves_table.sql
	);
}

sub insert_file_set {
	foreach my $file (@_) {
		chomp($file);
		print "\tImporting '$file'\n";
		exec_sql($_, "../sql/$file") for grab_statements($file);
	}
}

sub grab_statements {
	my ($file) = @_;
	my @stmt;
	my $sql = '';
	my $comment;

	open(SQL, "sql/$file") or die "Can't open '$file': $!\n";
	while(my $line = <SQL>) {
		# Skip single line comments.
		next if $line =~ /^--/;
		# Skip blank lines
		next if $line =~ /^\s*$/;

		# Check for a start comment block
		if($line =~ m|/\*|) {
			$comment = 1;
			next;
		}

		# Check for an end comment block
		if($line =~ m|\*/|) {
			$comment = 0;
			next;
		}

		next if $comment;
		# If we are at the end of a statement, push it onto the stack
		if($line =~ s/;\s*$//) {
			$sql .= $line;
			push(@stmt, $sql);
			$sql = '';
		} else {
			$sql .= $line;
		}
	}
	close(SQL);

	return @stmt;
}

sub exec_sql {
	my ($sql, $file) = @_;
	$file = $file ? "\n$file" : '';
	eval { $dbh->do($sql) };
	if ($@) {
		die"\nProblems executing sql: $@\n";
	}
}
