package Loggerithim::Database;
use strict;

=head1 NAME

Loggerithim::Database - Database Methods

=head1 DESCRIPTION

This module basically wraps the arguments for DBI's connect method, so
the programmer doesn't have to each time a DB connection is needed.  Creates
a 'native' Loggerithim Postgres connection by default, but can also be used
for Oracle connections.

=head1 SYNOPSIS

  my $db = Loggerithim::Database->new();
  my $dbh = $db->connect();
  # Do Something with $dbh... 
  $dbh->disconnect();

=cut

use DBI;

use Loggerithim::Config;

=head1 METHODS

=head2 Constructor

=over 4

=item Loggerithim::Database->new()

Creates and returns a new Loggerithim::Database object.  Defaults to the
PostgreSQL (Pg) driver, 'loggerithim' dbname, 'localhost' host, '5432'
port, and the database password from Loggerithim::Config.

=back

=cut
sub new {
	my $self = {};
	$self->{DRIVER} = "Pg";
	$self->{DBNAME}	= "loggerithim";
	$self->{HOST}	= Loggerithim::Config->fetch("database/host");
	$self->{PORT}	= Loggerithim::Config->fetch("database/port");
	$self->{USER}	= "loggerithim";
	$self->{PASS}	= Loggerithim::Config->fetch("database/password");
	bless($self);
	return $self;
}

=head2 Class Methods

=over 4

=item $db->connect()

Connects to the database and returns a DBI database handle.

=cut
sub connect {
	my $self = shift();

	my $dsn;
	if($self->driver() eq "Oracle") {
		$ENV{'ORACLE_HOME'} = "/home/oracle/OraHome1";
		$dsn = "dbi:$self->{DRIVER}:host=$self->{HOST};sid=$self->{SID};port=$self->{PORT}";
	} elsif($self->driver() eq "Pg") {
		$dsn = "dbi:$self->{DRIVER}:dbname=$self->{DBNAME}";
		if(defined($self->{HOST})) {
			$dsn .= ";host=".$self->{HOST}.";port=".$self->{PORT}.";";
		}
	}
	my $dbh = DBI->connect($dsn, $self->{USER}, $self->{PASS}, {
			RaiseError	=> 1,
			AutoCommit	=> 1,
	});
	return $dbh;
}

=item $db->driver()

=item $db->driver($driver)

Sets/Gets the driver value.  Currently can use Pg or Oracle.

=cut
sub driver {
	my $self = shift();
	if(@_) { $self->{DRIVER} = shift() }
	return $self->{DRIVER};
}

=item $db->host()

=item $db->host($host)

Sets/Gets the host value.

=cut
sub host {
	my $self = shift();
	if(@_) { $self->{HOST} = shift() }
	return $self->{HOST};
}

=item $db->port()

=item $db->port($port)

Sets/Gets the port value.

=cut
sub port {
	my $self = shift();
	if(@_) { $self->{PORT} = shift() }
	return $self->{PORT};
}

=item $db->user()

=item $db->user($user)

Sets/Gets the user value.

=cut
sub user {
	my $self = shift();
	if(@_) { $self->{USER} = shift() }
	return $self->{USER};
}

=item $db->pass()

=item $db->pass($pass)

Sets/Gets the pass value.

=cut
sub pass {
	my $self = shift();
	if(@_) { $self->{PASS} = shift() }
	return $self->{PASS};
}

=item $db->sid()

=item $db->sid($sid)

Sets/Gets the sid value (used for Oracle).

=cut
sub sid {
	my $self = shift();
	if(@_) { $self->{SID} = shift() }
	return $self->{SID};
}

=item $db->dbname()

=item $db->dbname($dbname)

Sets/Gets the name of the database to connect to (Pg).

=cut
sub dbname {
	my $self = shift();
	if(@_) { $self->{DBNAME} = shift() }
	return $self->{DBNAME};
}

=back

=head2 Static Methods

=over 4

NONE.

=back

=head1 AUTHOR

Cory 'G' Watson <gphat@loggerithim.org>

=head1 SEE ALSO

perl(1)

=cut
1;
