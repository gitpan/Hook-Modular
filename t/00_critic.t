use warnings;
use strict;
use FindBin '$Bin';
use UNIVERSAL::require;
use Test::More;

if (Perl::Critic->require('1.078') &&
    Test::Perl::Critic->require &&
    Test::Perl::Critic->import(-profile => "$Bin/perlcriticrc")) {

    all_critic_ok("lib");
} else {
    plan skip_all => $@;
}
