package Hook::Modular::Rule::Expression;
use warnings;
use strict;
use base 'Hook::Modular::Rule';
our $VERSION = '0.09';

sub dispatch {
    my ($self, $args) = @_;
    my $status = eval $self->{expression};
    if ($@) {
        Hook::Modular->context->log(
            error => "Expression error: $@ with '$self->{expression}'");
    }
    $status;
}
1;
__END__

=head1 NAME

Hook::Modular::Rule::Expression - Expression-based rule dispatcher

=head1 SYNOPSIS

    Hook::Modular::Rule::Expression->new;

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

