package Loggerithim::Access;
use strict;

=head1 NAME

Loggerithim::Access - Authorization Handler

=head1 DESCRIPTION

Controls access to Loggerithim by requiring a valid session cookie for any
page ending in .phtml besides index.phtml and error.phtml.  Uses
verify_ticket() from Loggerithim::Session to verify the session.

=cut
use Apache::Constants qw(OK FORBIDDEN);

use Loggerithim::Session;

=head1 METHODS

=head2 Constructor

=over 4

NONE.

=back

=head2 Class Methods

=over 4

=item handler

Verifies that the user has a session.  Allows non-sessioned clients
to the index and error pages.

=back

=cut
sub handler {
	my $r = shift();

	if($r->uri() =~ /^\/(index|error|)\./o) {
		return OK;
	}

	my $session = Loggerithim::Session->existingSession($r);
	unless(defined($session)) {
		return FORBIDDEN;
	}
	return OK;
}

=head2 Static Methods

=over 4

NONE.

=back

=head1 AUTHOR

Cory 'G' Watson <gphat@loggerithim.org>

=head1 SEE ALSO

perl(1), L<Loggerithim::Handler>, L<Loggerithim::Session>

=cut
1;
