package Hook::Modular::ConfigLoader;
use warnings;
use strict;
use Carp;
use Hook::Modular::Walker;
use YAML;
use Storable;
our $VERSION = '0.09';

sub new {
    my $class = shift;
    bless {}, $class;
}

sub load {
    my ($self, $stuff, $context) = @_;
    my $config;
    if (   (!ref($stuff) && $stuff eq '-')
        || (-e $stuff && -r _)) {
        $config = YAML::LoadFile($stuff);
        $context->{config_path} = $stuff if $context;
    } elsif (ref($stuff) && ref $stuff eq 'SCALAR') {
        $config = YAML::Load(${$stuff});
    } elsif (ref($stuff) && ref $stuff eq 'HASH') {
        $config = Storable::dclone($stuff);
    } else {
        croak "Hook::Modular::ConfigLoader->load: $stuff: $!";
    }
    unless ($config->{global} && $config->{global}->{no_decode_utf8}) {
        Hook::Modular::Walker->decode_utf8($config);
    }
    return $config;
}

sub load_include {
    my ($self, $config) = @_;
    my $includes = $config->{include} or return;
    $includes = [$includes] unless ref $includes;
    for my $file (@$includes) {
        my $include = YAML::LoadFile($file);
        for my $key (keys %{$include}) {
            my $add = $include->{$key};
            unless ($config->{$key}) {
                $config->{$key} = $add;
                next;
            }
            if (ref $config->{$key} eq 'HASH') {
                next unless ref $add eq 'HASH';
                for (keys %{ $include->{$key} }) {
                    $config->{$key}->{$_} = $include->{$key}->{$_};
                }
            } elsif (ref $include->{$key} eq 'ARRAY') {
                $add = [$add] unless ref $add eq 'ARRAY';
                push(@{ $config->{$key} }, @{ $include->{$key} });
            } elsif ($add) {
                $config->{$key} = $add;
            }
        }
    }
}

sub load_recipes {
    my ($self, $config) = @_;
    for (@{ $config->{recipes} }) {
        $self->error("no such recipe to $_")
          unless $config->{define_recipes}->{$_};
        my $plugin = $config->{define_recipes}->{$_};
        $plugin = [$plugin] unless ref $plugin eq 'ARRAY';
        push(@{ $config->{plugins} }, @{$plugin});
    }
}
1;
__END__

=head1 NAME

Hook::Modular::ConfigLoader - Configuration loader for Hook::Modular

=head1 SYNOPSIS

    Hook::Modular::ConfigLoader->new;

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

