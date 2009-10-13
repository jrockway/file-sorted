use MooseX::Declare;

class File::Sorted::Handle {
    use IO::File;
    use MooseX::Types -declare => [qw/SeekableHandle ChunkSize/];
    use MooseX::Types::Moose qw(Int);
    use Fcntl qw(SEEK_SET SEEK_CUR SEEK_END);

    my @methods = qw/sysread sysseek/;

    duck_type SeekableHandle, @methods; # not "duct_tape"

    subtype ChunkSize, as Int, where { $_ > 0 };

    has 'fh' => (
        is       => 'ro',
        isa      => SeekableHandle,
        required => 1,
        handles  => \@methods,
    );

    has 'chunk_size' => (
        is       => 'rw',
        isa      => ChunkSize,
        required => 1,
        default  => 256,
    );

    method tell {
        return $self->fh->sysseek(0, SEEK_CUR) or die "SEEK_CUR error: $!";
    }

    method eof_pos {
        my $cur = $self->tell;
        my $end = $self->fh->sysseek(0, SEEK_END) or die "SEEK_END error: $!";
        $self->fh->sysseek($cur, SEEK_SET) or die "SEEK_SET error: $!";
        return $end;
    }

    method eof {
        return (0+$self->tell) == (0+$self->eof_pos);
    }

    method seek(Int $pos) {
        return $self->fh->sysseek($pos, SEEK_SET) or die "SEEK_SET error: $!";
    }

    method rewind {
        $self->seek(0);
    }

    method read_forward_until(RegexpRef $separator){
        my $chunk_size = $self->chunk_size;
        my $start = $self->tell;

        my $buf = "";
        while(!$self->eof && $buf !~ /$separator/){
            my $tmp;
            my $count = $self->sysread( $tmp, $chunk_size );
            $buf .= $tmp;
        }

        my @records = split /($separator)/, $buf;

        no warnings 'uninitialized';
        my ($data, $sep, @rest) = @records;
        $self->seek($start + length("$data$sep"));

        # XXX: it is possible that we have not consumed the entire
        # separator yet, but there is no way to know this without
        # reading the entire file.  the record separator could easily
        # be:
        # qr/---(?:the entire rest of the file!)?/

        return $data;
    }

    method read_backward_until(RegexpRef $separator){
        my $chunk_size = $self->chunk_size;
        my $start = $self->tell;

        my $buf = "";
        while($self->tell != 0 && $buf !~ /$separator/){
            my $tmp;

            my $pos = $self->tell;
            my $read;
            if($pos < $chunk_size){
                $self->seek(0);
                $read = $self->sysread( $tmp, $pos );
            }
            else {
                $self->seek( $self->tell - $chunk_size );
                $read = $self->sysread( $tmp, $chunk_size );
            }
            $buf = "$tmp$buf";
            $self->seek( $self->tell - $read ); # "unget"
        }

        no warnings 'uninitialized';
        my @result = split /($separator)/, $buf;
        push @result, undef if @result % 2 == 0;
        my ($data, $sep, @rest) = reverse @result;

        $self->seek($start - length("$sep$data"));
        return $data;
    }
}
