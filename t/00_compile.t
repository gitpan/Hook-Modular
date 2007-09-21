use warnings;
use strict;
use Test::More tests => 15;

BEGIN {
    use_ok 'Hook::Modular';
    use_ok 'Hook::Modular::ConfigLoader';
    use_ok 'Hook::Modular::Cache';
    use_ok 'Hook::Modular::CacheProxy';
    use_ok 'Hook::Modular::Cache::Null';
    use_ok 'Hook::Modular::Crypt::Base64';
    use_ok 'Hook::Modular::Crypt';
    use_ok 'Hook::Modular::Operator';
    use_ok 'Hook::Modular::Plugin';
    use_ok 'Hook::Modular::Rule::Always';
    use_ok 'Hook::Modular::Rule::Expression';
    use_ok 'Hook::Modular::Rule';
    use_ok 'Hook::Modular::Rules';
    use_ok 'Hook::Modular::Test';
    use_ok 'Hook::Modular::Walker';
}
