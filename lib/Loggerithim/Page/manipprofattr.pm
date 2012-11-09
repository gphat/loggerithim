package Loggerithim::Page::manipprofattr;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self	= shift();
	my $stuff	= shift();

	my $parameters	= $stuff->{'parameters'};
	my $r			= $stuff->{'request'};
	my $user		= $stuff->{'user'};

	if($parameters->{'submitter'}) {
		unless(Loggerithim::Util::Permission->check($user, "Profile", "write")) {
			return { NORIGHTS => 1 };
		}
		my $p = Loggerithim::Profile->new($parameters->{'profileid'});
		$p->addAttribute($parameters->{'attributeid'});
		return {REDIRECT => "admin.phtml"};
	} elsif(($parameters->{'action'} eq "list") and ($parameters->{'profileid'})) {
		unless(Loggerithim::Util::Permission->check($user, "Profile", "read")) {
			return { NORIGHTS => 1 };
		}
		my $profile = Loggerithim::Profile->retrieve($parameters->{'profileid'});
		my @profattrs;
		my $aIter = $profile->profileAttributes();
		while(my $patt = $aIter->next()) {
			push(@profattrs, {
				profattrid	=> $patt->id(),
				name		=> $patt->attribute()->name(),
			});
		}
		return {
			title		=> 'List Profile Attributes',
			profattrlist=> 1,
			profattrs	=> \@profattrs,
		};

	} elsif($parameters->{'profileid'}) {
		unless(Loggerithim::Util::Permission->check($user, "Profile", "write")) {
			return { NORIGHTS => 1 };
		}
		my @attrs;
		my $aIter = Loggerithim::Attribute->retrieve_all();
		while(my $att = $aIter->next()) {
			push(@attrs, {
				id	=> $att->id(),
				name=> $att->name()
			});
		}

		return {
			title		=> "Manipulate Profile Attributes",
			profileid	=> $parameters->{'profileid'},
			attributes	=> \@attrs,
		};
	}
}

1;
