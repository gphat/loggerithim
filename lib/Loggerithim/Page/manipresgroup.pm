package Loggerithim::Page::manipresgroup;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r		    = $stuff->{'request'};
	my $user	    = $stuff->{'user'};

	if($parameters->{'submitter'}) {
		unless(Loggerithim::Util::Permission->check($user, "ResourceGroup", "write")) {
			return { NORIGHTS => 1 };
		}
		my $custom = $parameters->{'custom'};
		if($custom eq "on") {
			$custom = 1;
		} else {
			$custom = 0;
		}

		my $keyed = $parameters->{'keyed'};
		if($keyed eq "on") {
			$keyed = 1;
		} else {
			$keyed = 0;
		}

		if($parameters->{'resgroupid'}) {
			my $rg = Loggerithim::ResourceGroup->retrieve($parameters->{'resgroupid'});
			$rg->name($parameters->{'name'});
			$rg->custom($custom);
			$rg->keyed($keyed);
			$rg->update();
		} else {
			Loggerithim::ResourceGroup->create({
				name	=> $parameters->{'name'},
				custom	=> $custom,
				keyed	=> $keyed
			});
		}

		return {REDIRECT => "admin.phtml"};
	} elsif($parameters->{'action'} eq "list") {
		unless(Loggerithim::Util::Permission->check($user, "ResourceGroup", "read")) {
			return { NORIGHTS => 1 };
		}
		my @rgs;
		my $rgIter = Loggerithim::ResourceGroup->retrieve_all();
		while(my $rg = $rgIter->next()) {
			push(@rgs, {
				id		=> $rg->id(),
				name	=> $rg->name(),
				custom	=> $rg->custom(),
				keyed	=> $rg->keyed()
			});
		}
		return {
			title	=> "List Resource Groups",
			rglist	=> 1,
			rgs	    => \@rgs,
		};
	} elsif($parameters->{'resgroupid'}) {
		unless(Loggerithim::Util::Permission->check($user, "ResourceGroup", "read")) {
			return { NORIGHTS => 1 };
		}
		my $rg = Loggerithim::ResourceGroup->retrieve($parameters->{'resgroupid'});
		return {
			title		=> "Manipulate Resource Group",
			resgroupid	=> $rg->id(),
			name		=> $rg->name(),
			keyed		=> $rg->keyed(),
			custom		=> $rg->custom(),
		};
	}
	unless(Loggerithim::Util::Permission->check($user, "ResourceGroup", "write")) {
		return { NORIGHTS => 1 };
	}
	return {
		title		=> "Manipulate Resource Group",
		resgroupid	=> "",
	};
}

1;
