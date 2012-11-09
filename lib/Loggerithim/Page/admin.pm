package Loggerithim::Page::admin;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r		    = $stuff->{'request'};

	return {
		title		    => "Administrative Actions",
	};
}

1;
