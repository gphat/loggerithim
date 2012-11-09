package Loggerithim::Reporter;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table("reporters");
__PACKAGE__->columns(Primary => qw(reporterid));
__PACKAGE__->columns(Essential => qw(name description));
__PACKAGE__->columns(Stringify => qw(name));
__PACKAGE__->sequence('reporters_reporterid_seq');
