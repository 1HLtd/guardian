#!/usr/bin/perl

use strict;
use warnings;

package analyze_proc_data;
require Exporter;

our @ISA		= qw(Exporter);
our @EXPORT		= qw(analyze_proc_data save_old_stats);
our $VERSION	= '1.7.8';

# Dovecot
my $dovecot_down_count = 0;

# executes at run-time, unless used as module
__PACKAGE__->main() unless caller;

sub main {
	my $self = shift;
	sub logger { print @_, "\n"; }
}

sub analyze_proc_data {
	# %proc hash details:
	#	$proc_ref->{PID}[0] - UID(owner of the process)
	#	$proc_ref->{PID}[1] - Process creation time
	#	$proc_ref->{PID}[2] - cmdline of the process
	#	$proc_ref->{PID}[3] - process state
	#	$proc_ref->{PID}[4] - process priority value
	#	$proc_ref->{PID}[5] - process nice value
	#	$proc_ref->{PID}[6] - pid of the parent process
	#	$proc_ref->{PID}[7] - process session leader
	
	# %service hash details:
	# 	$service_ref->{$service}[0] - should we check this service 1/0 (yes/no)
	# 	$service_ref->{$service}[1] - status 0/1 (down/up)
	# 	$service_ref->{$service}[2] - should we restart it 0/1 (no/yes)
	# 	$service_ref->{$service}[3] - pid of the current process (default 0)
	# 	$service_ref->{$service}[4] - count of start attempts (default 0)
	# 	$service_ref->{$service}[5] - too many start attempts 1/0 (default 0)
	# 	$service_ref->{$service}[6] - time when the restart process was last started (default 0)
	# 	$service_ref->{$service}[7] - pid of the restart process (default 0)
	# 	$service_ref->{$service}[8] - how many instances can this service have (default 1)
	# 	$service_ref->{$service}[9] - count of found instances
	#	$service_ref->{$service}[10] - should we notify all logged users for the restart 
	#	$service_ref->{$service}[11] - do we have an init script for the service
	#	$service_ref->{$service}[12] - how many times we considered service as up via another service
	#   $service_ref->{$service}[13] - do not trigger restarts even if service is down 0 restart 1 do not restart


	my $loadtype = shift;
	my $proc_ref = shift;
	my $service_ref = shift;
	my $users_ref = shift;
	my $protected_users_ref = shift;
	my $proc_stats_ref = shift;
	my $current_time = shift;
	my $config = shift;
	my $checkNice = 0;
	my $user_exists = 0;

	my @service_status = (
		[ 0, 0, 0, 0, 0 ],		# Exim statuses
		[ 0, 0, 0 ],			# Pureftpd statuses
		[ 0, 0, 0 ],			# Dovecot statuses
		[ 0, 0, 0, 0, 0, 0 ],	# Courier statuses
		[ 0, 0, 0 ],			# litespeed statuses [1] of this array is DEPRICATED. See below. Hint: search for litespeed :)
		[ 0, 0, 0 ]				# nginx statuses
	);

	# the service_status array is used for services that
	# relay on other services in order to work properly
	#
	#	service_status[0] - exim
	#	service_status[0][0]	- exim on port 25 (status 0/1)
	#	service_status[0][1]	- exim on alt port (status 0/1)
	#	service_status[0][2]	- pid of exim on port 25
	#	service_status[0][3]	- exim for TLS conns (status 0/1)
	#	service_status[0][4]	- spamd/MailScanner (status 0/1)
	#
	#	service_status[1] - pureftpd
	#	service_status[1][0] - pureftpd status 0/1
	#	service_status[1][1] - pure-authd status 0/1
	#	service_status[1][2] - pureftpd pid
	#
	#	service_status[2] - dovecot
	#	service_status[2][0] - dovecot status 0/1
	#	service_status[2][1] - dovecot-auth status 0/1
	#	service_status[2][2] - dovecot pid
	#
	#	service_status[3] - courier
	#	service_status[3][0] - courier imapd status 0/1
	#	service_status[3][1] - courier pop3d status 0/1
	#	service_status[3][2] - courier pid
	#	service_status[3][3] - courier authd status 0/1
	#	service_status[3][4] - courier imap-ssl status 0/1
	#	service_status[3][5] - courier pop3-ssl status 0/1
	#
	#	service_status[4] - litespeed
	#	service_status[4][0] - Status of main litespeed process owned by root - 0/1
	#	service_status[4][1] - DEPRICATED!!! - No longer used!!! - Status of litespeed lscgid cgid of service_status[4][2] also owned by root - 0/1
	#	service_status[4][2] - Pid of service_status[4][0]
	#
	#	service_status[5] - nginx
	#	service_status[5][0] - Status of main nginx process owned by root - 0/1
	#	service_status[5][1] - Status of nginx worker process owned by nobody - 0/1
	#	service_status[5][2] - Pid of service_status[5][0]
	#
	#	service_status[6] - cdp-server	- R1Soft central server manager process
	#	service_status[6][0] - Status of main cdpserver process owned by root - 0/1
	#	service_status[6][1] - Status of child cdpserver worker process owned by root too - 0/1
	#	service_status[6][2] - Pid of service_status[5][0]

	
	# start the analyze of the processes here
	while ( my $pid = each (%{$proc_ref}) ) {
		$user_exists = 0;

		next if ($pid == 1);

		#unless (defined($pid)) {
		#	#main::logger("ERROR: Looping on \$proc_ref where \$pid element in $proc_ref is undefined");
		#	next;
		#}

		#unless (defined($proc_ref->{$pid})) {
		#	#main::logger("ERROR: \$proc_ref does not contain valid entry for PID $pid");
		#	next;
		#}

		#unless (defined($proc_ref->{$pid}[3])) {
		#	#main::logger("ERROR: \$proc_ref does not contain valid entry for PID \$proc_ref->{$pid}[3]");
		#	next;
		#}

		if ($proc_ref->{$pid}[3] eq 'Z') {
			# schedule all zombie process to be killed
			push(@{$proc_stats_ref->{'kills'}},$pid);
			next;
		}

		# skip the checks for this process if its parrent is Guardian
		next if ($proc_ref->{$pid}[6] == $$);

		if (exists $protected_users_ref->{$proc_ref->{$pid}[0]}) {
			# do something to the protected user process
		} else {
			if ($loadtype > 1 && $current_time - $proc_ref->{$pid}[1] > $config->{'long_process_time'}) {
				# processes which are working for more then 120sec and are not from any
				# protected user should be added to the long_processes array and killed
				# if needed, during increasing of the load

				#unless (defined($proc_ref->{$pid}[6])) {
				#	main::logger("Pid $pid parent is undefined \$proc_ref->{$pid}[6]");
				#	next;
				#}

				#unless (defined($proc_ref->{$proc_ref->{$pid}[6]}[2])) {
				#	main::logger("Pid $pid with parent $proc_ref->{$pid}[6] has no cmdline as \$proc_ref->{$proc_ref->{$pid}[6]}[2] is undefined");
				#	next;
				#}
				#unless (defined(($proc_ref->{$proc_ref->{$proc_ref->{$pid}[6]}[6]}[2]))) {
				#	main::logger("Pid $pid Parent $proc_ref->{$pid}[6] parent parent $proc_ref->{$proc_ref->{$pid}[6]}[6] parent parent cmdline $proc_ref->{$proc_ref->{$proc_ref->{$pid}[6]}[6]}[2]");
				#	next;
				#}

				# If the parent or grand parent of that particular long running process $pid is sshd
				# we should NOT add it to the long_processes array ref for later killing. Check #1277
				if (($proc_ref->{$pid}[6] > 1 && $proc_ref->{$proc_ref->{$pid}[6]}[2] =~ /sshd/) ||
					($proc_ref->{$proc_ref->{$pid}[6]}[6] > 1 && $proc_ref->{$proc_ref->{$proc_ref->{$pid}[6]}[6]}[2] =~ /sshd/)) {
					main::logger('Excluding (ssh) from long pid: '.$pid.' with cmd: ' . $proc_ref->{$pid}[2]) if ($config->{'extended_kill_log'});
					next;
				}

				# We should not add this pid to long_processes if long_procs_exclude is turned on and the pid name matches exclude_long_re re
				if ($config->{'long_procs_exclude'} && $proc_ref->{$pid}[2] =~ /($config->{'exclude_long_re'})/) {
					main::logger('Excluding (re) from long pid: '.$pid.' with cmd: ' . $proc_ref->{$pid}[2]) if ($config->{'extended_kill_log'});
					next;
				}

				# This process is neither started from sshd/bash nor it is excluded via exclude_long_re and long_procs_exclude
				# We should add it to long_processes list and later kill it if needed during high/ciritical load
				push(@{$proc_stats_ref->{'long_processes'}}, $pid);
			}
		}

		if ($proc_ref->{$pid}[2] =~ /($config->{'archivers_re'})/ ) {
			$checkNice = 1;

			if ($proc_ref->{$pid}[0] == 0 && $proc_ref->{$pid}[2] =~ /gzip/) {
				push(@{$proc_stats_ref->{'archivers'}}, $pid) if (
					$proc_ref->{$pid}[6] > 1 &&
					$proc_ref->{$proc_ref->{$pid}[6]}[6] > 1 &&
					($proc_ref->{$proc_ref->{$pid}[6]}[2] !~ /sshd/ || ($proc_ref->{$proc_ref->{$pid}[6]}[2] !~ /bash/ && $proc_ref->{$proc_ref->{$proc_ref->{$pid}[6]}[6]}[2] !~ /sshd/))
				);
			} else {
				push(@{$proc_stats_ref->{'archivers'}}, $pid);
			}
		}


		###############################
		# Detect running services
		###############################
		# start of checks to processes owned by root
		if ($proc_ref->{$pid}[0] == 0) {
			# start of checks to processes which are session leaders
			if ($proc_ref->{$pid}[6] == 1) {
				# Litespeed check starts here
				if (exists $service_ref->{'litespeed'}) {	
					# root	  2051  0.3  0.8  42252 33244 ?		S<   Jan11   0:33 litespeed (lshttpd)
					if ($proc_ref->{$pid}[2] =~ /litespeed\s+\(lshttpd\)/) {
						$service_status[4][0] = 1;					# The main litespeed process is up
						$service_status[4][2] = $pid; 				# We copy it to $service_status[4][2]
						push(@{$proc_stats_ref->{'httpd'}}, $pid);	# TODO?
						next;
					}
				}

				# Litespeed check starts here
				if (exists $service_ref->{'nginx'}) {					# If nginx check is enabled
					#root	 13144  0.0  0.0  38788   856 ?		Ss   09:04   0:00 nginx: master process /usr/local/nginx/sbin/nginx
					if ($proc_ref->{$pid}[2] =~ /nginx: master process/) {	# This is a session leader root owned pid with name nginx: master process
						$service_status[5][0] = 1;							# The main nginx process is up
						$service_status[5][2] = $pid; 						# We copy it to $service_status[5][2]
						push(@{$proc_stats_ref->{'httpd'}}, $pid);			# TODO?
						next;
					}
				}

				# Apache check stats here
				if (exists $service_ref->{'apache'}) {
					if ($proc_ref->{$pid}[2] =~ /httpd/) {
						# the service is up if the owner of the found pid is root and it is the session leader (0)
						$service_ref->{'apache'}[1] = 1;	# the service is UP
						$service_ref->{'apache'}[2] = 0;	# do not restart
						$service_ref->{'apache'}[3] = $pid;	# this is the pid of the service
						$service_ref->{'apache'}[4] = 0;	# set the count of service restarts to 0
						$service_ref->{'apache'}[12] = 0;	# This is the real check
						push(@{$proc_stats_ref->{'httpd'}}, $pid);
						next;
					}
				}

				# PureFTPD check starts here
				if (exists $service_ref->{'ftp'}) {
					if ($proc_ref->{$pid}[2] =~ /pure-ftpd \(SERVER\)/) {
						$service_status[1][0] = 1;
						$service_status[1][2] = $pid;
						$service_ref->{'ftp'}[9]++;		# increase the count of found instances of this service
						push(@{$proc_stats_ref->{'ftp'}}, $pid);
						next;
					}
					if ($proc_ref->{$pid}[2] =~ /^\/usr\/sbin\/pure-authd/) {
						$service_status[1][1] = 1;
						next;
					}
				}

				# cron daemon check starts here
				if (exists $service_ref->{'crond'}) {
					if ( $proc_ref->{$pid}[2] eq 'crond' || $proc_ref->{$pid}[2] eq '/usr/sbin/crond' ) {
						$service_ref->{'crond'}[1] = 1;
						$service_ref->{'crond'}[2] = 0;
						$service_ref->{'crond'}[3] = $pid;
						$service_ref->{'crond'}[4] = 0;
						$service_ref->{'crond'}[9]++;		# increase the count of found instances of this service
						next;
					}
				}

				# cPanel check starts here
				if (exists $service_ref->{'cpanel'}) {
					if ($proc_ref->{$pid}[2] =~ /^cpsrvd/ && $proc_ref->{$pid}[2] !~ /cpsrvd: internal update engine/) {
						$service_ref->{'cpanel'}[1] = 1;
						$service_ref->{'cpanel'}[2] = 0;
						$service_ref->{'cpanel'}[3] = $pid;
						$service_ref->{'cpanel'}[4] = 0;
						$service_ref->{'cpanel'}[9]++;		# increase the count of found instances of this service
						next;
					}
				}

				# Dovecot main pid check starts here
				if (exists $service_ref->{'dovecot'}) {
					if ($proc_ref->{$pid}[2] eq '/usr/sbin/dovecot' || $proc_ref->{$pid}[2] eq 'dovecot') {
						$service_status[2][0] = 1;
						$service_status[2][2] = $pid; # Write the main dovecot pid to $service_status[2][2]
						$service_ref->{'dovecot'}[9]++;		# increase the count of found instances of this service
						push(@{$proc_stats_ref->{'dovecot'}}, $pid);
						next;
					}
				}

				# courier check starts here
				if (exists $service_ref->{'courier'}) {
					if ($proc_ref->{$pid}[2] =~ /courierlogger.+name=imapd/) {
						$service_status[3][0] = 1;
						push(@{$proc_stats_ref->{'dovecot'}}, $pid);
					}
					if ($proc_ref->{$pid}[2] =~ /courierlogger.+name=pop3d/) {
						$service_status[3][1] = 1;
						push(@{$proc_stats_ref->{'dovecot'}}, $pid);
					}
					if ($config->{'courier_authd'} && $proc_ref->{$pid}[2] =~ /courier-authlib\/authdaemond/) {
						$service_status[3][2] = $pid;
						$service_status[3][3] = 1;
					}
					if ($config->{'courier_imap_tls'} && $proc_ref->{$pid}[2] =~ /courierlogger.+name=imapd-ssl/) {
						$service_status[3][4] = 1;
						push(@{$proc_stats_ref->{'dovecot'}}, $pid);
					}
					if ($config->{'courier_pop3_tls'} && $proc_ref->{$pid}[2] =~ /courierlogger.+name=pop3d-ssl/) {
						$service_status[3][5] = 1;
						push(@{$proc_stats_ref->{'dovecot'}}, $pid);
					}
				}

				# Zendaemon check starts here
				if (exists $service_ref->{'zendaemon'}) {
					if ($proc_ref->{$pid}[2] =~ /zendaemon start/i) {
						$service_ref->{'zendaemon'}[1] = 1;
						$service_ref->{'zendaemon'}[2] = 0;
						$service_ref->{'zendaemon'}[3] = $pid;
						$service_ref->{'zendaemon'}[4] = 0;
						$service_ref->{'zendaemon'}[9]++;		# increase the count of found instances of this service
						next;
					}
				}
				
				# Hawk check starts here
				if (exists $service_ref->{'hawk'}) {
					if ($proc_ref->{$pid}[2] eq '[Hawk]') {
						$service_ref->{'hawk'}[1] = 1;
						$service_ref->{'hawk'}[2] = 0;
						$service_ref->{'hawk'}[3] = $pid;
						$service_ref->{'hawk'}[4] = 0;
						$service_ref->{'hawk'}[9]++;		# increase the count of found instances of this service
						next;
					}
				}

				# mailquotad check starts here
				if (exists $service_ref->{'mailquotad'}) {
					if ($proc_ref->{$pid}[2] eq '[mailquotad]') {
						$service_ref->{'mailquotad'}[1] = 1;
						$service_ref->{'mailquotad'}[2] = 0;
						$service_ref->{'mailquotad'}[3] = $pid;
						$service_ref->{'mailquotad'}[4] = 0;
						$service_ref->{'mailquotad'}[9]++;		# increase the count of found instances of this service
						next;
					}
				}

				# multistatsd check starts here
				if (exists $service_ref->{'multistatsd'}) {
					if ($proc_ref->{$pid}[2] eq '[Multistatsd]') {
						$service_ref->{'multistatsd'}[1] = 1;
						$service_ref->{'multistatsd'}[2] = 0;
						$service_ref->{'multistatsd'}[3] = $pid;
						$service_ref->{'multistatsd'}[4] = 0;	# Make sure to zero restart counter
						next;
					}
				}

				# lifesigns starts here
				if (exists $service_ref->{'lifesigns'}) {
					if ($proc_ref->{$pid}[2] eq '[LifeSigns]') {
						$service_ref->{'lifesigns'}[1] = 1;
						$service_ref->{'lifesigns'}[2] = 0;
						$service_ref->{'lifesigns'}[3] = $pid;
						$service_ref->{'lifesigns'}[4] = 0;		# Make sure to zero restart counter
						$service_ref->{'lifesigns'}[9]++;		# increase the count of found instances of this service
						next;
					}
				}

				# Spam assassin check starts here
				if ($config->{'has_spamd'} && $proc_ref->{$pid}[2] =~ /\/bin\/spamd/ && $proc_ref->{$pid}[6] == 1) {
					$service_status[0][4] = 1;
					next;
				}

				# cpanellogd starts here
				if (exists $service_ref->{'cpanellogd'}) {
					if ($proc_ref->{$pid}[2] =~ /^cpanellogd/ || $proc_ref->{$pid}[2] =~ /cpanellogd$/) {
						$service_ref->{'cpanellogd'}[1] = 1;
						$service_ref->{'cpanellogd'}[2] = 0;
						$service_ref->{'cpanellogd'}[3] = $pid;
						$service_ref->{'cpanellogd'}[4] = 0;
						next;
					}
				}

				# R1Soft cdp-agent (client side) check starts here
				# root	 26358  0.0  0.1  41116  1544 ?		Ssl  09:02   0:00 /usr/sbin/r1soft/bin/cdp -s -c /usr/sbin/r1soft/conf/agent_config
				if (exists $service_ref->{'cdp-agent'}) {
					# Tell me if you have better solution :)
					if ($proc_ref->{$pid}[2] =~ /r1soft\/bin\/cdp\s+.*-s/) {
						$service_ref->{'cdp-agent'}[1] = 1;
						$service_ref->{'cdp-agent'}[2] = 0;
						$service_ref->{'cdp-agent'}[3] = $pid;
						$service_ref->{'cdp-agent'}[4] = 0;
						next;
					}
				}

				# R1Soft cdpserver (server side) check starts here
				# root	  2759  0.0  0.0  24052  1464 ?		Sl   Nov01   0:00 ./cdpserver /usr/sbin/r1soft/conf/server.conf
				# root	  2761 10.5 30.7 9928064 5057120 ?	 Sl   Nov01 349:40  \_ ./cdpserver /usr/sbin/r1soft/conf/server.conf
				if (exists $service_ref->{'cdp-server'}) {
					# Tell me if you have better solution :)
					if ($proc_ref->{$pid}[2] =~ /cdpserver\s*/) {
						$service_status[6][0] = 1;		# Main cdpserver process is up
						$service_status[6][2] = $pid;	# Pid of the main cdpserver process is copied to $service_status[6][2]
						next;
					}
				}

				# Login Failure Daemon (lfd) check starts here
				# root	 13456  0.1  0.6  18592 13868 ?		Ss   10:29   0:00 lfd - sleeping
				# root	  2653  2.0  1.9  14864  9992 ?		Rs   05:21   0:00 lfd - starting
				if (exists $service_ref->{'lfd'}) {
					if ($proc_ref->{$pid}[2] =~ /^lfd\s+-\s+/) {
						$service_ref->{'lfd'}[1] = 1;
						$service_ref->{'lfd'}[2] = 0;
						$service_ref->{'lfd'}[3] = $pid;
						$service_ref->{'lfd'}[4] = 1;
						next;
					}
				}
				# ClamAV check stars here
				# root	 17460  1.4  4.9 138136 101516 ?	   Ssl  03:33   0:06 /usr/sbin/clamd
				if (exists $service_ref->{'clamav'}) {
					if ($proc_ref->{$pid}[2] =~ /clamd/) {
						$service_ref->{'clamav'}[1] = 1;
						$service_ref->{'clamav'}[2] = 0;
						$service_ref->{'clamav'}[3] = $pid;
						$service_ref->{'clamav'}[4] = 1;
						next;
					}
				}

			# end of checks to processes which are session leaders
			} else {
				# Apache service needs to be monitored and apache is still marked as down
				if (exists $service_ref->{'apache'} && ! $service_ref->{'apache'}[1]) {
					if ($proc_ref->{$pid}[2] =~ /(safeapacherestart|safeaprestart|restartsrv_httpd)/) {
						# Always initialize
						$service_ref->{'apache'}[12] = 0 unless (defined($service_ref->{'apache'}[12]));

						# Number of times service has been fakely detected as up
						$service_ref->{'apache'}[12]++;

						main::logger("#$service_ref->{'apache'}[12] - Real apache pid not found but detected $proc_ref->{$pid}[2]");

						if ($service_ref->{'apache'}[12] > 10) {
							# Zero the counter
							$service_ref->{'apache'}[12] = 0;
							$service_ref->{'apache'}[13] = 0;	# Do not skip apache restarts anymore

							# apache is down for more than 10 cycles (5 seconds) and safeapacherestart can't finish its job ... skip marking apache as up
							main::logger("#$service_ref->{'apache'}[12] - Max fake checks reached for apache ... skip marking it as up even fake detection pid still present $proc_ref->{$pid}[2]");
							next;
						}
						
						main::logger("#$service_ref->{'apache'}[12] - apache fakely marked as up due to $proc_ref->{$pid}[2]");

						# the service is up if the owner of the found pid is root and it is the session leader (0)
						$service_ref->{'apache'}[13] = 1;	# do not restart it
						$service_ref->{'apache'}[3] = $pid;	# this is the pid of the service
						next;
					}
				}

				if ($proc_ref->{$pid}[2] =~ /suexec/ ) {
					push(@{$proc_stats_ref->{'suexec'}}, $pid);
					next;
				}

				# Check for cdp-server child process is exactly the same as the one for the parent.
				# The only difference is that in this piece of code we are checking for processes which are _NOT_
				# session leaders (childs)
				if (exists $service_ref->{'cdp-server'}) {
					# Tell me if you have better solution :)
					if ($proc_ref->{$pid}[2] =~ /cdpserver\s*/) {
						$service_status[6][1] = 1;		# For cdpserver PID we change the status of $service_status[6][1] to UP
						next;
					}
				}

				# DEPRICATED!!!!
				# Litespeed manage its childs by its own. Whenever litespeed is restarted gracefully lscgid is restarted as well
				# This means that if the code below is present when lscgid is gracefully restarted guardian will detect litespeed as down
				# This will lead to unneccesarry restarts of the service. That's why the code below is obsolote and should NOT be used
				# --------------------------------------------------
				# Litespeed lscgid root owned pid check stats here
				#if (exists $service_ref->{'litespeed'}) {	
				#	# root	  2052  0.0  0.0   1808   392 ?		S<   Jan11   0:00  \_ httpd (lscgid)
				#	if ($proc_ref->{$pid}[2] =~ /httpd\s+\(lscgid\)/) {
				#		$service_status[4][1] = 1;					# Litespeed lscgid pid is up
				#		push(@{$proc_stats_ref->{'httpd'}}, $pid);	# TODO?
				#		next;
				#	}
				#}
				# --------------------------------------------------
			}
			# end of checks to processes owned by root
			if (exists $service_ref->{'exim'} && $proc_ref->{$pid}[2] =~ /^\/usr\/sbin\/exim/ ) {
				if ($config->{'exim_tls'} && $proc_ref->{$pid}[2] =~ /\-tls-on-connect/) {
					$service_status[0][3] = 1;
				}
				if ($config->{'exim_alt_port'} != 0 && $proc_ref->{$pid}[2] =~ /\-oX $config->{'exim_alt_port'}/ ) {
					$service_status[0][1] = 1;
				}
				next;
			}
		}

		# skip memcached processes
		if ($proc_ref->{$pid}[2] =~ /memcached/) {
			next;
		}

		# locate mysql main process (it should be running as mysqld)
		# the service is up if the parrent process is not the current process and the command contains mysqld
		# if ($proc_ref->{$pid}[0] == $users_ref->{'mysql'}[0] &&
		#if (defined($proc_ref->{$pid}[0])) {
		$user_exists = 1 if (exists $users_ref->{$proc_ref->{$pid}[0]});
		#}

		# nginx check stats here
		if (exists $service_ref->{'nginx'}) {					# If nginx check is enabled
			if ($users_ref->{$proc_ref->{$pid}[0]} eq 'nobody' &&	# The process is a child one with user nobody
				# nobody   13145 75.1  0.3  53144 15500 ?		S	09:04   5:11  \_ nginx: worker process
				$proc_ref->{$pid}[2] =~ 'nginx: worker process') {	# And the name of the process match the nginx worker process
				$service_status[5][1] = 1;							# This means that nginx worker is up
				push(@{$proc_stats_ref->{'httpd'}}, $pid);			# We also increase the number of httpd processes in the stats
				next;												# Nothing more to do here ...
			}
		}

		# Dovecot auth check starts here
		if (exists $service_ref->{'dovecot'}) {
			# cPanel and DirectAdmin
			# root	 22713  0.0  0.0   2636   976 ?		S	02:23   0:00  \_ dovecot-auth
			# Newer DirectAmin
			# root	  5928  0.3  0.0   4116  1664 ?		S	06:06   0:00  \_ dovecot/auth [0 wait, 0 passdb, 0 userdb]
			if ($proc_ref->{$pid}[2] =~ /dovecot.auth/) {
				$service_status[2][1] = 1; # Dovecot auth is up so we write that to $service_status[2][1]
				next;
			}
		}

		# Direct admin check starts here
		# Main pid
		# nobody	8937  0.0  0.0   7608   956 ?		Ss	2010   0:00 /usr/local/directadmin/directadmin d
		# Childs
		# nobody   30305  0.0  0.0   7608   276 ?		S	Jan09   0:00  \_ /usr/local/directadmin/directadmin d
		if (exists $service_ref->{'directadmin'}) {						# If directadmin is enabled ...
			if ($proc_ref->{$pid}[6] == 1 &&		 							# If the process is session leather but it is NOT root owned
				$users_ref->{$proc_ref->{$pid}[0]} eq 'nobody' &&				# If the pid owned by nobody
				$proc_ref->{$pid}[2] =~ '/usr/local/directadmin/directadmin') { # If the name of the pid is the one we are searching for ...
				$service_ref->{'directadmin'}[1] = 1;	# Service is up
				$service_ref->{'directadmin'}[2] = 0;	# Do not restart it
				$service_ref->{'directadmin'}[3] = $pid;# This is the main pid
				$service_ref->{'directadmin'}[4] = 0;	# Zero restart attempts
				next;
			}
		}

		# Qmail check starts here
		# Main pid
		# qmails   17383  0.0  0.0   1728   396 pts/0	S	06:51   0:00 qmail-send
		if (exists $service_ref->{'qmail'}) {									# If qmail is enabled ...
			if ($proc_ref->{$pid}[6] == 1 &&		 							# If the process is session leather but it is NOT root owned
				$users_ref->{$proc_ref->{$pid}[0]} eq 'qmails' &&				# If the pid owned by qmails
				$proc_ref->{$pid}[2] =~ 'qmail-send') { # If the name of the pid is the one we are searching for ...
				$service_ref->{'qmail'}[1] = 1;	# Service is up
				$service_ref->{'qmail'}[2] = 0;	# Do not restart it
				$service_ref->{'qmail'}[3] = $pid;# This is the main pid
				$service_ref->{'qmail'}[4] = 0;	# Zero restart attempts
				push(@{$proc_stats_ref->{'smtp'}}, $pid);
				next;
			}
		}

		# SWSoft Plesk daemon
		# Since the user is not correctly catched we do not care who is the user/owner of this pid
		# Main pid
		# 502	  20183  0.0  0.1   5476  1004 ?		S	09:30   0:00 /usr/sbin/sw-cp-serverd -f /etc/sw-cp-server/config
		if (exists $service_ref->{'plesk'}) {									# If plesk is enabled ...
			if ($proc_ref->{$pid}[6] == 1 &&		 							# If the process is session leather but it is NOT root owned
				$proc_ref->{$pid}[2] =~ 'sw-cp-serverd') { # If the name of the pid is the one we are searching for ...
				$service_ref->{'plesk'}[1] = 1;	# Service is up
				$service_ref->{'plesk'}[2] = 0;	# Do not restart it
				$service_ref->{'plesk'}[3] = $pid;# This is the main pid
				$service_ref->{'plesk'}[4] = 0;	# Zero restart attempts
				next;
			}
		}

		# This check is used for proftpd servers. It uses the same guardian configuration key as pure-ftpd -> ftp
		if (exists $service_ref->{'ftp'}) {
			if ($proc_ref->{$pid}[6] == 1 && # If the process is session leather but it is NOT root owned
				($users_ref->{$proc_ref->{$pid}[0]} eq 'nobody' || $users_ref->{$proc_ref->{$pid}[0]} eq 'ftp') && # If the process is owend by user nobody or ftp 
				# cPanel pid:
				#	nobody	1655  0.0  0.0   6744  1404 ?		Ss   02:59   0:00 proftpd: (accepting connections)
				# Directadmin pid:
				#	ftp	  19388  0.0  0.0   2892  1056 ?		Ss   02:59   0:00 proftpd: (accepting connections)
				$proc_ref->{$pid}[2] =~ /proftpd: \(accepting connections\)/) { # If the process match the know cPanel and directadmin proftpd pids
				$service_status[1][0] = 1; # Mark the ftp service as up
				$service_status[1][1] = 1; # Mark the pure-authd as up. This is actually a hack. proftpd does not have authd but this is required by the pureftpd check which uses the same key.
				$service_status[1][2] = $pid; # Store proftpd pid
				$service_ref->{'ftp'}[9]++;			 # increase the count of found instances of this service
				push(@{$proc_stats_ref->{'ftp'}}, $pid);
				next;
			}
		}

		if (exists $service_ref->{'mysql'}) {					# mysql service is defined for monitoring
			if ($user_exists &&										# user which own this process exists on the system
				$users_ref->{$proc_ref->{$pid}[0]} eq 'mysql' &&	# owner of this pid is user mysql
				$pid != $proc_ref->{$pid}[7] &&						# Process is NOT a session leather
				( $proc_ref->{$pid}[2] =~ /^\/usr\/sbin\/mysqld/ || # Pid name match the standard mysqld running from /usr/sbin (cPanel)
				  $proc_ref->{$pid}[2] =~ /libexec\/mysqld/ ||		# Pid name match mysql /usr/libexec || /usr/local/mysql5mm/libexec/ (Plesk and SGMM MySQL)
				  $proc_ref->{$pid}[2] =~ /mysqld_safe/) ) {		# mysqld_safe is still up so don't restart mysql  in that case as well. just mark it up.
				$service_ref->{'mysql'}[1] = 1;
				$service_ref->{'mysql'}[2] = 0;
				$service_ref->{'mysql'}[3] = $pid;
				$service_ref->{'mysql'}[4] = 0;
				# $service_ref->{'mysql'}[9]++;		# increase the count of found instances of this service
				next;
			}
		}

		# locate exim main process (it should be running as mailnull
		# if it is a session leader (parrent process is 1) it is the main process
		# check only the session leader
		if (exists $service_ref->{'exim'}) {
			if ($user_exists && $users_ref->{$proc_ref->{$pid}[0]} eq $config->{'exim_user'}) {
				push(@{$proc_stats_ref->{'mailnull'}}, $pid);
				if ( $proc_ref->{$pid}[7] == $pid && $proc_ref->{$pid}[2] =~ /^\/usr\/sbin\/exim/ ) {
					if ( ( $config->{'exim_outgoing'} && $proc_ref->{$pid}[2] =~ /exim_outgoing/ ) || $proc_ref->{$pid}[2] =~ /\-bd/ ) {
						if ( $proc_ref->{$pid}[2] =~ /\-q\s*$config->{'exim_queue_time'}/ ) {
							# Set the status of the primary exim process as up
							# Such is set if the current process is similar to this one /usr/sbin/exim -bd -q1h
							$service_status[0][0] = 1;
							$service_status[0][2] = $pid;
							if (!$config->{'exim_multiple'}) {
								$service_ref->{'exim'}[9]++;		# increase the count of found instances of this service
							}
						}
					}
					if ( $config->{'exim_tls'} && $proc_ref->{$pid}[2] =~ /\-tls-on-connect/ ) {
						# Mark exim listening on tls port as up
						$service_status[0][3] = 1;
					}
					if ($config->{'exim_alt_port'} != 0 && $proc_ref->{$pid}[2] =~ /\-oX $config->{'exim_alt_port'}/ ) {
						# Mark exim listening on alternative port as up
						$service_status[0][1] = 1;
					}
					next;
				}
			}
		}

		if (exists $service_ref->{'mailscanner'}) {
			if ( $user_exists && $users_ref->{$proc_ref->{$pid}[0]} eq 'mailnull' && 
				 $proc_ref->{$pid}[2] =~ /^MailScanner:/ && $proc_ref->{$pid}[7] ) {
				$service_ref->{'mailscanner'}[1] = 1;
				$service_ref->{'mailscanner'}[2] = 0;
				$service_ref->{'mailscanner'}[3] = $pid;
				$service_ref->{'mailscanner'}[4] = 0;
				next;
			}
		}

		if (exists $service_ref->{'postgres'}) {
			if ($user_exists && $users_ref->{$proc_ref->{$pid}[0]} eq 'postgres' && $proc_ref->{$pid}[2] =~ /postmaster/) {
				$service_ref->{'postgres'}[1] = 1;
				$service_ref->{'postgres'}[2] = 0;
				$service_ref->{'postgres'}[3] = $pid;
				$service_ref->{'postgres'}[4] = 0;
				# $service_ref->{'postgres'}[9]++;		# increase the count of found instances of this service
				next;
			}
		}

		if (exists $service_ref->{'named'}) {
			if ($user_exists && $users_ref->{$proc_ref->{$pid}[0]} eq 'named' && $proc_ref->{$pid}[2] =~ '/usr/sbin/named') {
				$service_ref->{'named'}[1] = 1;
				$service_ref->{'named'}[2] = 0;
				$service_ref->{'named'}[3] = $pid;
				$service_ref->{'named'}[4] = 0;
				if ($proc_ref->{$pid}[7] == $pid) {
					$service_ref->{'named'}[9]++;		# increase the count of found instances of this service
				}
				next;
			}
		}

		if (exists $service_ref->{'nscd'}) {
			if ($user_exists && $users_ref->{$proc_ref->{$pid}[0]} eq 'nscd') {
				next if ($proc_ref->{$pid}[2] =~ /worker_nscd/);
				if ($proc_ref->{$pid}[2] eq '/usr/sbin/nscd') {
					$service_ref->{'nscd'}[1] = 1;
					$service_ref->{'nscd'}[2] = 0;
					$service_ref->{'nscd'}[3] = $pid;
					$service_ref->{'nscd'}[4] = 0;
					$service_ref->{'nscd'}[9]++;		# increase the count of found instances of this service
				}
				next;
			}
		}

		# If the process contains either yum or rpm, this process is highly probably to be 1h update
		# this skip is made because guardian will kill yum process who is updating php as result of 'php' word in process cmdline
		# if load is over critical limits when all php processes need to be killed
		if ($proc_ref->{$pid}[2] =~ /\/usr\/bin\/yum\s+/ || $proc_ref->{$pid}[2] =~ /\/bin\/rpm\s+/) {
			next;
		}

		###############################
		# Count some processes here
		###############################
		if ($proc_ref->{$pid}[2] =~ /httpd/) {
			push(@{$proc_stats_ref->{'httpd'}}, $pid);	# This handle both apache httpd pids as well as the litespeed pids as they also contain httpd in their names
			next;
		}
		if ($proc_ref->{$pid}[2] =~ /php/) {
			push(@{$proc_stats_ref->{'php'}}, $pid);
			next;
		}
		if ($proc_ref->{$pid}[2] =~ /ftpd/) {
			push(@{$proc_stats_ref->{'ftp'}}, $pid);
			next;
		}
		if ($config->{'has_spamd'} && $proc_ref->{$pid}[2] =~ /spamc/) {
			push(@{$proc_stats_ref->{'spamc'}}, $pid);
			next;
		}
		# If the pid name contains exim or qmail ...
		if ($proc_ref->{$pid}[2] =~ /exim/ || $proc_ref->{$pid}[2] =~ /qmail/) {
			push(@{$proc_stats_ref->{'smtp'}}, $pid);
			next;
		}
		if ($proc_ref->{$pid}[2] =~ /imapd/ || $proc_ref->{$pid}[2] =~ /pop3/) {
			next if ($proc_ref->{$pid}[2] eq 'imap-login ' );
			push(@{$proc_stats_ref->{'dovecot'}}, $pid);
			next;
		}
		if ($proc_ref->{$pid}[2] =~ /rsync/) {
			$checkNice = 1;
			push(@{$proc_stats_ref->{'rsync'}}, $pid);
			next;
		}
	}
	# end the analyze of the processes here

	if (exists $service_ref->{'exim'}) {
		if ( $service_status[0][0]) {
			# Do not execute the code below if the exim multiprocess monitoring is not enabled
			# Such monitoring is enabled ONLY in case we find ALTPORT OR tls-on-connect in /etc/init.d/exim
			# On newer cPanel versions of exim init script is extremely simple and it does not start multiple exim processes for different jobs
			# On those versions single exim process handle listening on multiple ports as well as on the ssl/tls port 
			# In case of newer cpanel exim init script do not check for alternative exim processes
			if ($config->{'exim_multiprocess_monitoring'}) {
				# if we have detected exim_alt_port and its status is not 1 we consider exim as down
				goto CONT if ($config->{'exim_alt_port'} !=0 && !$service_status[0][1]);
				# if we have detected exim_tls and its status is not 1 we consider exim as down
				goto CONT if ($config->{'exim_tls'} && !$service_status[0][3]);
			}
			# if we have spamd and its status is not 1 we consider exim as down
			goto CONT if ($config->{'has_spamd'} && !$service_status[0][4]);

			# If everything above is up then the entire service is up
			$service_ref->{'exim'}[1] = 1;
			$service_ref->{'exim'}[2] = 0;
			$service_ref->{'exim'}[3] = $service_status[0][2];
			$service_ref->{'exim'}[4] = 0;
		}
	}

	CONT:

	if (exists $service_ref->{'ftp'}) {
		if ( $service_status[1][0] && $service_status[1][1] ) {
			$service_ref->{'ftp'}[1] = 1;
			$service_ref->{'ftp'}[2] = 0;
			$service_ref->{'ftp'}[3] = $service_status[1][2];
			$service_ref->{'ftp'}[4] = 0;
		}
	}

	if (exists $service_ref->{'nginx'}) {	# We want to monitor it
		if ($service_status[5][0] &&			# The main nginx pid is up
			$service_status[5][1]) {			# nginx worker pid is up
			$service_ref->{'nginx'}[1] = 1; 	# The entire service is up
			$service_ref->{'nginx'}[2] = 0;		# No need to restart it
			$service_ref->{'nginx'}[3] = $service_status[5][2];	# This is the pid of the main process
			$service_ref->{'nginx'}[4] = 0;		# Zero restart counter
		}
	}

	if (exists $service_ref->{'cdp-server'}) {	# We want to monitor it
		if ($service_status[6][0] &&			# Main cdp-server process is up
			$service_status[6][1]) {			# cdp-server root owned child is also up
			$service_ref->{'cdp-server'}[1] = 1;	# Mark cdp-server service as up
			$service_ref->{'cdp-server'}[2] = 0;	# Say that there is no need to restart it
			$service_ref->{'cdp-server'}[3] = $service_status[6][2];	# Write down 
			$service_ref->{'cdp-server'}[4] = 0;	# Zero restart counter
		}
	}

	if (exists $service_ref->{'litespeed'}) {	# We want to monitor it
		if ($service_status[4][0]) {				# The main pid is up
			# This is OBSOLETE!!! listespeed lscgid process is no longer monitored
			#$service_status[4][1]) {				# Litespeed lscgid is up as well
			$service_ref->{'litespeed'}[1] = 1; 	# The entire service is up
			$service_ref->{'litespeed'}[2] = 0;		# No need to restart it
			$service_ref->{'litespeed'}[3] = $service_status[4][2];	# This is the pid of the main process
			$service_ref->{'litespeed'}[4] = 0;		# Zero restart counter
		}
	}

	if (exists $service_ref->{'dovecot'}) {
		if ($service_status[2][1] == 0) {
			$dovecot_down_count++;
		}

		# 6 checks represents 3 seconds
		if ($service_status[2][0] &&
			($service_status[2][1] || $dovecot_down_count < 6) &&
			(-e '/var/run/dovecot/login/default' || -e '/var/run/dovecot/login/login')) {
			$service_ref->{'dovecot'}[1] = 1;
			$service_ref->{'dovecot'}[2] = 0;
			$service_ref->{'dovecot'}[3] = $service_status[2][2];
			$service_ref->{'dovecot'}[4] = 0;
		} else {
			$dovecot_down_count = 0;
		}
	}
	if (exists $service_ref->{'courier'}) {
		if ($service_status[3][0] && $service_status[3][1]) {
			goto CONT2 if ($config->{'courier_authd'}	&& !$service_status[3][3]);	# Authd is set for monitoring but it is down
			goto CONT2 if ($config->{'courier_imap_tls'} && !$service_status[3][4]);	# imap_tls is set for monitoring but it is down
			goto CONT2 if ($config->{'courier_pop3_tls'} && !$service_status[3][5]);	# pop3_tls is set for monitoring but it is down
			$service_ref->{'courier'}[1] = 1;
			$service_ref->{'courier'}[2] = 0;
			$service_ref->{'courier'}[3] = $service_status[3][2];
			$service_ref->{'courier'}[4] = 0;			
		}
	}
	CONT2:

	return $checkNice;
}

sub save_old_stats {
	my $stats_ref = shift;
	while ( my $k = each(%{$stats_ref}) )  {
		next if ($k eq 'global');
		# save the current information for this user as last information for him
		$stats_ref->{$k}[4] = $stats_ref->{$k}[0];
		$stats_ref->{$k}[5] = $stats_ref->{$k}[1];
		$stats_ref->{$k}[6] = $stats_ref->{$k}[2];
		$stats_ref->{$k}[7] = $stats_ref->{$k}[3];
		$stats_ref->{$k}[0] = {};
		$stats_ref->{$k}[1] = 0;
		$stats_ref->{$k}[2] = 0;
		$stats_ref->{$k}[3] = 0;
	}
	# save the current reads, writes & process counts and zero the current values
	$stats_ref->{'global'}[3] = $stats_ref->{'global'}[0];
	$stats_ref->{'global'}[4] = $stats_ref->{'global'}[1];
	$stats_ref->{'global'}[5] = $stats_ref->{'global'}[2];
#   $stats_ref->{'global'}[0] = 0;
#   $stats_ref->{'global'}[1] = 0;
	$stats_ref->{'global'}[2] = 0;
}

1;
