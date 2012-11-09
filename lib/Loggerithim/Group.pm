package Loggerithim::Group;
use strict;

use Loggerithim::Database;

use base 'Loggerithim::DBI';

__PACKAGE__->table('groups');
__PACKAGE__->columns(Primary => qw(groupid));
__PACKAGE__->columns(Essential => qw(name departmentid systemid));
__PACKAGE__->columns(Stringify => qw(name));
__PACKAGE__->sequence('groups_groupid_seq');
__PACKAGE__->has_a(departmentid => 'Loggerithim::Department');
__PACKAGE__->has_a(systemid => 'Loggerithim::System');
__PACKAGE__->has_many('users' => ['Loggerithim::GroupUser' => 'user']);
__PACKAGE__->has_many('groupusers' => 'Loggerithim::GroupUser');
__PACKAGE__->has_many('objects' =>  ['Loggerithim::GroupObject' =>  'object']);
__PACKAGE__->has_many('groupobjects' =>  'Loggerithim::GroupObject');

sub addUser {
	my $self = shift();
	my $user = shift();

	my $uIter = $self->users();
	while(my $u = $uIter->next()) {
		if($user->id() == $u->id()) {
			return;
		}
	}

	Loggerithim::GroupUser->create({
		user	=> $user,
		group	=> $self
	});
}

sub checkRight {
	my $self	= shift();
	my $object	= shift() or die("Must supply an Object");
	my $action	= shift() or die("Must supply an Action");
	my $dept	= shift();
	my $sys		= shift();

	if(($action ne "read") and ($action ne "write") and ($action ne "remove")) {
		if(defined($self->department()) and ($dept->id() != $self->department()->id())) {
			return 0;
		}
	}

	if(defined($sys)) {
		if(defined($self->system()) and ($sys->id() != $self->system()->id())) {
			return 0;
		}
	}

	my $goIter = $self->groupobjects();
	while(my $go = $goIter->next()) {
		if($go->object()->id() == $object->id()) {
			return $go->$action;
		}
	}
	return 0;
}

1;
