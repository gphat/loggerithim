package Loggerithim::Page::manipjob;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r		    = $stuff->{'request'};
	my $user	    = $stuff->{'user'};

	if($parameters->{'submitter'}) {
		unless(Loggerithim::Util::Permission->check($user, "Job", "write")) {
			return { NORIGHTS => 1 };
		}
		if($parameters->{'jobid'}) {
			my $job = Loggerithim::Job->retrieve($parameters->{'jobid'});
			$job->interval(DateTime::Event::Cron->new_from_cron(cron => $parameters->{'interval'}));
			$job->smeeplet(Loggerithim::Smeeplet->retrieve($parameters->{'smeepletid'}));
			$job->attribute(Loggerithim::Attribute->retrieve($parameters->{'attributeid'}));
			$job->update();
		} else {
			my $job = Loggerithim::Job->create({
				interval	=> DateTime::Event::Cron->from_cron($parameters->{'interval'}),
				smeeplet	=> Loggerithim::Smeeplet->retrieve($parameters->{'smeepletid'}),
				attribute	=> Loggerithim::Attribute->retrieve($parameters->{'attributeid'}),
			});
		}
		return {REDIRECT => "admin.phtml"};

	} elsif($parameters->{'action'} eq "list") {
		unless(Loggerithim::Util::Permission->check($user, "Job", "read")) {
			return { NORIGHTS => 1 };
		}
		my $jIter = Loggerithim::Job->retrieve_all();

		my @jobs;
		while(my $job = $jIter->next()) {
			push(@jobs, {
				jobid		=> $job->id(),
				attribute	=> $job->attribute()->name(),
				smeeplet	=> $job->smeeplet()->name(),
				interval	=> $job->interval()->original(),
			});
		}

		return {
			title		=> "List Jobs",
			joblist		=> 1,
			jobs		=> \@jobs,
		}

	} elsif($parameters->{'jobid'}) {
		unless(Loggerithim::Util::Permission->check($user, "Job", "write")) {
			return { NORIGHTS => 1 };
		}
		my $job = Loggerithim::Job->retrieve($parameters->{'jobid'});

		my $aIter = Loggerithim::Attribute->retrieve_all();
		my @attributes;
		while(my $att = $aIter->next()) {
			my $selected = 0;
			if($att->id() eq $job->attribute()->id()) {
				$selected = 1;
			}
			push(@attributes, {
				id		=> $att->id(),
				name	=> $att->name(),
				selected=> $selected
			});
		}

		my $sIter = Loggerithim::Smeeplet->retrieve_all();
		my @smeeplets;
		while(my $smeep = $sIter->next()) {
			my $selected = 0;
			if($smeep->id() eq $job->smeeplet()->id()) {
				$selected = 1;
			}
			push(@smeeplets, {
				id		=> $smeep->id(),
				name	=> $smeep->name(),
				selected=> $selected
			});
		}

		return {
			title		=> "Manipulate Job",
			jobid		=> $job->id(),
			attributes	=> \@attributes,
			smeeplets	=> \@smeeplets,
			interval	=> $job->interval()->original(),
		};
	}
	unless(Loggerithim::Util::Permission->check($user, "Job", "write")) {
		return { NORIGHTS => 1 };
	}

	my $sIter = Loggerithim::Smeeplet->retrieve_all();
	my @smeeplets;
	while(my $smeep = $sIter->next()) {
		push(@smeeplets, {
			id		=> $smeep->id(),
			name	=> $smeep->name(),
		});
	}

	my $aIter = Loggerithim::Attribute->retrieve_all();
	my @attributes;
	while(my $att = $aIter->next()) {
		push(@attributes, {
			id		=> $att->id(),
			name	=> $att->name(),
		});
	}

	return {
		title	=> "Manipulate Job",
		jobid	=> "",
		attributes	=> \@attributes,
		smeeplets	=> \@smeeplets,
	};
}

1;
