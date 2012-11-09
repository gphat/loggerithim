package Loggerithim::Page::index;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters  = $stuff->{'parameters'};
	my $r           = $stuff->{'request'};

	if($parameters->{'action'} eq "logout") {
		my $session = Loggerithim::Session->existingSession($r);
		if(defined($session)) {
			$session->destroy();
		}
	}

	my $session = Loggerithim::Session->existingSession($r);
	if($session) {
		return {'REDIRECT' => "main.phtml"};
	}

	my %args;
	$args{'title'} = "Login";

	my $username = $parameters->{'username'};
	my $password = $parameters->{'password'};
	if(($username ne "") and ($password ne "")) {
		my $uIter = Loggerithim::User->search(username => $username);
		my $user = $uIter->next();
		if(defined($user)) {
			if(($user->username() eq $username) and ($user->password() eq $password)) {
				my $session = Loggerithim::Session->new($user->id());
				$args{'COOKIE'} = $session->cookie();
				$args{'REDIRECT'} = "main.phtml";
			} else {
				$args{'error'} = "The supplied credentials are incorrect.";
			}
		} else {
			$args{'error'} = "The supplied credentials are incorrect.";
		}
	}
	return \%args;
}	

1;
