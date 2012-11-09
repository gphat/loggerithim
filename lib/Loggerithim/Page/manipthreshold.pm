package Loggerithim::Page::manipthreshold;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r			= $stuff->{'request'};
	my $user		= $stuff->{'user'};

	if($parameters->{'submitter'}) {
		unless(Loggerithim::Util::Permission->check($user, "Threshold", "write")) {
			return { NORIGHTS => 1 };
		}
		if($parameters->{'thresholdid'}) {
			my $threshold = Loggerithim::Threshold->retrieve($parameters->{'thresholdid'});
			$threshold->host(Loggerithim::Host->retrieve($parameters->{'hostid'}));
			$threshold->resource(Loggerithim::Resource->retrieve($parameters->{'resourceid'}));
			$threshold->severity($parameters->{'severity'});
			$threshold->value($parameters->{'value'});
			$threshold->key($parameters->{'key'});
			$threshold->update();
		} else {
			Loggerithim::Threshold->create({
				host	=> Loggerithim::Host->retrieve($parameters->{'hostid'}),
				resource=> Loggerithim::Resource->retrieve($parameters->{'resourceid'}),
				severity=> $parameters->{'severity'},
				value	=> $parameters->{'value'},
				key		=> $parameters->{'key'},
			});
		}
		return {REDIRECT => "admin.phtml"};
	} elsif($parameters->{'action'} eq "list") {
		unless(Loggerithim::Util::Permission->check($user, "Threshold", "read")) {
			return { NORIGHTS => 1 };
		}
		my $host = Loggerithim::Host->retrieve($parameters->{'hostid'});
		my @thresholds;
		my $tIter = $host->thresholds();
		while(my $thresh = $tIter->next()) {
			push(@thresholds, {
				id			=> $thresh->id(),
				resource	=> $thresh->resource()->name(),
				severity	=> $thresh->severity(),
				value		=> $thresh->value(),
				key			=> $thresh->key()
			});
		}
		return {
			title		=> 'List Thresholds',
			thresholdlist	=> 1,
			hostid		=> $parameters->{'hostid'},
			thresholds	=> \@thresholds,
		};

	} elsif($parameters->{'thresholdid'}) {
		unless(Loggerithim::Util::Permission->check($user, "Threshold", "read")) {
			return { NORIGHTS => 1 };
		}

		my $thresh = Loggerithim::Threshold->retrieve($parameters->{'thresholdid'});

		my @resources;
		my $rIter = Loggerithim::Resource->retrieve_all();
		while(my $res = $rIter->next()) {
			my $selected = 1 unless $thresh->resource()->id() != $res->id();
			push(@resources, {
				id			=> $res->id(),
				selected	=> $selected,
				name		=> $res->name()
			});
		}

		return {
			title		=> "Manipulate Thresholds",
			thresholdid	=> $thresh->id(),
			hostid		=> $thresh->host()->id(),
			resources	=> \@resources,
			severity	=> $thresh->severity(),
			value		=> $thresh->value(),
			key			=> $thresh->key(),
		};
	}

	unless(Loggerithim::Util::Permission->check($user, "Threshold", "write")) {
		return { NORIGHTS => 1 };
	}
	
	my @resources;
	my $rIter = Loggerithim::Resource->retrieve_all();
	while(my $res = $rIter->next()) {
		push(@resources, {
			id			=> $res->id(),
			name		=> $res->name()
		});
	}
	return {
		title		=> "Manipulate Threshold",
		hostid		=> $parameters->{'hostid'},
		resources	=> \@resources,
	};
}

1;
