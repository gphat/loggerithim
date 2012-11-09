package Loggerithim::Medium;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table('mediums');
__PACKAGE__->columns(Primary => qw(mediumid));
__PACKAGE__->columns(Essential => qw(name handler));
__PACKAGE__->columns(Stringify => qw(name));
__PACKAGE__->sequence('mediums_mediumid_seq');
