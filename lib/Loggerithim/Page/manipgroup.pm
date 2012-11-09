package Loggerithim::Page::manipgroup;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r			= $stuff->{'request'};
	my $user		= $stuff->{'user'};

	if($parameters->{'submitter'}) {
		unless(Loggerithim::Util::Permission->check($user, "Group", "write")) {
			return { NORIGHTS => 1 }
		}
		if($parameters->{'groupid'}) {
			my $group = Loggerithim::Group->new($parameters->{'groupid'});
			$group->name($parameters->{'name'});
			$group->department(Loggerithim::Department->retrieve($parameters->{'departmentid'}));
			$group->system(Loggerithim::System->retrieve($parameters->{'systemid'}));
			$group->update();
		} else {
			Loggerithim::Group->create({
				name		=> $parameters->{'name'},
				system		=> Loggerithim::System->retrieve($parameters->{'systemid'}),
				department	=> Loggerithim::System->retrieve($parameters->{'systemid'}),
			});
		}

		if($parameters->{'groupid'}) {
			my @objects = Loggerithim::Object->list();
			my $group = Loggerithim::Group->new($parameters->{'groupid'});
			foreach my $obj (@objects) {
				my $test = 0;
				$parameters->{$obj->{'id'}."_read"} eq "" or $test = 1;
				$parameters->{$obj->{'id'}."_write"} eq "" or $test = 1;
				$parameters->{$obj->{'id'}."_remove"} eq "" or $test = 1;
				if($test) {
					my $read = 0;
					my $write = 0;
					my $remove = 0;
					if($parameters->{$obj->{'id'}."_read"}) {
						$read = 1;
					}
					if($parameters->{$obj->{'id'}."_write"}) {
						$write = 1;
					}
					if($parameters->{$obj->{'id'}."_remove"}) {
						$remove = 1;
					}
					$group->addObject($obj->{'id'}, $read, $write, $remove);
				}
			}
		}
		
		return {REDIRECT => "admin.phtml"};
	} elsif($parameters->{'action'} eq "list") {
		unless(Loggerithim::Util::Permission->check($user, "Group", "read")) {
			return { NORIGHTS => 1 }
		}
		my @groups;
		my $gIter = Loggerithim::Group->retrieve_all();
		while(my $grp = $gIter->next()) {
			push(@groups, {
				id	=> $grp->id(),
				name=> $grp->name()
			});
		}
		return {
			title		=> 'Group Listing',
			grouplist	=> 1,
			groups		=> \@groups,
		};
	} elsif($parameters->{'groupid'}) {
		unless(Loggerithim::Util::Permission->check($user, "Group", "read")) {
			return { NORIGHTS => 1 }
		}
		my $group = Loggerithim::Group->new($parameters->{'groupid'});

		# A Special Case!
		# Normally we return values in a box like so:
		# return {
		#	name	=> value,
		# };
		# But in this case we need to populate a long list of dynamic
		# variables, so we'll be returning a hashref.
		my @objects = Loggerithim::Object->list();
		my $returns;
		$returns->{'title'}		= "Manipulate Group";
		$returns->{'name'}		= $group->name();
		$returns->{'groupid'}	= $parameters->{'groupid'};

		my $goIter = $group->groupobjects();
		while(my $go = $goIter->next()) {
			push(@objects, {
				if			=> $go->id(),
				name		=> $go->object()->name(),
				read_on		=> $go->read(),
				write_on	=> $go->write(),
				remove_on	=> $go->revove(),
			});
		}
		$returns->{'objects'}	= \@objects;

		my @departments;
		my $dIter = Loggerithim::Department->retrieve_all();
		while(my $dept = $dIter->next()) {
			my $selected = 1 unless $dept->id() != $group->department()->id();
			push(@departments, {
				id	=> $dept->id(),
				name=> $dept->name(),
			});
		}

		my @systems;
		my $sIter = Loggerithim::System->retrieve_all();
		while(my $sys = $sIter->next()) {
			my $selected = 1 unless $sys->id() != $group->system()->id();
			push(@systems, {
				id	=> $sys->id(),
				name=> $sys->name(),
			});
		}

		$returns->{'departments'} = \@departments;
		$returns->{'systems'} = \@systems;

		return $returns;
	}

	unless(Loggerithim::Util::Permission->check($user, "Group", "write")) {
		return { NORIGHTS => 1 }
	}

	my @departments;
	my $dIter = Loggerithim::Department->retrieve_all();
	while(my $dept = $dIter->next()) {
		push(@departments, {
			id	=> $dept->id(),
			name=> $dept->name(),
		});
	}

	my @systems;
	my $sIter = Loggerithim::System->retrieve_all();
	while(my $sys = $sIter->next()) {
		push(@systems, {
			id	=> $sys->id(),
			name=> $sys->name(),
		});
	}

	return {
		title		=> "Manipulate Group",
		departments	=> \@departments,
		systems		=> \@systems,
	};
}

1;
