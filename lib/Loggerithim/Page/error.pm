package Loggerithim::Page::error;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $r = $stuff->{'request'};
	my $e = $stuff->{'ERROR'};

	$r->log_error("AOOOGA AOOOGA : $e");

	return {
		title	=> "Loggerithim Boo Boo",
		e	    => $e,
	}
}	

1;
