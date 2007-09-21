package Hook::Modular::Test;

use warnings;
use strict;
use File::Temp 'tempfile';
use YAML qw/Load DumpFile/;

use base 'Exporter';


our $VERSION = '0.03';


our %EXPORT_TAGS = (
    util => [ qw/
        write_config_file
    / ],
);

our @EXPORT_OK = @{ $EXPORT_TAGS{all} = [ map { @$_ } values %EXPORT_TAGS ] };


sub write_config_file {
    my $yaml = shift;
    my $filename = (tempfile())[1];
    DumpFile($filename, Load($yaml));
    $filename;
}


1;

__END__

=head1 NAME

Hook::Modular::Test - utility functions for testing Hook::Modular

=head1 SYNOPSIS

  # t/45blah.t

  use Hook::Modular::Test ':all';

  my $config_filename = write_config_file(do { local $/; <DATA> });

  sub run { ... }

  __DATA__
  global:
    log:
      level: error
  ...

=head1 DESCRIPTION

This module exports utility functions to aid in testing Hook::Modular. None of
the functions are exported automatically, but you can request them by name, or
get all of them if you use the C<:all> tag.

=head1 FUNCTIONS

=over 4

=item write_config_file($yaml)

Takes the yaml, loads it (partly to make sure it is valid), dumps it out to a
temporary file and returns the file name.

=back

=head1 AUTHOR

Marcel GrE<uuml>nauer, C<< <marcel@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2007 by Marcel GrE<uuml>nauer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

