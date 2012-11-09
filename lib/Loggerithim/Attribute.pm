package Loggerithim::Attribute;
use strict;

use base 'Loggerithim::DBI';

use URI;

__PACKAGE__->table('attributes');
__PACKAGE__->columns(Primary => qw(attributeid));
__PACKAGE__->columns(Essential => qw(name sigil types hours macros url));
__PACKAGE__->columns(Stringify => qw(name));
__PACKAGE__->sequence('attributes_attributeid_seq');

__PACKAGE__->has_a('url' => 'URI', {
	inflate => sub { URI->new(shift()) },
	deflate => "as_string"
});

1;
