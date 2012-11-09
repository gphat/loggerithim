package Loggerithim::Page::shared;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r			= $stuff->{'request'};

	my $cache = Loggerithim::Cache->cache();

	if(defined($parameters->{'clear'})) {
		$cache->clear();
	}

	my @temp = $cache->get_keys();
	my @objects;
	foreach my $name (@temp) {
		push(@objects, {
			name	=> $name,
		});
	}

	return {
		title		=> "Administrative Actions",
		hitrate		=> Loggerithim::Cache->hitRate(),
		hits		=> $cache->get("Hits"),
		requests	=> $cache->get("Requests"),
		removes		=> $cache->get("Removes"),
		list		=> $parameters->{'list'},
		numkeys		=> $#temp,
		objects		=> \@objects,
	};
}

1;
