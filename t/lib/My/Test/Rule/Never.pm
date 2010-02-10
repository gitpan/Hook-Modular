package My::Test::Rule::Never;
use warnings;
use strict;
use base 'Hook::Modular::Rule';
sub dispatch { 0 }
1;
