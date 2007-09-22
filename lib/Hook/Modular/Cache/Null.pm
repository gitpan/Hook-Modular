package Hook::Modular::Cache::Null;

use warnings;
use strict;


our $VERSION = '0.04';


sub new {
    bless {}, shift;
}


sub get {
    my ($self, $key) = @_;
    $self->{$key};
}


sub set {
    my ($self, $key, $value, $expiry) = @_;
    $self->{$key} = $value;
}


sub remove {
    my ($self, $key) = @_;
    delete $self->{$key};
}


1;
