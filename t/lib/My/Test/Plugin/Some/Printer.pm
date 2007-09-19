package My::Test::Plugin::Some::Printer;

use warnings;
use strict;

use base 'Hook::Modular::Plugin';


sub register {
    my ($self, $context) = @_;

    $context->register_hook(
        $self,
        'output.print' => $self->can('do_print'),
    );
}


sub indent {
    my $self = shift;
    $self->conf->{indent} || 0
}


sub indent_char {
    my $self = shift;
    $self->conf->{indent_char} || ''
}


sub text {
    my $self = shift;
    $self->conf->{text} || ''
}


sub do_print {
    my ($self, $context, $args) = @_;
    $args->{result}{text} = sprintf "%s%s\n",
        ($self->indent_char x $self->indent), $self->text;
}


1;
