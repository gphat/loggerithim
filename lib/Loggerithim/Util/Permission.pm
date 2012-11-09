package Loggerithim::Util::Permission;
use strict;

=head1 NAME

Loggerithim::Util::Permission- Check Permissions

=head1 DESCRIPTION

Checks the specified action against the rights of the specifed User.

=head1 SYNOPSIS

  if(Loggerithim::Util::Permission->check($user, $object, $action)) {
	# They have the right do perform the action on the specified object.
  } else {
	# They DO NOT have the right do perfrom the action on the specified object.
  }

=cut
use Loggerithim::Group;
use Loggerithim::Log;
use Loggerithim::Object;
use Loggerithim::User;

=head1 METHODS

=head2 Constructor

=over 4

NONE.

=back

=head2 Class Methods

=over 4

NONE.

=back

=head2 Static Methods

=over 4

=item Loggerithim::Util::Permission->check($userid, $object, $action)

=item Loggerithim::Util::Permission->check($userid, $object, $action, $departmentid, $systemid)

Check the values against the Thresholds, and return a list of Violations.

=cut
sub check {
	my $self	= shift();
	my $user	= shift();
	my $object	= shift();
	my $action	= shift();
	my $dept	= shift();
	my $sys		= shift();

	my $obj = Loggerithim::Object->search(name => $object)->next();
	if(!defined($obj)) {
		loglog("ERR", "Object '$object' does not exist to check it's permissions.");
		return 0;
	}

	my $gIter = $user->groups();
	while(my $group = $gIter->next()) {
		loglog("DEBUG", "Checking rights for user ".$user->fullname().", object ".$obj->name().", group ".$group->name().", and $action");
		if($group->checkRight($obj, $action, $dept, $sys)) {
			loglog("DEBUG", "Returning OK");
			return 1;
		}
	}
	
	return 0;
}

=back

=head2 Static Methods

=over 4

NONE.

=back

=head1 AUTHOR

Cory 'G' Watson <gphat@loggerithim.org>

=head1 SEE ALSO

perl(1), Loggerithim::User

=cut
1;
