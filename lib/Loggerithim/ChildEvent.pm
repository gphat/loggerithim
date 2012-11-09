package Loggerithim::ChildEvent;
use strict;

use base 'Loggerithim::DBI';

use Loggerithim::Database;

__PACKAGE__->table('childevents');
__PACKAGE__->columns(Primary => qw(childeventid));
__PACKAGE__->columns(Essential => qw(eventid severity message timestamp));
__PACKAGE__->columns(Stringify => qw(message));
__PACKAGE__->sequence('childevents_childeventid_seq');
__PACKAGE__->has_a(eventid => 'Loggerithim::Event');
__PACKAGE__->has_a(timestamp => 'DateTime',
	inflate => sub { DateTime::Format::Pg->parse_timestamp(shift()) },
	deflate => sub { DateTime::Format::Pg->format_timestamp(shift()) }
);

1;
