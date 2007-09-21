package Hook::Modular;

use warnings;
use strict;
use Encode ();
use Data::Dumper;
use File::Copy;
use File::Spec;
use File::Basename;
use File::Find::Rule (); # don't import rule()!
use Hook::Modular::ConfigLoader;
use UNIVERSAL::require;

use base qw( Class::Accessor::Fast );
__PACKAGE__->mk_accessors( qw(conf plugins_path cache) );


our $VERSION = '0.03';


use constant CACHE_CLASS => 'Hook::Modular::Cache';
use constant CACHE_PROXY_CLASS => 'Hook::Modular::CacheProxy';
use constant PLUGIN_NAMESPACE => 'Hook::Modular::Plugin';
use constant SHOULD_REWRITE_CONFIG => 0;


# Need an array, because rules live in Hook::Module::Rule::* as well as rule
# namespace of your subclassed program. We don't need such an array for
# PLUGIN_NAMESPACE because we don't have any plugins under
# 'Hook::Modular::Plugin::*'.

my @rule_namespaces = ('Hook::Modular::Rule');
sub add_to_rule_namespaces {
    my ($self, @ns) = @_;
    push @rule_namespaces => @ns;
}
sub rule_namespaces {
    wantarray ? @rule_namespaces : \@rule_namespaces;
}


my $context;
sub context     { $context }
sub set_context { $context = $_[1] }


sub new {
    my ($class, %opt) = @_;

    my $self = bless {
        conf          => {},
        plugins_path  => {},
        plugins       => [],
        rewrite_tasks => [],
    }, $class;

    my $loader = Hook::Modular::ConfigLoader->new;
    my $config = $loader->load($opt{config}, $self);

    $loader->load_include($config);
    $self->{conf} = $config->{global};
    $self->{conf}{log} ||= { level => 'debug' };
    $self->{conf}{plugin_namespace} ||= $self->PLUGIN_NAMESPACE;

    # don't use ||= here, as we are dealing with boolean values, so "0" is a
    # possible value.
    unless (defined $self->{conf}{should_rewrite_config}) {
        $self->{conf}{should_rewrite_config} = $self->SHOULD_REWRITE_CONFIG;
    }

    if (my $ns = $self->{conf}{rule_namespace}) {
        $ns = [ $ns ] unless ref $ns eq 'ARRAY';
        $self->add_to_rule_namespaces(@$ns);
    }

    if (eval { require Term::Encoding }) {
        $self->{conf}{log}->{encoding} ||= Term::Encoding::get_encoding();
    }

    Hook::Modular->set_context($self);

    $loader->load_recipes($config);
    $self->load_cache($opt{config});
    $self->load_plugins(@{ $config->{plugins} || [] });
    $self->rewrite_config if
        $self->{conf}{should_rewrite_config} && @{ $self->{rewrite_tasks} };

    # for subclasses
    $self->init;

    $self;
}


sub init {}


sub bootstrap {
    my $class = shift;
    my $self = $class->new(@_);
    $self->run;
    $self;
}


sub add_rewrite_task {
    my ($self, @stuff) = @_;
    push @{ $self->{rewrite_tasks} }, \@stuff;
}


sub rewrite_config {
    my $self = shift;

    unless ($self->{config_path}) {
        $self->log(warn =>
            "config is not loaded from file. Ignoring rewrite tasks."
        );
        return;
    }

    open my $fh, '<', $self->{config_path} or
        $self->error("$self->{config_path}: $!");
    my $data = join '', <$fh>;
    close $fh;

    my $old = $data;
    my $count;

    # xxx this is a quick hack: It should be a YAML roundtrip maybe
    for my $task (@{ $self->{rewrite_tasks} }) {
        my ($key, $old_value, $new_value ) = @$task;
        if ($data =~ s/^(\s+$key:\s+)\Q$old_value\E[ \t]*$/$1$new_value/m) {
            $count++;
        } else {
            $self->log(error =>
                "$key: $old_value not found in $self->{config_path}"
            );
        }
    }

    if ($count) {
        File::Copy::copy( $self->{config_path}, $self->{config_path} . '.bak' );
        open my $fh, '>', $self->{config_path} or
            return $self->log(error => "$self->{config_path}: $!");
        print $fh $data;
        close $fh;

        $self->log(info =>
            "Rewrote $count password(s) and saved to $self->{config_path}");
    }
}


sub load_cache {
    my($self, $config) = @_;

    # cache is auto-vivified but that's okay
    unless ($self->{conf}{cache}{base}) {
        # use config filename as a base directory for cache
        my $base = ( basename($config) =~ /^(.*?)\.yaml$/ )[0] || 'config';
        my $dir  = $base eq 'config' ? ".$0" : ".$0-$base";
        $self->{conf}{cache}{base} ||=
            File::Spec->catfile($self->home_dir, $dir);
    }

    my $cache_class = $self->CACHE_CLASS;
    $cache_class->require or die $@;
    $self->cache($cache_class->new($self->{conf}{cache}));
}


sub home_dir {
    eval { require File::HomeDir };
    return $@ ? $ENV{HOME} : File::HomeDir->my_home;
}


sub load_plugins {
    my ($self, @plugins) = @_;

    my $plugin_path = $self->conf->{plugin_path} || [];
       $plugin_path = [ $plugin_path ] unless ref $plugin_path;

    for my $path (@$plugin_path) {
        opendir my $dir, $path or do {
            $self->log(warn => "$path: $!");
            next;
        };
        while (my $ent = readdir $dir) {
            next if $ent =~ /^\./;
            $ent = File::Spec->catfile($path, $ent);
            if (-f $ent && $ent =~ /\.pm$/) {
                $self->add_plugin_path($ent);
            } elsif (-d $ent) {
                my $lib = File::Spec->catfile($ent, "lib");
                if (-e $lib && -d _) {
                    $self->log(debug => "Add $lib to INC path");
                    unshift @INC, $lib;
                } else {
                    my $rule = File::Find::Rule->new;
                    $rule->file;
                    $rule->name('*.pm');
                    my @modules = $rule->in($ent);
                    for my $module (@modules) {
                        $self->add_plugin_path($module);
                    }
                }
            }
        }
    }

    for my $plugin (@plugins) {
        $self->load_plugin($plugin) unless $plugin->{disable};
    }
}


sub add_plugin_path {
    my ($self, $file) = @_;

    my $pkg = $self->extract_package($file)
        or die "Can't find package from $file";
    $self->plugins_path->{$pkg} = $file;
    $self->log(debug => "$file is added as a path to plugin $pkg");
}


sub extract_package {
    my ($self, $file) = @_;

    my $ns = $self->{conf}{plugin_namespace} . '::';
    open my $fh, '<', $file or die "$file: $!";
    while (<$fh>) {
        /^package ($ns.*?);/ and return $1;
    }

    return;
}


sub autoload_plugin {
    my ($self, $plugin) = @_;
    unless ($self->is_loaded($plugin->{module})) {
        $self->load_plugin($plugin);
    }
}


sub is_loaded {
    my ($self, $stuff) = @_;

    my $sub = ref $stuff && ref $stuff eq 'Regexp'
        ? sub { $_[0] =~ $stuff }
        : sub { $_[0] eq $stuff };

    my $ns = $self->{conf}{plugin_namespace} . '::';
    for my $plugin (@{ $self->{plugins} }) {
        my $module = ref $plugin;
           $module =~ s/^$ns//;
        return 1 if $sub->($module);
    }

    return;
}


sub load_plugin {
    my ($self, $config) = @_;

    my $ns = $self->{conf}{plugin_namespace} . '::';
    my $module = delete $config->{module};
    if ($module !~ s/^\+//) {
        $module =~ s/^$ns//;
        $module = $ns . $module;
    }

    if ($module->isa($self->{conf}{plugin_namespace})) {
        $self->log(debug => "$module is loaded elsewhere ... maybe .t script?");
    } elsif (my $path = $self->plugins_path->{$module}) {
        eval { require $path } or die $@;
    } else {
        $module->require or die $@;
    }

    $self->log(info => "plugin $module loaded.");

    my $plugin = $module->new($config);
    my $cache_proxy_class = $self->CACHE_PROXY_CLASS;
    $cache_proxy_class->require or die $@;
    $plugin->cache(
        $cache_proxy_class->new($plugin, $self->cache)
    );
    $plugin->register($self);

    push @{$self->{plugins}}, $plugin;
}


sub register_hook {
    my ($self, $plugin, @hooks) = @_;
    while (my ($hook, $callback) = splice @hooks, 0, 2) {
        # set default rule_hook $hook to $plugin
        $plugin->rule_hook($hook) unless $plugin->rule_hook;

        push @{ $self->{hooks}{$hook} }, +{
            callback  => $callback,
            plugin    => $plugin,
        };
    }
}


sub run_hook {
    my ($self, $hook, $args, $once, $callback) = @_;

    my @ret;
    for my $action (@{ $self->{hooks}{$hook} }) {
        my $plugin = $action->{plugin};
        if ( $plugin->rule->dispatch($plugin, $hook, $args) ) {
            my $ret = $action->{callback}->($plugin, $self, $args);
            $callback->($ret) if $callback;
            if ($once) {
                return $ret if defined $ret;
            } else {
                push @ret, $ret;
            }
        } else {
            push @ret, undef;
        }
    }

    return if $once;
    return @ret;
}


sub run_hook_once {
    my ($self, $hook, $args, $callback) = @_;
    $self->run_hook($hook, $args, 1, $callback);
}


sub run_main {
    my $self = shift;

    $self->run_hook('plugin.init');
    $self->run;
    $self->run_hook('plugin.finalize');

    Hook::Modular->set_context(undef);
    $self;
}


sub run {}


sub log {
    my ($self, $level, $msg, %opt) = @_;

    return unless $self->should_log($level);

    # hack to get the original caller as Plugin or Rule
    my $caller = $opt{caller};
    unless ($caller) {
        my $i = 0;
        while (my $c = caller($i++)) {
            last if $c !~ /Plugin|Rule/;
            $caller = $c;
        }
        $caller ||= caller(0);
    }

    chomp($msg);
    if ($self->conf->{log}->{encoding}) {
        $msg = Encode::decode_utf8($msg) unless utf8::is_utf8($msg);
        $msg = Encode::encode($self->conf->{log}->{encoding}, $msg);
    }
    warn "$caller [$level] $msg\n";
}


my %levels = (
    debug => 0,
    warn  => 1,
    info  => 2,
    error => 3,
);


sub should_log {
    my ($self, $level) = @_;
    $levels{$level} >= $levels{$self->conf->{log}->{level}};
}


sub error {
    my ($self, $msg) = @_;
    my ($caller, $filename, $line) = caller(0);
    chomp($msg);
    die "$caller [fatal] $msg at line $line\n";
}


sub dumper {
    my ($self, $stuff) = @_;
    local $Data::Dumper::Indent = 1;
    $self->log(debug => Dumper $stuff);
}


1;

__END__

=head1 NAME

Hook::Modular - making pluggable applications easy

=head1 SYNOPSIS

  # some_config.yaml

  global:
    log:
      level: error
    cache:
      base: /tmp/test-hook-modular
    # plugin_namespace: My::Test::Plugin
  
  plugins:
    - module: Some::Printer
      config:
        indent: 4
        indent_char: '*'
        text: 'this is some printer'


  # here is the plugin:

  package My::Test::Plugin::Some::Printer;
  use warnings;
  use strict;
  use base 'Hook::Modular::Plugin';
  
  sub register {
      my ($self, $context) = @_;
      $context->register_hook($self, 'output.print' => $self->can('do_print'));
  }
  
  sub do_print { ... }


  # some_app.pl

  use base 'Hook::Modular';

  use constant PLUGIN_NAMESPACE => 'My::Test::Plugin';

  sub run {
    my $self = shift;
    $self->SUPER::run(@_);
    ...
    $self->run_hook('output.print', ...);
    ...
  }

  main->bootstrap(config => $config_filename);

=head1 DESCRIPTION

Hook::Modular makes writing pluggable applications easy. Use a config file to
specify which plugins you want and to pass options to those plugins. The
program to support those plugin then subclasses Hook::Modular and bootstraps
itself. This causes the plugins to be loaded and registered. This gives each
plugin the chance to register callbacks for any or all hooks the program
offers. The program then runs the hooks in the order it desires. Each time a
hook is run, all the callbacks the plugins have registered with this
particular hook are run in order.

Hook::Modular does more than just load and call plugins, however. It also
supports the following concepts:

=over 4

=item Cache

Plugins can cache their settings. Cached items can also expire after a given time.

=item Crypt

Hook::Lexwrap can go over your config file and encrypt any passwords it finds
(as determined by the key C<password>). It will then rewrite the config file
and make a backup of the original file. Encrypting and rewriting is turned off
by default, but subclasses can enable it, or you can enable it from a config
file itself.

At the moment, encrypting is rather basic: The passwords are only turned into
base64.

=item Rules

Hook::Modular supports rule-based dispatch of plugins.

=back

=head1 METHODS

=over 4

=item new(%opt)

Creates a new object and initializes it. The arguments are passed as a named
hash. Valid argument keys:

=over 4

=item config

Reads or sets the global configuration.

If the value is a simple string, it is interpreted as a filename. If the file
is readable, it is loaded as YAML. If the filename is C<->, the configuration
is read from STDIN.

If the value is a scalar reference, the dereferenced value is assumed to be
YAML and is loaded.

If the value is a hash reference, the configuration is cloned from that hash
reference.

=back

For example:

  Hook::Modular->new(config => 'some_config.yaml');


=item context(), set_context($context)

Gets and sets (respectively) the global context. It is singular; each program
has only one context. Thie can be used to communicate between the plugins.

=item conf([$conf])

TO BE WRITTEN

=item plugins_path([$path])

TO BE WRITTEN

=item cache([$cache])

TO BE WRITTEN

=item PLUGIN_NAMESPACE

A constant that specifies the namespace that is prepended to plugin names
found in the configuration. Defaults to C<Hook::Modular::Plugin>. Subclasses
can and probably should override this value. For example, if the plugin
namespace is set to C<My::Test::Plugin> and the config file specifies a plugin
with the name C<Some::Printer>, we will try to load
C<My:::Test::Plugin::Some::Printer>.

=back

=head1 TAGS

If you talk about this module in blogs, on del.icio.us or anywhere else,
please use the C<hookmodular> tag.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-hook-modular@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit <http://www.perl.com/CPAN/> to find a CPAN
site near you. Or see <http://www.perl.com/CPAN/authors/id/M/MA/MARCEL/>.

=head1 AUTHOR

Marcel GrE<uuml>nauer, C<< <marcel@cpan.org> >>

The code is almost completely lifted from L<Plagger>, so really Tatsuhiko
Miyagawa C<< <miyagawa@bulknews.net> >> deserves all the credit.

=head1 COPYRIGHT AND LICENSE

Copyright 2007 by Marcel GrE<uuml>nauer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

