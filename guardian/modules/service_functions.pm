#!/usr/bin/perl
use strict;
use warnings;

package service_functions;
require Exporter;
our @ISA		= qw(Exporter);
our @EXPORT		= qw(kill_service fork_function start_restart_services);
our $VERSION	= '1.1.2';

# executes at run-time, unless used as module
__PACKAGE__->main() unless caller;

sub main {
	my $self = shift;
	my $debug = 0;
	sub logger { print @_, "\n"; }
}

sub kill_service {
	my $service_name = shift;
	my $service_ref = shift;
	my $debug = shift;
	if ( -d '/proc/'.$service_ref->{$service_name}[0] ) {
		kill 9, $service_ref->{$service_name}[7];
		if ( $! > 0) {
			main::logger("Service $service_name(".$service_ref->{$service_name}.") successfully signaled!") if $debug;
			return 1;
		} else {
			main::logger("Service $service_name(".$service_ref->{$service_name}.") NOT signaled!") if $debug;
			return 0;
		}
	}
}

sub fork_function {
	my $service_name = shift;
	my $service_ref = shift;
	my $init_dir = shift;
	my $service_id = shift;
	my $restarts_file = shift;
	# 0 - start
	# 1 - restart
	defined(my $cpid=fork) or main::logger("Unable to create $service_name start process: $!");
	if ($cpid == 0) {
		# Restore oom scores to default before executing the restart
		if (-e "/proc/$$/oom_score_adj") {
			open my $OOM_SCORE_ADJ, '>', "/proc/$$/oom_score_adj" or logger("Warn: Unable to open /proc/$$/oom_score_adj for writing: $!");
			print $OOM_SCORE_ADJ "0" or logger("Warn: Unable to adjust oom_score_adj: $!");
			close $OOM_SCORE_ADJ;
		} elsif (-e "/proc/$$/oom_adj") {
			open my $OOM_ADJ, '>', "/proc/$$/oom_adj" or logger("Warn: Unable to open /proc/$$/oom_adj for writing: $!");
			print $OOM_ADJ "0" or logger("Warn: Unable to adjust oom_adj: $!");
			close $OOM_ADJ;
		}

		my $return = 0;
		# call the service init script within the child
		my $cmd = $init_dir.'/'.$service_name.'.sh';
		if ( ! -f $cmd ) {
			main::logger('No such file: '.$cmd);
			exit;
		}
		$cmd .= ' restart';
		#main::logger("$0 pid: $$ ppid:".getppid());

		if (defined($service_id) && defined($restarts_file)) {
			# increase restarts count for this service and refresh last restart time in service_restarts_file
			my $timestamp = time;
			my $restarts = $service_ref->{$service_name}[4] + 1;
			$service_id = $1 if ($service_id =~ /^([0-9]+)$/);
			system("if ( grep '^$service_id:' $restarts_file >/dev/null 2>&1 ); then sed -i '/^$service_id:/s/:[0-9]\\+:[0-9]\\+\$/:$restarts:$timestamp/' $restarts_file ; else echo '$service_id:$restarts:$timestamp' >> $restarts_file ; fi");
		}

		system($cmd);
		$return = $? >> 8 if ($? != -1);
 		if ( $return == 0 || $return == 16777215 ) {
			main::logger("Info: $service_name-restart($$) :: finished successfully($return)");
			system("echo 'Info: $service_name-restart($$) :: finished successfully($return)'|wall") if $service_ref->{$service_name}[10];
		} elsif ( $return == -1 ) {
			main::logger("Error: $service_name-restart($$) :: unable to execute($return)");
			system("echo 'Error: $service_name-restart($$) :: unable to execute($return)'|wall") if $service_ref->{$service_name}[10];
		} elsif ( $return == 1 ) {
			main::logger("Error: $service_name-restart($$) :: unable to start($return)");
			system("echo 'Error: $service_name-restart($$) :: unable to start($return)'|wall") if $service_ref->{$service_name}[10];
		} elsif ( $return == 2 ) {
			main::logger("Error: $service_name-restart($$) :: wrong configuration($return)");
			system("echo 'Error: $service_name-restart($$) :: unable to start($return)'|wall") if $service_ref->{$service_name}[10];
		} elsif ( $return == 3 ) {
			main::logger("Error: $service_name-restart($$) :: missing configuration file($return)");
			system("echo 'Error: $service_name-restart($$) :: unable to start($return)'|wall") if $service_ref->{$service_name}[10];
		} else {
			main::logger("Error: $service_name-restart($$) :: unknown error($return))");
			system("echo 'Error: $service_name-restart($$) :: unable to start($return)'|wall") if $service_ref->{$service_name}[10];
		}
		exit;
	} else {
	# add the pid of the process to the proper place in the service array
		main::logger("Info: started restart process for service $service_name ($cpid)");
		$service_ref->{$service_name}[7] = $cpid;
		$service_ref->{$service_name}[4]++;
		$service_ref->{$service_name}[2] = 0;
		$service_ref->{$service_name}[10] = 0;
	}
}

sub start_restart_services {
	my $service_ref = shift;
	my $proc_ref = shift;
	my $config_ref = shift;
	my $service_id_ref = shift;
	while ( my $svc = each(%{$service_ref}) ) {
		if (defined($service_ref->{$svc}[0])) {
			# we don't want to check this service
			next if ($service_ref->{$svc}[0] == 0);
		} else {
        	main::logger("Error: missing check status for service $svc");
        	next;
		}

		# skip restart if there is a service stop file in the stop_dir
		next if ( -f $config_ref->{'stop_dir'}."/$svc" );

		# skip if we don't have init script for this service
		next if ( $service_ref->{$svc}[11] == 0 );

		# if someone want from us to restart a services
		# remove the touched file and set the restart flag for that service
		if ( -f $config_ref->{'restart_dir'}."/$svc" ) {
			main::logger("Info: someone triggered restart for service $svc");
			$service_ref->{$svc}[2] = 1;
			$service_ref->{$svc}[10] = 1;
			unlink($config_ref->{'restart_dir'}."/$svc");
		}

		# skip if we still have running restart process and the stored restart pid is a child of Guardian
		if ( defined($service_ref->{$svc}[7]) && $service_ref->{$svc}[7] != 0 &&
			exists $proc_ref->{$service_ref->{$svc}[7]} && $proc_ref->{$service_ref->{$svc}[7]}[6] == $$ ) {
			main::logger("We have running restart process for service $svc(".$service_ref->{$svc}[7].')') if $config_ref->{'debug'};
			next;
		} else {
			$service_ref->{$svc}[7] = 0;
		}

		# if there is more then the normal count of service instances for this service
		# mark it for restart
		if ($service_ref->{$svc}[9] > $service_ref->{$svc}[8]) {
			main::logger('Too many instances of service '.$svc.'('.$service_ref->{$svc}[9].').');
			$service_ref->{$svc}[2] = 1;
		}

		if ( $service_ref->{$svc}[1] == 0 ) {
			# We are here if a given service is marked as down

			if  ($service_ref->{$svc}[13]) {
				main::logger("Service $svc is marked as down. HOWEVER internal do NOT restart flag was set. Usually apache/safeapacherestart case. Restart skipped ...");
				# I will skip restart this time but I will not the next time unless someone else set 13 to true
				$service_ref->{$svc}[13] = undef;
				next;
			}

			if ($service_ref->{$svc}[4] > 2 && $service_ref->{$svc}[4] % 3 == 0) {
				# check the start attempts
				if (time() - $service_ref->{$svc}[6] > $config_ref->{'time_between_restarts'}) {
					$service_ref->{$svc}[6] = 0;
					$service_ref->{$svc}[5] = 0;
				} else {
					if (!$service_ref->{$svc}[5]) {
						main::logger("Info: too many restart attempts for service $svc! Starting fixer for it!");
						$service_ref->{$svc}[5] = 1;
						if ( -x $config_ref->{'fixers_dir'}.'/'.$svc.'.sh' ) {
							system($config_ref->{'fixers_dir'}.'/'.$svc.'.sh');
						}
					}
					next;
				}
			}
			$service_ref->{$svc}[6] = time();
			# we don't have restart function running
			main::logger("Info: service $svc is down! Trying to restart(0) it...".$service_ref->{$svc}[4]);
			fork_function($svc,$service_ref,$config_ref->{'init_dir'},$service_id_ref->{$svc},$config_ref->{'service_restarts_file'});
			next;
		}

		# if the service is UP and is set to be restarted, and we don't have any other process
		# restarting it, we should restart it
		if ($service_ref->{$svc}[1] &&
			$service_ref->{$svc}[2] &&
			defined($service_ref->{$svc}[7]) &&
			$service_ref->{$svc}[7] == 0) {
			fork_function($svc,$service_ref,$config_ref->{'init_dir'});
			next;
		}
	}
}

1;
