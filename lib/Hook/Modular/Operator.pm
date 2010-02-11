package Hook::Modular::Operator;
use warnings;
use strict;
use List::Util qw(reduce);
our $VERSION = '0.09';
our %Ops     = (
    AND => [ sub { $_[0] && $_[1] } ],
    OR => [ sub { $_[0] || $_[1] } ],
    XOR  => [ sub { $_[0] xor $_[1] } ],
    NAND => [ sub { $_[0] && $_[1] }, 1 ],
    NOT  => [ sub { $_[0] && $_[1] }, 1 ],    # alias of NAND
    NOR  => [ sub { $_[0] || $_[1] }, 1 ],
);

sub is_valid_op {
    my ($class, $op) = @_;
    exists $Ops{$op};
}

sub call {
    my ($class, $op, @bool) = @_;
    my $bool = reduce { $Ops{$op}->[0]->($a, $b) } @bool;
    $bool = !$bool if $Ops{$op}->[1];
    $bool;
}
1;
__END__

=head1 NAME

Hook::Modular::Operator - Boolean operators for plugins

=head1 SYNOPSIS

    Hook::Modular::Operator->new;

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

