#!/usr/bin/perl -T

use strict;
use warnings;
use POSIX qw(setsid strftime :sys_wait_h);
use IO::Socket::INET;
use IPC::SysV qw(ftok IPC_CREAT S_IRUSR S_IWUSR);
use lib qw(/usr/local/1h/lib/perl);
use parse_config;

our $conf = '/usr/local/1h/etc/lifesigns.conf';
our %config = parse_config($conf);
our %service_ids = parse_config('/usr/local/1h/etc/services.conf');
our %service_names = ();
while (my ($k,$v) = each %service_ids) {
	$service_names{$v} = $k if (! exists ($service_names{$v}));
}

$0 = '[LifeSigns]';
my $VERSION = '0.3.6';
my $logfile = '/var/log/lifesigns.log';
my $pidfile = '/var/run/lifesigns.pid';
my $listen_address = '127.0.0.1';
my $listen_port = '1022';
our $conn_count = 0;
our $max_conns = 20;
my $max_conns_per_ip = 1;
my $timeout = 30;
my $server = ();
my $server_pid = ();
our %clients = ();
my %allow_from = ();
my %allow_root = ();
our %pid_ip = ();
my $debug = 0;
my $umask = 18;
my $shm_size = 2000;


$debug=1 if ( ( defined($ARGV[0]) && $ARGV[0] =~ /debug/ ) || ( defined($config{'debug'}) && $config{'debug'} == 1 ) );

if (defined($config{'listen_addr'})) {
	$listen_address = $1 if ($config{'listen_addr'} =~ /^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})$/);
} else {
	die "Error: unable to find listen_addr in configuration\n";
}
if (defined($config{'listen_port'}) && $config{'listen_port'} =~ /^([0-9]+)$/ && $1 > 150 && $1 < 65533) {
	$listen_port = $1;
} else {
	print "Error: invalid port configured for listen_port\n";
	exit(2);
}
if (defined($config{'max_conns_perIP'}) && $config{'max_conns_perIP'} =~ /^([0-9]+)$/) {
	$max_conns_per_ip = $1;
} else {
	print "Error: invalid value for max_conns_perIP. Should be integer!\n";
	exit(2);
}
if (defined($config{'max_conns'}) && $config{'max_conns'} =~ /^([0-9]+)$/) {
	$max_conns = $1;
} else {
	print "Error: invalid value for max_conns. Should be integer.\n";
	exit(2);
}
if (defined($config{'client_timeout'}) && $config{'client_timeout'} =~ /^([0-9]+)$/) {
	$timeout = $1;
} else {
	print "Error: invalid value for client_timeout. Should be integer.\n";
	exit(2);
}
if (defined($config{'status_file'}) && $config{'status_file'} =~ /^((\/[a-zA-Z0-9_.-]+)+)$/) {
	$config{'status_file'} = $1;
} else {
	print "Error: error in the path for status_file\n";
	exit(2);
}
if (defined($config{'log_file'}) && $config{'log_file'} =~ /^((\/[a-zA-Z0-9_.-]+)+)$/) {
	$logfile = $1;
} else {
	print "Error: error in the path for log_file\n";
	exit(2);
}
if (defined($config{'pid_file'}) && $config{'pid_file'} =~ /^((\/[a-zA-Z0-9_.-]+)+)$/) {
	$pidfile = $1;
} else {
	print "Error: error in the path for pid_file\n";
	exit(2);
}

if (defined($config{'allow_from'})) {
	foreach my $addr (split(" ", $config{'allow_from'})) {
		$allow_from{$1} = 1 if ($addr =~ /^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})$/ );
		print "Allowed IP: $1\n" if $debug;
	}
} else {
	die("Error: unable to find allow_from in configuration\n");
}
if (defined($config{'allow_root'})) {
	foreach my $addr (split(" ", $config{'allow_root'})) {
		$allow_root{$1} = 1 if ($addr =~ /^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})$/ );
		print "Allowed root from IP: $1\n" if $debug;
	}
} else {
	die("Error: unable to find allow_root in configuration\n");
}
if ( ! -f $config{'status_file'}) {
	open S, '>', $config{'status_file'};
	close S;
}

my $shmkey = ftok($config{'status_file'},42);
my $shm_id = shmget($shmkey, $shm_size, IPC_CREAT|S_IRUSR|S_IWUSR);
defined($shm_id) || die "Error: $!";

$umask = umask();
umask(066);
open LOG, '>>', $logfile or die "DIE: Unable to open logfile $logfile: $!\n";
umask($umask);
sub logger {
	print LOG strftime('%b %d %H:%M:%S', localtime(time)) . ' ' . $_[0] . "\n";
}
sub get_time {
	return strftime('%b %d %H:%M:%S', localtime(time));
}
sub sigHup {
	# reread configuration
	%config = parse_config($conf);
	$SIG{"HUP"} = \&sigHup;
}
sub sigTerm {
	logger("Somebody sent me a TERM signal ... Perhaps I was stopped with my init.d script?");
	close(LOG);
	exit(0);
}
sub sigChld {
	my $kid;
	do {
		$kid = waitpid(-1, WNOHANG);
		$conn_count-- if ($kid > 0);
		$clients{$pid_ip{$kid}}-- if (defined($pid_ip{$kid}) && exists $clients{$pid_ip{$kid}});

	} while ($kid > 0);
	while (my $k = each %pid_ip) {
		next if ! defined($pid_ip{$k});
		if ( ! -d "/proc/$k" ) {
			if (defined($clients{$pid_ip{$k}}) && $clients{$pid_ip{$k}} > 0) {
				$clients{$pid_ip{$k}}--;
			}
			delete $pid_ip{$k};
		}
	}

    logger("Current connections: $conn_count Max: $max_conns")
}

sub handle_client {
	my $handler = shift;
	my $client_ip = shift;
	my $client_timeout = shift;
	my $allow_root_ref = shift;
	my $invalid_cmd_count = 0;
	$0 = "[LifeSigns handling $$client_ip]";
	select((select($handler), $| = 1)[0]);
	print $handler '$ ';
	eval {
		local $SIG{ALRM} = sub { die 'Timeout' };
		alarm $$client_timeout;
		while(<$handler>) {
			next unless /\S/; # blank line
			next if ! defined($_);
			alarm $$client_timeout;
			if (/^status[\r|\n]+$/) {
				print $handler status_cmd();
				last;
			} elsif (/^stat[\r|\n]+$/) {
				explain_status($handler);
			} elsif (/^root[\r|\n]+$/) {
				alarm 0;
				root_cmd($handler,$client_ip,$allow_root_ref);
				last;
			} elsif (/^exit|^quit/i) {
				print $handler "Thank you for your time!\n";
				logger("Client $$client_ip exited!");
				last;
			} elsif (/^help[\r|\n]+$/) {
				print $handler "Available commands:\n\thelp - this help\n\tstatus - server status information\n\tstat - human readable server status information\n\tquit - leave this service\n";
				print $handler "\troot - enter in root shell\n" if (exists $allow_root_ref->{$$client_ip});
				print $handler '$ ';
			} elsif (/^[\r|\n]+$/ ) {
				next;
			} else {
				$invalid_cmd_count++;
				logger('Client '.$$client_ip.' used invalid command: '.$_);
				print $handler "Incorrect command...\n\$ ";
				last if ($invalid_cmd_count > 3);
			}
		}
		alarm 0;
		close $handler;
	};
 	if ($@ =~ /^Timeout/) {
		print $handler "Inactivity timeout $$client_timeout secs!\n";
		logger('Client '.$$client_ip.' timeout!');
 	}
	close $handler;
	exit(0);
}

sub root_cmd {
	my $conn_handler = shift;
	my $client_ip = shift;
	my $allow_root_ref = shift;

	if ( ! exists $allow_root_ref->{$$client_ip} ) {
		logger("Client $$client_ip not allowed to use root here!");
		print $conn_handler "You are not allowed to w00t here!\n\$ ";
		return 1;
	}
	logger("Client $$client_ip logged into w00t mode");
	print $conn_handler "Going into w00t mode\n";

	$ENV{PATH} = '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin';
	$ENV{TERM} = 'xterm';

	open(STDIN, '<&', $conn_handler) or logger("Unable to reopen stdin: $!");
	open(STDOUT, '>&', $conn_handler) or logger("Unable to reopen stdout: $!");
	open(STDERR, '>&', $conn_handler) or logger("Unable to reopen stderr: $!");
	select((select(STDIN),  $|=1)[0]);
	select((select(STDOUT), $|=1)[0]);
	select((select(STDERR), $|=1)[0]);

	system("/bin/bash -i");

	close STDIN;
	close STDOUT;
	close STDERR;

	$ENV{PATH} = '';

	open STDIN, '<', '/dev/null' or die "DIE: Cannot read stdin: $! \n";
	open STDOUT, '>>', '/dev/null' or die "DIE: Cannot write to stdout: $! \n";
    open STDERR, '>>', '/dev/null' or die "DIE: Cannot write to stderr: $! \n";

	return 0;
}

sub explain_status {
	my $handler = shift;
	my $stat = status_cmd();
	if ($stat =~ /^[0-9]+:/) {
		my @info = split /:/, $stat;
		printf $handler "LifeSigns version: $VERSION\n  System load: %.2f\n  System processes count: %d\n  Mail queue count: %d\n  HTTP Processes: %d\n  MySQL Processes: %d\n",
			$info[1], $info[2], $info[3], $info[4], $info[5];
		for (my $i=6; $i<=$#info; $i++) {
			next if ($info[$i] =~ /^\s*$/);
			my @service = split /,/, $info[$i];
			my $sep = "\t";
			my $svc = $service_names{$service[0]};
			$sep = "\t\t" if (length($svc) < 5);
			next if ($svc =~ /^\s*$/);
			printf $handler "  %s:$sep%s\n", $svc, $service[1] ? 'UP' : 'DOWN';
		}
		if ( $info[0] > 5 ) {
			print $handler "  Guardian:\tDOWN ($info[0] secs)\n";
		} else {
			print $handler "  Guardian:\tUP ($info[0] secs)\n";
		}
	} else {
		print $handler "Incorrect status information\n";
	}
	print $handler '$ ';
}

sub status_cmd {
	my $status = undef;
	shmread($shm_id, $status, 0, $shm_size);
	if (defined($status) && length($status) > 0) {
		$status =~ s/\0//g;
		$status =~ m/^([0-9]+):.*$/;
		my $diff = time() - $1;
		$status =~ s/^[0-9]+:/$diff:/;
	} else {
		$status = '120:0.00:0:0:0:0:';
	}
	return $status;
}

sub check_ip {
	my $client = shift;
	# check if the client is allowed to connect
	if ( exists $allow_from{$client} ) {
		if (exists $clients{$client}) {
			logger("Accepted connectionf from: $client (". $clients{$client} .')');
		} else {
			logger("Accepted connectionf from: $client (0)");
		}
		logger("Current connections: $conn_count Max: $max_conns") if $debug;
	} else {
		logger("Client $client denied connection!");
		$conn_count--;
		return 1;
	}
	if ( exists $clients{$client} ) {
		$clients{$client}++;
	} else {
		$clients{$client} = 1;
	}
	if ($clients{$client} > $max_conns_per_ip) {
		logger("Too many connections(".$clients{$client}.") from $client , connection denied!");
		$conn_count--;
		return 1;
	}
	return 0;
}

# start the actual daemon
logger("LifeSigns $VERSION started. Current: $conn_count Max: $max_conns!");

if ( -e $pidfile ) {
	open PIDFILE, '<', "$pidfile" or die "DIE: Can't open pid file($pidfile): $!\n";
	my $old_pid = <PIDFILE>;
	close(PIDFILE);
	if ( $old_pid =~ /[0-9]+/ ) {
		if ( -d "/proc/$old_pid" ) {
			open my $CMDLINE, '<', "/proc/$old_pid/cmdline" or die "DIE: Can't open cmdline (/proc/$old_pid/cmdline): $!\n";
			my $running_proc = <$CMDLINE>;
			close $CMDLINE;
			if ( $running_proc =~ /\Q$0\E/) {
				logger("LifeSigns is already running!");
				die "DIE: LifeSigns is already running!\n";
			}
		}
	} else {
		logger("Incorrect pid format!");
		die "DIE: Incorrect pid format!\n";
	}
}

defined(my $pid=fork) or die "DIE: Cannot fork process: $! \n";
exit if $pid;
setsid or die "DIE: Unable to setsid: $!\n";
umask 0;

$ENV{PATH} = '';
$SIG{"HUP"} = \&sigHup;
$SIG{"TERM"} = \&sigTerm;
$SIG{"CHLD"} = \&sigChld;
$|=1;


open STDIN, '<', '/dev/null' or die "DIE: Cannot read stdin: $! \n";
open STDOUT, '>>', '/dev/null' or die "DIE: Cannot write to stdout: $! \n";
open STDERR, '>>', '/dev/null' or die "DIE: Cannot write to stderr: $! \n" if ! $debug;

$umask = umask();
umask(066);
open PIDFILE, '>', "$pidfile" or die "DIE: Unable to open pidfile $pidfile: $!\n";
print PIDFILE $$;
close(PIDFILE);
umask($umask);

# make the output to the LOG unbuffered
select((select(LOG), $| = 1)[0]);
# 		'LocalAddr' => $listen_address,
if ( $server = new IO::Socket::INET (
		'LocalPort' => $listen_port,
		'Timeout' => $timeout+2,
		'Proto' => 'tcp', 'Listen' => 1, 'Reuse' => 1)) {
	logger("Server created on $listen_address:$listen_port") if $debug;
} else {
	logger("Failed to bind to $listen_address:$listen_port : $!");
	exit(1);
}

# now wait for connections
while (1) {
	while ( my ($conn_handler, $client) = $server->accept() ) {
		$conn_count++;
		$conn_handler->autoflush(1);
		select((select($conn_handler), $| = 1)[0]);
		my ($client_port, $client_ip) = sockaddr_in($client);
		$client_ip = inet_ntoa($client_ip);

		# check if we have reached the maximum allowed clients
		if ($conn_count > $max_conns) {
			print $conn_handler "Max conn $max_conns reached!\n";
			logger("Max conn $max_conns reached!");
			close $conn_handler;
			$conn_count--;
			next;
		}

		if (check_ip($client_ip)) {
			close($conn_handler);
			next;
		}

		$server_pid=fork();
		logger("Cannot fork: $!") unless defined $server_pid;
		if ($server_pid == 0) {
			handle_client($conn_handler,\$client_ip,\$timeout,\%allow_root);
			close $conn_handler;
		} else {
			$pid_ip{$server_pid} = $client_ip;
			close $conn_handler;
		}
	}
}


logger("Somehow HIT QUIT?");
close ($server);
close (LOG);
exit 0;
