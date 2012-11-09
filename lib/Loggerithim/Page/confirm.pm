package Loggerithim::Page::confirm;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r		    = $stuff->{'request'};

	my $action;
	my $message;

	if($parameters->{'action'} eq "remove") {
		$action		= "remove";
		$message	= "Are you sure you want to remove ";
	}

	my $thing;
	my $back;

	if($parameters->{'ARCHIVE'}) {
		my $events;
		foreach my $param (keys %{ $parameters }) {
			if($param =~ /event-(\d+)/) {
				$events .= "$1,";
			}
		}
		$thing = "delete.phtml?events=$events";
		$message .= "Are you sure you want to archive these events?  This will move each event and all their it's events into archive!";
		$back	= "events.phtml";
	} elsif($parameters->{'SQUELCH'}) {
		my $events;
		foreach my $param (keys %{ $parameters }) {
			if($param =~ /event-(\d+)/) {
				$events .= "$1,";
			}
		}
		$thing	= "act.phtml?events=$events&action=squelch";
		$message .= "Are you sure you want to squelch these events? No more alerts will be sent for them!";
		$back	= "events.phtml";
	} elsif($parameters->{'UNSQUELCH'}) {
		my $events;
		foreach my $param (keys %{ $parameters }) {
			if($param =~ /event-(\d+)/) {
				$events .= "$1,";
			}
		}
		$thing	= "act.phtml?events=$events&action=unsquelch";
		$message .= "Are you sure you want to squelch these events? Alerts will be generated for them!";
		$back	= "events.phtml";
	} elsif(($parameters->{'departmentid'}) and ($action eq "remove")) {
		$thing = "delete.phtml?departmentid=".$parameters->{'departmentid'};
		$message .= "Department ".$parameters->{'departmentid'}."?";
	} elsif(($parameters->{'saveid'}) and ($action eq "remove")) {
		$thing = "delete.phtml?saveid=".$parameters->{'saveid'};
		$message .= "Save ".$parameters->{'saveid'}."?";
	} elsif(($parameters->{'annotationid'}) and ($action eq "remove")) {
		$thing = "delete.phtml?annotationid=".$parameters->{'annotationid'};
		$message .= "Annotation ".$parameters->{'annotationid'}."?";
	} elsif(($parameters->{'groupid'}) and ($action eq "remove")) {
		$thing = "delete.phtml?groupid=".$parameters->{'groupid'};
		$message .= "Group ".$parameters->{'groupid'}."?  This remove any associations with Users or Objects.";
	} elsif(($parameters->{'groupuserid'}) and ($action eq "remove")) {
		$thing = "delete.phtml?groupuserid=".$parameters->{'groupuserid'};
		$message .= "Group Member ".$parameters->{'groupuserid'}."?";
	} elsif(($parameters->{'profattrid'}) and ($action eq "remove")) {
		$thing = "delete.phtml?profattrid=".$parameters->{'profattrid'};
		$message .= "Profile Attribute ".$parameters->{'profattrid'}."?";
	} elsif(($parameters->{'profileid'}) and ($action eq "remove")) {
		$thing = "delete.phtml?profileid=".$parameters->{'profileid'};
		$message .= "Profile ".$parameters->{'profiled'}."?";
	} elsif(($parameters->{'systemid'}) and ($action eq "remove")) {
		$thing = "delete.phtml?systemid=".$parameters->{'systemid'};
		$message .= "System ".$parameters->{'systemid'}."?";
	} elsif(($parameters->{'reportid'}) and ($action eq "remove")) {
		$thing = "delete.phtml?reportid=".$parameters->{'reportid'};
		$message .= "Report ".$parameters->{'reportid'}."?";
	} elsif(($parameters->{'hostattrid'}) and ($action eq "remove")) {
		$thing = "delete.phtml?hostattrid=".$parameters->{'hostattrid'};
		$message .= "Host Attribute ".$parameters->{'hostattrid'}."?";
	} elsif(($parameters->{'attributeid'}) and ($action eq "remove")) {
		$thing = "delete.phtml?attributeid=".$parameters->{'attributeid'};
		$message .= "Attribute ".$parameters->{'attributeid'}."?";
		$back = "admin.phtml";
	} elsif(($parameters->{'resourceid'}) and ($action eq "remove")) {
		$thing = "delete.phtml?resourceid=".$parameters->{'resourceid'};
		$message .= "Resource ".$parameters->{'resourceid'}."?";
		$back = "admin.phtml";
	} elsif(($parameters->{'resgroupid'}) and ($action eq "remove")) {
		$thing = "delete.phtml?resgroupid=".$parameters->{'resgroupid'};
		$message .= "Resource Group ".$parameters->{'resgroupid'}."?";
		$back = "admin.phtml";
	} elsif(($parameters->{'sessionid'}) and ($action eq "remove")) {
		$thing = "delete.phtml?sessionid=".$parameters->{'sessionid'};
		$message .= "Session ".$parameters->{'sessionid'}."? That user will have to log in again.";
		$back = "sessions.phtml";
	} elsif(($parameters->{'jobid'}) and ($action eq "remove")) {
		$thing = "delete.phtml?jobid=".$parameters->{'jobid'};
		$message .= "Job ".$parameters->{'jobid'}."?  This will remove all of it's notifications!";
		$back = "admin.phtml";
	} elsif(($parameters->{'notificationid'}) and ($action eq "remove")) {
		$thing = "delete.phtml?notificationid=".$parameters->{'notificationid'};
		$message .= "this Notification?  This Group will no longer receive messages through this method!";
		$back = "admin.phtml";
	} elsif(($parameters->{'userid'}) and ($action eq "remove")) {
		$thing = "delete.phtml?userid=".$parameters->{'userid'};
		$message .= "User ".$parameters->{'userid'}."? This will remove this user and any contacts associated with it!";
		$back = "admin.phtml";
	} elsif(($parameters->{'contactid'}) and ($action eq "remove")) {
		$thing = "delete.phtml?contactid=".$parameters->{'contactid'};
		$message .= "Contact ".$parameters->{'contactid'}."? This will remove the ability to communicate with this user via this medium!";
		$back = "admin.phtml";
	} elsif(($parameters->{'smeepletid'}) and ($action eq "remove")) {
		$thing = "delete.phtml?smeepletid=".$parameters->{'smeepletid'};
		$message .= "Smeeplet ".$parameters->{'smeepletid'}."? This will remove it's capability!";
		$back = "admin.phtml";
	} elsif(($parameters->{'thresholdid'}) and ($action eq "remove")) {
		$thing = "delete.phtml?thresholdid=".$parameters->{'thresholdid'};
		$message .= "Threshold ".$parameters->{'thresholdid'}."? This will remove it's detection capability!";
		$back = "admin.phtml";
	} elsif(($parameters->{'reporterid'}) and ($action eq "remove")) {
		$thing = "delete.phtml?reporterid=".$parameters->{'reporterid'};
		$message .= "Reporter ".$parameters->{'reporterid'}."? This will remove it's reporting capability!";
		$back = "admin.phtml";
	} else {
		return { ERROR =>  "I don't know how to perform '$action' on the thing you specified." };
	}

	return {
		title		=> "Confirm",
		message		=> $message,
		back		=> $back,
		thing		=> $thing,
	};
}

1;
