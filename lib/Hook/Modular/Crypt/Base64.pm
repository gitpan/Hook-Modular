package Hook::Modular::Crypt::Base64;

use warnings;
use strict;
use MIME::Base64 ();


our $VERSION = '0.03';


use constant id => 'base64';


sub decrypt {
    my ($self, $text) = @_;
    MIME::Base64::decode($text);
}


sub encrypt {
    my ($self, $text) = @_;
    MIME::Base64::encode($text, '');
}

1;

