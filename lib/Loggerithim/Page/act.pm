package Loggerithim::Page::act;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r		    = $stuff->{'request'};
	my $user	    = $stuff->{'user'};

	if($parameters->{'events'}) {
		my @events = split(/,/, $parameters->{'events'});
		foreach my $eid (@events) {
			my $event = Loggerithim::Event->retrieve($eid);
			unless(Loggerithim::Util::Permission->check($user, "Event", "write", $event->host()->department(), $event->host()->system())) {
				return { NORIGHTS => 1 };
			}
			if($parameters->{'action'} eq "squelch") {
				$event->squelched(1);
			} elsif($parameters->{'action'} eq "unsquelch") {
				$event->squelched(0);
			}
			$event->update();
		}
	}

	return {
		REDIRECT => "events.phtml",
	};
}

1;
