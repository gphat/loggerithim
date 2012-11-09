package Loggerithim::Processors;
use strict;

=head1 NAME

Loggerithim::Processes - Process Metrics

=head1 DESCRIPTION

A Processor takes raw data from monitors and makes them into data suitable
for a metric entry.

Each of these methods takes in a cached and fresh value and time.  It then
splits the data up by it's key (key being the generic term applied to
any metric that has multiple targets, like eth0, or hda1), then by commas.

The method then subtracts the cached value from the fresh one, yielding
a result that shows how much of something has happened since the last
query.

=cut
use DateTime;
use DateTime::Format::Pg;

use Loggerithim::Date;

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

=item Loggerithim::Processors->processRawinterfaces($cacheline, $cachetime, $freshline, $freshtime)

Takes the cached value and the fresh value from the monitor, then returns a 
line suitable for Metric entry.

=cut
sub processRawinterfaces {
	my $self = shift();
	my $cacheline = shift();
	my $cachetime = shift();
	my $freshline = shift();
	my $freshtime = shift();

	my $diffinsecs = $freshtime->epoch() - $cachetime->epoch();

	my %cstorage;
	my %fstorage;

	my @cachelist = split(/\:/, $cacheline);
	my @freshlist = split(/\:/, $freshline);

	foreach my $cline (@cachelist) {
		my @c = split(/,/, $cline);
		$cstorage{$c[0]} = {
			ifInKBytes	=> $c[1],
			ifOutKBytes	=> $c[2],
		};
	}
	foreach my $fline (@freshlist) {
		my @f = split(/,/, $fline);
		$fstorage{$f[0]} = {
			ifInKBytes	=> $f[1],
			ifOutKBytes	=> $f[2],
		};
	}

	my %result;

	foreach my $diff (keys %cstorage) {
		my $c = $cstorage{$diff};
		if(my $f = $fstorage{$diff}) {
			$result{$diff} = {
				ifInKBytes	=> abs(sprintf("%.2f", ($f->{ifInKBytes} - $c->{ifInKBytes}) / $diffinsecs)),
				ifOutKBytes	=> abs(sprintf("%.2f", ($f->{ifOutKBytes} - $c->{ifOutKBytes}) / $diffinsecs)),
			};
		}
	}

	my $line;
	foreach my $interface (keys %result) {
		my $r = $result{$interface};
		if($r->{'ifInKBytes'} < 0) {
			$r->{'ifInKBytes'} = 0;
		}
		if($r->{'ifOutKBytes'} < 0) {
			$r->{'ifOutKBytes'} = 0;
		}
		$line .= $interface.",".$r->{ifInKBytes}.",".$r->{ifOutKBytes}.":";
	}
	return $line;
}

=item Loggerithim::Processors->processRawcpu($cacheline, $cachetime, $freshline, $freshtime)

Takes the cached value and the fresh value from the monitor, then
returns a line suitable for Metric entry.

=cut
sub processRawcpu {
	my $self = shift();
	my $cacheline = shift();
	my $cachetime = shift();
	my $freshline = shift();
	my $freshtime = shift();

	my @c = split(/,/, $cacheline);
	my @f = split(/,/, $freshline);

	my $user	= $f[0] - $c[0];
	my $sys		= $f[1] - $c[1];
	my $idle	= $f[2] - $c[2];

	my $total	= $user + $sys + $idle;
	my $cpuUser	= sprintf("%.2f", (($user / $total) * 100));
	my $cpuSys	= sprintf("%.2f", (($sys / $total) * 100));
	my $cpuIdle	= sprintf("%.2f", (($idle / $total) * 100));

	return "$cpuUser,$cpuSys,$cpuIdle";
}

=item Loggerithim::Processors->processRawmisc($cacheline, $cachetime, $freshline, $freshtime)

Takes the cached value and the fresh value from the monitor, then returns a
line suitable for Metric entry.

=cut
sub processRawmisc {
	my $self	= shift();
	my $cacheline	= shift();
	my $cachetime	= shift();
	my $freshline	= shift();
	my $freshtime	= shift();

	my @c = split(/,/, $cacheline);
	my @f = split(/,/, $freshline);

	my $miscPagesIn		= $f[0] - $c[0];
	my $miscPagesOut	= $f[1] - $c[1];
	my $miscSwapIn		= $f[2] - $c[2];
	my $miscSwapOut		= $f[3] - $c[3];

	return "$miscPagesIn,$miscPagesOut,$miscSwapIn,$miscSwapOut";
}
=back

=head1 AUTHOR

Cory 'G' Watson <gphat@loggerithim.org>

=head1 SEE ALSO

perl(1)

=cut
1;
