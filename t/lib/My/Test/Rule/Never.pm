package My::Test::Rule::Never;
our $VERSION = '1.100820';
use warnings;
use strict;
use base 'Hook::Modular::Rule';
sub dispatch { 0 }
1;
