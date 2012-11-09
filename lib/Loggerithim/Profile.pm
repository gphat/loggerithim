package Loggerithim::Profile;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table('profiles');
__PACKAGE__->columns(Primary => qw(profileid));
__PACKAGE__->columns(Essential => qw(name));
__PACKAGE__->columns(Stringify => qw(name));
__PACKAGE__->sequence('profiles_profileid_seq');
__PACKAGE__->has_many('attributes' => ['Loggerithim::ProfileAttribute' => 'attribute']);
__PACKAGE__->has_many('profileAttributes' => 'Loggerithim::ProfileAttribute');
