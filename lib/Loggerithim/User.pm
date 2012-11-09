package Loggerithim::User;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table('users');
__PACKAGE__->columns(Primary => qw(userid));
__PACKAGE__->columns(Essential => qw(username password preferences fullname));
__PACKAGE__->columns(Stringify => qw(fullname));
__PACKAGE__->sequence('users_userid_seq');
__PACKAGE__->has_many('groups' => ['Loggerithim::GroupUser' => 'group']);
__PACKAGE__->has_many('contacts' => 'Loggerithim::Contact');
__PACKAGE__->has_many('saves' => 'Loggerithim::Save');

sub getPreferences {
	my $self = shift();
	my $userprefs;
	my @prefs = split(/,/, $self->preferences());
	foreach my $preference (@prefs) {
		my ($name, $val) = split(/=/, $preference);
		$userprefs->{$name} = $val;
	}
	return $userprefs;
}

1;
