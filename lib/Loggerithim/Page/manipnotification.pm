package Loggerithim::Page::manipnotification;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r		    = $stuff->{'request'};
	my $user		= $stuff->{'user'};

	if($parameters->{'submitter'}) {
		unless(Loggerithim::Util::Permission->check($user, "Notification", "write")) {
			return { NORIGHTS => 1 };
		}
		if($parameters->{'notificationid'}) {
			my $notif = Loggerithim::Notification->retrieve($parameters->{'notificationid'});
			$notif->group(Loggerithim::Grou->retrieve($parameters->{'group'}));
			$notif->system(Loggerithim::System->retrieve($parameters->{'system'}));
			$notif->update();
		} else {
			Loggerithim::Notification->create({
				job		=> Loggerithim::Job->retrieve($parameters->{'jobid'}),
				group	=> Loggerithim::Group->retrieve($parameters->{'group'}),
				system	=> Loggerithim::System->retrieve($parameters->{'system'}),
			});
		}
		return {REDIRECT => "admin.phtml"};
	} elsif(($parameters->{'action'} eq "list") and ($parameters->{'jobid'})) {
		unless(Loggerithim::Util::Permission->check($user, "Notification", "read")) {
			return { NORIGHTS => 1 };
		}

		my $job = Loggerithim::Job->retrieve($parameters->{'jobid'});

		my $nIter = $job->notifications();
		my @list;
		while(my $not = $nIter->next()) {
			my $sysname;
			if(defined($not->system())) {
				$sysname = $not->system()->name();
			}
			push(@list, {
				notificationid	=> $not->id(),
				group			=> $not->group()->name(),
				system			=> $sysname
			});
		}
		
		return {
			title			=> "List Notifications",
			notificationlist=> 1,
			list			=> \@list,
		}
	} elsif($parameters->{'notificationid'}) {
		unless(Loggerithim::Util::Permission->check($user, "Notification", "write")) {
			return { NORIGHTS => 1 };
		}
		my $not = Loggerithim::Notification->retrieve($parameters->{'notificationid'});

		my @groups;
		my $gIter = Logerithim::Group->retrieve_all();
		while(my $grp = $gIter->next()) {
			my $selected = 1 unless $grp->id() != $not->group()->id();
			push(@groups, {
				id	=> $grp->id(),
				name=> $grp->name(),
			});
		}

		my @systems;
		my $sIter = Logerithim::System->retrieve_all();
		while(my $sys = $sIter->next()) {
			my $selected = 0;
			if(defined($not->system())) {
				if($sys->id() != $not->system()->id()) {
					$selected = 1;
				}
			}
			push(@systems, {
				id	=> $sys->id(),
				selected => $selected,
				name=> $sys->name(),
			});
		}
		unshift(@systems, {
			name	=> "None"
		});

		return {
			title			=> "Manipulate Notification",
			jobid			=> $parameters->{'jobid'},
			notificationid	=> $parameters->{'notificationid'},
			systems			=> \@systems,
			groups			=> \@groups,
		};
	} elsif($parameters->{'jobid'}) {
		unless(Loggerithim::Util::Permission->check($user, "Notification", "write")) {
			return { NORIGHTS => 1 };
		}
		my @groups = Loggerithim::Group->list();
		my $gIter = Logerithim::Group->retrieve_all();
		while(my $grp = $gIter->next()) {
			my $selected = 1 unless $grp->id() != $grp->group()->id();
			push(@groups, {
				id	=> $grp->id(),
				name=> $grp->name(),
			});
		}

		my @systems;
		my $sIter = Logerithim::System->retrieve_all();
		while(my $sys = $sIter->next()) {
			push(@systems, {
				id	=> $sys->id(),
				name=> $sys->name(),
			});
		}
		unshift(@systems, {
			name	=> "None"
		});

		return {
			title	=> "Manipulate Notification",
			jobid	=> $parameters->{'jobid'},
			systems	=> \@systems,
			groups	=> \@groups,
		};
	}
}

1;
