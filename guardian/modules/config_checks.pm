#!/usr/bin/perl -T

use strict;
use warnings;

package config_checks;
require Exporter;
our @ISA		= qw(Exporter);
our @EXPORT	 = qw(config_checks);
our $VERSION	= '0.10.0';

$ENV{'PATH'} = '/sbin:/usr/sbin:/bin:/usr/bin';

sub config_checks {
	my $config_ref = shift;
	my $service_ref = shift;
	my $load_vars_ref = shift;

	my %defaults = (
		'logfile' => '/usr/local/1h/var/log/guardian.log',
		'pidfile' => '/usr/local/1h/var/log/guardian.log',
		'kills_log' => '/usr/local/1h/var/log/guardian-kills.log',
		'error_log' => '/usr/local/1h/var/log/guardian-errors.log',
		'status_file' => '/tmp/guardian.status',
		'service_restarts_file' => '/home/1h/tmp/guardian_service_restarts'
	);

	# check files
	foreach my $k(qw( logfile pidfile kills_log error_log status_file init_dir stop_dir restart_dir service_restarts_file)) {
		if (defined($config_ref->{$k})) {
			if ($config_ref->{$k} =~ /^((\/[a-zA-Z0-9_.-]+)+)$/) {
				$config_ref->{$k} = $1;
			} else {
				print "Error: invalid format for configuration option $k\n";
				exit(2);
			}
		} else {
			print "Warning: missing $k config directive. Assuming default: $defaults{$k}\n";
			$config_ref->{$k} = $defaults{$k};
		}
	}

	if (defined($config_ref->{'archivers_re'}) && $config_ref->{'archivers_re'} ne '') {
		if ($config_ref->{'archivers_re'} =~ /^(([\\.a-zA-Z0-9-_ ]+\|?)+)$/) {
			$config_ref->{'archivers_re'} = $1;
		} else {
			print "Error: invalid format for configuration option archivers_re\n";
			exit(2);
		}
	} else {
		print "Warning: missing archivers_re config directive. Assuming default: 'gzip|bzip2|tar |rar|zip'\n";
		$config_ref->{'archivers_re'} = 'gzip|bzip2|tar |rar|zip';
	}

	# Check if fixers_dir is defined in the conf and has correct format
	if (defined($config_ref->{'fixers_dir'}) && $config_ref->{'fixers_dir'} ne '') {
		if ($config_ref->{'fixers_dir'} =~ /^(\/[\/\-_a-zA-Z0-9]+)$/i) {
			$config_ref->{'fixers_dir'} = $1;
		} else {
			print "Error: invalid format for configuration option fixers_dir\n";
			exit(2);
		}
	} else {
		print "Warning: missing fixers_dir config directive. Assuming default: '/usr/local/1h/lib/guardian/fixers'\n";
		$config_ref->{'fixers_dir'} = '/usr/local/1h/lib/guardian/fixers';
	}

	if ($config_ref->{'debug'} != 0 && $config_ref->{'debug'} != 1) {
		print "Warning: invalid value for debug, it should be 1 or 0. Defaulting to 0\n";
		$config_ref->{'debug'} = 0;
	}

	if ($config_ref->{'protected_users'} !~ /^([a-z0-9_-]+,?)+$/) {
		print "Error: invalid value(s) for protected_users.\nCheck for spaces left between the commas or at the end of the line.\n";
		exit(2);
	}

	if (! defined($config_ref->{'mysql_protected'})) {
		$config_ref->{'mysql_protected'} = '';
	}
	if ($config_ref->{'mysql_protected'} ne '' && 
		$config_ref->{'mysql_protected'} !~ /^([a-z0-9_-]+,?)+$/) {
		print "Error: invalid value(s) for mysql_protected.\nCheck for spaces left between the commas or at the end of the line.\n";
		exit(2);
	}

	if ($config_ref->{'check_services'} !~ /^([a-z0-9_-]+,?)+$/) {
		print "Error: invalid value(s) for check_services.\nCheck for spaces left between the commas or at the end of the line.\n";
		exit(2);
	}

	if ($config_ref->{'load_vars'} !~ /^[0-9]+(\.[0-9]+)?,[0-9]+(\.[0-9]+)?,[0-9]+(\.[0-9]+)?$/) {
		print "Error: invalid value(s) for load_vars.\nIt should include only 3 values. Example: load_vars=8,10,15\n";
		exit(2);
	}

	# check and create dirs 
	foreach my $k(qw( restart_dir stop_dir init_dir )) {
		if ( ! -d $config_ref->{$k} ) {
			main::logger($k.'('.$config_ref->{$k}.') is invalid');
			if (mkdir($config_ref->{$k}, 0700)) {
				main::logger($k.'('.$config_ref->{$k}.') created');
			} else {
			 	die('Unable to create '.$k.'('.$config_ref->{$k}.")\n");
			}
		}
	}

	# verify the numbered values in the conf
	foreach my $k (qw( long_procs_exclude extended_kill_log mysql_copy_tmp_time mysql_sleep_query_time mysql_long_query_time mysql_idle_check pause_arch critical_kill_mail critical_kill_arch critical_kill_php critical_kill_ftp high_kill_smtp high_kill_imap high_kill_arch normal_kill_php long_php_time long_imap_time long_process_time time_between_restarts templar)) {
		if (defined($config_ref->{$k})) {
			if ($config_ref->{$k} =~ /^\s*([0-9]+)\s*$/) {
				$config_ref->{$k} = $1;
			} else {
				main::logger("Error: invalid format for $k configuration option!");
				die("Error: invalid format for $k configuration option!\n");
			}
		} else {
			main::logger("Warning: $k configuration option not defined! Defaulting to 0.");
			$config_ref->{$k} = 0;
		}
	}

	if (defined($config_ref->{'exclude_long_re'}) && $config_ref->{'long_procs_exclude'} ) {
		if ( $config_ref->{'exclude_long_re'} eq '' ) {
			main::logger("Warning: missing or empty exclude_long_re config directive. Assuming default: '^\$'\n");
			$config_ref->{'exclude_long_re'} = '^$';
		} else {
			if ($config_ref->{'exclude_long_re'} =~ /^(([\\\/.a-zA-Z0-9-_ ]+\|?)+)$/) {
				$config_ref->{'exclude_long_re'} = $1;
			} else {
				print "Error: invalid format or missing configuration - exclude_long_re\n";
				exit(2);
			}
		}
	}
	
	foreach my $k (split /,/, $config_ref->{'check_services'}) {
		# skip this service if we don't have init script for it
		if ( ! -f $config_ref->{'init_dir'}.'/'.$k.'.sh' ) {
			main::logger("Warning: we don't have init script for this service($k)! The service will not be monitored!");
			next;
		}
		# check if the script is executable
		if ( ! -x $config_ref->{'init_dir'}.'/'.$k.'.sh' ) {
			main::logger("Error: the init script for this service($k) is not executable!") if $config_ref->{'debug'};
			next;
		}
		$service_ref->{$k}[0] = 1;	# we should check this service
		$service_ref->{$k}[3] = 0;	# we don't have pid of the service
		$service_ref->{$k}[4] = 0;	# count of start attempts
		$service_ref->{$k}[5] = 0;
		$service_ref->{$k}[6] = 0;	# we don't have pid of a start process
		$service_ref->{$k}[7] = 0;	# we don't have pid of a restart process
		$service_ref->{$k}[8] = 1;	# we would have only one instance of this service
		$service_ref->{$k}[9] = 0;	# zero the number of found instanses
		$service_ref->{$k}[10] = 0;   # we don't need to notify the all logged users
		$service_ref->{$k}[11] = 1;   # we have init script for this service
	}

	if (exists $service_ref->{'courier'}) {
		$config_ref->{'courier_imap_tls'} = 0 if ( !defined($config_ref->{'courier_imap_tls'}) );
		$config_ref->{'courier_pop3_tls'} = 0 if ( !defined($config_ref->{'courier_pop3_tls'}) );
		$config_ref->{'courier_authd'} = 0 if ( !defined($config_ref->{'courier_authd'}) );
	}

	for my $v (split /,/, $config_ref->{'load_vars'}) {
		if ($v =~ /^([0-9]+)$/) {
			push(@{$load_vars_ref}, $1);
		} else {
			main::logger('Incorrect value('.$v.') in load_vars configuration');
			die "Incorrect value($v) in load_vars configuration\n";
		}
	}

	if ( ! -f $config_ref->{'status_file'}) {
		main::logger('Note: missing status file, creating it!');
		open S, '>', $config_ref->{'status_file'};
		close S;
	}

	# By default the queue check is turned on
	if ( -x '/usr/sbin/exim' ) {
		# If this is exim just use exim -bpc
		$config_ref->{'queue_cmd'} = '/usr/sbin/exim -bpc';
	} elsif ( -x '/var/qmail/bin/qmail-qstat' ) {
		# If this is qmail use find + wc :)
		$config_ref->{'queue_cmd'} = '/usr/bin/find /var/qmail/queue/mess -type f | /usr/bin/wc -l';
	}
}
