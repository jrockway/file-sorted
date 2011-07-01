package File::Sorted::02Packages;
# ABSTRACT: read the CPAN index efficiently
use Moose;
use namespace::autoclean;

use MooseX::Types::Path::Class qw(File);
use File::Sorted::02Packages::Record;

extends 'File::Sorted';

has '+record_builder' => (
    default => sub {
        sub { File::Sorted::02Packages::Record->new( raw => $_[0] ) }
    },
);

__PACKAGE__->meta->make_immutable;
1;
