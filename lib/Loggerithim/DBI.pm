package Loggerithim::DBI;

use strict;

use base 'Class::DBI';

use Loggerithim::Config;

Loggerithim::DBI->set_db('Main', 'dbi:Pg:dbname=loggerithim', 'loggerithim', Loggerithim::Config->fetch('database/password'), {
	InactiveDestroy => 1,
	AutoCommit		=> 1
});
		
sub accessor_name {
	my ($class, $column) = @_;
	if($column eq "db_sid") {
		return $column;
	}
	$column =~ s/id$//;
	return $column;
}

sub do_transaction {
	my $class = shift();
	my ( $code ) = @_;
	local $class->db_Main->{ AutoCommit };

	eval { $code->() };
	if($@) {
		my $error = $@;
		eval { $class->dbi_rollback };
		die $error;
	}
}

1;
