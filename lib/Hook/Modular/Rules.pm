package Hook::Modular::Rules;

use warnings;
use strict;
use Hook::Modular::Operator;


our $VERSION = '0.03';


sub new {
    my ($class, $op, @rules) = @_;
    Hook::Modular::Operator->is_valid_op(uc($op))
        or Hook::Modular->context->error("operator $op not supported");

    bless {
        op => uc($op),
        rules => [ map Hook::Modular::Rule->new($_), @rules ],
    }, $class;
}


sub dispatch {
    my ($self, $plugin, $hook, $args) = @_;

    return 1 unless $plugin->dispatch_rule_on($hook);

    my @bool;
    for my $rule (@{ $self->{rules} }) {
        push @bool, ($rule->dispatch($args) ? 1 : 0);
    }

    # can't find rules for this phase: execute it
    return 1 unless @bool;

    Hook::Modular::Operator->call($self->{op}, @bool);
}


sub id {
    my $self = shift;
    join '|', map $_->id, @{$self->{rules}};
}


sub as_title {
    my $self = shift;
    join " $self->{op} ", map $_->as_title, @{$self->{rules}};
}


1;
