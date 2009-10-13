use strict;
use warnings;
use Test::More tests => 55;

use Path::Class qw(file);
use File::Sorted::Handle;
use Directory::Scratch;

my $tmp = Directory::Scratch->new;
$tmp->touch('foo', "Line 1-Line 2-Line 3");

my $h = File::Sorted::Handle->new(
    fh => $tmp->exists('foo')->openr,
);

ok $h;

#for my $cs (1..30){
#$h->seek(0);
#$h->chunk_size($cs);
#diag "chunk size: $cs";
my $rx = qr/-/;
is $h->read_forward_until($rx), 'Line 1', 'got line 1 first';
is $h->read_forward_until($rx), 'Line 2', 'then line 2';
is $h->read_forward_until($rx), "Line 3\n", 'then line 3';
ok !defined $h->read_forward_until($rx), 'not defined at end';
is $h->tell, $h->eof_pos, 'at eof';

is $h->read_backward_until($rx), "Line 3\n", 'reading backwards; line 3';
is $h->read_backward_until($rx), 'Line 2', 'line 2 again';
is $h->read_backward_until($rx), 'Line 1', 'line 1';
ok !defined $h->read_backward_until($rx), 'seek pointer points to nothing at beginning';

for(0..6){
    $h->seek($_);
    is $h->read_forward_until($rx),
      substr('Line 1', $_, 6),
        qq{got part of "Line 1" from $_ to end};
}

for(reverse 1..6){
    $h->seek($_);
    is $h->read_backward_until($rx),
      substr('Line 1', 0, $_),
        qq{backwards: got part of "Line 1" from $_ to end};
}

$h->seek(0);
ok !defined $h->read_backward_until($rx), 'not defined at beginning';


for(7..13){
    $h->seek($_);
    is $h->read_forward_until($rx),
      substr('Line 2', $_-7, 6),
        qq{got part of "Line 2" from $_ to end};
}

for(reverse 8..13){
    $h->seek($_);
    is $h->read_backward_until($rx),
      substr('Line 2', 0, $_-7),
        qq{backwards: got part of "Line 2" from $_ to end};
}

$h->seek(7);
ok !defined $h->read_backward_until($rx), 'backward not defined on separator';
$h->seek(7);
ok defined $h->read_forward_until($rx), 'forward defined on separator';

for(14..20){
    $h->seek($_);
    is $h->read_forward_until($rx),
      substr("Line 3\n", $_-14, 7),
        qq{got part of "Line 3" from $_ to end};
}

for(reverse 15..21){
    $h->seek($_);
    is $h->read_backward_until($rx),
      substr("Line 3\n", 0, $_-14),
        qq{backwards: got part of "Line 3" from $_ to end};
}

$h->seek($h->eof_pos);
ok !defined $h->read_forward_until($rx), 'nothing to read forward at end of file';
$h->seek($h->eof_pos);
is $h->read_backward_until($rx), "Line 3\n", 'last line is obviously available though';
#}
