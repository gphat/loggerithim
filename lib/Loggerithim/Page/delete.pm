package Loggerithim::Page::delete;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self 	= shift();
	my $stuff 	= shift();

	my $parameters	= $stuff->{'parameters'};
	my $r			= $stuff->{'request'};
	my $user		= $stuff->{'user'};

	my $message;
	my $id;
	my $back;

	if($parameters->{'events'}) {
		unless(Loggerithim::Util::Permission->check($user, "Event", "write")) {
			return { NORIGHTS => 1 };
		}
		my @events = split(/,/, $parameters->{'events'});
		foreach my $eid (@events) {
			my $event = Loggerithim::Event->retrieve($eid);
			$event->archive();
		}
		$message = "Event moved to Archive!";
		$back = "events.phtml";
	} elsif($parameters->{'profattrid'}) {
		my $pa = Loggerithim::ProfileAttribute->retrieve($parameters->{'profattrid'});
		$pa->delete();
		$message = "Profile Attribute Removed!";
		$back = "admin.phtml";
	} elsif($parameters->{'groupuserid'}) {
		my $gu = Loggerithim::GroupUser->retrieve($parameters->{'groupuserid'});
		$gu->delete();
		$message = "Group Member Removed!";
		$back = "admin.phtml";
	} elsif($parameters->{'annotationid'}) {
		my $annot = Loggerithim::Annotation->retrieve($parameters->{'annotationid'});
		$annot->delete();
		$message = "Annotation Removed!";
		$back = "admin.phtml";
	} elsif($parameters->{'groupid'}) {
		my $group = Loggerithim::Group->retrieve($parameters->{'groupid'});
		$group->delete();
		$message = "Group Removed!";
		$back = "admin.phtml";
	} elsif($parameters->{'profileid'}) {
		my $prof = Loggerithim::Profile->retrieve($parameters->{'profileid'});
		$prof->delete();
		$message = "Profile Removed!";
		$back = "admin.phtml";
	} elsif($parameters->{'saveid'}) {
		my $save = Loggerithim::Save->retrieve($parameters->{'saveid'});
		$save->delete();
		$message = "Save Removed!";
		$back = "admin.phtml";
	} elsif($parameters->{'departmentid'}) {
		my $d = Loggerithim::Department->retrieve($parameters->{'departmentid'});
		$d->delete();
		$message = "Department Removed!";
		$back = "admin.phtml";
	} elsif($parameters->{'systemid'}) {
		my $s = Loggerithim::System->retrieve($parameters->{'systemid'});
		$s->delete();
		$message = "System Removed!";
		$back = "admin.phtml";
	} elsif($parameters->{'reportid'}) {
		my $r = Loggerithim::Report->retrieve($parameters->{'reportid'});
		$r->delete();
		$message = "Report Removed!";
		$back = "admin.phtml";
	} elsif($parameters->{'hostattrid'}) {
		my $ha = Loggerithim::HostAttribute->retrieve($parameters->{'hostattrid'});
		$ha->delete();
		$message = "Host Attribute Removed!";
		$back = "admin.phtml";
	} elsif($parameters->{'attributeid'}) {
		my $a = Loggerithim::Attribute->retrieve($parameters->{'attributeid'});
		$a->delete();
		$message = "Attribute Removed!";
		$back = "admin.phtml";
	} elsif($parameters->{'resourceid'}) {
		my $r = Loggerithim::Resource->retrieve($parameters->{'resourceid'});
		$r->delete();
		$message = "Resource Removed!";
		$back = "admin.phtml";
	} elsif($parameters->{'resgroupid'}) {
		my $rg = Loggerithim::ResourceGroup->retrieve($parameters->{'resgroupid'});
		$rg->delete();
		$message = "Resource Group Removed!";
		$back = "admin.phtml";
	} elsif($parameters->{'jobid'}) {
		my $j = Loggerithim::Job->retrieve($parameters->{'jobid'});
		$j->delete();
		$message = "Job Removed!";
		$back = "admin.phtml";
	} elsif($parameters->{'reporterid'}) {
		my $r = Loggerithim::Reporter->retrieve($parameters->{'reporterid'});
		$r->delete();
		$message = "Reporter Removed!";
		$back = "admin.phtml";
	} elsif($parameters->{'reportid'}) {
		my $r = Loggerithim::Report->retrieve($parameters->{'reportid'});
		$r->delete();
		$message = "Report Removed!";
		$back = "admin.phtml";
	} elsif($parameters->{'sessionid'}) {
		my $db = Loggerithim::Database->new();
		my $dbh = $db->connect();
		my $delsth = $dbh->prepare("DELETE FROM sessions WHERE id=?");
		$delsth->execute($parameters->{'sessionid'});
		$dbh->commit();
		$dbh->disconnect();
		$message = "Session Removed!";
		$back = "admin.phtml";
	} elsif($parameters->{'notificationid'}) {
		my $n = Loggerithim::Notification->retrieve($parameters->{'notificationid'});
		$n->delete();
		$message = "Notification Removed!";
		$back = "admin.phtml";
	} elsif($parameters->{'userid'}) {
		my $u = Loggerithim::User->retrieve($parameters->{'userid'});
		$u->delete();
		$message = "User Removed!";
		$back = "admin.phtml";
	} elsif($parameters->{'contactid'}) {
		my $c = Loggerithim::Contact->retrieve($parameters->{'contactid'});
		$c->delete();
		$message = "Contact removed!";
		$back = "admin.phtml";
	} elsif($parameters->{'smeepletid'}) {
		my $s = Loggerithim::Smeeplet->retrieve($parameters->{'smeepletid'});
		$s->delete();
		$message = "Smeeplet removed!";
		$back = "admin.phtml";
	} elsif($parameters->{'thresholdid'}) {
		my $t = Loggerithim::Threshold->retrieve($parameters->{'thresholdid'});
		$t->delete();
		$message = "Threshold removed!";
		$back = "admin.phtml";
	} else {
		return {
			message	=> "Must supply a thing to Delete!",
			back	=> "main.phtml",
		}
	}

	return {
		title		=> "Delete",
		message		=> $message,
		back		=> $back,
	};
}

1;
