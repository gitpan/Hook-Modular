package Hook::Modular::CacheProxy;
use warnings;
use strict;
our $VERSION = '0.08';

sub new {
    my ($class, $plugin, $cache) = @_;
    bless {
        namespace => $plugin->plugin_id,
        cache     => $cache,
    }, $class;
}
for my $meth (qw(get get_callback set remove)) {
    no strict 'refs';
    *{$meth} = sub {
        my $self = shift;
        my $key  = shift;
        $key = "$self->{namespace}|$key";
        $self->{cache}->$meth($key, @_);
    };
}

sub path_to {
    my ($self, @path) = @_;
    $self->{cache}->path_to($self->{namespace}, @path);
}
1;
__END__

=head1 NAME

Hook::Modular::CacheProxy - Cache proxy for Hook::Modular

=head1 SYNOPSIS

    Hook::Modular::CacheProxy->new;

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

