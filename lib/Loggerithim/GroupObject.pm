package Loggerithim::GroupObject;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table('groupobjects');
__PACKAGE__->columns(Primary => qw(groupobjectid));
__PACKAGE__->columns(Essential => qw(groupid objectid read write remove));
__PACKAGE__->sequence('groupobjects_groupobjectid_seq');
__PACKAGE__->has_a(groupid => 'Loggerithim::Group');
__PACKAGE__->has_a(objectid => 'Loggerithim::Object');
