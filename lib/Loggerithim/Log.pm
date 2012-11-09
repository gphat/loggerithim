package Loggerithim::Log;
use strict;

=head1 NAME

Loggerithim::Log - Loggerithim Logging

=head1 DESCRIPTIOON

Handles logging.  Interested modules should 'use' Loggerithim::Log and make use of the
exported 'loglog' method.

be sent to /var/log/loggerithim.log.

=head1 SYSNOPSIS

  use Loggerithim::Log;

  loglog("ERR", "I did something bad!");

=cut
use Exporter;

use Sys::Syslog;

use Loggerithim::Config;
use Loggerithim::Date;

@Loggerithim::Log::ISA = qw(Exporter);
@Loggerithim::Log::EXPORT = qw(loglog);

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

=item Loggerithim::Log->loglog($severity, $message)

Writes the supplied message to the logfile.

=cut
sub loglog {
	my $sev		= shift();
    my $message = shift();

	unless($message) {
		return;
	}

	my @cal = caller();

	if((Loggerithim::Config->fetch("debug")) or ($sev eq "ERR")) {
		openlog("loggerithim", "pid,ndelay,cons", "daemon");
		syslog($sev, "$cal[1]:$cal[2] - $message");
		closelog();
	}
}

=back

=head1 AUTHOR

Cory 'G' Watson <gphat@loggerithim.org>

=head1 SEE ALSO

perl(1)

=cut
1;
