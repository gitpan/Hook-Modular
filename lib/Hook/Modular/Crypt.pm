package Hook::Modular::Crypt;

use warnings;
use strict;


our $VERSION = '0.06';


use Module::Pluggable::Fast
    search => [ qw/Hook::Modular::Crypt/ ],
    require => 1;


my %handlers = map { $_->id => $_ } __PACKAGE__->plugins;
my $re = "^(" . join("|", map $_->id, __PACKAGE__->plugins) . ")::";


sub decrypt {
    my ($class, $ciphertext, @args) = @_;

    if ($ciphertext =~ s!$re!!) {
        my $handler = $handlers{$1};
        my @param = split /::/, $ciphertext;
        return $handler->decrypt(@param, @args);
    }

    return $ciphertext; # just plain text
}


sub encrypt {
    my ($class, $plaintext, $driver, @param) = @_;
    my $handler = $handlers{$driver}
        or Hook::Modular::Crypt->context->error(
            "No crypt handler for $driver");
    join '::', $driver, $handler->encrypt($plaintext, @param);
}


1;
