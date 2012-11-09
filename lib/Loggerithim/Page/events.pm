package Loggerithim::Page::events;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r		    = $stuff->{'request'};
	my $user	    = $stuff->{'user'};

	unless(Loggerithim::Util::Permission->check($user, "Event", "read")) {
		return { NORIGHTS => 1 };
	}

	my @events;

	my $eIter = Loggerithim::Event->retrieve_all();
	while(my $event = $eIter->next()) {
		push(@events, {
			eventid		=> $event->id(),
			severity	=> $event->relativeSeverity(),
			identifier	=> $event->identifier(),
			message		=> $event->message(),
			timestamp	=> $event->timestamp()->strftime("%A %B %d, %Y"),
			squelched	=> $event->squelched()
		});
	}

	return {
		NOCACHE		=> 1,
		title		=> "Events",
		events		=> \@events,
	};
}

1;
