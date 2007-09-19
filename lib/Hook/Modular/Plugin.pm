package Hook::Modular::Plugin;

use warnings;
use strict;
use File::Find::Rule ();  # don't import rule()
use File::Spec;
use File::Basename;
use Hook::Modular::Crypt;
use Hook::Modular::Rule;
use Hook::Modular::Rules;
use Scalar::Util qw(blessed);

our $VERSION = '0.01';

use base qw( Class::Accessor::Fast );
__PACKAGE__->mk_accessors( qw(rule_hook cache) );


sub new {
    my ($class, $opt) = @_;
    my $self = bless {
        conf      => $opt->{config} || {},
        rule      => $opt->{rule},
        rule_op   => $opt->{rule_op} || 'AND',
        rule_hook => '',
        meta      => {},
    }, $class;
    $self->init;
    $self;
}


sub init {
    my $self = shift;

    if (my $rule = $self->{rule}) {
        $rule = [ $rule ] if ref $rule eq 'HASH';
        my $op = $self->{rule_op};
        $self->{rule} = Hook::Modular::Rules->new($op, @$rule);
    } else {
        $self->{rule} = Hook::Modular::Rule->new({ module => 'Always' });
    }

    $self->walk_config_encryption;
}


sub conf { $_[0]->{conf} }
sub rule { $_[0]->{rule} }


sub walk_config_encryption {
    my $self = shift;
    my $conf = $self->conf;

    $self->do_walk($conf);
}


sub do_walk {
    my ($self, $data) = @_;
    return unless defined($data) && ref $data;

    if (ref $data eq 'HASH') {
        for my $key (keys %$data) {
            if ($key =~ /password/) {
                $self->decrypt_config($data, $key);
            }
            $self->do_walk($data->{$key});
        }
    } elsif (ref $data eq 'ARRAY') {
        $self->do_walk($_) for @$data;
    }
}


sub decrypt_config {
    my ($self, $data, $key) = @_;

    my $decrypted = Hook::Modular::Crypt->decrypt($data->{$key});
    if ($decrypted eq $data->{$key}) {
        Hook::Modular->context->add_rewrite_task($key, $decrypted,
            Hook::Modular::Crypt->encrypt($decrypted, 'base64')
        );
    } else {
        $data->{$key} = $decrypted;
    }
}


sub dispatch_rule_on {
    my ($self, $hook) = @_;
    $self->rule_hook && $self->rule_hook eq $hook;
}


sub class_id {
    my $self = shift;

    my $ns = Hook::Modular->context->{conf}{plugin_namespace};
    my $pkg = ref($self) || $self;
       $pkg =~ s/$ns//;
    my @pkg = split /::/, $pkg;

    return join '-', @pkg;
}


# subclasses may overload to avoid cache sharing
sub plugin_id {
    my $self = shift;
    $self->class_id;
}


sub assets_dir {
    my $self = shift;
    my $context = Hook::Modular->context;

    if ($self->conf->{assets_path}) {
        return $self->conf->{assets_path}; # look at config:assets_path first
    }

    my $assets_base =
        $context->conf->{assets_path} ||              # or global:assets_path
        File::Spec->catfile($FindBin::Bin, "assets"); # or "assets" under current script

    return File::Spec->catfile(
        $assets_base, "plugins", $self->class_id,
    );
}


sub log {
    my $self = shift;
    Hook::Modular->context->log(@_, caller => ref $self);
}


sub load_assets {
    my($self, $rule, $callback) = @_;

    unless (blessed($rule) && $rule->isa('File::Find::Rule')) {
        $rule = File::Find::Rule->name($rule);
    }

    # ignore .svn directories
     $rule->or(
         $rule->new->directory->name('.svn')->prune->discard,
         $rule->new,
     );

    # $rule isa File::Find::Rule
    for my $file ($rule->in($self->assets_dir)) {
        my $base = File::Basename::basename($file);
        $callback->($file, $base);
    }
}


1;
