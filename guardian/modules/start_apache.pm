#!/usr/bin/perl
use strict;
use warnings;

package apache;
require Exporter;
our @ISA		= qw(Exporter);
our @EXPORT		= qw(start_apache);
our $VERSION	= 0.01;

# executes at run-time, unless used as module
__PACKAGE__->main() unless caller;

sub main {
	my $self = shift;
	use lib '/root/guardian/modules';
	use parse_config;
	sub logger { print @_, "\n"; }
	my %config = ();
	%config = parse_config($conf) if ( -e '/etc/guardian.conf');
	start_apache(\%config);
}

sub start_apache {
	my %config_ref = shift;
	if ($config_ref->{'start_apache'}) {
		main::logger("start_apache commencing") if $config_ref->{'debug'};
		if (system('/usr/local/apache/bin/httpd -T')) {
			main::logger('start_apache :: configuration file error');
			exit;
		}
		main::logger('start_apache :: finished') if $config_ref->{'debug'};
		exit;
	} else {
		main::logger('start_apache :: Disabled!');
	}
}


1;
