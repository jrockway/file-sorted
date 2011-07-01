package File::Sorted::02Packages::Record;
# ABSTRACT: object representing a record in 02packages.details.txt
use Moose;
use namespace::autoclean;
use version;

with 'File::Sorted::Record';

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

has 'version' => (
    is         => 'ro',
    isa        => 'Str',
    lazy_build => 1,
);

has 'dist' => (
    is         => 'ro',
    isa        => 'Str',
    lazy_build => 1,
);

sub _build_parsed {
    my $self = shift;
    [ split /\s+/, $self->raw ];
}

sub _build_name {
    my $self = shift;
    $self->parsed->[0];
}

sub _build_version {
    my $self = shift;
    $self->parsed->[1];
}

sub parsed_version {
    my $self = shift;
    return version->parse($self->version);
}

sub _build_dist {
    my $self = shift;
    $self->parsed->[2];
}

sub compare {
    my ($self, $term) = @_;
    return (lc $term cmp lc $self->name);
}

__PACKAGE__->meta->make_immutable;
1;
