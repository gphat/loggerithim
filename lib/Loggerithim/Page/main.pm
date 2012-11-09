package Loggerithim::Page::main;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self	= shift();
	my $stuff	= shift();

	my $parameters	= $stuff->{'parameters'};
	my $r			= $stuff->{'request'};
	my $user		= $stuff->{'user'};

	my $userprefs = $user->getPreferences();

	# Grab the arguments needed to construct the page.
	my $color	= $userprefs->{'Color'};
	my $deptid	= $userprefs->{'Department'} || 1;
	my $sysid	= $userprefs->{'System'};
	if($parameters->{'department'}) {
		$deptid = $parameters->{'department'};
	}
	if($parameters->{'system'}) {
		$sysid = $parameters->{'system'};
	}

	my $dept= Loggerithim::Department->retrieve($deptid);

	# Get the hosts.
	my @hostlist;
	my $hIter = $dept->hosts();
	while(my $host = $hIter->next()) {
		my @categories;
		my @links;
		if($sysid) {
			unless($sysid == $host->system()->id()) {
				next;
			}
		}
		my $class;
		# TODO Can't this be wrapped up in the Host object?
		if($color) {
			$class = Loggerithim::Sensor->sense($host);
		}
		my $aIter = $host->attributes();
		while(my $attr = $aIter->next()) {
			if(length($attr->url())) {
				my $url = $attr->url()->as_string();
				my $hid = $host->id();
				$url =~ s/!!HOSTID!!/$hid/g;
				my $hip = $host->ip();
				$url =~ s/!!HOSTIP!!/$hip/g;
				push(@links, {
					sigil		=> $attr->sigil(),
					url			=> $url
				});
			} else {
				my @elems;
				if(defined($attr->types())) {
					my @types = split(/,/, $attr->types());
					foreach my $type (@types) {
						push(@elems, {
							type	=> $type
						});
					}
					push(@links, {
						elems	=> \@elems,
						class	=> $class->{$attr->sigil()},
						hours	=> $attr->hours(),
						macros	=> $attr->macros(),
						sigil	=> $attr->sigil(),
					});
				}
			}
		}
	
		push(@hostlist, {
			id			=> $host->id(),
			name		=> $host->name(),
			function	=> $host->purpose(),
			links		=> \@links
		});
	}

	my $sysname;
	if(defined($sysid)) {
		$sysname = Loggerithim::System->retrieve($sysid)->name();
	}
	return {
        refresh         => 90,
		title			=> "Main",
		hostlist		=> \@hostlist,
		department		=> $dept->name(),
		system			=> $sysname,
	};
}

1;
