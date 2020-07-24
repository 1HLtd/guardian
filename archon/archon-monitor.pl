#!/usr/bin/perl -w -T

use strict;
use warnings;

use Storable qw( freeze thaw );
use POSIX qw(strftime);
use DBD::Pg;
use POSIX ":sys_wait_h";

use lib qw(/usr/local/1h/lib/archon /usr/local/1h/lib/perl);
use Gearman::Client;
use parse_config;
use daemonize;
use database;

my $VERSION = '3.5.3';
our $CONFIGURATION = '/usr/local/1h/etc/archon.conf';
our %config = parse_config($CONFIGURATION);
our @servers = ();
our %downs = ();
our $raped_childs = 0;
our $spawned_childs = 0;

die "LOG file not defined!\n" if ! defined($config{'logfile'});
die "PID file not defined!\n" if ! defined($config{'pidfile'});

$config{'logfile'} = $1 if ($config{'logfile'} =~ m/^(.*)$/);
$config{'pidfile'} = $1 if ($config{'pidfile'} =~ m/^(.*)$/);

if ($config{'debug'} || defined($ARGV[0])) {
	$config{'debug'} = 1;
	printf "Running in DEBUG mode! My pid is: %d\nLogfile: %s \nPidfile: %s\nSleep between waves: %d\n",
		$$, $config{'logfile'}, $config{'pidfile'}, $config{'sleep_between_waves'};
}


become_daemon($config{'pidfile'}, 'Archon-monitor');

sub REAPER {
   my $child;
   while ($child = waitpid(-1,WNOHANG)) {

   }
   $SIG{CHLD} = \&REAPER;  # still loathe sysV
}

$SIG{CHLD} = \&REAPER;

$0='Archon-monitor';
$|=1;

my $client = Gearman::Client->new;
$client->job_servers('127.0.0.1:4730');
$client->dispatch_background('log_me', "Archon-Monitor version $VERSION started");

clear_status(\%config);
init_db(\%config);
update_server_list(\%config, \@servers);
%downs = get_down_ids(\%config);

print "Current list count: ".$#servers."\n" if $config{'debug'};

my $timer = 0;

SERVER:
my $last = 0;
my $prev = 0;
my $start_time = time();

for (my $i=0; $i<=$#servers; $i++) {
	# @servers description:
	# 0 - server id
	# 1 - server name
	# 2 - server ip
	# 3 - server group
	# 4 - disabled services
	my $disabled_svc = 0;
	if (defined($servers[$i][4])) {
		my $service_list = '';
		while (my $k = each (%{$servers[$i][4]})) {
			$service_list .= $k . ' ';
		}
		printf "Calling server %s(%d) ip: %s disabled services: %s\n", $servers[$i][1], $servers[$i][0],
			$servers[$i][2], $service_list if ($config{'debug'});
		$disabled_svc = $servers[$i][4];
	} else {
		printf "Calling server %s(%d) ip: %s disabled services: %s\n", $servers[$i][1], $servers[$i][0],
			$servers[$i][2], 'none' if ($config{'debug'});
	}
	print "Checking server ".$servers[$i][1]."\n" if $config{'debug'};

	# gather_child() parameters:
	# 0 - server id
	# 1 - server ip
	# 2 - server name
	# 3 - down id
	# 4 - disabled services
	my $str;
	if (exists $downs{$servers[$i][0]}) {
		$client->dispatch_background('log_me', "MON: There are known downs for this server") if ($config{'debug'});
		$str = freeze([ $servers[$i][0], $servers[$i][2], $servers[$i][1], $downs{$servers[$i][0]}, $disabled_svc ]);
	} else {
		$client->dispatch_background('log_me', "MON: No downs for this server") if ($config{'debug'});
		$str = freeze([ $servers[$i][0], $servers[$i][2], $servers[$i][1], 0, $disabled_svc ]);
	}

	eval {
		local $SIG{ALRM} = sub { die 'timeout'; };
		alarm(3);

		$client->dispatch_background('log_me', "Gathering childs with from archon monitor") if ($config{'debug'});
		$client->dispatch_background('gather_child', $str);
		alarm(0);
	};
}

sleep($config{'sleep_between_waves'});
%downs = ();
%downs = get_down_ids(\%config);

# Get the new servers each 20 seconds
if ($timer > 2) {
	my %old_srv_ids = ();
	my %new_srv_ids = ();

	print "Current list count: ".$#servers."\n" if ($config{'debug'});
	$client->dispatch_background('log_me', "Current list count: " . $#servers) if ($config{'debug'});

	for (my $i; $i <= $#servers; $i++) {
		$old_srv_ids{$servers[$i][0]} = $servers[$i][1];
		$client->dispatch_background('log_me', "Got old server id $servers[$i][0] with server name  $servers[$i][1]") if ($config{'debug'});
	}

	@servers = ();

	print "before update: ".$#servers."\n" if ($config{'debug'});
	$client->dispatch_background('log_me', "Before update count: " . $#servers) if ($config{'debug'});

	update_server_list(\%config, \@servers);

	for (my $i; $i <= $#servers; $i++) {
		$new_srv_ids{$servers[$i][0]} = $servers[$i][1];
		$client->dispatch_background('log_me', "Got new for server id $servers[$i][0] with server name  $servers[$i][1]") if ($config{'debug'});
	}

	while (my $old_srv_id = each (%old_srv_ids)) {
		if (! defined($new_srv_ids{$old_srv_id})) {
			$client->dispatch_background('log_me', "Old srv id $old_srv_id is missing from the new srv_ids hash. Finishing all downs for it") if ($config{'debug'});
			disabled_end_downs(\%config,$old_srv_id) or $client->dispatch_background('log_me', "disabled_end_downs failed for $old_srv_id");
		}
	}

	print "after update: ".$#servers."\n" if ($config{'debug'});
	$client->dispatch_background('log_me', "After update count: " . $#servers) if ($config{'debug'});

	$client->dispatch_background('log_me', "Zero server count. Nothing to monitor? Count is: " . $#servers) if ($#servers < 0 && $config{'debug'});
	die "Zero server count. Nothing to monitor?\n" if ($#servers < 0 && $config{'debug'});
	$timer = 0;
}

$timer++;
goto SERVER;

# __END__

=head1 NAME

monitor - monitoring and downtime statistics of all servers

=head1 SYNOPSIS

Just run it, it is a daemon

=head1 DESCRIPTION

This tool monitors the status of all servers.
All information gathered by the tool is stored in PgSQL DB.

The schema used for status information is 'monitoring'. The current status is stored in srv_status and svc_status tables.

All downtimes are stored in the 'problems' schema.


=head1 SEE ALSO

archon.conf services.conf

=head1 CHANGELOG

=head2 08.Mar.2010 - Initial release 2.0

=head2 09.Mar.2010 - Version 3.0

=head2 19.Mar.2010 - Version 3.2

    Added init_db
    Changed the debug logging to be more accurate

=head1 AUTHOR

 Marian Marinov <mm@yuhu.biz> (c)
 Project started Mar.2010

=cut
