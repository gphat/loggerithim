package Loggerithim::Page::manipgroupuser;
use strict;

use base("Loggerithim::Page");

sub handler {
	my $self	= shift();
	my $stuff	= shift();

	my $parameters	= $stuff->{'parameters'};
	my $r			= $stuff->{'request'};
	my $user		= $stuff->{'user'};

	if($parameters->{'submitter'}) {
		unless(Loggerithim::Util::Permission->check($user, "Group", "write")) {
			return { NORIGHTS => 1 };
		}
		my $group = Loggerithim::Group->retrieve($parameters->{'groupid'});
		$group->addUser(Loggerithim::User->retrieve($parameters->{'userid'}));

		return {REDIRECT => "admin.phtml"};
	} elsif(($parameters->{'action'} eq "list") and ($parameters->{'groupid'})) {
		unless(Loggerithim::Util::Permission->check($user, "Group", "read")) {
			return { NORIGHTS => 1 };
		}
		my $group = Loggerithim::Group->retrieve($parameters->{'groupid'});

		my @users;
		my $guIter = $group->groupusers();
		while(my $guser = $guIter->next()) {
			push(@users, {
				groupuserid	=> $guser->id(),
				username	=> $guser->user()->username(),
				fullname	=> $guser->user()->fullname()
			});
		}
		return {
			title			=> 'List Group Members',
			groupuserlist	=> 1,
			users			=> \@users,
		};
	} else {
		unless(Loggerithim::Util::Permission->check($user, "Group", "write")) {
			return { NORIGHTS => 1 };
		}
		my @users;
		my $uIter = Loggerithim::User->retrieve_all();
		while($user = $uIter->next()) {
			push(@users, {
				id			=> $user->id(),
				fullename	=> $user->fullname(),
				username	=> $user->username()
			});
		}
		return {
			title		=> 'Add Member to Group',
			groupid		=> $parameters->{'groupid'},
			users		=> \@users,
		}
	}
}

1;
