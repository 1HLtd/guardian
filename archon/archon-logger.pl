#!/usr/bin/perl

use warnings;
use strict;

use POSIX qw(strftime);

use lib qw(/usr/local/1h/lib/archon /usr/local/1h/lib/perl);
use Gearman::Worker;
use daemonize;
use parse_config;

my $VERSION = '0.0.3';
my $config_file = '/usr/local/1h/etc/archon.conf';
our %config = parse_config($config_file);

die "Missing logfile var from config\n" if ! defined($config{'logfile'});

become_daemon;

sub RELOAD_CONFIG {
        %config = parse_config($config_file);
        $SIG{HUP} = \&RELOAD_CONFIG;
}
$SIG{HUP}  = \&RELOAD_CONFIG;
$0 = 'Archon-logger';
$|=1;

open LOG, '>>', $config{'logfile'};
select((select(LOG), $| = 1)[0]);

my $logger = sub {
	print LOG strftime('%b %d %H:%M:%S', localtime(time)) . ' ' . ${${$_[0]}[2]} ."\n";
};

my $w = Gearman::Worker->new;
$w->job_servers('127.0.0.1:4730');
$w->register_function( log_me => $logger );
$w->work while 1;
