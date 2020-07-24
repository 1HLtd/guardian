#!/usr/bin/perl
package list_services;
use strict;
use warnings;
use Exporter;
our @ISA		= qw(Exporter);
our @EXPORT		= qw(svc_list svc_id svc_from_id);
our $VERSION	= 0.01;

# executes at run-time, unless used as module
__PACKAGE__->main() unless caller;

sub main {
    my $self = shift;
    sub logger { print @_, "\n"; }
	use lib '/root/guardian/modules';
	use parse_config;
	my %services = parse_config("/etc/services.conf");
	svc_list(\%services);
}

sub svc_list {
	my $list_n = shift;
	print "List all services: \n";
	for my $k (sort { $list_n->{$a} <=> $list_n->{$b} } keys %{$list_n}) {
		printf 'Service %s has ID %d'."\n", $k, $list_n->{$k};
	}
}

sub svc_id {
	my $list_n = shift;
	return $list_n->{$_[0]} if defined($list_n->{$_[0]});
	main::logger('Missing service '.$_[0].' from the services module!');
	return 101;
}

sub svc_from_id {
	my $list_n = shift;
	while (my $k = each %{$list_n} ) {
		return $k if ($list_n->{$k} <=> $_[0]);
	}
	return $_[0];
}

1;
