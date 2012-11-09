package Loggerithim::Page::reports;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r			= $stuff->{'request'};
	my $user		= $stuff->{'user'};

	my @reports;
	my $rIter = Loggerithim::Report->retrieve_all();
	while(my $rep = $rIter->next()) {
		push(@reports, {
			reportid	=> $rep->id(),
			attribute	=> $rep->attribute()->name(),
			name		=> $rep->name(),
			output		=> $rep->output(),
		});
	}

	return {
		NOCACHE		=> 1,
		title		=> "Reports",
		reports		=> \@reports,
	};
}


1;
