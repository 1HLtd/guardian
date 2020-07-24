#!/usr/bin/perl
use strict;
use warnings;

package proc_funcs;
require Exporter;
our @ISA		= qw(Exporter);
our @EXPORT		= qw(gather_proc_info find_kernel_procs kill_zombies kill_long_procs kill_logic);
our $VERSION	= 4.8;

# executes at run-time, unless used as module
__PACKAGE__->main() unless caller;

sub main {
	my $self = shift;
	sub logger { print @_, "\n"; }
	our %proc = ();
	our %stats = ();
	my %kprocs = ();
	my $kthread_pid = proc_funcs::find_kthread(\%proc, \%kprocs);
	proc_funcs::find_kernel_procs(\%kprocs, $kthread_pid);
	%proc = ();
	proc_functs::gather_proc_info(\%stats,\%proc);
	while ( my $pid = each(%proc)) {
		printf "Pid: %d Owner: %d State: %s CMD: %s\n", $pid, $proc{$pid}[0], $proc{$pid}[3], $proc{$pid}[2];
	}
}

sub gather_proc_info {
	# %proc hash details
	# $proc{PID}[0] - UID(owner of the process)
	# $proc{PID}[1] - Process creation time
	# $proc{PID}[2] - cmdline of the process
	# $proc{PID}[3] - process state
	# $proc{PID}[4] - process priority value
	# $proc{PID}[5] - process nice value
	# $proc{PID}[6] - pid of the parent process
	# $proc{PID}[7] - process session leader
	# $proc{PID}[8] - user time (clock ticks)
	# $proc{PID}[9] - system time (clock ticks)
	# $proc{PID}[10] - process memory
	my $stats_ref = shift;
	my $proc_ref = shift;
	my $kprocs_ref = shift;

	opendir PROC, '/proc' or main::logger("Unable to open dir /proc: $!");
	while ( my $pid = readdir(PROC) ) {
		my @pid_info = ();
		my @stat = ();
		my @io = ();

		# cycle only trough the PIDs
		next unless ($pid =~ /^[0-9]+$/);

		#next if ($pid < 2);

		# skip kernel related processes
		next if (exists($kprocs_ref->{$pid}));

		# pid_info[4] - UID
		# pid_info[9] - Process creation time
		# stat[2] - process state
		# stat[3] - pid of the parent process
		# stat[18] - nice level#  vsize - Process Virtual Memory size (unknown scale) #  vsize - Process Virtual Memory size (unknown scale) 
		# stat[14] - process utime
		# stat[15] - process stime
		# stat[] - process memory
		@pid_info = stat("/proc/$pid") or next;
		open CMDLINE, '<', "/proc/$pid/cmdline" or next;
		my $cmdline = <CMDLINE>;
		close CMDLINE;

		open STAT, '<', "/proc/$pid/stat" or next;
		my $statline = <STAT>;
		close STAT;

		# content of $statline is critical so we will always next if it is not defined
		unless (defined($statline)) {
			#main::logger("/proc/$pid/stat content is undefined");
			next;
		}

		my $stat_cmd = $statline;
		$stat_cmd =~ s/^.*\((.*)\).*/$1/;
		# Cleanup the garbage otherwise data will be filled with garbage!
		$stat_cmd =~ s/[\0|\r|\n]$//;
		$stat_cmd =~ s/[\0|\r|\n]/ /g;
		$statline =~ s/^.*\)\s+//;

		@stat = split /\s+/, $statline;
		next unless (defined($stat[1]));

		# Strip bad chars from cmdline if it is defined
		if (defined($cmdline)) {
			$cmdline =~ s/[\0|\r|\n]*$//;
			$cmdline =~ s/[\0|\r|\n]/ /g;
			$cmdline =~ s/\s*$//g;
		} else {
			# Get the full cmd line from /proc/$pid/stat in case /proc/$pid/cmdline does not contain valid entries
			#main::logger("/proc/$pid/cmdline is undefined. Falling back to to cmdline from /proc/$pid/stat which is $stat_cmd");
			$cmdline = $stat_cmd;
		}

		# update the stats
		if ($pid_info[4] != 0) {
			$stats_ref->{'global'}[2]++;
		}
		# put the info into the process table hash
		$proc_ref->{$pid} = [ $pid_info[4], $pid_info[9], $cmdline, $stat[0], $stat[15], $stat[16], $stat[1], $stat[3], $stat[12], $stat[13], $stat[20] ];

		# Make sure that all variables in $proc_ref->{$pid} are populated or we better delete this pid information and move ahead
		# This ensures that all the information parsed by analyze proc data will be populated prior our attempts to work with it
		#for(my $i = 0; $i<11; $i++) {
		#	unless (defined($proc_ref->{$pid}[$i])) {
		#		main::logger("ERROR: Undefined information for pid $pid at index $i");
		#		delete $proc_ref->{$pid};
		#		last;
		#	}
		#}

	}
	closedir PROC;
}

sub find_kthread {
	my $proc_ref = shift;
	my $kprocs_ref = shift;
	my $kthread_pid = 0;
	my %stats = ( 'global' => [ 0, 0, 0 ] );
	gather_proc_info(\%stats, $proc_ref, $kprocs_ref);
	# find the kthreadd pid
	while (my $pid = each %{$proc_ref}) {
		if ($proc_ref->{$pid}[0] == 0 && $proc_ref->{$pid}[2] =~ /kthread/) {
			$kthread_pid = $pid;
			$kprocs_ref->{$pid} = 0;
			last;
		}
	}
	return $kthread_pid;
}

sub find_kernel_procs {
	my $kprocs_ref = shift;
	my $kthread_pid = shift;
	return 0 if ($kthread_pid == 0);
	my %proc = ();
	my %stats = ( 'global' => [ 0, 0, 0 ] );
	gather_proc_info(\%stats, \%proc, $kprocs_ref);

	# find all childs of kthreadd
	while (my $pid = each %proc) {
		if ($proc{$pid}[6] == $kthread_pid) {
			$kprocs_ref->{$pid} = 0;
		}
	}
}

sub kill_zombies {
	my $proc_ref = shift;
	my $proc_stats_ref = shift;
	my $config_ref = shift;
	# kill all zombie processes
	if ($#{$proc_stats_ref->{'kills'}} != -1) {
		my $killed_pids = '';
		if ($config_ref->{'extended_kill_log'}) {
			foreach my $pid(@{$proc_stats_ref->{'kills'}}) {
				main::kill_log("Killed zombie procs($pid) cmd: ".$proc_ref->{$pid}[2]);
			}
		}
		kill 9, @{$proc_stats_ref->{'kills'}};
		$proc_stats_ref->{'kills'} = [];
	}
}

sub kill_long_procs {
	my $proc_stats_ref = shift;
	my $proc_ref = shift;
	my $loadtype = shift;
	my $current_time = shift;
	my $curload = shift;
	my $load_vars_ref = shift;
	my $user_ref = shift;
	my $config_ref = shift;
	my @kill_list = ();
	# kill all long processes if they are imap or php and the load is increasing
	for my $pid (@{$proc_stats_ref->{'long_processes'}}) {
		if ( $loadtype > 1 ) {
			if ( $proc_ref->{$pid}[2] =~ /php$/ ) {
				push(@kill_list, $pid);
				main::kill_log("Killed long proc($pid) owner(".$user_ref->{$proc_ref->{$pid}[0]}.') :: '.$proc_ref->{$pid}[2]);
			} elsif ( $curload > $load_vars_ref->[1] && $proc_ref->{$pid}[2] =~ /imap/ && $current_time-$proc_ref->{$pid}[1] > $config_ref->{'long_imap_time'} ) {
				push(@kill_list, $pid);
				main::kill_log("Killed long proc($pid) owner(".$user_ref->{$proc_ref->{$pid}[0]}.') :: '.$proc_ref->{$pid}[2]);
			}
		}
	}
	kill 15, @kill_list;
}

sub kill_logic {
	my $curload = shift;
	my $proc_stats_ref = shift;
	my $proc_ref = shift;
	my $config_ref = shift;
	my $load_vars_ref = shift;
	my $loadtype = shift;
	my $current_time = shift;
	
	# if the load is under the normal load(load_vars[2])
	# and we have some stopped processes
	# continue all of them and clean the stopped_procs array
	if ($config_ref->{'pause_arch'}) { 
		if ($curload < $load_vars_ref->[2] && $#{$proc_stats_ref->{'stopped'}} >= 0) {
			if ($config_ref->{'extended_kill_log'}) {
				foreach my $pid(@{$proc_stats_ref->{'stopped'}}) {
					main::kill_log(" Continue stopped process($pid) cmd: ".$proc_ref->{$pid}[2]);
				}
			}
			kill 18, @{$proc_stats_ref->{'stopped'}};
			$proc_stats_ref->{'stopped'} = [];
		}
	}

	# if the load is over the normal load (load_vars[2])
	# and the process is running for more then 'php_long_time' secs kill it
	# kill the PHP and its parent (suexec)
	# this kills only processes which parent is suexec
	if ($config_ref->{'normal_kill_php'} && $curload > $load_vars_ref->[2]) {
		for my $pid (@{$proc_stats_ref->{'php'}}) {
			$pid = $1 if ($pid =~ /^([0-9]+)$/);
			if ($proc_ref->{$proc_ref->{$pid}[6]}[2] =~ /suexec/ &&
				$current_time - $proc_ref->{$pid}[1] > $config_ref->{'long_php_time'}) {
				$proc_ref->{$pid}[6] = $1 if ($proc_ref->{$pid}[6] =~ /^([0-9]+)$/);
				if ($config_ref->{'extended_kill_log'}) {
					main::kill_log('  Kill TERM pid: '.$pid.' cmd: '.$proc_ref->{$pid}[2]);
				}
				kill 9, $pid, $proc_ref->{$pid}[6];
			}
		}
	}

	# if the load is over the high load(load_vars[1])
	# killall imap processes and stop all archives (runned not by root)
 	if ($curload > $load_vars_ref->[1]) {
		main::kill_log("High load ($curload) reached!");
		if ($config_ref->{'high_kill_imap'}) {
			if ($config_ref->{'extended_kill_log'}) {
				for (my $i=0; $i<=$#{$proc_stats_ref->{'dovecot'}}; $i++) {
					main::kill_log('  Kill TERM pid: '.$proc_stats_ref->{'dovecot'}[$i].' cmd: '.$proc_ref->{$proc_stats_ref->{'dovecot'}[$i]}[2]);
				}
			}
	 		kill 15, @{$proc_stats_ref->{'dovecot'}};
			$proc_stats_ref->{'dovecot'} = [];
		}
		if ( $config_ref->{'pause_arch'} && $#{$proc_stats_ref->{'archivers'}} != -1 ) {
			for (my $p = 0; $p <= $#{$proc_stats_ref->{'archivers'}}; $p++ ) {
				if ($proc_ref->{$proc_stats_ref->{'archivers'}[$p]}[0] != 0) {
					main::kill_log(' Paused process(' . $proc_stats_ref->{'archivers'}[$p] . ') cmd: '. $proc_ref->{$proc_stats_ref->{'archivers'}[$p]}[2] ) if $config_ref->{'extended_kill_log'};
					kill 19, $proc_stats_ref->{'archivers'}[$p];
					push(@{$proc_stats_ref->{'stopped'}}, $proc_stats_ref->{'archivers'}[$p]);
				}
			}
		}
		# if the load is over the high (load_vars_ref[1])
		if ($config_ref->{'high_kill_arch'}) {
			if ($config_ref->{'extended_kill_log'}) {
				for (my $i=0; $i<=$#{$proc_stats_ref->{'archivers'}}; $i++) {
					main::kill_log('  Kill pid: '.$proc_stats_ref->{'archivers'}[$i].' cmd: '.$proc_ref->{$proc_stats_ref->{'archivers'}[$i]}[2]);
				}
			}
	 		kill 9, @{$proc_stats_ref->{'archivers'}};
			$proc_stats_ref->{'archivers'} = [];
		}
		if ($config_ref->{'high_kill_smtp'}) {
			if ($config_ref->{'extended_kill_log'}) {
				for (my $i=0; $i<=$#{$proc_stats_ref->{'smtp'}}; $i++) {
					main::kill_log('  Kill TERM pid: '.$proc_stats_ref->{'smtp'}[$i].' cmd: '.$proc_ref->{$proc_stats_ref->{'smtp'}[$i]}[2]);
				}
				for (my $i=0; $i<=$#{$proc_stats_ref->{'mailnull'}}; $i++) {
					main::kill_log('  Kill pid: '.$proc_stats_ref->{'mailnull'}[$i].' cmd: '.$proc_ref->{$proc_stats_ref->{'mailnull'}[$i]}[2]);
				}
			}
	 		kill 15, @{$proc_stats_ref->{'smtp'}};
			$proc_stats_ref->{'smtp'} = [];
		}
	}

 	if ($curload > $load_vars_ref->[0]) {
	# if the load is critical (over load_vars[0])
	# kill all php, ftp, smtp, mailnull and archives procs
		if ($config_ref->{'extended_kill_log'}) {
			main::kill_log("Critical load($curload) reached!");
			if ($config_ref->{'critical_kill_php'}) {
				for (my $i=0; $i<=$#{$proc_stats_ref->{'php'}}; $i++) {
					main::kill_log('  Kill pid: '.$proc_stats_ref->{'php'}[$i].' cmd: '.$proc_ref->{$proc_stats_ref->{'php'}[$i]}[2]);
				}
			}
			if ($config_ref->{'critical_kill_ftp'}) {
				for (my $i=0; $i<=$#{$proc_stats_ref->{'ftp'}}; $i++) {
					main::kill_log('  Kill pid: '.$proc_stats_ref->{'ftp'}[$i].' cmd: '.$proc_ref->{$proc_stats_ref->{'ftp'}[$i]}[2]);
				}
			}
			if ($config_ref->{'critical_kill_mail'}) {
				for (my $i=0; $i<=$#{$proc_stats_ref->{'smtp'}}; $i++) {
					main::kill_log('  Kill pid: '.$proc_stats_ref->{'smtp'}[$i].' cmd: '.$proc_ref->{$proc_stats_ref->{'smtp'}[$i]}[2]);
				}
				for (my $i=0; $i<=$#{$proc_stats_ref->{'mailnull'}}; $i++) {
					main::kill_log('  Kill pid: '.$proc_stats_ref->{'mailnull'}[$i].' cmd: '.$proc_ref->{$proc_stats_ref->{'mailnull'}[$i]}[2]);
				}
			}
			if ($config_ref->{'critical_kill_arch'}) {
				for (my $i=0; $i<=$#{$proc_stats_ref->{'archivers'}}; $i++) {
					main::kill_log('  Kill pid: '.$proc_stats_ref->{'archivers'}[$i].' cmd: '.$proc_ref->{$proc_stats_ref->{'archivers'}[$i]}[2]);
				}
			}
		}
 		if ($config_ref->{'critical_kill_php'}) {
	 		kill 9, @{$proc_stats_ref->{'php'}};
			$proc_stats_ref->{'php'} = [];
		}
		if ($config_ref->{'critical_kill_ftp'}) {
			kill 9, @{$proc_stats_ref->{'ftp'}};
			$proc_stats_ref->{'ftp'} = [];
		}
		if ($config_ref->{'critical_kill_mail'}) {
			kill 9, @{$proc_stats_ref->{'smtp'}};
			kill 9, @{$proc_stats_ref->{'mailnull'}};
	 		$proc_stats_ref->{'smtp'} = [];
	 		$proc_stats_ref->{'mailnull'} = [];
		}
		if ($config_ref->{'critical_kill_arch'}) {
	 		kill 9, @{$proc_stats_ref->{'archivers'}};
 			$proc_stats_ref->{'archivers'} = [];
		}
 		main::kill_log("Critical load ($curload) reached! Killing all php,ftp,smtp,mailnull,archivers procs!");
 	}
}

1;
