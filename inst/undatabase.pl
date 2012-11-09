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

print "\n---- Dropping Loggerithim Database ----\n\n";
exec_sql("DROP DATABASE loggerithim");
print "\n---- Dropping User ----\n";
exec_sql("DROP USER loggerithim");

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
}

sub exec_sql {
	my ($sql, $file) = @_;
	$file = $file ? "\n$file" : '';
	eval { $dbh->do($sql) };
	if ($@) {
		die"\nProblems executing sql: $@\n";
	}
}
