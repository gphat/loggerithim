package Loggerithim::Page::manipprofile;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r			= $stuff->{'request'};
	my $user		= $stuff->{'user'};

	if($parameters->{'submitter'}) {
		unless(Loggerithim::Util::Permission->check($user, "Profile", "write")) {
			return { NORIGHTS	=> 1 }
		}
		if($parameters->{'profileid'}) {
			my $prof = Loggerithim::Profile->retrieve($parameters->{'profileid'});
			$prof->name($parameters->{'name'});
			$prof->update();
		} else {
			Loggerithim::Profile->create({
				name	=> $parameters->{'name'}
			});
		}
		return {REDIRECT => "admin.phtml"};
	} elsif($parameters->{'action'} eq "list") {
		unless(Loggerithim::Util::Permission->check($user, "Profile", "read")) {
			return { NORIGHTS	=> 1 }
		}
		my @profiles;
		my $pIter = Loggerithim::Profile->retrieve_all();
		while(my $prof = $pIter->next()) {
			push(@profiles, {
				id	=> $prof->id(),
				name=> $prof->name()
			});
		}
		return {
			title		=> 'List Profiles',
			profilelist	=> 1,
			profiles	=> \@profiles,
		};
	
	} elsif($parameters->{'profileid'}) {
		unless(Loggerithim::Util::Permission->check($user, "Profile", "read")) {
			return { NORIGHTS	=> 1 }
		}
		my $prof = Loggerithim::Profile->retrieve($parameters->{'profileid'});

		return {
			title		=> "Manipulate Profile",
			profileid	=> $parameters->{'profileid'},
			name		=> $prof->name(),
		};
	}

	unless(Loggerithim::Util::Permission->check($user, "Profile", "write")) {
		return { NORIGHTS	=> 1 }
	}
	return {
		title		=> "Manipulate Profile",
	};
}

1;
