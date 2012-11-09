package Loggerithim::Annotation;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table('annotations');
__PACKAGE__->columns(Primary => qw(annotationid));
__PACKAGE__->columns(Essential => qw(systemid timestamp sigil comment));
__PACKAGE__->columns(Stringify => qw(comment));
__PACKAGE__->sequence('annotations_annotationid_seq');
__PACKAGE__->has_a(systemid => 'Loggerithim::System');
__PACKAGE__->has_a(timestamp => 'DateTime',
	inflate	=> sub { DateTime::Format::Pg->parse_timestamptz(shift()) }, 
	deflate	=> sub { DateTime::Format::Pg->format_timestamptz(shift()) }, 
);

__PACKAGE__->set_sql('annotationsBetween' => qq{
	SELECT annotationid FROM annotations
	WHERE systemid=? AND timestamp BETWEEN ? AND ?
});

1;
