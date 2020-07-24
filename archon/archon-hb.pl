#!/usr/bin/perl

use strict;
use warnings;

use IO::Socket::INET;

use lib qw(/usr/local/1h/lib/archon /usr/local/1h/lib/perl);
use parse_config;

my $VERSION = '0.2.1';

our $CONFIGURATION = '/usr/local/1h/etc/archon.conf';
our %config = parse_config($CONFIGURATION);

my @workers = (
	'/usr/local/1h/sbin/archon-gather.pl',
	'/usr/local/1h/sbin/archon-dbwork.pl',
	'/usr/local/1h/sbin/archon-logger.pl'
);

my $max_gather = $config{'max_gather_workers'};
my $max_db = $config{'max_db_workers'};
my $max_loggers = 5;
my $fork_step = $config{'fork_step'};

sub run_childs {
	my $count = shift;
	my $worker = shift;

	print "run_childs has been called for $workers[$worker]. We need to start $count new workers.\n";

	for (my $i=1; $i <= $count; $i++) {
		if (system($workers[$worker])) {
			print "Failed to start $workers[$worker] number $i.\n";
		} else {
			print "$workers[$worker] number $i has been successfully started.\n";
		}
	}
}

sub get_step {
	my $queue = shift;
	my $workers = shift;
	my $max = shift;
	my $step = 0;
	my $inc_percent = 0;
	my $queue_percent = ($queue / $workers) * 100;

	if ($queue_percent > 250) {
		$inc_percent = 100;
	} elsif ($queue_percent > 200) {
		$inc_percent = 50;
	} elsif ($queue_percent > 150) {
		$inc_percent = 20;
	}

	if ($inc_percent != 0) {
		$step = ($inc_percent / 100) * $workers;
		if ($workers + $step > $max) {
			$step = $max - $workers;
		}
	}

	if (($step + $workers) < ($queue / 2)) {
		$step = $step*2;
	}

	if (($workers < $fork_step) && ($step < $fork_step)) {
		$step = $fork_step;
	}

	return $step;
}

sub check_status {
	my $found_gathers = 0;
	my $found_db_workers = 0;
	my $found_loggers = 0;

	# If we can not connect to this socket we should restart gearman!
	my $sock = new IO::Socket::INET (
		PeerAddr => '127.0.0.1',
		PeerPort => 4730,
		Proto => 'tcp',
		Timeout => 5)
		or print "Failed to connect to the gearman server" and check_gearmand();

	print $sock "status\n" or print "Failed to write to gearman socket" and check_gearmand();

	while (<$sock>) {
		last if ($_ =~ /^\.\s*$/);

		#			function name  queue   exec worker
		#				   log_me	  1	  0	  0
		#			update_status	  0	  0	  0
		#			   store_down	  0	  0	  0
		#			 gather_child	  0	  0	 20
		my @line = split /\s+/, $_;

		# A better chomp
		$line[3] =~ s/[\r\n]+$//m;

		if ($line[0] eq 'gather_child') {
			# If there are ZERO monitor workers code below will never be executed and things will be handled by run_childs at the end of the function
			if (defined($line[3]) && $line[3] =~ /^[0-9]+$/ && $line[3] > 0) {
				$found_gathers = $line[3];
				my $count = get_step($line[1], $line[3], $max_gather);
				if ($count > 0) {
				   	run_childs($count, 0) if ($line[3] < $max_gather);
				}
			}
		} elsif ($line[0] eq 'update_status') {
			# If there are ZERO db workers code below will never be executed and things will be handled by run_childs at the end of the function
			if (defined($line[3]) && $line[3] =~ /^[0-9]+$/ && $line[3] > 0) {
				$found_db_workers = $line[3];
				my $count = get_step($line[1], $line[3], $max_db);
				if ($count > 0) {
				   	run_childs($count, 1) if ($line[3] < $max_db);
				}
			}
		} elsif ($line[0] eq 'log_me') {
			# If there are ZERO log_me workers code below will never be executed and things will be handled by run_childs at the end of the function
			if (defined($line[3]) && $line[3] =~ /^[0-9]+$/ && $line[3] > 0) {
				$found_loggers = $line[3];
				my $count = get_step($line[1], $line[3], $max_loggers);
				if ($count > 0) {
				   	run_childs($count, 2) if ($line[3] < $max_loggers);
				}
			}
		}

	}
	close $sock;

	# If we can NOT find gather_child line in the gearman output from the status cmd this means that all gathers are dead and we should run 20 immediately
	run_childs(20, 0) if ($found_gathers < 1);
	# If we can NOT find update_status line in the gearman output from the status cmd this means that all gathers are dead and we should run 4 immediately
	run_childs(4, 1) if ($found_db_workers < 1);
	# If we can not find any logger processes start some
	run_childs(2, 2) if ($found_loggers < 1);
}

sub restart_archon {
	print "Archon-Monitor seems to be down\n";
	my $archon_init = '/etc/init.d/archon';

	if (! -x $archon_init) {
		print "$archon_init is missing or it is not executable\n";
		return;
	}
	if (system("$archon_init restart")) {
		print "Failed to restart archon\n";
	} else {
		print "$archon_init successfully started\n";
	}
}

sub check_monitor {
	if (! -f $config{'pidfile'} ) {
		restart_archon();
		return;
	}

	open PID, '<', $config{'pidfile'};
	my $pid_num = <PID>;
	close PID;
	$pid_num =~ s/[\r\n]+$//m;

	if ($pid_num !~ /^[0-9]+$/ || ! -d '/proc/' . $pid_num) {
		restart_archon();
	}
}

sub restart_gearmand {
	my $gearman_init = '/etc/init.d/gearman';
	$gearman_init = '/etc/init.d/gearman-job-server' if (-f '/etc/debian_version');
    $gearman_init = '/etc/init.d/gearmand' if (-x '/etc/init.d/gearmand');
	print "gearmand seems to be down\n";

	if (! -x $gearman_init) {
		print "$gearman_init missing or not executable. Can't restart gearman without it.\n";
		return;
	}

	if (system("$gearman_init restart")) {
		print "$gearman_init restart failed\n";
	} else {
		print "gearmand has been successfully restarted.\n";
	}

	# If gearmand has been restarted this means that the entire archon should be restarted as well and we should quit afterwards
	restart_archon();
	exit 0;
}

sub check_gearmand {
	my $gearmand_pid_file = '/var/run/gearman.pid';
	$gearmand_pid_file = '/var/run/gearman/gearmand.pid' if (-f '/etc/debian_version');
    $gearmand_pid_file = '/var/run/gearmand/gearmand.pid' if (-x '/etc/init.d/gearmand');

	if (! -f $gearmand_pid_file) {
		restart_gearmand();
		return;
	}

	open PID, '<', $gearmand_pid_file or print "Failed to open $gearmand_pid_file: $!\n";
	my $pid_num = <PID>;
	close PID;
	$pid_num =~ s/[\r\n]+$//m;

	if ($pid_num !~ /^[0-9]+$/ || ! -d '/proc/' . $pid_num) {
		restart_gearmand();
	}
}

# Always check gearman status first prior checking anything else
check_gearmand();
check_status();
check_monitor();

exit 0;
