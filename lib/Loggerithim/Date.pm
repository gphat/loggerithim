package Loggerithim::Date;
use strict;

=head1 NAME

Loggerithim::Date - Date Convenience

=head1 DESCRIPTION

Loggerithim's date convenience module.

=head1 SYNOPSIS

 my $date = Loggerithim::Date->new();

=cut

use base('DateTime');

use DateTime::TimeZone;

my $tz = DateTime::TimeZone->new(name => 'local');

=head1 METHODS

=head2 Constructor

=over 4

=item Loggerithim::Date->new()

Creates a new Loggerithim::Date object.

=back

=cut
sub new {
	my $proto = shift();
	my $class = ref($proto) || $proto;
	my @args = @_;
	my $self = {};

	my $d;
	if(defined($args[0])) {
		$d = DateTime->new(@args);
	} else {
		$d = DateTime->now();
	}
	$d->set_time_zone($tz);

	return $d;
}

=item Loggerithim::Date->fromEpoch(epoch => $epoch)

Creates a new Loggerithim::Date object from epoch.

=back

=cut
sub fromEpoch {
	my $proto	= shift();
	my $arg		= shift(); 

	my $class = ref($proto) || $proto;
	my $self = {};

	my $d = DateTime->from_epoch(epoch => $arg);
	$d->set_time_zone($tz);

	return $d;
}

=head2 Class Methods

=over 4

NONE.

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
