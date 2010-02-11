package Hook::Modular::Cache;
use warnings;
use strict;
use File::Path;
use File::Spec;
use UNIVERSAL::require;
our $VERSION = '0.09';

sub new {
    my ($class, $conf, $name) = @_;
    mkdir $conf->{base}, 0700 unless -e $conf->{base} && -d_;

    # Cache default configuration
    $conf->{class}  ||= 'Cache::FileCache';
    $conf->{params} ||= {
        cache_root => File::Spec->catfile($conf->{base}, 'cache'),
        default_expires_in => $conf->{expires} || 'never',
        directory_umask => 0077,
    };
    $conf->{class}->require;

    # If class is not loadable, falls back to on memory cache
    if ($@) {
        Hook::Modular->context->log(error =>
"Can't load $conf->{class}. Falling back to Hook::Modular::Cache::Null"
        );
        require Hook::Modular::Cache::Null;
        $conf->{class} = 'Hook::Modular::Cache::Null';
    }
    my $self = bless {
        base     => $conf->{base},
        cache    => $conf->{class}->new($conf->{params}),
        to_purge => $conf->{expires} ? 1 : 0,
    }, $class;
}

sub path_to {
    my ($self, @path) = @_;
    if (@path > 1) {
        my @chunk = @path[ 0 .. $#path - 1 ];
        mkpath(File::Spec->catfile($self->{base}, @chunk), 0, 0700);
    }
    File::Spec->catfile($self->{base}, @path);
}

sub get {
    my $self = shift;
    my $value;
    if ($self->{cache}->isa('Cache')) {
        eval { $value = $self->{cache}->thaw(@_) };
        if ($@ && $@ =~ /Storable binary/) {
            $value = $self->{cache}->get(@_);
        }
    } else {
        $value = $self->{cache}->get(@_);
    }
    my $hit_miss = defined $value ? "HIT" : "MISS";
    Hook::Modular->context->log(debug => "Cache $hit_miss: $_[0]");
    $value;
}

sub get_callback {
    my ($self, $key, $callback, $expiry) = @_;
    my $data = $self->get($key);
    if (defined $data) {
        return $data;
    }
    $data = $callback->();
    if (defined $data) {
        $self->set($key => $data, $expiry);
    }
    $data;
}

sub set {
    my ($self, $key, $value, $expiry) = @_;
    my $setter = $self->{cache}->isa('Cache') && ref $value ? 'freeze' : 'set';
    $self->{cache}->$setter(@_);
}

sub remove {
    my $self = shift;
    $self->{cache}->remove(@_);
}

sub DESTROY {
    my $self = shift;
    $self->{cache}->purge if $self->{to_purge};
}
1;
__END__

=head1 NAME

Hook::Modular::Cache - Cache for Hook::Modular

=head1 SYNOPSIS

    Hook::Modular::Cache->new;

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

