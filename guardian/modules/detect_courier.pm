#!/usr/bin/perl 
use strict;
use warnings;

package detect_courier;
require Exporter;
our @ISA        = qw(Exporter);
our @EXPORT     = qw(check_courier);
our $VERSION    = '0.0.3';

# executes at run-time, unless used as module
__PACKAGE__->main() unless caller;

sub main {
    my $self = shift;
	my %conf = ();
	check_courier(\%conf);
	printf "Courier\n  IMAP SSL: %s\n  POP3 SSL: %s\n  Authd: %s\n", 
		$conf{'courier_imap_tls'} ? 'found' : 'not found', 
		$conf{'courier_pop3_tls'} ? 'found' : 'not found',
		$conf{'courier_authd'}   ? 'found' : 'not found';
}

$ENV{'PATH'} = '/sbin:/usr/sbin:/bin:/usr/bin';

sub check_courier {
	my $conf_ref = shift;
	

	my %courier_config = (
		'courier_imap_tls' => [
			'/usr/lib/courier-imap/etc/imapd-ssl',	# imapd-ssl found on cPanel servers
			'/etc/courier-imap/imapd-ssl'			# imapd-ssl found on Plesk servers
		],
		'courier_pop3_tls' => [
			'/usr/lib/courier-imap/etc/pop3d-ssl',	# pop3d-ssl found on cPanel servers
			'/etc/courier-imap/pop3d-ssl'			# pop3d-ssl found on Plesk servers
		]
	);

	# This server does not have courier installed. No need to check further.
	# This file is the same on both cPanel and Plesk
	return if (! -f '/etc/init.d/courier-imap');

	while (my $courier_key = each(%courier_config)) {
		#print "My CKEY is $courier_key\n";
		foreach my $ssl_conf_file (@{$courier_config{$courier_key}})  {
			#print "My conf file $ssl_conf_file\n";
			next if (! -f $ssl_conf_file); # No such config file so we move on
			#print "$ssl_conf_file is here\n";
			open S, '<', $ssl_conf_file or print "Error: Unable to open $ssl_conf_file conf file for $courier_key: $!\n" and return;
			while (<S>) {
				next if ($_ !~ /^\s*(POP3D|IMAPD)SSLSTART=Y/);	# SSLSTART is not set to yes so we will not turn on the check
				$conf_ref->{$courier_key} = 1;					# SSLSTART is set to yes so we will turn on the check for the
				last;											# SSL is enabled for this conf so we do not need to parse it anymore
			}
			close S;
		}
	}

	$conf_ref->{'courier_authd'} = 1 if (-f '/usr/libexec/courier-authlib/authdaemond');
}

1;
