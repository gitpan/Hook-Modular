package Hook::Modular::Rule;

use warnings;
use strict;
use UNIVERSAL::require;


our $VERSION = '0.06';


sub new {
    my ($class, $config) = @_;

    if (my $exp = $config->{expression}) {
        $config->{module} = 'Expression';
    }

    my $module_suffix = delete $config->{module};

    my $module;
    my $found = 0;
    my @tried;
    for my $ns (Hook::Modular->rule_namespaces) {
        $module = $ns . '::' . $module_suffix;
        push @tried => $module;
        if ($module->require) {
            $found++;
            last;
        }
    }
    $found or die sprintf "can't find any of %s", join(', ' => @tried);

    my $self = bless {%$config}, $module;
    $self->init;
    $self;
}


sub init {}


use constant id       => 'xxx';
use constant as_title => 'xxx';


1;
