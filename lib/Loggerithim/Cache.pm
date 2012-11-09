package Loggerithim::Cache;
use strict;

=head1 NAME

Loggerithim::Cache - Caching of Objects

=head1 DESCRIPTION

The Cache stores Loggerithim objects in a file based cache.  Objects can be
stored, fetched, and removed.  Currently, only some objects are cached.
This includes the Resource object, as it is accessed frequently during some
operations.

=head1 SYNOPSIS

  my $cachedobject = Loggerithim::Cache->fetch("SomeObject", $objectsID);

=cut

use base qw(Apache::Singleton);

use Cache::Cache qw($EXPIRES_NEVER $EXPIRES_NOW);
use Cache::FileCache;

use Loggerithim::Config;
use Loggerithim::Log;

=head1 METHODS

=head2 Constructor

=over 4

NONE.

=back

=cut

my $cache = new Cache::FileCache({
	'namespace'			=> 'Loggerithim',
	'cache_root'		=> Loggerithim::Config->fetch("cache_root"),
});

=head2 Class Methods

=over 4

NONE.

=back

=head2 Static Methods

=over 4

=item Loggerithim::Cache->store($name, $key, $payload)

Store an object in the cache.

=cut
sub store {
	my $self	= shift();
	my $name	= shift();
	my $key		= shift();
	my $payload	= shift();

    loglog("DEBUG", "Storing $name$key in the cache.");
	$cache->set("$name$key", $payload);
}

=item Loggerithim::Cache->fetch($name, $key)

Fetch an object from the cache.

=cut
sub fetch {
	my $self	= shift();
	my $name	= shift();
	my $key		= shift();

	my $object;
	my $requests = $cache->get("Requests");
	if(!defined($requests)) {
		$requests = 0;
	}
	$cache->set("Requests", ++$requests, $EXPIRES_NEVER);
	loglog("DEBUG", "Fetching $name$key from cache.");

	$object = $cache->get("$name$key");
	if(defined($object)) {
		my $hits = $cache->get("Hits");
		if(!defined($hits)) {
			$hits = 0;
		}
 		loglog("DEBUG", "Fetched $name$key successfully.");
		$cache->set("Hits", ++$hits, $EXPIRES_NEVER);
		return $object;
	} else {
		loglog("DEBUG", "$name$key not found.");
		return undef;
	}
}

=item Loggerithim::Cache->remove($name, $key)

Remove an object from the cache.

=cut
sub remove {
	my $self 	= shift();
	my $name	= shift();
	my $key		= shift();

    loglog("DEBUG", "Removing $name$key from cache.");
	$cache->set("$name$key", undef, $EXPIRES_NOW);

	my $removes = $cache->get("Removes");
	$cache->set("Removes", ++$removes, $EXPIRES_NEVER);
}

=item Loggerithim::Cache->hitRate()

Returns the current hit-rate of the cache.

=cut
sub hitRate {
	my $self	= shift();

	my $requests= $cache->get("Requests");
	my $hits 	= $cache->get("Hits");
	if($requests > 0) {
		return sprintf("%.2f", ($hits / $requests) * 100);
	} else {
		return 0;
	}
}

=item Loggerithim::Cache->cache()

Returns the Cache::Cache object used.

=cut
sub cache {
	return $cache;
}

=back

=head1 AUTHOR

Cory 'G' Watson <gphat@loggerithim.org>

=head1 SEE ALSO

perl(1)

=cut
1;
