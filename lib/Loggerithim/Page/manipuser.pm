package Loggerithim::Page::manipuser;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r			= $stuff->{'request'};
	my $user		= $stuff->{'user'};

	if($parameters->{'submitter'}) {
		unless(Loggerithim::Util::Permission->check($user, "User", "write")) {
			return { NORIGHTS => 1 }
		}

		if($parameters->{'userid'}) {
			my $user = Loggerithim::User->retrieve($parameters->{'userid'});
			$user->username($parameters->{'username'});
			$user->password($parameters->{'password'});
			$user->fullname($parameters->{'fullname'});
			$user->update();
		} else {
			Loggerithim::User->create({
				username	=> $parameters->{'username'},
				password	=> $parameters->{'password'},
				fullname	=> $parameters->{'fullname'}
			});
		}
		return {REDIRECT => "admin.phtml"};
	} elsif($parameters->{'action'} eq "list") {
		unless(Loggerithim::Util::Permission->check($user, "User", "read")) {
			return { NORIGHTS => 1 }
		}
		my @users;
		my $uIter = Loggerithim::User->retrieve_all();
		while(my $user = $uIter->next()) {
			push(@users, {
				id			=> $user->id(),
				username	=> $user->username(),
				fullname	=> $user->fullname(),
			});
		}
		return {
			title			=> 'User Listing',
			userlist		=> 1,
			users			=> \@users,
		};
	} elsif($parameters->{'userid'}) {
		unless(Loggerithim::Util::Permission->check($user, "User", "read")) {
			return { NORIGHTS => 1 }
		}
		my $user = Loggerithim::User->retrieve($parameters->{'userid'});

		return {
			title			=> 'Manipulate User',
			userid			=> $user->id(),
			username		=> $user->username(),
			password		=> $user->password(),
			fullname		=> $user->fullname(),
		};
	}

	unless(Loggerithim::Util::Permission->check($user, "User", "write")) {
		return { NORIGHTS => 1 }
	}
	return {
		title	=> "Manipulate User",
	};
}

1;
