package Hook::Modular::Rule::Expression;

use warnings;
use strict;
use base 'Hook::Modular::Rule';


our $VERSION = '0.06';


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
