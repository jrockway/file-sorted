use strict;
use warnings;
use Test::More tests => 5;

use File::Sorted;

my $cpan_module = class with File::Sorted::Record {
    has 'raw' => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    has 'parsed' => (
        is         => 'ro',
        isa        => 'ArrayRef[Str]',
        lazy_build => 1,
    );

    has 'name' => (
        is         => 'ro',
        isa        => 'Str',
        lazy_build => 1,
    );

    method _build_parsed {
        [ split /\s+/, $self->raw ];
    }

    method _build_name {
        $self->parsed->[0];
    }

    method compare(Str $term) {
        return (lc $term cmp lc $self->name);
    }
};

my $mods = File::Sorted->new(
    file => 't/02packages.details.txt',
    record_builder => sub {
        my $record = shift;
        return $cpan_module->name->new( raw => $record );
    },
);

is $mods->search('Angerwhale')->name, 'Angerwhale';
is $mods->search('CPAN')->name, 'CPAN';
is $mods->search('CPANPLUS')->name, 'CPANPLUS';
is $mods->search('Moose')->name, 'Moose';

ok !defined $mods->search('OH::HAI::HopefullyThisIsNotAModule');
