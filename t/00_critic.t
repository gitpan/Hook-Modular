use warnings;
use strict;
use FindBin '$Bin';
use File::Spec;
use UNIVERSAL::require;
use Test::More;

plan skip_all => 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.'
    unless $ENV{TEST_AUTHOR};

my $rc_file = File::Spec->catfile($Bin, 'perlcriticrc');

if (Perl::Critic->require('1.078') &&
    Test::Perl::Critic->require &&
    Test::Perl::Critic->import(-profile => $rc_file)) {

    all_critic_ok("lib");
} else {
    plan skip_all => $@;
}
