package logging;
use strict;
use warnings;
use POSIX qw(strftime);

require Exporter;
our @ISA        = qw(Exporter);
our @EXPORT     = qw($VERSION init_log logger);
our $VERSION    = 1.0;

sub init_log {
	my $conf_ref = shift;
	open LOG, '>>', $conf_ref->{'logfile'} or die 'Unable to open logfile('.$conf_ref->{'logfile'}."): $!\n";
	select((select(LOG), $| = 1)[0]);
	return 1;
}

sub logger {
 	print $_[0] ."\n" if ($main::config{'debug'});
	print LOG strftime('%b %d %H:%M:%S', localtime(time)) . ' ' . $_[0] ."\n";
}

sub new {
  my $package = shift;
  my $conf_ref = shift;
  open LOG, '>>', $conf_ref->{'logfile'} or die 'Unable to open logfile('.$conf_ref->{'logfile'}."): $!\n";
  select((select(LOG), $| = 1)[0]);
  return bless({}, $package);
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
