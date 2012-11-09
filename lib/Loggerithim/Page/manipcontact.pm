package Loggerithim::Page::manipcontact;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r	    	= $stuff->{'request'};
	my $user		= $stuff->{'user'};

	if($parameters->{'submitter'}) {
		unless(Loggerithim::Util::Permission->check($user, "Contact", "write")) {
			return { NORIGHTS => 1 };
		}
		if($parameters->{'contactid'}) {
			my $contact = Loggerithim::Contact->retrieve($parameters->{'contactid'});
			$contact->userid($parameters->{'userid'});
			$contact->mediumid($parameters->{'medium'});
			$contact->value($parameters->{'value'});
			$contact->update();
		} else {
			my $contact = Loggerithim::Contact->create({
				user	=> Loggerithim::User->retrieve($parameters->{'userid'}),
				medium	=> Loggerithim::Medium->retrieve($parameters->{'medium'}),
				value	=> $parameters->{'value'},
			});
		}
		return {REDIRECT => "admin.phtml"};

	} elsif(($parameters->{'action'} eq "list") and ($parameters->{'userid'})) {
		unless(Loggerithim::Util::Permission->check($user, "Contact", "read")) {
			return { NORIGHTS => 1 };
		}
		my $u = Loggerithim::User->retrieve($parameters->{'userid'});
		my @contacts;
		my $cIter = $u->contacts();
		while(my $con = $cIter->next()) {
			push(@contacts => {
				id		=> $con->id(),
				medium	=> $con->medium()->name(),
				value	=> $con->value()
			});
		}
		return {
			title		=> "List Contacts",
			contactlist	=> 1,
			contacts	=> \@contacts,
		}

	} elsif($parameters->{'contactid'}) {
		unless(Loggerithim::Util::Permission->check($user, "Contact", "read")) {
			return { NORIGHTS => 1 };
		}
		my $contact = Loggerithim::Contact->retrieve($parameters->{'contactid'});
		my $medIter = Loggerithim::Medium->retrieve_all();
		my @mediums;
		while(my $med = $medIter->next()) {
			my $selected = 1 unless $med->id() != $parameters->{'contactid'};
			push(@mediums, {
				id		=> $med->id(),
				selected=> $selected,
				name	=> $med->name(),
			});
		}

		return {
			title		=> "Manipulate Contact",
			contactid	=> $parameters->{'contactid'},
			userid		=> $contact->user()->id(),
			mediums		=> \@mediums,
			value		=> $contact->value(),
		};
	}

	unless(Loggerithim::Util::Permission->check($user, "Contact", "write")) {
		return { NORIGHTS => 1 };
	}
	my $medIter = Loggerithim::Medium->retrieve_all();
	my @mediums;
	while(my $med = $medIter->next()) {
		my $selected = 1 unless $med->id() != $parameters->{'contactid'};
		push(@mediums, {
			id		=> $med->id(),
			selected=> $selected,
			name	=> $med->name(),
		});
	}

	return {
		title		=> "Manipulate Contact",
		userid		=> $parameters->{'userid'},
		mediums		=> \@mediums,
	};
}

1;
