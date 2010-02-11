package Hook::Modular::Crypt::Base64;
use warnings;
use strict;
use MIME::Base64 ();
our $VERSION = '0.09';
use constant id => 'base64';

sub decrypt {
    my ($self, $text) = @_;
    MIME::Base64::decode($text);
}

sub encrypt {
    my ($self, $text) = @_;
    MIME::Base64::encode($text, '');
}
1;
__END__

=head1 NAME

Hook::Modular::Crypt::Base64 - Base64 crypt mechanism for passwords in workflows

=head1 SYNOPSIS

    Hook::Modular::Crypt::Base64->new;

=head1 DESCRIPTION

None yet.

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

