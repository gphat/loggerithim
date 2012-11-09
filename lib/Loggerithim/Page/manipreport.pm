package Loggerithim::Page::manipreport;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r		    = $stuff->{'request'};
	my $user	    = $stuff->{'user'};

	if($parameters->{'submitter'}) {
		unless(Loggerithim::Util::Permission->check($user, "Report", "write")) {
			return { NORIGHTS => 1 };
		}
		# TODO Use Attributes rather than Host IDs?
		if($parameters->{'reportid'}) {
			my $rep = Loggerithim::Report->retrieve($parameters->{'reportid'});
			$rep->hosts($parameters->{'hosts'});
			$rep->reporterid($parameters->{'reporterid'});
			$rep->interval($parameters->{'interval'});
			$rep->name($parameters->{'name'});
			$rep->output($parameters->{'output'});
			$rep->commit();
		} else {
			Loggerithim::Report->create({
				hosts	=> $parameters->{'hosts'},
				reporter=> Loggerithim::Reporter->retrieve($parameters->{'reporterid'}),
				interval=> DateTime::Event::Cron->from_cron($parameters->{'interval'}),
				name	=> $parameters->{'name'},
				output	=> $parameters->{'output'}
			});
		}
		return {REDIRECT => "admin.phtml"};
	} elsif($parameters->{'action'} eq "list") {
		unless(Loggerithim::Util::Permission->check($user, "Report", "read")) {
			return { NORIGHTS => 1 };
		}
		my @reports;
		my $rIter = Loggerithim::Report->retrieve_all();
		while(my $rep = $rIter->next()) {
			push(@reports, {
				id	=> $rep->id(),
				name=> $rep->name()
			});
		}
		return {
			title		=> "List Reports",
			reportlist	=> 1,
			reports		=> \@reports,
		};
	} elsif($parameters->{'reportid'}) {
		unless(Loggerithim::Util::Permission->check($user, "Report", "read")) {
			return { NORIGHTS => 1 };
		}
		my $rep = Loggerithim::Report->retrieve($parameters->{'reportid'});

		my @reporters;
		my $rIter = Loggerithim::Reporter->retrieve_all();
		while(my $r = $rIter->next()) {
			my $selected = 1 unless $rep->id() != $r->id();
			push(@reporters, {
				id		=> $r->id(),
				selected=> $selected,
				name	=> $r->name()
			});
		}
		return {
			title		=> "Manipulate Report",
			reportid	=> $rep->id(),
			hosts		=> $rep->hosts(),
			reporters	=> \@reporters,
			interval	=> $rep->interval()->original(),
			name		=> $rep->name(),
			output		=> $rep->output(),
		};
	}
	unless(Loggerithim::Util::Permission->check($user, "Report", "write")) {
		return { NORIGHTS => 1 };
	}
	my @reporters;
	my $rIter = Loggerithim::Reporter->retrieve_all();
	while(my $rep = $rIter->next()) {
		push(@reporters, {
			id	=> $rep->id(),
			name=> $rep->name()
		});
	}
	return {
		title		=> "Manipulate Report",
		reportid	=> "",
		reporters	=> \@reporters,
	};
}

1;
