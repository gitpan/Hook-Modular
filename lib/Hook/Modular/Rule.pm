package Hook::Modular::Rule;
use warnings;
use strict;
use UNIVERSAL::require;
our $VERSION = '0.09';

sub new {
    my ($class, $config) = @_;
    if (my $exp = $config->{expression}) {
        $config->{module} = 'Expression';
    }
    my $module_suffix = delete $config->{module};
    my $module;
    my $found = 0;
    my @tried;
    for my $ns (Hook::Modular->rule_namespaces) {
        $module = $ns . '::' . $module_suffix;
        push @tried => $module;
        if ($module->require) {
            $found++;
            last;
        }
    }
    $found or die sprintf "can't find any of %s", join(', ' => @tried);
    my $self = bless {%$config}, $module;
    $self->init;
    $self;
}
sub init { }
use constant id       => 'xxx';
use constant as_title => 'xxx';
1;
__END__

=head1 NAME

Hook::Modular::Rule - A Workflow rule

=head1 SYNOPSIS

    Hook::Modular::Rule->new;

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

