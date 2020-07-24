use strict;
use warnings;

package web_error;
require Exporter;
our @ISA		= qw(Exporter);
our @EXPORT		= qw(web_error);
our $VERSION	= 0.1;

sub web_error {
	print $_[0];
	die $_[0];
}

1;
