package Loggerithim::Page::hostinfo;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r		    = $stuff->{'request'};

	my $host = Loggerithim::Host->retrieve($parameters->{'hostid'});
	my $dept = $host->department();

	my @hostlist;
	
	my $metric_data;
	
	my @storage;
	my @interfaces;

	my $cmIter = $host->cachedMetrics();
	while(my $cm = $cmIter->next()) {
		my $rg = $cm->resgroup();
		$metric_data->{$rg->name()} = Loggerithim::Parsers->genParse($rg, $cm->data());
	}

	my $memory	= $metric_data->{'memory'};
	my $cpu		= $metric_data->{'cpu'};
	my $static	= $metric_data->{'static'};
	my $load	= $metric_data->{'load'};
	my $misc	= $metric_data->{'misc'};
	my $storage	= $metric_data->{'storage'};
	my $interfaces	= $metric_data->{'interfaces'};

	foreach my $sto (keys %{$storage}) {
		push(@storage, $storage->{$sto});
	}

	foreach my $int (keys %{$interfaces}) {
		push(@interfaces, $interfaces->{$int});
	}

	$metric_data->{'memPercent'} = sprintf("%02d", ((($memory->{'memAvailReal'} + $memory->{'memCached'})/ $static->{'memTotalReal'}) * 100));
	$metric_data->{'swapPercent'} = sprintf("%02d", (($memory->{'memAvailSwap'} / $static->{'memTotalSwap'}) * 100));

	return {
		title		=> "Host Information",
		hostid		=> $host->id(),
		lastsampled	=> $host->last_sampled(),
		department	=> $dept->name(),
		hostname	=> $host->name(),
		hostos		=> $static->{'sysOS'},
		hostosver	=> $static->{'sysOSVer'},
		hostip		=> $host->ip(),
		hostpurpose	=> $host->purpose(),
		uptime		=> $static->{'sysUptime'},
		swapAvail	=> $memory->{'memAvailSwap'},
		swapTotal	=> $static->{'memTotalSwap'},
		memAvail	=> $memory->{'memAvailReal'},
		memTotal	=> $static->{'memTotalReal'},
		swapPercent	=> $metric_data->{'swapPercent'},
		memPercent	=> $metric_data->{'memPercent'},
		buffered	=> $memory->{'memBuffered'},
		cached		=> $memory->{'memCached'},
		cpuUser		=> $cpu->{'cpuUser'},
		cpuIdle		=> $cpu->{'cpuIdle'},
		cpuSystem	=> $cpu->{'cpuSys'},
		swapIn		=> $misc->{'miscSwapIn'},
		swapOut		=> $misc->{'miscSwapOut'},
		pagesIn		=> $misc->{'miscPagesIn'},
		pagesOut	=> $misc->{'miscPagesOut'},
		load1		=> $load->{'loaLoad1'},
		load2		=> $load->{'loaLoad2'},
		load3		=> $load->{'loaLoad3'},
		storage		=> \@storage,
		interfaces	=> \@interfaces,
	};
}

1;
