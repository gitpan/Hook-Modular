package Hook::Modular::Rules;
use warnings;
use strict;
use Hook::Modular::Operator;
our $VERSION = '0.08';

sub new {
    my ($class, $op, @rules) = @_;
    Hook::Modular::Operator->is_valid_op(uc($op))
      or Hook::Modular->context->error("operator $op not supported");
    bless {
        op    => uc($op),
        rules => [ map Hook::Modular::Rule->new($_), @rules ],
    }, $class;
}

sub dispatch {
    my ($self, $plugin, $hook, $args) = @_;
    return 1 unless $plugin->dispatch_rule_on($hook);
    my @bool;
    for my $rule (@{ $self->{rules} }) {
        push @bool, ($rule->dispatch($args) ? 1 : 0);
    }

    # can't find rules for this phase: execute it
    return 1 unless @bool;
    Hook::Modular::Operator->call($self->{op}, @bool);
}

sub id {
    my $self = shift;
    join '|', map $_->id, @{ $self->{rules} };
}

sub as_title {
    my $self = shift;
    join " $self->{op} ", map $_->as_title, @{ $self->{rules} };
}
1;
__END__

=head1 NAME

Hook::Modular::Rules - Workflow rules

=head1 SYNOPSIS

    Hook::Modular::Rules->new;

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

