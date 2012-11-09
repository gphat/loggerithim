package Loggerithim::Object;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table('objects');
__PACKAGE__->columns(Primary => qw(objectid));
__PACKAGE__->columns(Essential => qw(name));
__PACKAGE__->columns(Stringify => qw(name));
__PACKAGE__->sequence('objects_objectid_seq');
