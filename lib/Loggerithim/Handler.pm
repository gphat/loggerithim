package Loggerithim::Handler;
use strict;

=head1 NAME

Loggerithim::Handler - Apache Request Handler

=head1 DESCRIPTION

The Handler pre-creates all of the 'pages' used by Loggerithim.  It then
waits for a request, parses the request's URI, and if the result is determined
to be a page that is handled by Loggerithim, it calls that object's handler
method.  It stores the result received from the page object, replied with the
Content-Type, stuffs the result into the HTML::Template object, and sends the
output to the client.

=head1 SYNOPSIS

  <VirtualHost *>
    ServerAdmin     you@yourdomain.com
    ServerName      loggerithim.yourdomain.com
    DocumentRoot    /home/httpd/loggerithim/html
    ErrorLog        logs/loggerithim-error_log
    CustomLog       logs/loggerithim-access_log common

    SetHandler      perl-script

    PerlModule      Loggerithim::Handler

    PerlHandler     Loggerithim::Handler

    <FilesMatch "\.phtml$">
        PerlAccessHandler   Loggerithim::Access
    </FilesMatch>

    ErrorDocument   403 http://loggerithim.yourdomain.com/index.phtml
    ErrorDocument   500 http://loggerithim.yourdomain.com/error.phtml
  </VirtualHost>

=cut
use Apache;
use Apache::Constants qw(REDIRECT FORBIDDEN DECLINED OK AUTH_REQUIRED);
use Apache::Cookie;
use Apache::Request;

use File::Find;
use HTML::Template;
use Time::HiRes qw(time);

use Loggerithim::Config;
use Loggerithim::Lists;
use Loggerithim::Log;
use Loggerithim::Session;
use Loggerithim::User;

my $prefix = Loggerithim::Config->fetch("prefix");

# Go to the Page directory and load a list of all the modules inside it.
# This is only done when the module is first loaded.
my @pages = Loggerithim::Handler->getModules("$prefix/loggerithim/lib/Loggerithim/Page");

my $tmpl_dir = "$prefix/loggerithim/templates";

# Empty hash for pre-instantiating pages
my %pageobjs;

# Create each page object and cache it.  Doing this saves us from having to
# create the page at request time.
foreach my $pobj (@pages) {
	require "Loggerithim/Page/$pobj.pm";
	loglog("DEBUG", "Loading $pobj");
	$pageobjs{$pobj} = "Loggerithim::Page::$pobj"->new();
	if(Loggerithim::Config->fetch("caching/template")) {
		if(-e "$tmpl_dir/$pobj.tmpl") {
			HTML::Template->new(
				filename=> "$tmpl_dir/$pobj.tmpl",
				cache	=> 1
			);
		} else {
			loglog("WARNING", "$pobj does not have a template");
		}
	}
}

=head1 METHODS

=head2 Construcor

=over 4

NONE.

=back

=head2 Class Methods

=over 4

NONE.

=back

=head2 Static Methods

=over 4

=item Loggerithim::Handler->handler($r)

Handles the page request.

=cut
sub handler {
	my $ap   = shift();
	my $file= $ap->uri();
	my $page= undef;

	my $name;
	# If the ask for /, give them index
	if($file =~ /\/$/o) {
		if($file =~ /\/(\S+)\/$/o) {
			$name = "$1/index";
		} else {
			$name = "index";
		}
	} elsif($file =~ /^\/(\S*)\.phtml$/o) {
		$name = $1;
	}

	# If we have that page...
	if($page = $pageobjs{$name}) {
		# Store the incoming parameters
		my $req = Apache::Request->new($ap);
		my %parameters;
		foreach my $key ($req->param()) {
			my @values = $req->param($key);
			$parameters{$key} = @values == 1 ? $values[0] : \@values;
		}

		# Call the page, passing it the Apache::Request object, and the 
		# parameters.
		my $t_args;
        my $diff;
		my $user;

		my $session = Loggerithim::Session->existingSession($req);
		if(defined($session)) {
			$user = Loggerithim::User->retrieve($session->get("userid"));
		}
		my $start = Time::HiRes::time();
		$t_args = $page->handler({
			apache		=> $ap,
			request		=> $req,
			parameters	=> \%parameters,
			user		=> $user,
		});
		$diff = sprintf("%.3f", Time::HiRes::time() - $start);

        if(defined(Loggerithim::Config->fetch("debug"))) {
            loglog("DEBUG", "Spent $diff seconds in $name page handler.");
        }

		if($t_args->{'ERROR'}) {
			$name = "error";
			loglog("ERR", $t_args->{'ERROR'});
		}
		if($t_args->{'NORIGHTS'}) {
			$name = "error";
			$t_args->{'ERROR'} = "You do not have the privileges to perform this action.";
		}

        # Some of our pages give us images, not HTML::Template content.
        if($t_args->{'IMAGE'}) {
		    $ap->send_http_header("image/png");
			print $t_args->{'IMAGE'};
            return OK;
        }

		# Add the departmental menu
		my @dmenu;

		if(Loggerithim::Config->fetch("caching/object")) {
			my $cache = Loggerithim::Cache->fetch("DepartmentMenu", 0);
			if(defined($cache)) {
				@dmenu = @{ $cache };
			}
		}

		unless(exists($dmenu[0])) {
			my %seen;
			my $hIter = Loggerithim::Host->search('active' => 1);
			while(my $host = $hIter->next()) {
				$seen{$host->department()->name()}->{$host->system()->id()} = {
					departmentid	=> $host->department()->id(),
					systemid		=> $host->system()->id(),
					systemname		=> $host->system()->name()
				};
			}
			foreach my $k (keys(%seen)) {
				my @systems;
				foreach my $sk (keys(%{ $seen{$k} })) {
					push(@systems, $seen{$k}->{$sk});
				}
				
				push(@dmenu, {
					name 	=> $k,
					systems	=> \@systems,
				});
			}
			if(Loggerithim::Config->fetch("caching/object")) {
				Loggerithim::Cache->store("DepartmentMenu", 0);
			}
		}
		
		$t_args->{'department_menu'} = \@dmenu;
	
		# Add user saves
		if(defined($user)) {
			my @saves;
			my $sIter = $user->saves();
			while(my $save = $sIter->next()) {
				push(@saves, {
					page	=> $save->page(),
					params	=> $save->params(),
					name	=> $save->name()
				});
			}
			$t_args->{'saves'} = \@saves;
		}
		
		# If they asked us to set up a cookie, do it now.
		if($t_args->{'COOKIE'}) {
			my $cookie = Apache::Cookie->new($ap,
				-name => 'LoggerTicket',
				-value => $t_args->{'COOKIE'},
				-expires => '+180d',
			);
			$cookie->bake();
		}

		# Some pages ask to NOT be cached by the client, and Apache's method
		# seems to work much better than page pragma.
		if($t_args->{'NOCACHE'}) {
			$ap->no_cache(1);
		}

		# Sometimes we redirect without telling the client.
		# We're so sneaky... teeheehee
		if($t_args->{'INT_REDIRECT'}) {
			$ap->internal_redirect($t_args->{'REDIRECT'});
			return OK;
		}

		# Other times we tell them...
		if($t_args->{'REDIRECT'}) {
			$ap->header_out(Location => $t_args->{'REDIRECT'});
			return REDIRECT;
		}

		# Create a new Template
		my $template = HTML::Template->new(
			filename			=> "$tmpl_dir/$name.tmpl",
			global_vars			=> 1,
			loop_context_vars	=> 1,
			die_on_bad_params 	=> 0,
			cache				=> Loggerithim::Config->fetch("caching/template"), 
		);
		# Give the template the output from our page object.
		$template->param($t_args);
		# Set the content type.
		$ap->send_http_header("text/html");
		# Display the results of the template.
		print $template->output();
	} else {
		return DECLINED;
	}

	return OK;
}

=item Loggerithim::Handler->getModules($dir)

=item Loggerithim::Handler->getModules($dir, $parent)

Fetch all page objects from the specified directory.

=cut
sub getModules {
	my $self	= shift();
	my $dir		= shift();
	my $parent	= shift();

	my @modules = ();

	opendir(DIR, $dir) || return ();
	my @dirents = grep { !/^\./o } readdir(DIR);
	closedir(DIR);

	foreach my $ent (@dirents) {
		if(-d "$dir/$ent") {
			my @a = Loggerithim::Handler->getModules("$dir/$ent",
				(defined($parent)) ? "$parent/$ent" : "$ent");
			push(@modules, @a);
		}

		if(-f "$dir/$ent" && $ent =~ /^(\w+).pm$/o) {
			push(@modules, (defined($parent)) ? "$parent/$1" : $1);
		}
	}

	return @modules;
}
=back

=head1 AUTHOR

Cory 'G' Watson <gphat@loggerithim.org>

=head1 SEE ALSO

perl(1)

=cut
1;
