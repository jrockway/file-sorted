use strict;
use warnings;
use Test::More tests => 5;

use File::Sorted::02Packages;

my $mods = File::Sorted::02Packages->new(
    file => 't/02packages.details.txt',
);

is $mods->search('Angerwhale')->name, 'Angerwhale';
is $mods->search('CPAN')->name, 'CPAN';
is $mods->search('CPANPLUS')->name, 'CPANPLUS';
is $mods->search('Moose')->name, 'Moose';

ok !defined $mods->search('OH::HAI::HopefullyThisIsNotAModule');
