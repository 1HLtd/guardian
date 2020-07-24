#!/usr/bin/perl 
use strict;
use warnings;

package detect_exim;
require Exporter;
our @ISA        = qw(Exporter);
our @EXPORT     = qw(get_exim_queue get_exim_info modify_exim_init);
our $VERSION    = '0.5.4';

# executes at run-time, unless used as module
__PACKAGE__->main() unless caller;

sub main {
    my $self = shift;
    sub logger { print @_, "\n"; }
	my %conf = ();
	$conf{'init_dir'} = '/usr/local/1h/lib/guardian/init';
	get_exim_queue(\%conf);
	get_exim_info(\%conf);
	printf "Exim queue time: %s\nExim outgoing: %s\nExim alt port: %s\nExim tls support: %s\nHas spamd: %s\nExim user: %s\n",
		$conf{'exim_queue_time'}, $conf{'exim_outgoing'} ? 'found' : 'not found', 
		$conf{'exim_alt_port'} ? $conf{'exim_alt_port'} : 'not detected', 
		$conf{'exim_tls'} ? 'true' : 'false',
		$conf{'has_spamd'} ? 'true' : 'false',
		$conf{'exim_user'};
}

$ENV{'PATH'} = '/sbin:/usr/sbin:/bin:/usr/bin';

sub get_exim_queue {
	my $config_ref = shift;
	$config_ref->{'exim_queue_time'} = '15m';
	$config_ref->{'exim_outgoing'} = 0;
	$config_ref->{'exim_multiprocess_monitoring'} = 0;

	if ( -f '/etc/init.d/exim' ) {
		open C, '<', '/etc/init.d/exim' or die "Cannot open /etc/init.d/exim\n";
		while (<C>) {
			$config_ref->{'exim_multiprocess_monitoring'} = 1 if ($_ =~ /(ALTPORT|tls-on-connect)/);

			if ($_ =~ /^\s*QUEUE=[0-9]+/) {
				$config_ref->{'exim_queue_time'} = $_;
			}
			if ($_ =~ /exim_outgoing.conf/ && -e '/etc/exim_outgoing.conf') {
				$config_ref->{'exim_outgoing'} = 1;
			}
		}
		close C;
	}
	if ( -f '/etc/sysconfig/exim' ) {
		open C, '<', '/etc/sysconfig/exim' or die "Cannot open /etc/sysconfig/exim\n";
		while (<C>) {
			if ($_ =~ /^\s*QUEUE=[0-9]+/) {
				$config_ref->{'exim_queue_time'} = $_;
				last;
			}
		}
		close C;
	}
	#$config_ref->{'exim_queue_time'} =~ s/^\s*QUEUE=(.*)\s*\n?$/$1/;
	$config_ref->{'exim_queue_time'} =~ s/^\s*QUEUE=([0-9]+[mhdMHD]+).*[\r\n]*/$1/;
	return 1;
}

sub get_exim_info {
	my $config_ref = shift;
	my @ports = ();
	my $conf = '/etc/exim.conf';
	my $exim_bin = '/usr/sbin/exim';

	$config_ref->{'exim_alt_port'} = 0;
	$config_ref->{'exim_tls'} = 0;
	$config_ref->{'has_spamd'} = 1;
	$config_ref->{'exim_multiple'} = 0;
	$config_ref->{'exim_user'} = 'mailnull';

	if (-x $exim_bin) {
		open EXIM, '-|', "$exim_bin -bP exim_user";
		while (<EXIM>) {
			next if ($_ !~ /^exim_user/);
			# $exim_user_row[0] - conf var name -> exim_user
			# $exim_user_row[1] - real user Debian-exim, mailnull, mail etc.
			#print "Got it at $_\n";
			my @exim_user_row = split(/\s*=\s*/, $_);
			#print "Data is $exim_user_row[1]\n";
			$config_ref->{'exim_user'} = $exim_user_row[1];
			$config_ref->{'exim_user'} =~ s/(\r|\n)//g;
			$config_ref->{'exim_user'} = $1 if ($config_ref->{'exim_user'} =~ /^(.*)$/);
			#print "Then it is $config_ref->{'exim_user'}\n";
		}
		close EXIM;
	}

	# disable spamd checks if we have /etc/spamddisable
	$config_ref->{'has_spamd'} = 0 if ( -e '/etc/spamddisable' || ( ! -x '/usr/bin/spamd' && ! -x '/usr/local/cpanel/3rdparty/perl/514/bin/spamd' && ! -x '/usr/local/bin/spamd'));
	# check if we have altport defined in the /etc/chkserv.d
	if ( -d '/etc/chkserv.d' ) {
		opendir CD, '/etc/chkserv.d' or die "Cannot open /etc/chkserv.d\n";
		while ( my $entry = readdir CD ) {
			if ( $entry =~ /^exim-(\d+)$/ ) {
				$config_ref->{'exim_alt_port'} = $1;
				last;
			}
		}
		closedir(CD);
	}
	# check for exim_outgoing.conf and use it later
	$conf = '/etc/exim_outgoing.conf' if ( $config_ref->{'exim_outgoing'} );

	# verify the configuration and get daemon_smtp_port
	# also check if we have to check for tls process
	if ( -f $conf ) {
		open C, '<', $conf or die "Cannot open $conf\n";
		while (<C>) {
			if ($_ =~ /^\s*daemon_smtp_port/) {
				if ($_ =~ /:/) {
					my $line = $_;
					$line =~ s/.*=\s*//;
					$line =~ s/\s+//;
					@ports = split /:/, $line;
				}
			}
			if (/^\s*tls_on_connect_ports.*465/) {
				$config_ref->{'exim_tls'} = 1;
			}
#			if ($_ =~ /multiple/ ) {
#				$config_ref->{'exim_multiple'} = 1;
#			}
		}
		close C;
	}
	# if we find the ports in daemon_smtp_port we disable the separate process checks
	for (my $i=0; $i<=$#ports; $i++) {
		$config_ref->{'exim_tls'} = 0 if ($ports[$i] == 465);
		$config_ref->{'exim_alt_port'} = 0 if ($ports[$i] == $config_ref->{'exim_alt_port'});
	}

	return 1;
}
sub modify_exim_init {
	my $config_ref = shift;
	my $change = 0;
	if ( -f $config_ref->{'init_dir'}.'/exim.sh') {
		open C, '<' , $config_ref->{'init_dir'}.'/exim.sh';
		while (<C>) {
			if ($_ =~ /pidfile_spamd/) {
				$change = 1;
				last;
			}
		}
		close C;
	} else {
		return 0;
	}
	if ($change) {
		defined(my $pid=fork) or die "DIE: Cannot fork process: $! \n";
		if ($pid == 0) {
			system("sed -i '/^QUEUE=/s/=.*/=".$config_ref->{'exim_queue_time'}."/' ".$config_ref->{'init_dir'}.'/exim.sh');
			system("sed -i '/^ALTPORT=/s/=.*/=".$config_ref->{'exim_alt_port'}."/' ".$config_ref->{'init_dir'}.'/exim.sh');
			if ($config_ref->{'exim_tls'}) {
				system("sed -i '/^TLS=/s/=.*/=true/' ".$config_ref->{'init_dir'}.'/exim.sh');
			} else {
				system("sed -i '/^TLS=/s/=.*/=false/' ".$config_ref->{'init_dir'}.'/exim.sh');
			}
			exit(0);
		}
	}
	return 1;
}
