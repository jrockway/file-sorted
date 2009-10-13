use inc::Module::Install;

requires 'Binary::Search';
requires 'Moose';
requires 'MooseX::Declare';
requires 'MooseX::Types';
requires 'MooseX::Types::Path::Class';
requires 'IO::Handle';
requires 'Path::Class';

build_requires 'Test::More';
build_requires 'Directory::Scratch';

WriteAll;
