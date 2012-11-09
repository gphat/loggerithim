package Loggerithim::ResourceGroup;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table("resgroups");
__PACKAGE__->columns(Primary => qw(resgroupid));
__PACKAGE__->columns(Essential => qw(name custom keyed));
__PACKAGE__->columns(Stringify => qw(name));
__PACKAGE__->sequence('resourcegroups_resgroupid_seq');

__PACKAGE__->has_many('resources' => 'Loggerithim::Resource');

1;
