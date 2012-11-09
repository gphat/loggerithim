package Loggerithim::Page::manipsmeeplet;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r		    = $stuff->{'request'};
	my $user	    = $stuff->{'user'};

	if($parameters->{'submitter'}) {
		unless(Loggerithim::Util::Permission->check($user, "Smeeplet", "write")) {
			return { NORIGHTS => 1 };
		}
		if($parameters->{'smeepletid'}) {
			my $s = Loggerithim::Smeeplet->retrieve($parameters->{'smeepletid'});
			$s->name($parameters->{'name'});
			$s->description($parameters->{'description'});
			$s->update();
		} else {
			my $s = Loggerithim::Smeeplet->create({
				name		=> $parameters->{'name'},
				description => $parameters->{'description'}
			});
		}
		return {REDIRECT => "admin.phtml"};
	} elsif($parameters->{'action'} eq "list") {
		unless(Loggerithim::Util::Permission->check($user, "Smeeplet", "read")) {
			return { NORIGHTS => 1 };
		}
		my @smeeplets;
		my $sIter = Loggerithim::Smeeplet->retrieve_all();
		while(my $smeep = $sIter->next()) {
			push(@smeeplets, {
				id			=> $smeep->id(),
				name		=> $smeep->name(),
				description	=> $smeep->description()
			});
		}
		return {
			title		=> "List Smeeplets",
			smeepletlist=> 1,
			smeeplets	=> \@smeeplets,
		};

	} elsif($parameters->{'smeepletid'}) {
		unless(Loggerithim::Util::Permission->check($user, "Smeeplet", "read")) {
			return { NORIGHTS => 1 };
		}
		my $s = Loggerithim::Smeeplet->retrieve($parameters->{'smeepletid'});

		return {
			title		=> "Edit Smeeplet",
			id			=> $s->id(),
			name		=> $s->name(),
			description	=> $s->description(),
		};
	}
	unless(Loggerithim::Util::Permission->check($user, "Smeeplet", "write")) {
		return { NORIGHTS => 1 };
	}
	return {
		title		=> "Manipulate Smeeplet",
		smeepletid	=> "",
	};
}

1;
