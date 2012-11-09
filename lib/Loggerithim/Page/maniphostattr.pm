package Loggerithim::Page::maniphostattr;
use strict;

use base("Loggerithim::Page");

sub handler {
	my $self	= shift();
	my $stuff	= shift();

	my $parameters	= $stuff->{'parameters'};
	my $r			= $stuff->{'request'};
	my $user		= $stuff->{'user'};

	if($parameters->{'submitter'}) {
		unless(Loggerithim::Util::Permission->check($user, "Host", "write")) {
			return { NORIGHTS => 1 };
		}
		my $host = Loggerithim::Host->retrieve($parameters->{'hostid'});
		die("TODO");
		$host->addAttribute($parameters->{'attributeid'});
		return {REDIRECT => "admin.phtml"};
	} elsif(($parameters->{'action'} eq "list") and ($parameters->{'hostid'})) {
		unless(Loggerithim::Util::Permission->check($user, "Host", "read")) {
			return { NORIGHTS => 1 };
		}
		my $host = Loggerithim::Host->retrieve($parameters->{'hostid'});
		my @hostattrs;
		my $haIter = $host->hostAttributes();
		while(my $hattr = $haIter->next()) {
			push(@hostattrs, {
				hostattrid	=> $hattr->id(),
				name		=> $hattr->attribute()->name(),
			});
		}
		return {
			title		=> 'List Host Attributes',
			hostattrlist=> 1,
			hostattrs	=> \@hostattrs,
		};

	} elsif($parameters->{'hostid'}) {
		unless(Loggerithim::Util::Permission->check($user, "Host", "write")) {
			return { NORIGHTS => 1 };
		}
		my @attrs;
		my $aIter = Loggerithim::Attribute->retrieve_all();
		while(my $att = $aIter->next()) {
			push(@attrs, {
				id		=> $att->id(),
				name	=> $att->name()
			});
		}

		return {
			title		=> "Manipulate Host Attributes",
			hostid		=> $parameters->{'hostid'},
			attributes	=> \@attrs,
		};
	}
}

1;
