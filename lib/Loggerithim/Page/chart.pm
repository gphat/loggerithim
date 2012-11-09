package Loggerithim::Page::chart;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r			= $stuff->{'request'};
	my $user		= $stuff->{'user'};

	my @elements;
	my $hours;

	if(!($parameters->{'elems'})) {
		return { ERROR =>  "I need elements to graph." };
	}

	$hours = $parameters->{'hours'};
	my $mult = $parameters->{'mult'};
	if($mult < 1) {
		$mult = 1;
	}

	my $totalHours = $hours * $mult;

	my @elems = split(/,/, $parameters->{'elems'});

	my $cache;
    my $count = 0;

	my %seenAnnots;
	foreach my $e (@elems) {
		my ($hostid, $type, $key, $axis, $start, $end) = split(/:/, $e);

		my $host = Loggerithim::Host->retrieve($hostid);
		my $res = Loggerithim::Resource->search(name => $type)->next();

		my $ge = Loggerithim::Element->new();
		$ge->host($host);
		$ge->resource($res);
		$ge->key($key);

		if($axis) {
			$ge->axis($axis);
		}

		if((defined($start) and defined($end)) and ($start ne " ")) {
			my @spieces = split(/ /, $start);
			my @epieces = split(/ /, $end);

			$spieces[1] =~ tr/-/\:/;
			$epieces[1] =~ tr/-/\:/;
			
			$ge->starttime(DateTime::Format::Pg->parse_timestamptz($spieces[0]." ".$spieces[1]));
			$ge->endtime(Date::Format::Pg->parse_timestamptz($epieces[0]." ".$epieces[1]));
		} else {
			my $span = DateTime::Duration->new(hours => $totalHours);
			$ge->span($span);
		}
		$cache = $ge->prepare($cache);
		my $stats = $ge->stats();
		if($count < $stats->{'Count'}) {
			$count = $stats->{'Count'};
		}

		unless(exists($seenAnnots{$host->department->id()."-".$host->system()->id()})) {
			$seenAnnots{$host->department()->id()."-".$host->system()->id()} = 1;
			my @annots = $host->system()->annotationsBetween($ge->starttime(), $ge->endtime());
			$ge->annotations(\@annots);
		}
	
		push(@elements, $ge);
	}
	my $chart = Loggerithim::Chart->new();

	if($parameters->{'max'} ne "") {
		$chart->max($parameters->{'max'});
	}
	if($parameters->{'legend'} ne "") {
		$chart->legend($parameters->{'legend'});
	}
	if($parameters->{'xlabels'} ne "") {
		$chart->xlabels($parameters->{'xlabels'});
	}
	if($parameters->{'width'} ne "") {
		$chart->width($parameters->{'width'});
	} else {
		$chart->width(800 + int($totalHours / 2));
	}
	if($parameters->{'height'} ne "") {
		$chart->height($parameters->{'height'});
	} else {
		$chart->height(500);
	}

	$chart->elements(\@elements);

	my $dedwidth = int($chart->width() / 45);
	my $skip = int($count / $dedwidth);
    $chart->skip($skip);
	if($parameters->{'charttype'}) {
		$chart->chartType($parameters->{'charttype'});
	} else {
		$chart->chartType("line");
	}

	my $png = $chart->graph($r);
	unless(defined($png)) {
		return { ERROR => "Error drawing chart." };
	}

	my @yewnits = Loggerithim::Lists->units($mult);

	return {
        NOCACHE => 1,
        IMAGE   => $png
	};
}

1;
