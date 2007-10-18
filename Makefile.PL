use inc::Module::Install;
name 'Hook-Modular';
all_from 'lib/Hook/Modular.pm';
perl_version '5.006';

requires 'Cache::FileCache';
requires 'Class::Accessor::Fast';
requires 'Encode';
requires 'File::Find::Rule';
requires 'File::HomeDir';
requires 'Module::Pluggable::Fast';
requires 'MIME::Base64';
requires 'List::Util';
requires 'Scalar::Util';
requires 'UNIVERSAL::require';
requires 'YAML';

build_requires 'Test::More' => '0.70';

use_standard_tests(without => 'pod_coverage');
auto_include;
WriteAll;
