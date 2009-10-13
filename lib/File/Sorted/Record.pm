use MooseX::Declare;

role File::Sorted::Record {
    requires 'compare'; # (Str $search_term)
}
