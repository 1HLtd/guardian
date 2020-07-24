#!/usr/bin/perl -w

use strict;
use warnings;

use Storable qw(freeze thaw);
use IO::Socket::INET;

use lib qw(/usr/local/1h/lib/archon /usr/local/1h/lib/perl);
use Gearman::Worker;
use Gearman::Client;
use daemonize;
use parse_config;

my $VERSION = '0.0.16';
my $config_file = '/usr/local/1h/etc/archon.conf';
our %config = parse_config($config_file);
our %services = parse_config($config{'svc_groups'});

become_daemon;

$0='Archon-Gather'.'-'.$VERSION;

sub RELOAD_CONFIG {
	%config = parse_config($config_file);
	%services = parse_config($config{'svc_groups'});
	$SIG{HUP} = \&RELOAD_CONFIG;
}
$SIG{HUP} = \&RELOAD_CONFIG;

our $client = Gearman::Client->new;
my $worker = Gearman::Worker->new;
$client->job_servers('127.0.0.1:4730');
$worker->job_servers('127.0.0.1:4730');

my $f = sub {
	# 0 - server id
	# 1 - server ip
	# 2 - server name
	# 3 - down id
	# 4 - disabled services
	my ($srv_id, $ip, $srv_name, $down_id, $disabled_services) = @{ thaw($_[0]->arg) };
	$client->dispatch_background('log_me', "Entered f function in gather with $srv_id, $ip, $srv_name, $down_id, $disabled_services") if ($config{'debug'});
	my @status = ();
	our $replay = '';
	our $error = '';
	my $err2 = '';
	#printf "SID: %d   IP: %s   SVCs: %s     DID: %d    Name: %s\n", $srv_id, $ip, $disabled_services, $down_id, $srv_name;
	eval {
		local $SIG{ALRM} = sub { die 'timeout'; };
		alarm($config{'connection_alarm'});
		if ( my $sock = new IO::Socket::INET (
                        PeerAddr => $ip,
                        PeerPort => $config{'lifesigns_port'},
                        Proto => 'tcp',
                        Timeout => $config{'connection_timeout'}) ) {
			print $sock "status\n";
			$replay = <$sock>;
			close $sock;
		} else {
			$error = "error: $!";
			$client->dispatch_background('log_me', "IO socket returned $error ... exitting function f with return") if ($config{'debug'});
			return;
		}
		$client->dispatch_background('log_me', "Set the alarm to zero and continue the eval") if ($config{'debug'});
		alarm(0);
	};

	$err2 = $@;
	$client->dispatch_background('log_me', "Eval above said $err2") if ($config{'debug'});

 	if ( $error =~ /^error:/ || $err2 =~ /^timeout/ ) {
		$error =~ s/[\r|\n]$//g;
		$err2 =~ s/at \.\/gather.*// if ($err2 =~ /timeout/);
		$error .= ' '.$err2;
 		# unable to connect
		$client->dispatch_background('log_me', 'Unable to connect to '.$srv_name.': '.$error);
 		$client->dispatch_background('store_down',		freeze([0, $srv_id, 'System error: '.$error ]) );
		$client->dispatch_background('update_status',	freeze([0, $srv_id, $down_id ]) );
 		$@='';
		return 0;
	}

	# remove the leading $, it is printed by LifeSings for better user experience for admins
	$replay =~ s/^\$ (.*)\n?$/$1/;
	my $validate = validate_replay($replay);
	if ( ! $validate ) {
		# guardian is down or all services are down
		$client->dispatch_background('log_me', 'Invalid reply from '.$srv_name.': '.$replay);
 		$client->dispatch_background('store_down',		freeze([ 1, $srv_id, 'System error: invalid reply('.$replay.')' ]));
		$client->dispatch_background('update_status',	freeze([ 1, $srv_id, $down_id ]));
		return 1;
	}

	@status = split /:/, $replay;
	# convert the status array to a hash
	my %statuses = status_to_hash(\@status, $validate);
	$client->dispatch_background('log_me', 'We are now back from the status to hash') if ($config{'debug'});

	populate_missing_services(\%statuses, \%services, $disabled_services);
	$client->dispatch_background('log_me', 'back from the populate_missing_services') if ($config{'debug'});
	
	# check if the guardian is down
	$statuses{19} = 2 if ($statuses{'lag'} > 10);

	if (check_for_down(\%statuses)) {
		$client->dispatch_background('log_me', 'check_for_down and the statuses hash is not empty so we will call store_down and update_status') if ($config{'debug'});
 		$client->dispatch_background('store_down', 		freeze([ 2, $srv_id, 'System error: detected services down', %statuses ]));
		$client->dispatch_background('update_status',	freeze([ 2, $srv_id, $down_id, %statuses ]));
		return 2;
	}

	$client->dispatch_background('log_me', 'everything is up? well simply update the status') if ($config{'debug'});
	$client->dispatch_background('update_status', 		freeze([ 3, $srv_id, $down_id, %statuses ]));
	return 3;
};

sub validate_replay {
	return 1 if ($_[0] =~ /^[0-9]+:[0-9.]+:[0-9]+:[0-9]+(:[0-9]{1,3}\,[01]{1})+:*$/);
	return 2 if ($_[0] =~ /^[0-9]+:[0-9.]+:[0-9]+:[0-9]+:[0-9]+:[0-9]+(:[0-9]{1,3}\,[01]{1})+:*$/);
	return 0;
}

sub status_to_hash {
	$client->dispatch_background('log_me', 'Entering status to hash function') if ($config{'debug'});
	my $status_ref = shift;
	my $type = shift;
	my %statuses = ();
	$statuses{'lag'} = shift(@{$status_ref});
	$statuses{'load'} = shift(@{$status_ref});
	$statuses{'procs'} = shift(@{$status_ref});
	$statuses{'queue'} = shift(@{$status_ref});
	if ($type == 2) {
		$statuses{'http_procs'} = shift(@{$status_ref});
		$statuses{'mysql_procs'} = shift(@{$status_ref});
	}
	# novq service conf
	# value server_svc_id
	for (my $i=0; $i<=$#{$status_ref}; $i++) {
		next if ($status_ref->[$i] !~ /,/ || $status_ref->[$i] =~ /^\s*$/);
		my ($svc, $stat) = split /,/, $status_ref->[$i];
		# $svc is the id of the service as guardian/lifesigns know it
		#$statuses{$svc} = $stat;
	
		# $services{$svc} -> this transforms the service id as guardian knows it to a group id known by archon.
		# Example: apache and nginx are from a same group let's say 0 but they both have diff services ids. We just need 0 to show that there is a web issue on a given server
		next if (! defined($services{$svc})); # Skip this response from guardian if the archon does not known anything about a service/group where the svc_id part is $svc
		$statuses{$services{$svc}} = $stat;
	}
	return %statuses;
}

sub populate_missing_services {
	$client->dispatch_background('log_me', 'Entering populate missing services function') if ($config{'debug'});
	# check for missing services
	# if the service is disabled set the proper status
	my $services_ref = shift;
	my $service_list = shift;
	my $disabled_services_ref = shift;
	while (my ($svc_id,$svc_gid) = each %{$service_list}) {
        if (defined($services_ref->{$svc_gid})) {
            if ($services_ref->{$svc_gid} == 0) {
                if ($disabled_services_ref != 0 && !defined($disabled_services_ref->{$svc_gid})) {
                    $services_ref->{$svc_gid} = 2;
                }
            }
        } else {
            if ($disabled_services_ref != 0 && defined($disabled_services_ref->{$svc_gid}) ) {
                $services_ref->{$svc_gid} = 0;
            } else {
                $services_ref->{$svc_gid} = 2;
            }
        }
	}
}

sub check_for_down {
	# service statuses
	# 0 - not monitored
	# 1 - ok
	# 2 - down
	my $status_ref = shift;
	my $down = 0;
	while (my $k = each %{$status_ref}) {
		next if ($k !~ /^[0-9]+$/);
		$down=1 if ($status_ref->{$k} >= 2);
	}
	return $down;
}

$worker->register_function( gather_child => $f );
while (1) {
    eval {
		$worker->work;
	};
}

__END__

=head1 NAME



=head1 SYNOPSIS

 how to us your program

=head1 DESCRIPTION

 long description of your program

=head1 SEE ALSO

 need to know things before somebody uses your program

=head1 AUTHOR

 Marian Marinov

=cut
