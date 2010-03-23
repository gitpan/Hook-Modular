package My::Test::Rule::Maybe;
our $VERSION = '1.100820';
use warnings;
use strict;
use base 'Hook::Modular::Rule';

sub dispatch {
    my $self = shift;
    $self->{chance} || 0;
}
1;
