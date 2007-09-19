package Hook::Modular::Rule::Expression;
use strict;
use base 'Hook::Modular::Rule';


sub dispatch {
    my($self, $args) = @_;
    my $status = eval $self->{expression};
    if ($@) {
        Hook::Modular->context->log(error =>
            "Expression error: $@ with '$self->{expression}'"
        );
    }
    $status;
}


1;
