package Loggerithim::Department;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table('departments');
__PACKAGE__->columns(Primary => qw(departmentid));
__PACKAGE__->columns(Essential => qw(name));
__PACKAGE__->columns(Stringify => qw(name));
__PACKAGE__->sequence('departments_departmentid_seq');
__PACKAGE__->has_many('hosts' => 'Loggerithim::Host');

1;
