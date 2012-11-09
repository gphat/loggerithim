package Loggerithim::Page::manipsystem;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r	    	= $stuff->{'request'};
	my $user    	= $stuff->{'user'};

	if($parameters->{'submitter'}) {
		unless(Loggerithim::Util::Permission->check($user, "System", "write")) {
			return { NORIGHTS => 1 };
		}
		if($parameters->{'systemid'}) {
			my $sys = Loggerithim::System->retrieve($parameters->{'systemid'});
			$sys->name($parameters->{'name'});
			$sys->update();
		} else {
			Loggerithim::System->create({
				name	=> $parameters->{'name'}
			});
		}
		return {REDIRECT => "admin.phtml"};
	} elsif($parameters->{'action'} eq "list") {
		unless(Loggerithim::Util::Permission->check($user, "System", "read")) {
			return { NORIGHTS => 1 };
		}

		my @systems;
		my $sysIter = Loggerithim::System->retrieve_all();
		while(my $sys = $sysIter->next()) {
			push(@systems, {
				id		=> $sys->id(),
				name	=> $sys->name()
			});
		}
		return {
			title		=> 'List Systems',
			systemlist	=> 1,
			systems		=> \@systems,
		};

	} elsif($parameters->{'systemid'}) {
		unless(Loggerithim::Util::Permission->check($user, "System", "read")) {
			return { NORIGHTS => 1 };
		}
		my $sys = Loggerithim::System->retrieve($parameters->{'systemid'});

		return {
			title		=> "Manipulate System",
			systemid	=> $parameters->{'systemid'},
			name		=> $sys->name(),
		};
	}

	unless(Loggerithim::Util::Permission->check($user, "System", "write")) {
		return { NORIGHTS => 1 };
	}
	return {
		title		=> "Manipulate System",
	};
}

1;
