package Hook::Modular::Crypt;
use warnings;
use strict;
our $VERSION = '0.09';
use Module::Pluggable::Fast
  search  => [qw/Hook::Modular::Crypt/],
  require => 1;
my %handlers = map { $_->id => $_ } __PACKAGE__->plugins;
my $re = "^(" . join("|", map $_->id, __PACKAGE__->plugins) . ")::";

sub decrypt {
    my ($class, $ciphertext, @args) = @_;
    if ($ciphertext =~ s!$re!!) {
        my $handler = $handlers{$1};
        my @param = split /::/, $ciphertext;
        return $handler->decrypt(@param, @args);
    }
    return $ciphertext;    # just plain text
}

sub encrypt {
    my ($class, $plaintext, $driver, @param) = @_;
    my $handler = $handlers{$driver}
      or Hook::Modular::Crypt->context->error("No crypt handler for $driver");
    join '::', $driver, $handler->encrypt($plaintext, @param);
}
1;
__END__

=head1 NAME

Hook::Modular::Crypt - Crypt mechanism for passwords in workflows

=head1 SYNOPSIS

    Hook::Modular::Crypt->new;

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

