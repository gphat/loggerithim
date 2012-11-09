package Loggerithim::Page::manipattribute;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r			= $stuff->{'request'};
	my $user		= $stuff->{'user'};

	if($parameters->{'submitter'}) {
		unless(Loggerithim::Util::Permission->check($user, "Attribute", "write")) {
			return { NORIGHTS => 1 };
		}
		my $attr;
		my $attributeid	= $parameters->{'attributeid'};
		if($attributeid) {
			$attr = Loggerithim::Attribute->retrieve($attributeid);
			$attr->name($parameters->{'name'});
			$attr->sigil($parameters->{'sigil'});
			$attr->types($parameters->{'types'});
			$attr->hours($parameters->{'hours'});
			$attr->macros($parameters->{'macros'});
			$attr->url(URI->new($parameters->{'url'}));
			$attr->update();
		} else {
			my $attr = Loggerithim::Attribute->create({
				name	=> $parameters->{'name'},
				sigil	=> $parameters->{'sigil'},
				types	=> $parameters->{'types'},
				hours	=> $parameters->{'hours'},
				macros	=> $parameters->{'macros'},
				url		=> URI->new($parameters->{'url'})
			});
		}
		return {REDIRECT => "admin.phtml"};
	} elsif($parameters->{'action'} eq "list") {
		unless(Loggerithim::Util::Permission->check($user, "Attribute", "read")) {
			return { NORIGHTS => 1 };
		}
		my @attributes;
		my $aIter = Loggerithim::Attribute->retrieve_all();
		while(my $att = $aIter->next()) {
			my $url;
			if(defined($att->url())) {
				$url = $att->url()->as_string();
			}
			push(@attributes, {
				attributeid	=> $att->id(),
				name		=> $att->name(),
				sigil		=> $att->sigil(),
				types		=> $att->types(),
				hours		=> $att->hours(),
				macros		=> $att->macros(),
				url			=> $url
			});
		}
		return {
			title			=> 'List Attributes',
			attributelist	=> 1,
			attributes		=> \@attributes,
		};

	} elsif($parameters->{'attributeid'}) {
		unless(Loggerithim::Util::Permission->check($user, "Attribute", "read")) {
			return { NORIGHTS => 1 };
		}
		my $attr = Loggerithim::Attribute->retrieve($parameters->{'attributeid'});

		my $url;
		if(defined($attr->url())) {
			$url = $attr->url()->as_string();
		}
		return {
			title		=> "Manipulate Attribute",
			attributeid	=> $parameters->{'attributeid'},
			name		=> $attr->name(),
			sigil		=> $attr->sigil(),
			types		=> $attr->types(),
			hours		=> $attr->hours(),
			macros		=> $attr->macros(),
			url			=> $url,
		};
	}

	unless(Loggerithim::Util::Permission->check($user, "Attribute", "write")) {
		return { NORIGHTS => 1 };
	}
	return {
		title		=> "Manipulate Attribute",
		attributeid	=> "",
	};
}

1;
