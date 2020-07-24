#!/usr/bin/perl -T
use strict;
use warnings;
use POSIX qw(strftime setsid :sys_wait_h getgrnam);
use IPC::SysV qw(ftok IPC_CREAT IPC_STAT IPC_SET S_IRUSR S_IWUSR S_IRGRP);
use lib qw (/usr/local/1h/lib/perl /usr/local/1h/lib/guardian/modules);
use parse_config;
use config_checks;
use nice;
use get_load;
use get_users;
use service_functions;
use proc_funcs;
use analyze_proc_data;
use detect_exim;
use detect_courier;
use mysql_funcs;

$ENV{'PATH'} = '/sbin:/usr/sbin:/bin:/usr/bin';

our $VERSION = '0.20.12';
my $config_file = '/usr/local/1h/etc/guardian.conf';
my $debug = 0;
my %proc = ();
my %kprocs = ();
my @long_processes = ();
my @mailnull = ();
my @suexec = ();
my @rsync = ();
my @httpd = ();
my @kills = ();
my @smtp = ();
my @dovecot = ();
my @ftp = ();
my @php = ();
my @stopped_procs = ();
my %protected_users = ();
my %mysql_protected = ();
my $mysql_procs = 0;
my $newload = 0;
my $checknice = 0;
my %ioclass = ( 0 => 'none', 1 => 'realtime', 2 => 'best-effort', 3 => 'idle' );
# load types:
# 0 - steady not changing
# 1 - increasing
# 2 - decreasing
my $loadtype = 0;
my @loadinfo = ();
my @load_vars = ();
my @proc_counts = ();
our @sda = 0;
our @sdb = 0;
my $current_time = 0;
my $curload = 0;
my %users = ();
my %stats = ();
my $logfile = '';
my $pidfile = '';
my $init_dir = '';
my $umask = umask;
my $mysql_root_pass = '';
my $mysql_idle_check = 1;
my $mysql_host = '';
my $mysql_conn_check = 1;
my $max_mysql_conns = 0;
my $min_free_mysql_conns = 5;
# Last state returned by $mysql_conn_check
my $mysql_conn_check_status = 1;
# Rotate tcp and unix socket
my $mysql_conn_rotate = 0;

if ( ! -f '/usr/local/1h/etc/services.conf' ) {
	print "Missing services.conf file!\n";
	exit(2);
}
my %service_id = parse_config('/usr/local/1h/etc/services.conf');

for (my $i=0; $i<=$#ARGV; $i++) {
	if (defined($ARGV[$i])) {
		if ($ARGV[$i] eq 'help') {
				print "Usage: guardian [debug] [conf config] [log logfile] [version]\n";
				exit;
		} elsif ($ARGV[$i] eq 'version') {
			print "Guardian version: $VERSION\nBuilt-in modules:\n";
			printf "  nice: %s\n", $nice::VERSION;
			printf "  service_functions: %s\n", $service_functions::VERSION;
			printf "  proc_funcs: %s\n", $proc_funcs::VERSION;
			printf "  analyze_proc_data: %s\n", $analyze_proc_data::VERSION;
			printf "Shared modules:\n";
			printf "  parse_config: %s\n", $parse_config::VERSION;
			printf "  get_load: %s\n", $get_load::VERSION;
			printf "  get_users: %s\n", $get_users::VERSION;
			printf "  detect_exim: %s\n", $detect_exim::VERSION;
			printf "  detect_courier: %s\n", $detect_courier::VERSION;
			printf "  mysql_funcs: %s\n", $mysql_funcs::VERSION;
			printf "  config_checks: %s\n", $config_checks::VERSION;
			exit;
		} elsif ($ARGV[$i] eq 'debug') {
				$debug = 1;
		} elsif ($ARGV[$i] eq 'pid' && defined($ARGV[$i+1])) {
			$pidfile = $ARGV[$i+1];
		} elsif ($ARGV[$i] eq 'log' && defined($ARGV[$i+1])) {
			if ( -f $ARGV[$i+1] ) {
				$logfile = $ARGV[$i+1];
			} else {
				print 'Invalid log file location('.$ARGV[$i+1].").\n";
				exit;
			}
		} elsif ($ARGV[$i] eq 'initdir' && defined($ARGV[$i+1])) {
			if ( -d $ARGV[$i+1] ) {
				$init_dir = $ARGV[$i+1];
			} else {
				print 'Invalid init_dir location('.$ARGV[$i+1].").\n";
				exit;
			}
		} elsif ($ARGV[$i] eq 'conf' && defined($ARGV[$i+1])) {
			if ( -f $ARGV[$i+1] ) {
				$config_file = $ARGV[$i+1];
			} else {
				print 'Invalid config file location('.$ARGV[$i+1].").\n";
				exit;
			}
		}
	}
}

if ( ! -f $config_file ) {
	print "Error: missing configuration file($config_file)!\n";
	exit(1);
}
my %config = parse_config($config_file);
$config{'logfile'} = $logfile if ($logfile ne '');
$config{'pidfile'} = $pidfile if ($pidfile ne '');
$config{'init_dir'} = $init_dir if ($init_dir ne '');

# Defaults if variables for oom are not set or out of bounds
$config{'oom_adj'} = -10 if (! defined($config{'oom_adj'}) || $config{'oom_adj'} < -17 || $config{'oom_adj'} > 15);
$config{'oom_score_adj'} = -600 if (! defined($config{'oom_score_adj'}) || $config{'oom_score_adj'} < -1000 || $config{'oom_score_adj'} > 1000);

get_exim_queue(\%config);
get_exim_info(\%config);
modify_exim_init(\%config);
check_courier(\%config);

$config{'debug'} = 1 if $debug;

# %stats hash details:
#  $stats{$user}[0] - process count
#  $stats{$user}[1] - reads
#  $stats{$user}[2] - writes
#  $stats{$user}[3] - idle processes killed for the last 10min
#  $stats{$user}[4] - idle processes killed for the last 30min
#  $stats{$user}[5] - idle processes killed for the last 1h
$stats{'global'}[0] = 0;
$stats{'global'}[1] = 0;
$stats{'global'}[2] = 0;

my %proc_stats = (
	'niced_count' => 0,
	'long_processes' => [],
	'archivers' => [],
	'stopped' => [],
	'suexec' => [],
	'httpd' => [],
	'kills' => [],
	'dovecot' => [],
	'mailnull' => [],
	'smtp' => [],
	'ftp' => [],
	'php' => [],
	'rsync' => []
);

# %service hash details:
# 	$service{$service}[0] - should we check this service 1/0 (yes/no)
# 	$service{$service}[1] - status 0/1 (down/up)
# 	$service{$service}[2] - should we restart it 0/1 (no/yes)
# 	$service{$service}[3] - pid of the current process (default 0)
# 	$service{$service}[4] - count of start attempts (default 0)
# 	$service{$service}[5] - too many start attempts 1/0 (default 0)
# 	$service{$service}[6] - time when the restart process was last started (default 0)
# 	$service{$service}[7] - pid of the restart process (default 0)
# 	$service{$service}[8] - how many instances can this service have (default 1)
# 	$service{$service}[9] - count of found instances
#	$service{$service}[10] - should we notify all logged users for the restart
#	$service{$service}[11] - do we have an init script for the service
#   $service{$service}[12] - how many times we considered service as up via another service
#   $service{$service}[13] - do not trigger restarts even if service is down 0 restart 1 do not restart


my %service = ();

if (defined($config{'logfile'})) {
	if ($config{'logfile'} =~ /^((\/[a-zA-Z0-9_.-]+)+)$/) {
		$config{'logfile'} = $1;
	} else {
		print "Error: invalid format for configuration option logfile\n";
		exit(2);
	}
} else {
	print "Warning: missing logfile config directive. Assuming default: /usr/local/1h/var/log/guardian.log\n";
	$config{'logfile'} = '/usr/local/1h/var/log/guardian.log';
}

umask 077;
open my $LOG, '>>', $config{'logfile'} or die('Unable to open logfile('.$config{'logfile'}."): $!\n");
umask($umask);

config_checks(\%config,\%service,\@load_vars);
umask 077;
open my $KILLS, '>>', $config{'kills_log'} or die('Unable to open kills log('.$config{'kills_log'}."): $!\n");
umask($umask);


# check if the daemon is running
if ( -e $config{'pidfile'} ) {
	# get the old pid
	umask 077;
	open my $PIDFILE, '<', $config{'pidfile'} or die("DIE: Can't open pid file(".$config{'pidfile'}."): $!\n");
	my $old_pid = <$PIDFILE>;
	close $PIDFILE;
	umask($umask);
	# check if $old_pid is still running
	if ( $old_pid =~ /[0-9]+/ ) {
		if ( -d "/proc/$old_pid" ) {
			die "DIE: Daemon is already running!\n";
		}
	} else {
		die "DIE: Incorrect pid format!\n";
	}
}

get_mysql_details(\$mysql_root_pass,\$mysql_host);
print "Gathered mysql info - host: $mysql_host  pass: $mysql_root_pass\n" if ($debug);

$mysql_idle_check = 0 if ($mysql_root_pass eq '');
if (! test_mysql_conn($mysql_root_pass,$mysql_host)) {
	$mysql_idle_check = 0;
	$mysql_conn_check = 0;
}
$mysql_idle_check = 0 if (defined($config{'mysql_idle_check'}) && $config{'mysql_idle_check'} == 0 );

$mysql_conn_check = 0 if ($mysql_root_pass eq '');
$mysql_conn_check = 0 if (defined($config{'mysql_conn_check'}) && $config{'mysql_conn_check'} == 0 );

$max_mysql_conns = get_max_mysql_conns($mysql_root_pass,$mysql_host) if ($mysql_conn_check);
$mysql_conn_check = 0 if ($max_mysql_conns < 1);

$min_free_mysql_conns = $config{'min_free_mysql_conns'} if (defined($config{'min_free_mysql_conns'}) && $config{'min_free_mysql_conns'} ne '' && $config{'min_free_mysql_conns'} =~ /^([0-9]+)$/);

my $oneh_gid = getgrnam('1h');
$oneh_gid =~ s/^.*x([0-9]+)$/$1/;

my $shmsize = 2000;
my $shmkey = ftok($config{'status_file'},42);
my $shm_id = shmget($shmkey, $shmsize, IPC_CREAT|S_IRUSR|S_IWUSR|S_IRGRP);
defined($shm_id) || die "Error: $!";
my $shm_info = '';
shmctl($shm_id, IPC_STAT, $shm_info);
my @shm_struct = unpack('S*', $shm_info);
$shm_struct[4] = $oneh_gid;
$shm_struct[10] = 0640;
shmctl($shm_id, IPC_SET, pack('s*', @shm_struct));
undef $shm_info;
undef @shm_struct;

my $clear = '';
for (1-1800) {
	$clear .= "\0";
}
shmwrite($shm_id, $clear, 0, 1800) or die "Error: unable to clear SHM: $!\n";


## Define functions used by the daemon

if (!$config{'debug'}) {
	# become daemon
	defined(my $pid=fork) or die "DIE: Cannot fork process: $! \n";
	exit if $pid;
	setsid or die "DIE: Unable to setsid: $!\n";
}
# Signal Handlers should be setup here. Using POSIX signal handling for better portability
sub raper {
	my $child;
	while (($child = waitpid(-1,WNOHANG)) > 0) { ; }
	$SIG{CHLD} = \&raper;  # reinstate the handler
}
$SIG{CHLD} = \&raper;

if (!$config{'debug'}) {
	# redirect standart file descriptors to /dev/null
	open(STDIN, '<', '/dev/null') or die("DIE: Cannot read stdin: $! \n");
	open(STDOUT, '>>', '/dev/null') or die("DIE: Cannot write to stdout: $! \n");
	umask 077;
	open(STDERR, '>>', $config{'error_log'}) or die("DIE: Cannot write to stderr: $! \n");
	umask($umask);
}

# write the program pid to the $pidfile
umask 077;
open my $PIDFILE, '>', $config{'pidfile'} or die("DIE: Unable to open pidfile ".$config{'pidfile'}.": $!\n");
print $PIDFILE $$;
close $PIDFILE;
umask($umask);

sub logger {
	if ($config{'debug'}) {
		print strftime('%b %d %H:%M:%S', localtime(time)) . ' ' . $_[0] ."\n";
	} else {
		print $LOG strftime('%b %d %H:%M:%S', localtime(time)) . ' ' . $_[0] ."\n";
	}
}
sub kill_log {
	print $KILLS strftime('%b %d %H:%M:%S', localtime(time)) . ' ' . $_[0] ."\n";
}
sub adjust_oom_scores {
	my $config = shift;

	# Adjust Giardian's oom score based on config. If unsuccessfull just continue
	if (-e "/proc/$$/oom_score_adj") {
		open my $OOM_SCORE_ADJ, '>', "/proc/$$/oom_score_adj" or logger("Warn: Unable to open /proc/$$/oom_score_adj for writing: $!") and return;
		print $OOM_SCORE_ADJ "$config->{'oom_score_adj'}" or logger("Warn: Unable to adjust /proc/$$/oom_score_adj to $config->{'oom_score_adj'}: $!") and return;
		close $OOM_SCORE_ADJ;
	} elsif (-e "/proc/$$/oom_adj") {
		open my $OOM_ADJ, '>', "/proc/$$/oom_adj" or logger("Warn: Unable to open /proc/$$/oom_adj for writing: $!") and return;
		print $OOM_ADJ "$config->{'oom_adj'}" or logger("Warn: Unable to adjust /proc/$$/oom_adj to $config->{'oom_adj'}: $!") and return;
		close $OOM_ADJ;
	}
}

# make the output to LOG and to STDOUT unbuffered
# this has to be done after the fork and after detaching from the command terminal
$|=1;
select((select($LOG), $| = 1)[0]);
select((select($KILLS), $| = 1)[0]);

#$0 = '[GuarDian]';

logger("Guardian version $VERSION started. Pid: $$");

adjust_oom_scores(\%config);

$curload = get_load();
get_users(\%users);

# populate the $protected_users hash
foreach my $user(split(',',$config{'protected_users'})) {
	while (my $u = each(%users)) {
		if ($users{$u} eq $user) {
			$protected_users{$u} = $users{$u};
		}
	}
}

# populate the %mysql_protected hash
foreach my $u(split(',',$config{'mysql_protected'})) {
	$mysql_protected{$u} = 0;
}

my $last_users_update = 0;
my $last_loadtype = 0;
my $last_mysql_idle_check = 0;
my $last_mysql_proc_check = 0;
my $last_mysql_conn_check = 0;
my $queue = 0;

#sub proc_count { $stats{$b}[1] <=> $stats{$a}[1] };

my $kthread_pid = proc_funcs::find_kthread(\%proc, \%kprocs);
proc_funcs::find_kernel_procs(\%kprocs, $kthread_pid);

while (1) {
	# zero all used variables
	$proc_stats{'long_processes'} = [];
	$proc_stats{'archivers'} = [];
	$proc_stats{'suexec'} = [];
	$proc_stats{'httpd'} = [];
	$proc_stats{'kills'} = [];
	$proc_stats{'dovecot'} = [];
	$proc_stats{'mailnull'} = [];
	$proc_stats{'spamc'} = [];
	$proc_stats{'smtp'} = [];
	$proc_stats{'ftp'} = [];
	$proc_stats{'php'} = [];
	$proc_stats{'rsync'} = [];

	%proc = ();
	# %stats = ();
	while ( my $k = each (%service) ) {
		$service{$k}[1] = 0;	# the service is down
		$service{$k}[2] = 0;	# we don't have to restart the service
		$service{$k}[9] = 0;	# clear the count of found instances
	}
	$current_time = time();

	if ($current_time - $last_loadtype > 5) {
		# execute this code every 5 seconds
		($loadtype,$curload) = get_loadtype($curload,\%config,\@loadinfo);
		$last_loadtype = $current_time;
		if (exists $config{'queue_cmd'}) {
			$queue = `$config{'queue_cmd'}`;
			# Remove all chars we do not need
			$queue =~ s/(\r|\n)//g;
		}
	}

	# reload the users hash every 300 seconds (5min)
	if ( $current_time - $last_users_update > 300 ) {
		get_users(\%users);
		proc_funcs::find_kernel_procs(\%kprocs, $kthread_pid);
		$last_users_update = $current_time;
		logger("Users refreshed") if $config{'debug'};
	}

	analyze_proc_data::save_old_stats(\%stats);
	proc_funcs::gather_proc_info(\%stats, \%proc, \%kprocs);

	# add the current process count so we can check it in the future
	# and remove too old values from the array
	push(@proc_counts,$stats{'global'}[2]);
	shift(@proc_counts) if ($#proc_counts > 10);

	$checknice = analyze_proc_data::analyze_proc_data(
		$loadtype,
		\%proc,
		\%service,
		\%users,
		\%protected_users,
		\%proc_stats,
		$current_time,
		\%config
	);

	# kill logic starts here
	###
	
	proc_funcs::kill_zombies(\%proc, \%proc_stats, \%config);
	proc_funcs::kill_long_procs(\%proc_stats, \%proc, $loadtype, $current_time, $curload, \@load_vars, \%users, \%config);
	proc_funcs::kill_logic($curload,\%proc_stats,\%proc, \%config, \@load_vars, $loadtype, $current_time);

	if ($checknice) {
		nice::nice_ionice_procs(\%proc,\%proc_stats,\@load_vars, $curload);
	}


	if ($curload < $load_vars[1]-1) {
		service_functions::start_restart_services(\%service,\%proc,\%config,\%service_id);
	}

	# run the mysql idle scan only when the load is over 3
	# and there is no other scan process allready running
	# and the last known pid is not existing
	if ($mysql_idle_check) {
		if ( $curload > 3 && $current_time - $last_mysql_idle_check > 20 ) {
			scan_for_idle_mysql($mysql_root_pass, $mysql_host, \%config, \%mysql_protected, $mysql_procs);
			$last_mysql_idle_check = $current_time;
		} elsif ($current_time - $last_mysql_proc_check > 5) {
			my @data;
			get_mysql_procs($mysql_root_pass, $mysql_host, \@data);
			$mysql_procs = scalar(@data)-1;
			$last_mysql_proc_check = $current_time;
		}
	}

	# If mysql monitoring is enabled and $mysql_conn_check is enabled
	if (defined($service{'mysql'}) && $mysql_conn_check) {
		# get_current_mysql_conns only if we did not checked for the number of active mysql connections more than 5 seconds ago
		if ($current_time - $last_mysql_conn_check > 5) {
			logger("Calling get_current_mysql_conns") if ($debug);
			my $active_connections = get_current_mysql_conns($mysql_root_pass, $mysql_host, \$mysql_conn_rotate);
			logger("get_current_mysql_conns returned $active_connections. max connections are set to $max_mysql_conns.") if ($debug);

			# If the number of active connections is less than zero (get_current_mysql_conns returned error)
			# or connections are almost exceeded
			if ($active_connections < 0 || ($max_mysql_conns - $active_connections) <= $min_free_mysql_conns) {
				logger("Marking mysql as down. Active connections: $active_connections < 0 or $max_mysql_conns - $active_connections <= $min_free_mysql_conns");
				# Mark mysql as down without restarting it
				$service{'mysql'}[1] = 0;
				# Set the value of $mysql_conn_check_status to down
				$mysql_conn_check_status = 0;
			} else {
				logger("MySQL conns are normal") if ($debug);
				$mysql_conn_check_status = 1;
			}

			# Do not perform the same check during the 
			$last_mysql_conn_check = $current_time;
		} elsif ($mysql_conn_check_status == 0) {
			# If the last value returned by $mysql_conn_check_status is down (0) continue to show mysql service as down until we enter get_current_mysql_conns check again and both analyze_proc_data and get_current_mysql_conns say that mysql is up
			logger("Last get_current_mysql_conns check showed that mysql connections are exceeded. I will continue to confirm that for the next 5 seconds even I don't run the same check again") if ($debug);
			$service{'mysql'}[1] = 0;
		}
	}

	my $shm_pos = 0;
	my $templar_status = '';
	my $status_string = sprintf('%d:%.2f:%d:%d:%d:%d:', $current_time, $curload, $stats{'global'}[2], $queue, $#{$proc_stats{'httpd'}}+1, $mysql_procs);
	my $status_length = length($status_string);
	shmwrite($shm_id, $clear, 0, 1800) or logger('Error: unable to clear SHM(2): '.$!);
	shmwrite($shm_id, $status_string, $shm_pos, $status_length) or logger('Error: unable to write to SHM: '.$!);
	$shm_pos += $status_length;

	while ( my $k = each(%service) ) {
		$status_string = sprintf('%d,%d:', $service_id{$k}, $service{$k}[1]);
		$status_length = length($status_string);
		shmwrite($shm_id, $status_string, $shm_pos, $status_length) or logger('Error: unable to write to SHM: '.$!);
		$shm_pos += $status_length;
		$templar_status .= $status_string;
	}

	if ($config{'debug'}) {
		print $current_time.':: ';
		# however in the production it is not passed to the lifesigns/archon yet because additional changes are required
		while ( my $k = each(%service) ) {
			print $k.':'.$service{$k}[1].'('.$service{$k}[3].")\t";
		}
		print "\n";
	}
	# Skip the update of the status file if templar is not defined
	if (!exists($config{'templar'}) or $config{'templar'} != 1) {
		goto finish;
	}
	umask 022;
	open my $STATUS, '>', $config{'status_file'} or logger('Unable to open '.$config{'status_file'}.': '.$!);
	umask($umask);
	printf $STATUS '%d:%.2f:%d:%d:%d:%d:',	$current_time, $curload, $stats{'global'}[2], $queue, $#{$proc_stats{'httpd'}}+1, $mysql_procs;
	printf $STATUS $templar_status;
	print $STATUS "\n";
	printf $STATUS "Load: %.2f\nExims: %d\nSpamc: %d\nMailnull: %d\nIMAPD: %d\nFTP: %d\nApache: %d\nSuexec: %d\nPHP: %d\nRsyncs: %d\nStopped: %d\nArchivers: %d\nNiced: %d\n",
		$curload,
		$#{$proc_stats{'smtp'}},
		$#{$proc_stats{'spamc'}},
		$#{$proc_stats{'mailnull'}},
		$#{$proc_stats{'dovecot'}},
		$#{$proc_stats{'ftp'}},
		$#{$proc_stats{'httpd'}}+1,
		$#{$proc_stats{'suexec'}},
		$#{$proc_stats{'php'}},
		$#{$proc_stats{'rsync'}},
		$#{$proc_stats{'stopped'}},
		$#{$proc_stats{'archivers'}},
		$proc_stats{'niced_count'};

	print $STATUS "Global info:\n=================================\n";
	printf $STATUS "Current user reads: %d\twrites: %d\nLast	user reads: %d\twrites: %d\nCurrent process count: %d\nLast	process count: %d\n=================================\n",
		$stats{'global'}[0] ? $stats{'global'}[0] : 0,
		$stats{'global'}[1] ? $stats{'global'}[1] : 0,
		$stats{'global'}[3] ? $stats{'global'}[3] : 0,
		$stats{'global'}[4] ? $stats{'global'}[4] : 0,
		$stats{'global'}[2],
		$stats{'global'}[5];
	print $STATUS "Top users:\n===============================\n";

	finish:
	# sleep for 500ms
	select(undef, undef, undef, 0.5);
}
close $KILLS;
close $LOG;
