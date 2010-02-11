package Hook::Modular::Test;
use warnings;
use strict;
use File::Temp 'tempfile';
use YAML qw/Load DumpFile/;
use Exporter qw(import);
our $VERSION     = '0.09';
our %EXPORT_TAGS = (
    util => [
        qw/
          write_config_file
          /
    ],
);
our @EXPORT_OK = @{ $EXPORT_TAGS{all} = [ map { @$_ } values %EXPORT_TAGS ] };

sub write_config_file {
    my $yaml     = shift;
    my $filename = (tempfile())[1];
    DumpFile($filename, Load($yaml));
    $filename;
}
1;
__END__

=for test_synopsis
1;
__END__

=head1 NAME

Hook::Modular::Test - utility functions for testing Hook::Modular

=head1 SYNOPSIS

  # t/45blah.t

  use Hook::Modular::Test ':all';

  my $config_filename = write_config_file(do { local $/; <DATA> });

  sub run {
      # ...
  }

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

=item C<write_config_file>

  my $temp_file_name = write_config_file($yaml_string);

Takes the YAML, loads it (partly to make sure it is valid), dumps it out to a
temporary file and returns the file name.

=back

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org>.

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit <http://www.perl.com/CPAN/> to find a CPAN
site near you. Or see L<http://search.cpan.org/dist/Hook-Modular/>.

=head1 AUTHORS

Tatsuhiko Miyagawa C<< <miyagawa@bulknews.net> >>

Marcel GrE<uuml>nauer, C<< <marcel@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2009 by the authors.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

