package Loggerithim::Sensor;
use strict;

=head1 NAME

Loggerithim::Sensor - Senses 'color' of data.

=head1 DESCRIPTION

Loggerithim's main page shows a number of important links.  To aid the
user in the detection of possible problems, the links are colored according
to resource availability.  This class determines what CSS class to use for
anchor tag, and returns it.

=head1 SYNOPSIS

  my $class = Loggerithim::Sensor->sense($host);

=cut
use Loggerithim::Cache;
use Loggerithim::Config;
use Loggerithim::Database;
use Loggerithim::Log;
use Loggerithim::Parsers;
use Loggerithim::ResourceGroup;

=head1 METHODS

=head2 Constructor

=over 4

NONE.

=back

=cut

sub _senseCPU {
	my $cpu = shift();

	# Pick the appropriate class for the utilization
	my $class = "normal";
	if(($cpu->{'cpuUser'} > 60) or ($cpu->{'cpuSys'} > 50)) {
		$class = "warn";
	}
	if(($cpu->{'cpuUser'} > 80) or ($cpu->{'cpuSys'} > 80)) {
		$class = "danger";
	}
	return $class;
}

sub _senseMemory {
	my $memory = shift();
	my $static = shift();

	# Fetch the static memory information, so we now the percentages.
	my ($mempercentage, $swappercentage);
	if($static->{'memTotalReal'}) {
		$mempercentage = sprintf("%02d", ((($memory->{'memAvailReal'} + $memory->{'memCached'})/ $static->{'memTotalReal'}) * 100));
	}
	if($static->{'memTotalSwap'}) {
		$swappercentage = sprintf("%02d", (($memory->{'memAvailSwap'} / $static->{'memTotalSwap'}) * 100));
	}

	my $memclass="normal";
	my $swapclass="normal";

	if($mempercentage < 20) {
		$memclass = "warn";
	}
	if($mempercentage < 10) {
		$memclass = "danger";
	}
	if($swappercentage < 20) {
		$swapclass = "warn";
	}
	if($swappercentage < 10) {
		$swapclass = "danger";
	}
	return ($memclass, $swapclass);
}

=head2 Static Methods

=over 4

=item Loggerithim::Sensor->sense($host)

Given a Host, returns the CSS classes denoting their states.  Try
displaying the results with Data::Dumper to get an idea of the structure.
=cut
sub sense {
	my $self    = shift();
	my $host	= shift();

	if(Loggerithim::Config->fetch("caching/object")) {
		my $cacheobj = Loggerithim::Cache->fetch("Sense", $host->id());
		if(defined($cacheobj)) {
            loglog("DEBUG", "Fetched Sense data for Host ".$host->id()." from cache.");
			return $cacheobj;
		}
	}

	# Get the type ids
	my $cpurg	= Loggerithim::ResourceGroup->search(name => "cpu")->next();
	my $memrg	= Loggerithim::ResourceGroup->search(name => "memory")->next();
	my $staticrg= Loggerithim::ResourceGroup->search(name => "static")->next();

	my %results;
	
	my $db = Loggerithim::Database->new();
	my $dbh = $db->connect();
	
	# Get the information
	my $cmIter = $host->cachedMetrics();
	while(my $cm = $cmIter->next()) {
		if($cm->resgroup()->id() == $cpurg->id()) {
			$results{'cpu'} = Loggerithim::Parsers->genParse($cpurg, $cm->data());
		}
		if($cm->resgroup()->id() == $memrg->id()) {
			$results{'memory'} = Loggerithim::Parsers->genParse($memrg, $cm->data);
		}
		if($cm->resgroup()->id() == $staticrg->id()) {
			$results{'static'} = Loggerithim::Parsers->genParse($staticrg, $cm->data);
		}
	}

	$dbh->disconnect();

	my $classes;

	$classes->{'CPU'} = _senseCPU($results{'cpu'});
	($classes->{'Memory'}, $classes->{'Swap'}) = _senseMemory($results{'memory'}, $results{'static'});

	if(defined(Loggerithim::Config->fetch("caching/object"))) {
        loglog("DEBUG", "Generated and cached sense data for Host $host->id()");
		Loggerithim::Cache->store("Sense", $host->id(), $classes);
	}

	return $classes;
}
=back

=head1 AUTHOR

Cory 'G' Watson <gphat@loggerithim.org>

=head1 SEE ALSO

perl(1)

=cut
1;
