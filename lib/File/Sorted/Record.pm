package File::Sorted::Record;
# ABSTRACT: role for records
use Moose::Role;
requires 'compare'; # (Str $search_term)

1;
