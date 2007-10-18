package Hook::Modular::CacheProxy;

use warnings;
use strict;


our $VERSION = '0.06';


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
