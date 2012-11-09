package Loggerithim::GroupUser;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table('groupusers');
__PACKAGE__->columns(Primary => qw(groupuserid));
__PACKAGE__->columns(Essential => qw(groupid userid));
__PACKAGE__->sequence('groupusers_groupuserid_seq');
__PACKAGE__->has_a(groupid => 'Loggerithim::Group');
__PACKAGE__->has_a(userid => 'Loggerithim::User');
