package Loggerithim::Page::maniphost;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r		    = $stuff->{'request'};
	my $user		= $stuff->{'user'};

	if($parameters->{'submitter'}) {
		unless(Loggerithim::Util::Permission->check($user, "Host", "write")) {
			return { NORIGHTS => 1 };
		}

		my $active = $parameters->{'active'};
		if($active eq "on") {
			$active = 1;
		} else {
			$active = 0;
		}

		my $dbport	= $parameters->{'dbport'};
		if(!($dbport)) {
			$dbport = undef;
		}
		if($parameters->{'hostid'}) {
			my $host = Loggerithim::Host->retrieve($parameters->{'hostid'});
			$host->name($parameters->{'name'});
			$host->ip($parameters->{'ip'});
			$host->purpose($parameters->{'purpose'});
			$host->department(Loggerithim::Department->retrieve($parameters->{'department'}));
			$host->system(Loggerithim::System->retrieve($parameters->{'system'}));
			$host->db_sid($parameters->{'dbsid'});
			$host->db_password($parameters->{'dbpassword'});
			$host->active($active);
			$host->db_port($dbport);
			$host->update();
		} else {
			Loggerithim::DBI->do_transaction( sub {
				my $host = Loggerithim::Host->create({
					name		=> $parameters->{'name'},
					ip			=> $parameters->{'ip'},
					purpose		=> $parameters->{'purpose'},
					department	=> Loggerithim::Department->retrieve($parameters->{'department'}),
					system		=> Loggerithim::System->retrieve($parameters->{'system'}),
					db_sid		=> $parameters->{'dbsid'},
					db_password	=> $parameters->{'dbpassword'},
					db_port		=> $dbport,
					active 		=> $active
				});
				my $profile = Loggerithim::Profile->retrieve($parameters->{'profile'});
				my $attIter = $profile->attributes();
				while(my $att = $attIter->next()) {
					$host->addAttribute($att);
				}
			});
		}

		return {REDIRECT => "admin.phtml"};
	} elsif($parameters->{'action'} eq "list") {
		unless(Loggerithim::Util::Permission->check($user, "Host", "read")) {
			return { NORIGHTS => 1 };
		}

		my @hosts;
		my $hIter = Loggerithim::Host->retrieve_all();
		while(my $host = $hIter->next()) {
			push(@hosts, {
				id			=> $host->id(),
				name		=> $host->name(),
				ip			=> $host->ip(),
				active		=> $host->active(),
				purpose		=> $host->purpose(),
				department	=> $host->department()->name(),
				system		=> $host->system()->name(),
			});
		}
		return {
			title		=> "List Hosts",
			hostlist	=> 1,
			hosts		=> \@hosts,
		};
	} elsif($parameters->{'hostid'}) {
		unless(Loggerithim::Util::Permission->check($user, "Resource", "read")) {
			return { NORIGHTS => 1 };
		}
		my $host = Loggerithim::Host->retrieve($parameters->{'hostid'});

		my @departments;
		my $dIter = Loggerithim::Department->retrieve_all();
		while(my $dept = $dIter->next()) {
			my $selected = 0;
			if($dept->id() == $host->department()->id()) {
				$selected = 1;
			}
			push(@departments, {
				id		=> $dept->id(),
				name	=> $dept->name(),
				selected=> $selected,
			});
		}

		my @systems;
		my $sIter = Loggerithim::System->retrieve_all();
		while(my $sys = $sIter->next()) {
			my $selected = 0;
			if($sys->id() == $host->system()->id()) {
				$selected = 1;
			}
			push(@systems, {
				id		=> $sys->id(),
				name	=> $sys->name(),
				selected=> $selected
			});
		}

		return {
			hostid		=> $host->id(),
			name		=> $host->name(),
			ip			=> $host->ip(),
			active		=> $host->active(),
			purpose		=> $host->purpose(),
			departments	=> \@departments,
			systems		=> \@systems,
			dbsid		=> $host->db_sid(),
			dbport		=> $host->db_port(),
			dbpassword	=> $host->db_password(),
		};
	}

	my @departments;
	my $dIter = Loggerithim::Department->retrieve_all();
	while(my $dept = $dIter->next()) {
		push(@departments, {
			id		=> $dept->id(),
			name	=> $dept->name(),
		});
	}

	my @systems;
	my $sIter = Loggerithim::System->retrieve_all();
	while(my $sys = $sIter->next()) {
		push(@systems, {
			id		=> $sys->id(),
			name	=> $sys->name(),
		});
	}

	my @profiles;
	my $pIter = Loggerithim::Profile->retrieve_all();
	while(my $prof = $pIter->next()) {
		push(@profiles, {
			id		=> $prof->id(),
			name	=> $prof->name(),
		});
	}

	unless(Loggerithim::Util::Permission->check($user, "Host", "write")) {
		return { NORIGHTS => 1 };
	}
	return {
		title		=> "Manipulate Host",
		hostid		=> "",
		departments	=> \@departments,
		systems		=> \@systems,
		profiles	=> \@profiles,
	};
}

1;
