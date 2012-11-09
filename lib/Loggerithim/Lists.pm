package Loggerithim::Lists;
use strict;

=head1 NAME

Loggerithim::Lists - List Convenience

=head1 DESCRIPTION

Lists generates lists suitable for page listings.

=head1 SYNOPSIS

=cut

use Loggerithim::Database;

=head1 METHODS

=head2 Constructor

=over 4

NONE.

=back

=head2 Class Methods

=over 4

NONE.

=back

=head2 Static Methods

=over 4

=item Loggerithim::Lists->units()

=item Loggerithim::Lists->units($unit)

Returns an array of hash references.  If a unit is provided, that unit will be
the 0th element of the array.

=cut
sub units {
	my $self	= shift();
	my $default = shift();
	
	my @valids = (
		{
			name	=> "Hours",
			number	=> 1,
		},
		{
			name	=> "Days",
			number	=> 24,
		},
		{
			name	=> "Weeks",
			number	=> 168,
		},
		{
			name	=> "Months",
			number	=> 672
		}
	);

	my @units;
	foreach my $unit (@valids) {
		my $selected = undef;
		if($unit->{'number'} eq $default) {
			$selected = 1;
		}
		push(@units, {
			selected=> $selected,
			name	=> $unit->{'name'},
			number	=> $unit->{'number'}
		});
	}

	return @units;
}

=back

=head1 AUTHOR

Cory 'G' Watson <gphat@loggerithim.org>

=head1 SEE ALSO

perl(1)

=cut
1;
