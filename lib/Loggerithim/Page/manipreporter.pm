package Loggerithim::Page::manipreporter;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r	    	= $stuff->{'request'};
	my $user    	= $stuff->{'user'};

	if($parameters->{'submitter'}) {
		unless(Loggerithim::Util::Permission->check($user, "Reporter", "write")) {
			return { NORIGHTS => 1 };
		}
		if($parameters->{'reporterid'}) {
			my $rep = Loggerithim::Reporter->retrieve($parameters->{'reporterid'});
			$rep->name($parameters->{'name'});
			$rep->description($parameters->{'description'});
			$rep->update();
		} else {
			Loggerithim::Reporter->create({
				name		=> $parameters->{'name'},
				description	=> $parameters->{'description'}
			});
		}
		return {REDIRECT => "admin.phtml"};
	} elsif($parameters->{'action'} eq "list") {
		unless(Loggerithim::Util::Permission->check($user, "Reporter", "read")) {
			return { NORIGHTS => 1 };
		}

		my @reporters;
		my $rIter = Loggerithim::Reporter->retrieve_all();
		while(my $rep = $rIter->next()) {
			push(@reporters, {
				id			=> $rep->id(),
				name		=> $rep->name(),
				description	=> $rep->description()
			});
		}
		return {
			title		=> "List Reporters",
			reporterlist=> 1,
			reporters	=> \@reporters,
		};
	} elsif($parameters->{'reporterid'}) {
		unless(Loggerithim::Util::Permission->check($user, "Reporter", "read")) {
			return { NORIGHTS => 1 };
		}
		my $r = Loggerithim::Reporter->retrieve($parameters->{'reporterid'});
		return {
			title		=> "Manipulate Reporter",
			reporterid	=> $r->id(),
			name		=> $r->name(),
			description	=> $r->description(),
		};
	}

	unless(Loggerithim::Util::Permission->check($user, "Reporter", "write")) {
		return { NORIGHTS => 1 };
	}
	return {
		title		=> "Manipulate Reporter",
	};
}

1;
