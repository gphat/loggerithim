package Loggerithim::Page::manipresource;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r		    = $stuff->{'request'};
	my $user	    = $stuff->{'user'};

	if($parameters->{'submitter'}) {
		unless(Loggerithim::Util::Permission->check($user, "Resource", "write")) {
			return { NORIGHTS => 1 };
		}
		if($parameters->{'resourceid'}) {
			my $res = Loggerithim::Resource->retrieve($parameters->{'resourceid'});
			$res->resgroup(Loggerithim::ResourceGroup->retrieve($parameters->{'resgroupid'}));
			$res->name($parameters->{'name'});
			$res->index($parameters->{'index'});
			$res->update();
		} else {
			Loggerithim::Resource->create({
				resgroup	=> Loggerithim::ResourceGroup->retrieve($parameters->{'resgroupid'}),
				name		=> $parameters->{'name'},
				index		=> $parameters->{'index'}
			});
		}
		return {REDIRECT => "admin.phtml"};
	} elsif($parameters->{'action'} eq "list") {
		unless(Loggerithim::Util::Permission->check($user, "Resource", "read")) {
			return { NORIGHTS => 1 };
		}

		my $rg = Loggerithim::ResourceGroup->retrieve($parameters->{'resgroupid'});
		my @resources;
		my $rIter = $rg->resources();
		while(my $res = $rIter->next()) {
			push(@resources, {
				id		=> $res->id(),
				name	=> $res->name(),
				index	=> $res->index()
			});
		}

		return {
			title		=> "List Resources",
			resourcelist=> 1,
			resources	=> \@resources,
		};
	} elsif($parameters->{'resourceid'}) {
		unless(Loggerithim::Util::Permission->check($user, "Resource", "read")) {
			return { NORIGHTS => 1 };
		}
		my $r = Loggerithim::Resource->retrieve($parameters->{'resourceid'});
		return {
			title		=> "Manipulate Resource",
			resourceid	=> $r->id(),
			name		=> $r->name(),
			index		=> $r->index(),
			resgroupid	=> $r->resgroup()->id(),
		};
	}

	unless(Loggerithim::Util::Permission->check($user, "Resource", "write")) {
		return { NORIGHTS => 1 };
	}
	return {
		title		=> "Manipulate Resource",
		resgroupid	=> $parameters->{'resgroupid'},
	};
}

1;
