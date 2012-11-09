package Loggerithim::Page::preferences;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r			= $stuff->{'request'};
	my $user		= $stuff->{'user'};

	if($parameters->{'submitter'}) {
		my $password = $parameters->{'password'};

		my $stats;
		if($parameters->{'stats'} eq "on") {
			$stats = 1;
		} else {
			$stats = 0;
		}

		my $timer;
		if($parameters->{'timer'} eq "on") {
			$timer = 1;
		} else {
			$timer = 0;
		}

		my $color;
		if($parameters->{'color'} eq "on") {
			$color = 1;
		} else {
			$color = 0;
		}

		my $dept	= $parameters->{'department'};
		my $sys		= $parameters->{'system'};

		$user->password($password);
		$user->preferences("Color=$color,Department=$dept,System=$sys");
		$user->update();
		return {REDIRECT => "main.phtml"};
	}

	my $userprefs = $user->getPreferences();

	my @departments;
	my $dIter = Loggerithim::Department->retrieve_all();
	while(my $d = $dIter->next()) {
		my $selected = 1 unless $d->id() != $userprefs->{'Department'};
		push(@departments, {
			id		=> $d->id(),
			selected=> $selected,
			name	=> $d->name()
		});
	}

	my @systems;
	my $sIter = Loggerithim::System->retrieve_all();
	while(my $s = $sIter->next()) {
		my $selected = 1 unless $s->id() != $userprefs->{'Department'};
		push(@systems, {
			id		=> $s->id(),
			selected=> $selected,
			name	=> $s->name()
		});
	}

	my @saves;
	my $savIter = $user->saves();
	while(my $save = $savIter->next()) {
		push(@saves, {
			id	=> $save->id(),
			name=> $save->name(),
			page=> $save->page()
		});
	}

	return {
		NOCACHE		=> 1,
		title		=> "Preferences",
		departments	=> \@departments,
		systems		=> \@systems,
		password	=> $user->password(),
		color		=> $userprefs->{"Color"},
		dept		=> $userprefs->{"Department"},
		sys			=> $userprefs->{"System"},
		loc			=> $userprefs->{"Location"},
		saves		=> \@saves,
	};
}

1;
