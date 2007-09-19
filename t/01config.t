#!/usr/bin/perl
use strict;
use warnings;
use FindBin '$Bin';
use File::Spec;
use lib File::Spec->catdir($Bin, 'lib');
use Test::More tests => 1;

use base 'Hook::Modular';


# specifying the appropriate plugin namespace for this program saves you from
# having to specify it in every config file.

use constant PLUGIN_NAMESPACE => 'My::Test::Plugin';


sub run {
    my $self = shift;
    $self->SUPER::run(@_);
    my %result;
    $self->run_hook('output.print', { result => \%result });
    is($result{text}, "****this is some printer\n",
        'Some::Printer output.print');
}

my $config = File::Spec->catfile($Bin, '01config.yaml');
main->bootstrap(config => $config);

