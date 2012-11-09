#!/usr/bin/perl

use strict;

use lib '/usr/local/loggerithim/lib';

$| = 1;

use IO::Socket;
use Net::SSLeay qw(die_if_ssl_error);
use POSIX qw(:sys_wait_h setsid);
use Proc::Daemon;
use Sys::Syslog;
use Time::HiRes qw(time);
use XML::XPath;

use Loggerithim::Config;
use Loggerithim::Database;
use Loggerithim::Date;
use Loggerithim::Event;
use Loggerithim::Host;
use Loggerithim::Log;
use Loggerithim::Metric;

Net::SSLeay::load_error_strings();
Net::SSLeay::SSLeay_add_ssl_algorithms();
Net::SSLeay::randomize();

my $CHILDEXITED;
my $certpath = Loggerithim::Config->fetch("prefix")."/loggerithim/certificates";
my $servport = Loggerithim::Config->fetch("serverport");
unless(defined($servport)) {
	die("Must specify a serverport in /etc/loggerithim.config.xml!");
}

sub DISSOLVE;
sub REAPER;

$SIG{TERM} = \&DISSOLVE;
$SIG{CHLD} = \&REAPER;

daemonize();

# Create the socket
my $servhandle = IO::Socket::INET->new(
	Proto		=> "tcp",
	LocalPort	=> $servport,
	Listen		=> SOMAXCONN,
	Reuse		=> 1
);
die("Couldn't bind to port $servport: $!") unless $servhandle;

my $ctx = Net::SSLeay::CTX_v3_new() or die("Failed to create SSL_CTX $!");
Net::SSLeay::CTX_set_options($ctx, &Net::SSLeay::OP_ALL) and die_if_ssl_error("ssl ctx set options");

Net::SSLeay::set_verify($ctx, &Net::SSLeay::VERIFY_PEER | &Net::SSLeay::VERIFY_FAIL_IF_NO_PEER_CERT, 0);
Net::SSLeay::CTX_load_verify_locations($ctx, "$certpath/CA.crt", 0);
Net::SSLeay::set_client_CA_list($ctx, Net::SSLeay::load_client_CA_file("$certpath/CA.crt"));

Net::SSLeay::CTX_use_RSAPrivateKey_file($ctx, "$certpath/server.key", &Net::SSLeay::FILETYPE_PEM)
	or die("Error reading private key.");
Net::SSLeay::CTX_use_certificate_file($ctx, "$certpath/server.crt", &Net::SSLeay::FILETYPE_PEM)
	or die("Error reading cerficiate.");

my $message;

# Lewp.
while(1) {
	my $clihandle = $servhandle->accept();
	if($CHILDEXITED) {
		$CHILDEXITED = 0;
		next;
	}
	next if my $pid = fork();
	$servhandle->close();

	my $ip = $clihandle->peerhost();
	my $port = $clihandle->peerport();
	
	syslog("LOG_INFO", "Connect from $ip:$port.");

	my $ssl = Net::SSLeay::new($ctx) or die("SSL_new: $!");
	Net::SSLeay::set_fd($ssl, $clihandle->fileno());

	my $err = Net::SSLeay::accept($ssl) or syslog("LOG_ERR", "Error in accept(): $!");

	my $blank;
	while(1) {
		my $line = Net::SSLeay::ssl_read_CRLF($ssl)
			or exit_and_complain("Error reading from socket, exiting.");

		chop($line);
		chop($line);
		if($line eq "+DONE+") {
			syslog("LOG_DEBUG", "<-- +DONE+");
			last;
		}
		$message .= $line;
		syslog("LOG_DEBUG", "<-- metric");
	}
	
	Net::SSLeay::free($ssl);
	$clihandle->close();

	my $xp = XML::XPath->new(xml => $message);

	my $hostname = getValue($xp, 'host');

	my $host = Loggerithim::Host->search(ip => $ip)->next();

    if(!defined($host)) {
		syslog("LOG_INFO", "I don't know host: $hostname!");
        $host = Loggerithim::Host->search(name => $hostname)->next();
        if(!defined($host)) {
			syslog("LOG_INFO", "Tried to find $hostname by name, no luck.\n");
            my $event = Loggerithim::Event->create({
				timestamp	=> Loggerithim::Date->new(),
            	severity	=> 5,
            	identifier	=> "UNKNOWN HOST: $hostname",
            	message		=> "Failed to find record of host $hostname to commit metrics to."
			});
			exit(0);
		} else {
			syslog("LOG_INFO", "Found $hostname by name.\n");
		}
	}

	syslog("LOG_INFO", "Processing metric from $hostname.");
	my $start = time();

	process_metric($host, $xp);
	$host->last_sampled(Loggerithim::Date->new());
	$host->update();

	my $elapsed = time() - $start;
	syslog("LOG_INFO", "Metric for ".$host->name()." completed in $elapsed seconds.");
	exit();

} continue {
	close(CLIENT);
}

close SERVER;

sub daemonize {
	if(-e "/var/run/loggerserver.pid") {
		die("loggeragent already running? (/var/run/loggeragent.pid).");
	}

	open(PIDFILE, ">/var/run/loggerserver.pid");
	autoflush PIDFILE 1;
	print PIDFILE $$;
	close PIDFILE;

	Proc::Daemon::Init;

	openlog("loggerserver", "cons,pid,ndelay", "LOG_DAEMON");
	syslog("LOG_INFO", "Started");
}

sub process_metric {
	my $host	= shift();
	my $xp		= shift();

	my $thatime = Loggerithim::Date->fromEpoch(getValue($xp, 'timestamp'));

	my $uptime = getValue($xp, 'uptime');
	my $dd = int($uptime / 86400);
	$uptime -= $dd * 86400;
	my $hh = int($uptime / 3600);
	$uptime -= $hh * 3600;
	my $mm = int($uptime / 60);
	$uptime -= $mm * 60;

    my $db = Loggerithim::Database->new();
    my $dbh = $db->connect();

	my $memg = Loggerithim::ResourceGroup->search(name => 'memory')->next();
	my $memory = getValueList($xp, 'avail_swap', 'avail_real', 'buffer_mem', 'cached_mem');
	my $memMetric = Loggerithim::Metric->create({
		resgroup	=> $memg,
		data		=> $memory,
		timestamp	=> $thatime,
		cache		=> 'yes',
		host		=> $host,
		handle		=> $dbh
	});

	my $statg = Loggerithim::ResourceGroup->search(name => 'static')->next();
	my $static = getValueList($xp, 'total_swap', 'total_real');
	$static .= "$dd days $hh:$mm,".getValue($xp, 'system').",".getValue($xp, 'release');
	my $staticMetric = Loggerithim::Metric->create({
		resgroup	=> $statg,
		data		=> $static,
		timestamp	=> $thatime,
		cache		=> 'yes',
		cacheonly	=> 'yes',
		host		=> $host,
		handle		=> $dbh
	});

	my $cpug = Loggerithim::ResourceGroup->search(name => 'cpu')->next();
	my $user = getValue($xp, 'cpu_totals/user') + getValue($xp, 'cpu_totals/nice');
	my $cpu = "$user,".getValueList($xp, 'cpu_totals/sys', 'cpu_totals/idle');
	my $cpuMetric = Loggerithim::Metric->create({
		resgroup	=> $cpug,
		data		=> $cpu,
		timestamp	=> $thatime,
		cache		=> 'yes',
		host		=> $host,
		process		=> 'yes',
		handle		=> $dbh
	});

	my $miscg = Loggerithim::ResourceGroup->search(name => 'misc')->next();
	my $misc = getValueList($xp, 'pages_in', 'pages_out', 'swap_in', 'swap_out');
	my $miscMetric = Loggerithim::Metric->create({
		resgroup	=> $miscg,
		data		=> $misc,
		timestamp	=> $thatime,
		cache		=> 'yes',
		host		=> $host,
		process		=> 'yes',
		handle		=> $dbh
	});

	my $loadg = Loggerithim::ResourceGroup->search(name => 'load')->next();
	my $load = getValueList($xp, 'load/one', 'load/five', 'load/fifteen');
	my $loadMetric = Loggerithim::Metric->create({
		resgroup	=> $loadg,
		data		=> $load,
		timestamp	=> $thatime,
		cache		=> 'yes',
		host		=> $host,
		handle		=> $dbh
	});

	my $storage;
	my $stolist = getNodeList($xp, '/metric/filesystems/filesystem');
	foreach my $sto (@{ $stolist }) {
		if($sto->{'blocks'} == 0) {
			next;
		}
		my $bs = $sto->{'block_size'};
		my $totalk = (($sto->{'blocks'} * $bs) / 1024);
		my $usedk = (($sto->{'blocks'} - $sto->{'blocks_free'}) * $bs) / 1024;
		# HAH!  This variable name is FREEK, like 'freak of nature', and it
		# was totally by accident!  HAH!
		my $freek = ($sto->{'blocks_free'} * $bs) / 1024;
		my $percent = sprintf("%2.f", (($usedk / $totalk) * 100));
		$storage .= $sto->{'mountpoint'}.",$totalk,$usedk,$freek,$percent%,".$sto->{'device'}.":";
	}
	my $stog = Loggerithim::ResourceGroup->search(name => 'storage')->next();
	my $stoMetric = Loggerithim::Metric->create({
		resgroup	=> $stog,
		data		=> $storage,
		timestamp	=> $thatime,
		cache		=> 'yes',
		cacheonly	=> 'yes',
		host		=> $host,
		handle		=> $dbh
	});

	my $interface;
	my $iflist = getNodeList($xp, '/metric/interfaces/interface');
	foreach my $if (@{ $iflist }) {
		if($if->{'device'} eq "lo") {
			next;
		}
		my $kbIn  = sprintf("%.2f", ($if->{'rxbytes'} / 1024));
		my $kbOut = sprintf("%.2f", ($if->{'txbytes'} / 1024));
		$interface .= $if->{'device'}.",$kbIn,$kbOut:";
	}
	my $intg = Loggerithim::ResourceGroup->search(name => 'interfaces')->next();
	my $ifMetric = Loggerithim::Metric->create({
		resgroup	=> $intg,
		data		=> $interface,
		timestamp	=> $thatime,
		cache		=> 'yes',
		host		=> $host,
		process		=> 'yes',
		handle		=> $dbh
	});

    $dbh->commit();
    $dbh->disconnect();

    if(Loggerithim::Config->fetch("debug")) {
	    syslog("LOG_INFO", "Host: ".$host->name().", ".$host->ip());
	    syslog("LOG_INFO", "Memory: $memory");
	    syslog("LOG_INFO", "Static: $static");
	    syslog("LOG_INFO", "CPU: $cpu");
	    syslog("LOG_INFO", "Misc: $misc");
	    syslog("LOG_INFO", "Load: $load");
	    syslog("LOG_INFO", "Storage: $storage");
	    syslog("LOG_INFO", "Interface: $interface");
    }
}

sub exit_and_complain {
	my $message = shift();

	syslog("LOG_ERR", $message);
	exit();
}

sub DISSOLVE {
	syslog("LOG_INFO", "SIGTERM caught, cleaning up and exiting.");
	closelog();
	unlink("/var/run/loggerserver.pid");
	exit();
}

sub REAPER {
	my $pid;
	$CHILDEXITED = 1;

	while(($pid = waitpid(-1, WNOHANG)) > 0) {
		syslog("LOG_INFO", "Reaped child $pid.");
	}

	$SIG{CHLD} = \&REAPER;
}

sub getNodeList {
	my $xp = shift();
	my $path = shift();

	my @nodes;

	my $nodeset = $xp->find($path);

	foreach my $node ($nodeset->get_nodelist()) {
		my %temp;
		my @children = $node->getChildNodes();
		foreach my $child (@children) {
			if($child->getName()) {
				$temp{$child->getName()} = $child->string_value();
			}
		}
		push(@nodes, \%temp);
	}

	return \@nodes;
}

sub getValueList {
	my $xp = shift();
	my @keys = @_;

	my $string;

	foreach my $key (@keys) {
		$string .= getValue($xp, $key).",";
	}

	return $string;
}

sub getValue {
	my $xp = shift();
	my $path = shift();

	my $lit = $xp->getNodeText("metric/$path");
	if(!defined($lit) or ($lit->value() eq "")) {
		return undef;
	} else {
		return $lit->value();
	}
}
