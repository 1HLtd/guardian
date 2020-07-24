package gather_info;
use strict;
use warnings;
use IO::Socket::INET;
use database;

require Exporter;
our @ISA        = qw(Exporter);
our @EXPORT     = qw(gather_child validate_replay status_to_hash check_for_down populate_missing_services);
our $VERSION    = 1.0;

sub gather_child {
	my $id = shift;
	my $servers_ref = shift;
	my $conf_ref = shift;
	my $service_list_ref = shift;
	my @status = ();
	our $replay = '';
	eval {
		local $SIG{ALRM} = sub {
			die 'timeout';
		};
		alarm($conf_ref->{'connection_alarm'});
		if ( my $sock = new IO::Socket::INET (
                        PeerAddr => $servers_ref->[$id][2],
                        PeerPort => $conf_ref->{'lifesigns_port'},
                        Proto => 'tcp',
                        Timeout => $conf_ref->{'connection_timeout'}) ) {
			print $sock "status\n";
			$replay = <$sock>;
			close $sock;
 			alarm 0;
		} else {
			die "error: $!";
		}
	};
	init_db($conf_ref);
 	if ( $@ =~ /^timeout$/ || $@ =~ /^error: / ) {
  		store_down(0,$servers_ref->[$id][0]);
  		update_status(0,$conf_ref);
  		exit 1;
	}
	# remove the leading $, it is printed by LifeSings for better user experience for admins
	$replay =~ s/^\$ (.*)\n$/$1/;
	if ( ! validate_replay($replay) ) {
		# guardian is down or all services are down
		store_down(1,$servers_ref->[$id][0],\@status);
		update_status(1,$conf_ref,$servers_ref->[$id][0],\@status);
		exit 1;
	}
	@status = split /:/, $replay;
	my %statuses = status_to_hash(\@status);
	store_down(2,$servers_ref->[$id][0],\%statuses) if check_for_down(\%statuses);

	populate_missing_services(\%statuses, $service_list_ref, $servers_ref->[$id][4]);

	update_status(2,$conf_ref,$servers_ref->[$id][0],\%statuses);
	exit 0;
}

sub validate_replay {
	if ($_[0] =~ /^[0-9]+:[0-9.]+:[0-9]+:[0-9]+(:[0-9]{1,3}\,[01]{1})+:$/) {
		return 1;
	} else {
		return 0;
	}
}

sub status_to_hash {
	my $status_ref = shift;
	my %statuses = ();
	$statuses{'lag'} = shift(@{$status_ref});
	$statuses{'load'} = shift(@{$status_ref});
	$statuses{'procs'} = shift(@{$status_ref});
	$statuses{'queue'} = shift(@{$status_ref});
	for (my $i=0; $i<=$#{$status_ref}; $i++) {
		next if ($status_ref->[$i] !~ /,/ || $status_ref->[$i] =~ /^\s*$/);
		my ($svc, $stat) = split /,/, $status_ref->[$i];
		$statuses{$svc} = $stat;
	}
	return %statuses;
}

sub check_for_down {
	my $status_ref = shift;
	my $down = 0;
	while (my $k = each %{$status_ref}) {
		if (defined($status_ref->{$k})) {
			if ($status_ref->{$k} <=> 0) {
				$down = 1;
				last;
			}
		} else {
			$down = 1;
		}
	}
	return $down;
}

sub populate_missing_services {
	my $services_ref = shift;
	my $service_list = shift;
	my $disabled_services_ref = shift;
	while (my ($svc_name,$svc_id) = each %{$service_list}) {
		if (!defined($services_ref->{$svc_id})) {
			if ( defined($disabled_services_ref->{$svc_id}) ) {
				$services_ref->{$svc_id} = 0;
			} else {
				$services_ref->{$svc_id} = 2;
			}
		}
	}
}

1;

__END__

=head1 NAME

ModuleName - short discription of your program

=head1 SYNOPSIS

 how to us your module

=head1 DESCRIPTION

 long description of your module

=head1 SEE ALSO

 need to know things before somebody uses your program

=head1 AUTHOR

 Marian Marinov

=cut
