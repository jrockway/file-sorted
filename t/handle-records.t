use strict;
use warnings;
use Test::More tests => 26;

use Path::Class qw(file);
use File::Sorted::Handle;
use Directory::Scratch;

my $tmp = Directory::Scratch->new;
$tmp->touch('foo', "Line 1-Line 2-Line 3");

my $h = File::Sorted::Handle->new(
    fh => $tmp->exists('foo')->openr,
);

ok $h;
my $rx = qr/-/;

is $h->read_record($rx), 'Line 1', 'line 1';
is $h->read_record($rx), 'Line 2', 'line 2';
is $h->read_record($rx), "Line 3\n", 'line 3';

for(0..6){
    $h->seek($_);
    is $h->read_record($rx), 'Line 1', "still line 1 when starting at $_";
}
for(7..13){
    $h->seek($_);
    is $h->read_record($rx), 'Line 2', "still line 2 when starting at $_";
}
for(14..21){
    $h->seek($_);
    is $h->read_record($rx), "Line 3\n", "still line 3 when starting at $_";
}
