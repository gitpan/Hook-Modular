use inc::Module::Install;
name 'Hook-Modular';
all_from 'lib/Hook/Modular.pm';
perl_version '5.008';   # for Encode.pm

requires 'Cache::FileCache';
requires 'Class::Accessor::Fast';
requires 'File::Find::Rule';
requires 'File::HomeDir';
requires 'Module::Pluggable::Fast';
requires 'MIME::Base64';
requires 'List::Util';
requires 'Scalar::Util';

build_requires('Test::More');

auto_include;
WriteAll;
