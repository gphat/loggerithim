package Loggerithim::Page::chartmunkey;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r			= $stuff->{'request'};
	my $user		= $stuff->{'user'};

	my $preferences = $user->getPreferences();

	my $mult = $parameters->{'mults'};
	if($mult < 1) {
		$mult = 1;
	}

	my @multis = Loggerithim::Lists->units($mult);

	if($parameters->{'advanced'}) {
		my $elements;
		my $count = 0;
		while(defined($parameters->{"host$count"})) {
			my $rescount = 0;
			while(defined($parameters->{"resource$count-$rescount"})) {
				if((!($parameters->{"remove$count-$rescount"} eq "on")) and (!($parameters->{"host$count"} == 0))) {
					my $res = Loggerithim::Resource->retrieve($parameters->{"resource$count-$rescount"});
					my $elemstr = $parameters->{"host$count"};
					$elemstr .= ":";
					$elemstr .= $res->name();
					$elemstr .= ":";
					$elemstr .= $parameters->{"key$count-$rescount"};
					$elemstr .= ":";
					if($parameters->{"axis$count-$rescount"}) {
						$elemstr .= $parameters->{"axis$count-$rescount"};
					}
					$elemstr .= ":";
					my $s;
					my $e;
					if($parameters->{"start$count-$rescount"}) {
						if(defined($parameters->{"end$count-$rescount"})) {
							$s = $parameters->{"start$count-$rescount"};
							$e = $parameters->{"end$count-$rescount"};
							$s =~ s/\:/-/go;
							$e =~ s/\:/-/go;
							$elemstr .= "$s\:$e";
						}
					}
					$elements .= "$elemstr,";	
				}
				$rescount++;
			}
			$count++;
		}
		chop($elements);
		if($parameters->{'savename'}) {
			my $savename = $parameters->{'savename'};
			$savename =~ tr/,//d;
			my $params = "elems=$elements&amp;";
			$params .= "charttype=".$parameters->{'charttype'}."&amp;";
			$params .= "max=".$parameters->{'max'}."&amp;";
			$params .= "hours=".$parameters->{'hours'}."&amp;";
			$params .= "mults=".$parameters->{'mults'}."&amp;";
			$params .= "mult=".$parameters->{'mult'}."&amp;";
			$params .= "height=".$parameters->{'height'}."&amp;";
			$params .= "width=".$parameters->{'width'}."&amp;";
			$params .= "legend=".$parameters->{'legend'}."&amp;";
			$params .= "xlabels=".$parameters->{'xlabels'}."&amp;";
			Loggerithim::Save->create({
				name	=> $savename,
				userid	=> $user,
				page	=> "chartmunkey.phtml",
				params	=> $params
			});
		}
		$parameters->{'elems'} = $elements;
	}

	my @elems = split(/,/, $parameters->{'elems'});

	my %hostlist;
	my @hosts;
	my $lastid = undef;
	my @reslines;
	my $count = 0;
	my $rescount = 0;


	foreach my $e (@elems) {
		my @parts = split(/:/, $e);

		my $hostid	= $parts[0];
		my $res		= $parts[1];
		my $key		= $parts[2];
		my $axis	= $parts[3];
		my $start	= $parts[4];
		my $end		= $parts[5];

		my $testcount = 0;
		if(defined($hostlist{$hostid})) {
			my @testhost = @{ $hostlist{$hostid} };
			if($#testhost != -1) {
				$testcount = $#testhost + 1;
			}
		}
			
		my ($sd, $st) = split(/ /, $start);
		my ($ed, $et) = split(/ /, $end);
		$st =~ s/-/\:/go;
		$et =~ s/-/\:/go;
		$start = "$sd $st";
		$end = "$ed $et";

		my @resources;
		my $rIter = Loggerithim::Resource->retrieve_all();
		while(my $r = $rIter->next()) {
			my $selected = 1 unless $r->name() ne $res;
			push(@resources, {
				id	=> $r->id(),
				name=> $r->name(),
				selected => $selected,
			});
		}
		
		push(@{ $hostlist{$hostid} }, {
			resources	=> \@resources,
			key			=> $key,
			rescount	=> $testcount,
			axis		=> $axis,
			start		=> $start,
			end			=> $end
		});
	}

	my $hcount = 0;
	foreach my $hid (keys %hostlist) {

		my @hlist;
		my $hIter = Loggerithim::Host->retrieve_all();
		while(my $host = $hIter->next()) {
			my $selected = 1 unless $host->id() != $hid;
			push(@hlist, {
				id			=> $host->id(),
				name		=> $host->name(),
				selected	=> $selected
			});
		}
	
		push(@hosts, {
			hlist		=> \@hlist,
			reslines	=> $hostlist{$hid},
			count		=> $hcount,
		});
		$hcount++;
	}
	my $filled = 0;
	if($parameters->{"charttype"} eq "filled") {
		$filled = 1;
	}
	my @charttypes = (
		{
			type		=> "line",
			name		=> "Line",
		},
		{
			type		=> "filled",
			name		=> "Filled",
			selected	=> $filled,
		}
	);

	if(($parameters->{'legend'} eq "On") or !defined($parameters->{'legend'})) {
		$parameters->{'legend'} = 1;
	} else {
		$parameters->{'legend'} = 0;
	}
	my @legendstates = (
		{
			type	=> "Off",
			name	=> "Off",
		},
		{
			type	=> "On",
			name	=> "On",
			selected=> $parameters->{'legend'}
		}
	);

	if(($parameters->{'xlabels'} eq "On") or !defined($parameters->{'xlabels'})) {
		$parameters->{'xlabels'} = 1;
	} else {
		$parameters->{'xlabels'} = 0;
	}
	my @xlabelsstates = (
		{
			type	=> "Off",
			name	=> "Off",
		},
		{
			type	=> "On",
			name	=> "On",
			selected=> $parameters->{'xlabels'}
		}
	);

	my @hlist;
	my $hIter = Loggerithim::Host->retrieve_all();
	while(my $host = $hIter->next()) {
		push(@hlist, {
			id			=> $host->id(),
			name		=> $host->name(),
		});
	}
	unshift(@hlist, {
		id		=> undef,
		name	=> "None",
	});

	my @resources;
	my $rIter = Loggerithim::Resource->retrieve_all();
	while(my $res = $rIter->next()) {
		push(@resources, {
			id	=> $res->id(),
			name=> $res->name(),
		});
	}

	my @extra;
	push(@extra, {
		resources	=> \@resources,
	});
	push(@hosts, {
		hlist 		=> \@hlist,
		reslines	=> \@extra,
		count		=> $hcount
	});
	my $flathours = $parameters->{'hours'} * $parameters->{'mults'};
	if(!$flathours) {
		$flathours = 24;
	}

	return {
		title		=> "Graph",
		charttype	=> $parameters->{'charttype'},
        max         => $parameters->{'max'},
		hours		=> $parameters->{'hours'},
		flathours	=> $flathours,
		mults		=> \@multis,
        mult        => $parameters->{'mults'},
		elems		=> $parameters->{'elems'},
		hosts		=> \@hosts,
		charttypes	=> \@charttypes,
		height		=> $parameters->{'height'},
		width		=> $parameters->{'width'},
		legend		=> $parameters->{'legend'},
		legendstates=> \@legendstates,
		xlabels		=> $parameters->{'xlabels'},
		xlabelsstates=> \@xlabelsstates,
	};
}

1;
