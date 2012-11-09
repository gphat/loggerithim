package Loggerithim::Page::childevents;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r	    	= $stuff->{'request'};

	my $event = Loggerithim::Event->retrieve($parameters->{'eventid'});

	my @events;
	my $cIter = $event->children();
	while(my $child = $cIter->next()) {
		push(@events, {
			severity	=> $child->severity(),
			text		=> $child->text(),
			timestamp	=> $child->timestamp()->strftime("%A %B %d, %Y")
		});
	}

	return {
		NOCACHE		=> 1,
		title		=> "Child Events",
		events		=> \@events,
	};
}

1;
