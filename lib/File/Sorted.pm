package File::Sorted;
# ABSTRACT: efficiently find a line-based record in a sorted file
use Moose;

use File::Sorted::Record;
use File::Sorted::Handle;
use Search::Binary;

use MooseX::Types::Path::Class qw(File);
use MooseX::Types::Moose qw(CodeRef RegexpRef Str);

has 'file' => (
    is       => 'ro',
    isa      => File,
    required => 1,
    coerce   => 1,
);

has 'record_separator' => (
    is       => 'ro',
    isa      => RegexpRef,
    required => 1,
    default  => sub { qr/\n/ },
);

has 'record_builder' => (
    is       => 'ro',
    isa      => CodeRef,
    required => 1,
);

sub search {
    my ($self, $term) = @_;

    my $fh = File::Sorted::Handle->new(
        fh => $self->file->openr,
    );

    my $_build_record = sub {
        my $pos = shift;

        # if !defined, we are reading the next record
        $fh->seek($pos) if(defined $pos);

        my $record_txt = $fh->read_record($self->record_separator);
        return $self->record_builder->($record_txt);
    };

    my $found_pos = binary_search(
        0, $fh->eof_pos, $term, sub {
            my ($search_handle, $term, $pos) = @_;

            my $record = $_build_record->($pos);
            return ($record->compare($term), $fh->tell-1);
        },
    );

    my $result = $_build_record->($found_pos);
    return $result if $result->compare($term) == 0;
    return;                     # not found
}

1;
