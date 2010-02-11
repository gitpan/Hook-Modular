package Hook::Modular::Plugin::Attribute;
use warnings;
use strict;
our $VERSION = '0.09';
use base qw(
  Hook::Modular::Plugin
  Attribute::Handlers
);

sub UNIVERSAL::Hook : ATTR(CODE) {
    my ($package, $symbol, $referent, $attr, $data, $phase) = @_;
    use Data::Dumper;
    warn Dumper \@_;
    $data = [$data] unless ref $data eq 'ARRAY';
    for my $item (@$data) {
        my $name = "${package}::${item}";
        warn "GOT [$name]\n";

        # subname $name => $referent;
        #no strict 'refs';
        #*{$name} = $referent;
    }
}

sub register {
    my ($self, $context) = @_;
    warn "IN REGISTER()\n";

    #$context->register_hook(
    #    $self,
    #    'policy.delegation_domain.create' =>
    #        $self->can('policy_delegation_domain_create'),
    #);
    $self->register_manually($context);
}
sub register_manually { }
1;
__END__

=head1 NAME

Hook::Modular::Plugin - base class for plugins constructed with attributes

=head1 SYNOPSIS

  package My::Test::Plugin::Some::Printer;
  use warnings;
  use strict;
  use base 'Hook::Modular::Plugin::Attribute';
  
  sub do_print :Hook(output.print) {
      # ...
  }

=head1 DESCRIPTION

NOTE: This is a documentation in progress. Not all features or quirks of this
class have been documented yet.

This is a subclass of L<Hook::Modular::Plugin> that provides an attribute for
denoting hook subroutines more directly. Plugins wishing to use this attribute
should subclass this class.

For everything else related to writing plugins see the documentation of
L<Hook::Modular::Plugin>.

=head1 ATTRIBUTE

=over 4

=item :Hook

Blah.

You can mix attribute-based hook declarations with manual registration. For
example:

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

